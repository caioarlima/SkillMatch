import 'package:cloud_firestore/cloud_firestore.dart';
import '../Model/Mensagem.dart';
import '../Model/Chat.dart';

class MensagemRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Chat>> buscarChatsUsuario(String userId) async {
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
    try {
      final query = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('mensagens')
          .orderBy('timestamp', descending: false)
          .get();

      return query.docs.map((doc) => Mensagem.fromMap(doc.id, doc.data())).toList();
    } catch (e) {
      print('Erro ao buscar mensagens: $e');
      return [];
    }
  }

  Future<void> enviarMensagem(String chatId, String texto, String senderId) async {
    try {
      // Primeiro verifica se o chat existe
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

  Future<void> criarChat(String user1Id, String user2Id, String user1Nome, String user2Nome) async {
    try {
      final chatId = _gerarChatId(user1Id, user2Id);
      
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      
      if (!chatDoc.exists) {
        final chat = {
          'participantes': [user1Id, user2Id],
          'ultimaMensagem': '',
          'timestamp': FieldValue.serverTimestamp(),
          'usuariosInfo': {
            user1Id: user1Nome,
            user2Id: user2Nome,
          },
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

  String _gerarChatId(String user1Id, String user2Id) {
    final ids = [user1Id, user2Id]..sort();
    return 'chat_${ids[0]}_${ids[1]}';
  }

  Future<void> verificarECriarChat(String chatId, String user1Id, String user2Id, String user1Nome, String user2Nome) async {
    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      
      if (!chatDoc.exists) {
        final chat = {
          'participantes': [user1Id, user2Id],
          'ultimaMensagem': '',
          'timestamp': FieldValue.serverTimestamp(),
          'usuariosInfo': {
            user1Id: user1Nome,
            user2Id: user2Nome,
          },
        };
        await _firestore.collection('chats').doc(chatId).set(chat);
        print('Chat criado via verificação: $chatId');
      }
    } catch (e) {
      print('Erro ao verificar/criar chat: $e');
      throw e;
    }
  }
}