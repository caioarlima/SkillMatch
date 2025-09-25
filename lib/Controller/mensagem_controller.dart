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

  Future<void> enviarMensagem(String chatId, String texto, String senderId) async {
    try {
      await _repository.enviarMensagem(chatId, texto, senderId);
      // Recarregar mensagens após enviar
      await carregarMensagens(chatId);
    } catch (e) {
      print('Erro ao enviar mensagem: $e');
    }
  }

  Future<String> criarChat(String user1Id, String user2Id, String user1Nome, String user2Nome) async {
    return await _repository.criarChat(user1Id, user2Id, user1Nome, user2Nome);
  }
}