import 'package:flutter/material.dart';
import '../Model/Mensagem.dart';
import '../Model/Chat.dart';
import '../Repository/mensagem_repository.dart';

class MensagemController with ChangeNotifier {
  final MensagemRepository _repository = MensagemRepository();
  List<Chat> _chats = [];
  List<Mensagem> _mensagens = [];
  bool _carregando = false;

  List<Chat> get chats => _chats;
  List<Mensagem> get mensagens => _mensagens;
  bool get carregando => _carregando;

  Future<void> carregarChats(String userId) async {
    _carregando = true;
    notifyListeners();
    
    try {
      _chats = await _repository.buscarChatsUsuario(userId);
      print('Chats carregados: ${_chats.length}');
    } catch (e) {
      print('Erro ao carregar chats: $e');
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> carregarMensagens(String chatId) async {
    _carregando = true;
    notifyListeners();
    
    try {
      _mensagens = await _repository.buscarMensagensChat(chatId);
    } catch (e) {
      print('Erro ao carregar mensagens: $e');
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> enviarMensagem(String chatId, String texto, String senderId, String user1Nome, String user2Nome) async {
    try {
      final outroUsuario = _extrairOutroUsuario(chatId, senderId);
      await _repository.verificarECriarChat(chatId, senderId, outroUsuario, user1Nome, user2Nome);
      
      await _repository.enviarMensagem(chatId, texto, senderId);
      await carregarMensagens(chatId);
    } catch (e) {
      print('Erro ao enviar mensagem: $e');
      rethrow;
    }
  }

  Future<void> criarChat(String user1Id, String user2Id, String user1Nome, String user2Nome) async {
    await _repository.criarChat(user1Id, user2Id, user1Nome, user2Nome);
  }

  Future<void> verificarECriarChat(String chatId, String user1Id, String user2Id, String user1Nome, String user2Nome) async {
    await _repository.verificarECriarChat(chatId, user1Id, user2Id, user1Nome, user2Nome);
  }

  String _extrairOutroUsuario(String chatId, String senderId) {
    final parts = chatId.split('_');
    if (parts.length >= 3) {
      final id1 = parts[1];
      final id2 = parts[2];
      return id1 == senderId ? id2 : id1;
    }
    return '';
  }
}