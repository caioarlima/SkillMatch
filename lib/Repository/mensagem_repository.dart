import 'package:cloud_firestore/cloud_firestore.dart';
import '../Model/Mensagem.dart';
import '../Model/Chat.dart';

class MensagemRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Chat>> buscarChatsUsuario(String userId) async {
    final query = await _firestore
        .collection('chats')
        .where('participantes', arrayContains: userId)
        .orderBy('timestamp', descending: true)
        .get();

    return query.docs.map((doc) => Chat.fromMap(doc.id, doc.data())).toList();
  }

  Future<List<Mensagem>> buscarMensagensChat(String chatId) async {
    final query = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('mensagens')
        .orderBy('timestamp', descending: false)
        .get();

    return query.docs.map((doc) => Mensagem.fromMap(doc.id, doc.data())).toList();
  }

  Future<void> enviarMensagem(String chatId, String texto, String senderId) async {
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
  }

  Future<String> criarChat(String user1Id, String user2Id, String user1Nome, String user2Nome) async {
    final chatId = _gerarChatId(user1Id, user2Id);
    
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
    return chatId;
  }

  String _gerarChatId(String user1Id, String user2Id) {
    final ids = [user1Id, user2Id]..sort();
    return '${ids[0]}_${ids[1]}';
  }
}