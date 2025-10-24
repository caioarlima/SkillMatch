import 'package:flutter/material.dart';
import '../Model/Mensagem.dart';
import '../Model/Chat.dart';
import '../Repository/mensagem_repository.dart';
import '../Repository/usuario_repository.dart'; 

class MensagemController with ChangeNotifier {

  final UsuarioRepository _usuarioRepository = UsuarioRepository();

  // 2. Declara o MensagemRepository
  final MensagemRepository _repository;

  MensagemController() : _repository = MensagemRepository(UsuarioRepository());

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

  Future<void> enviarMensagem(
    String chatId,
    String texto,
    String senderId,
    String user1Nome,
    String user2Nome,
    String user1Foto,
    String user2Foto,
  ) async {
    try {
      final outroUsuario = _extrairOutroUsuario(chatId, senderId);
      await _repository.verificarECriarChat(
        chatId,
        senderId,
        outroUsuario,
        user1Nome,
        user2Nome,
        user1Foto,
        user2Foto,
      );

      await _repository.enviarMensagem(chatId, texto, senderId);
      await carregarMensagens(chatId);
    } catch (e) {
      print('Erro ao enviar mensagem: $e');
      rethrow;
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
    await _repository.criarChat(
      user1Id,
      user2Id,
      user1Nome,
      user2Nome,
      user1Foto,
      user2Foto,
    );
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
    await _repository.verificarECriarChat(
      chatId,
      user1Id,
      user2Id,
      user1Nome,
      user2Nome,
      user1Foto,
      user2Foto,
    );
  }

  Future<void> marcarMensagensComoLidas(String chatId, String userId) async {
    try {
      final mensagensNaoLidas = _mensagens
          .where(
            (mensagem) =>
                mensagem.senderId != userId &&
                !mensagem.visualizadaPor.contains(userId),
          )
          .toList();

      if (mensagensNaoLidas.isNotEmpty) {
        final mensagemIds = mensagensNaoLidas.map((m) => m.mensagemId).toList();
        await _repository.marcarMensagensComoLidas(chatId, userId, mensagemIds);

        for (final mensagem in mensagensNaoLidas) {
          final index = _mensagens.indexWhere(
            (m) => m.mensagemId == mensagem.mensagemId,
          );
          if (index != -1) {
            _mensagens[index] = mensagem.copyWith(
              visualizadaPor: [...mensagem.visualizadaPor, userId],
              lida: true,
            );
          }
        }
        notifyListeners();
      }
    } catch (e) {
      print('Erro ao marcar mensagens como lidas: $e');
    }
  }

  Future<int> contarMensagensNaoLidas(String chatId, String userId) async {
    try {
      return await _repository.contarMensagensNaoLidas(chatId, userId);
    } catch (e) {
      print('Erro ao contar mensagens não lidas: $e');
      return 0;
    }
  }

  int contarMensagensNaoLidasLocal(String chatId, String userId) {
    return _mensagens
        .where(
          (mensagem) =>
              mensagem.senderId != userId &&
              !mensagem.visualizadaPor.contains(userId),
        )
        .length;
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
