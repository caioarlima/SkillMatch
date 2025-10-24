import 'package:flutter/material.dart';
import '../Model/Chat.dart';
import '../Model/Mensagem.dart';
import '../Repository/chat_repository.dart';
import '../Repository/mensagem_repository.dart';
import '../Repository/usuario_repository.dart';

class ChatController with ChangeNotifier {
  final UsuarioRepository _usuarioRepository = UsuarioRepository();
  final MensagemRepository _mensagemRepository;
  final ChatRepository _chatRepository = ChatRepository();

  ChatController()
    : _mensagemRepository = MensagemRepository(UsuarioRepository());

  List<Chat> _chats = [];
  List<Mensagem> _mensagens = [];
  bool _loading = false;
  String? _error;
  Chat? _chatSelecionado;

  List<Chat> get chats => _chats;
  List<Mensagem> get mensagens => _mensagens;
  bool get loading => _loading;
  String? get error => _error;
  Chat? get chatSelecionado => _chatSelecionado;

  Future<void> carregarChatsUsuario(String userId) async {
    _setLoading(true);
    _error = null;

    try {
      _chats = await _mensagemRepository.buscarChatsUsuario(userId);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setLoading(false);
      _error = 'Erro ao carregar chats: $e';
      notifyListeners();
    }
  }

  Future<void> carregarMensagensChat(String chatId) async {
    _setLoading(true);
    _error = null;

    try {
      _mensagens = await _mensagemRepository.buscarMensagensChat(chatId);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setLoading(false);
      _error = 'Erro ao carregar mensagens: $e';
      notifyListeners();
    }
  }

  Future<bool> enviarMensagem({
    required String chatId,
    required String texto,
    required String senderId,
  }) async {
    _error = null;

    try {
      if (texto.trim().isEmpty) {
        _error = 'Mensagem não pode estar vazia';
        notifyListeners();
        return false;
      }

      await _mensagemRepository.enviarMensagem(chatId, texto.trim(), senderId);

      await carregarMensagensChat(chatId);

      return true;
    } catch (e) {
      _error = 'Erro ao enviar mensagem: $e';
      notifyListeners();
      return false;
    }
  }

  Future<String?> criarNovoChat({
    required String user1Id,
    required String user2Id,
    required String user1Nome,
    required String user2Nome,
    String? user1Foto,
    String? user2Foto,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final chatId = _mensagemRepository.gerarChatId(user1Id, user2Id);

      await _mensagemRepository.criarChat(
        user1Id,
        user2Id,
        user1Nome,
        user2Nome,
        user1Foto ?? '',
        user2Foto ?? '',
      );

      _setLoading(false);
      notifyListeners();
      return chatId;
    } catch (e) {
      _setLoading(false);
      _error = 'Erro ao criar chat: $e';
      notifyListeners();
      return null;
    }
  }

  Future<void> verificarECriarChat({
    required String chatId,
    required String user1Id,
    required String user2Id,
    required String user1Nome,
    required String user2Nome,
    String? user1Foto,
    String? user2Foto,
  }) async {
    _error = null;

    try {
      await _mensagemRepository.verificarECriarChat(
        chatId,
        user1Id,
        user2Id,
        user1Nome,
        user2Nome,
        user1Foto ?? '',
        user2Foto ?? '',
      );
    } catch (e) {
      _error = 'Erro ao verificar/criar chat: $e';
      notifyListeners();
    }
  }

  Future<void> marcarMensagensComoLidas({
    required String chatId,
    required String userId,
    required List<String> mensagemIds,
  }) async {
    _error = null;

    try {
      await _mensagemRepository.marcarMensagensComoLidas(
        chatId,
        userId,
        mensagemIds,
      );

      for (final mensagem in _mensagens) {
        if (mensagemIds.contains(mensagem.mensagemId)) {
          mensagem.copyWith(
            lida: true,
            visualizadaPor: [...mensagem.visualizadaPor, userId],
          );
        }
      }

      notifyListeners();
    } catch (e) {
      _error = 'Erro ao marcar mensagens como lidas: $e';
      notifyListeners();
    }
  }

  Future<int> contarMensagensNaoLidas(String chatId, String userId) async {
    try {
      return await _mensagemRepository.contarMensagensNaoLidas(chatId, userId);
    } catch (e) {
      return 0;
    }
  }

  Future<int> getTotalTrocasUsuario(String usuarioId) async {
    try {
      return await _chatRepository.getTotalTrocasUsuario(usuarioId);
    } catch (e) {
      return 0;
    }
  }

  void selecionarChat(Chat chat) {
    _chatSelecionado = chat;
    notifyListeners();
  }

  void limparChatSelecionado() {
    _chatSelecionado = null;
    _mensagens.clear();
    notifyListeners();
  }

  String? getNomeOutroParticipante(Chat chat, String usuarioAtualId) {
    final outrosParticipantes = chat.participantes
        .where((participante) => participante != usuarioAtualId)
        .toList();

    if (outrosParticipantes.isNotEmpty) {
      return chat.usuariosInfo[outrosParticipantes.first];
    }

    return null;
  }

  String? getFotoOutroParticipante(Chat chat, String usuarioAtualId) {
    final outrosParticipantes = chat.participantes
        .where((participante) => participante != usuarioAtualId)
        .toList();

    if (outrosParticipantes.isNotEmpty) {
      return chat.usuariosFotos[outrosParticipantes.first];
    }

    return null;
  }

  String gerarChatId(String user1Id, String user2Id) {
    return _mensagemRepository.gerarChatId(user1Id, user2Id);
  }

  void limparErro() {
    _error = null;
    notifyListeners();
  }

  void limparMensagens() {
    _mensagens.clear();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
