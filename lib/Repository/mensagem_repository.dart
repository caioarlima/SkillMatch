import 'package:cloud_firestore/cloud_firestore.dart';
import '../Model/Mensagem.dart';
import '../Model/Chat.dart';
import 'usuario_repository.dart'; // Mantido, pois é usado para enriquecer mensagens

class MensagemRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UsuarioRepository _usuarioRepository; // Mantido, necessário para buscarMensagensChat

  MensagemRepository(this._usuarioRepository); // Mantido

  Future<List<Chat>> buscarChatsUsuario(String userId) async {
    // ... (código existente, permanece o mesmo) ...
    try {
      final query = await _firestore
          .collection('chats')
          .where('participantes', arrayContains: userId)
          .orderBy('timestamp', descending: true)
          .get();

      print('Chats encontrados para $userId: ${query.docs.length}');

      return query.docs.map((doc) => Chat.fromMap(doc.id, doc.data())).toList();
    } catch (e) {
      print('Erro ao buscar chats: $e');
      return [];
    }
  }

  Future<List<Mensagem>> buscarMensagensChat(String chatId) async {
    // ... (código corrigido na interação anterior, permanece o mesmo) ...
    try {
      final query = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('mensagens')
          .orderBy('timestamp', descending: false)
          .get();

      return await Future.wait(query.docs.map((doc) async {
        final mensagem = Mensagem.fromMap(doc.id, doc.data());

        // Lógica de enriquecimento que corrigimos antes
        final remetente = await _usuarioRepository.buscarUsuarioPorId(mensagem.senderId);

        return mensagem.copyWith(remetente: remetente);
      }).toList());
    } catch (e) {
      print('Erro ao buscar mensagens: $e');
      return [];
    }
  }

  Future<void> enviarMensagem(
    String chatId,
    String texto,
    String senderId,
  ) async {
    // ... (código existente, permanece o mesmo) ...
    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();

      if (!chatDoc.exists) {
        throw Exception('Chat não existe: $chatId');
      }

      final mensagemRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('mensagens')
          .doc();

      final mensagem = {
        'texto': texto,
        'senderId': senderId,
        'timestamp': FieldValue.serverTimestamp(),
        'lida': false,
        'visualizadaPor': [],
      };

      await mensagemRef.set(mensagem);

      await _firestore.collection('chats').doc(chatId).update({
        'ultimaMensagem': texto,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Mensagem enviada com sucesso para $chatId');
    } catch (e) {
      print('Erro ao enviar mensagem: $e');
      throw e;
    }
  }

  Future<void> criarChat(
    String user1Id,
    String user2Id,
    String user1Nome,
    String user2Nome,
    String user1Foto,
    String user2Foto,
  ) async {
    try {
      final chatId = gerarChatId(user1Id, user2Id);

      final chatDoc = await _firestore.collection('chats').doc(chatId).get();

      if (!chatDoc.exists) {
        // ⭐️ CORREÇÃO AQUI: Garante que o valor da foto não é nulo/vazio ao salvar
        final String foto1 = user1Foto.isEmpty ? 'NO_FOTO_URL' : user1Foto;
        final String foto2 = user2Foto.isEmpty ? 'NO_FOTO_URL' : user2Foto;

        final chat = {
          'participantes': [user1Id, user2Id],
          'ultimaMensagem': '',
          'timestamp': FieldValue.serverTimestamp(),
          'usuariosInfo': {user1Id: user1Nome, user2Id: user2Nome},
          'usuariosFotos': {user1Id: foto1, user2Id: foto2}, // Usa os valores garantidos
        };

        await _firestore.collection('chats').doc(chatId).set(chat);
        print('Chat criado: $chatId');
      } else {
        print('Chat já existe: $chatId');
      }
    } catch (e) {
      print('Erro ao criar chat: $e');
      throw e;
    }
  }

  String gerarChatId(String user1Id, String user2Id) {
    final ids = [user1Id, user2Id]..sort();
    return 'chat_${ids[0]}_${ids[1]}';
  }

  Future<void> verificarECriarChat(
    String chatId,
    String user1Id,
    String user2Id,
    String user1Nome,
    String user2Nome,
    String user1Foto,
    String user2Foto,
  ) async {
    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();

      // ⭐️ CORREÇÃO AQUI: Garante que o valor da foto não é nulo/vazio ao salvar
      final String foto1 = user1Foto.isEmpty ? 'NO_FOTO_URL' : user1Foto;
      final String foto2 = user2Foto.isEmpty ? 'NO_FOTO_URL' : user2Foto;

      if (!chatDoc.exists) {
        final chat = {
          'participantes': [user1Id, user2Id],
          'ultimaMensagem': '',
          'timestamp': FieldValue.serverTimestamp(),
          'usuariosInfo': {user1Id: user1Nome, user2Id: user2Nome},
          'usuariosFotos': {user1Id: foto1, user2Id: foto2}, // Usa os valores garantidos
        };
        await _firestore.collection('chats').doc(chatId).set(chat);
        print('Chat criado via verificação: $chatId');
      } else {
        // ⭐️ CORREÇÃO AQUI: Atualiza as fotos (sempre bom garantir a foto mais recente)
        await _firestore.collection('chats').doc(chatId).update({
          'usuariosFotos': {user1Id: foto1, user2Id: foto2},
        });
        print('Fotos atualizadas no chat: $chatId');
      }
    } catch (e) {
      print('Erro ao verificar/criar chat: $e');
      throw e;
    }
  }

  Future<void> marcarMensagensComoLidas(
    String chatId,
    String userId,
    List<String> mensagemIds,
  ) async {
    // ... (código existente, permanece o mesmo) ...
    try {
      final batch = _firestore.batch();

      for (final mensagemId in mensagemIds) {
        final mensagemRef = _firestore
            .collection('chats')
            .doc(chatId)
            .collection('mensagens')
            .doc(mensagemId);

        batch.update(mensagemRef, {
          'visualizadaPor': FieldValue.arrayUnion([userId]),
          'lida': true,
        });
      }

      await batch.commit();
      print('Mensagens marcadas como lidas por $userId');
    } catch (e) {
      print('Erro ao marcar mensagens como lidas: $e');
      throw e;
    }
  }

  Future<int> contarMensagensNaoLidas(String chatId, String userId) async {
    // ... (código existente, permanece o mesmo) ...
    try {
      final query = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('mensagens')
          .where('senderId', isNotEqualTo: userId)
          .get();

      int count = 0;
      for (final doc in query.docs) {
        final visualizadaPor = List<String>.from(
          doc.data()['visualizadaPor'] ?? [],
        );
        if (!visualizadaPor.contains(userId)) {
          count++;
        }
      }

      return count;
    } catch (e) {
      print('Erro ao contar mensagens não lidas: $e');
      return 0;
    }
  }
}