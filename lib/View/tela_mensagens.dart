import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Controller/chat_controller.dart';
import '../Controller/auth_controller.dart';
import '../Controller/colors.dart';
import '../Model/Chat.dart';
import '../Controller/usuario_controller.dart';
import '../Model/Usuario.dart';
import 'tela_chat.dart';

class TelaMensagens extends StatefulWidget {
  const TelaMensagens({super.key});

  @override
  State<TelaMensagens> createState() => _TelaMensagensState();
}

class _TelaMensagensState extends State<TelaMensagens> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarChats();
    });
  }

  void _carregarChats() {
    final authController = Provider.of<AuthController>(context, listen: false);
    final chatController = Provider.of<ChatController>(context, listen: false);

    final user = authController.currentUser;
    if (user != null) {
      chatController.carregarChatsUsuario(user.uid);
    }
  }

  String _getNomeOutroUsuario(Chat chat) {
    final authController = Provider.of<AuthController>(context, listen: false);
    final user = authController.currentUser;
    final meuId = user?.uid ?? "";

    for (final participanteId in chat.participantes) {
      if (participanteId != meuId) {
        return chat.usuariosInfo[participanteId] ?? 'Usuário Sem Nome';
      }
    }
    return chat.participantes.isNotEmpty ? chat.participantes[0] : '';
  }

  List<Chat> _filtrarChats(List<Chat> chats, String query) {
    if (query.isEmpty) return chats;

    return chats.where((chat) {
      final outroUsuarioNome = _getNomeOutroUsuario(chat);
      return outroUsuarioNome.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final chatController = Provider.of<ChatController>(context);
    final authController = Provider.of<AuthController>(context, listen: false);
    final usuarioController = Provider.of<UsuarioController>(
      context,
      listen: false,
    );
    final user = authController.currentUser;
    final meuId = user?.uid ?? "";
    final chatsFiltrados = _filtrarChats(chatController.chats, _searchQuery);

    return Scaffold(
      backgroundColor: AppColors.fundo,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Mensagens",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Converse com pessoas e combine trocas",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.cinza,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Buscar conversas...",
                        hintStyle: TextStyle(
                          color: AppColors.cinza.withOpacity(0.7),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 18.0,
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.only(left: 8, right: 4),
                          child: Icon(
                            Icons.search,
                            color: AppColors.roxo,
                            size: 24,
                          ),
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: AppColors.cinza,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = '';
                                    _searchController.clear();
                                  });
                                },
                              )
                            : null,
                      ),
                      style: TextStyle(color: AppColors.black, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: chatController.loading
                  ? Center(
                      child: CircularProgressIndicator(color: AppColors.roxo),
                    )
                  : chatsFiltrados.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _searchQuery.isEmpty
                                ? Icons.chat_bubble_outline
                                : Icons.search_off,
                            size: 64,
                            color: AppColors.cinza.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'Nenhuma conversa encontrada'
                                : 'Nenhum chat encontrado com "$_searchQuery"',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.cinza,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: chatsFiltrados.length,
                      itemBuilder: (context, index) {
                        final chat = chatsFiltrados[index];
                        return _ItemConversa(
                          chat: chat,
                          meuId: meuId,
                          usuarioController: usuarioController,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemConversa extends StatelessWidget {
  final Chat chat;
  final String meuId;
  final UsuarioController usuarioController;

  _ItemConversa({
    required this.chat,
    required this.meuId,
    required this.usuarioController,
  });

  String _getOutroUsuarioId() {
    for (final participanteId in chat.participantes) {
      if (participanteId != meuId) {
        return participanteId;
      }
    }
    return chat.participantes.isNotEmpty ? chat.participantes[0] : '';
  }

  Widget _buildUserAvatarWithFallback(String outroUsuarioId) {
    return FutureBuilder<Usuario?>(
      // ⭐️ CORREÇÃO DO NOME DO MÉTODO AQUI
      future: usuarioController.buscarUsuarioPorId(outroUsuarioId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.roxo.withOpacity(0.2),
            child: CircularProgressIndicator(
              color: AppColors.roxo,
              strokeWidth: 2,
            ),
          );
        }

        final outroUsuario = snapshot.data;
        final userName = outroUsuario?.nomeCompleto ?? 'S';
        final userFoto = outroUsuario?.fotoUrl;

        if (userFoto != null && userFoto.isNotEmpty) {
          if (userFoto.startsWith('http') || userFoto.startsWith('https')) {
            return CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(userFoto),
            );
          }

          try {
            final bytes = base64Decode(userFoto);
            return CircleAvatar(
              radius: 25,
              backgroundImage: MemoryImage(bytes),
            );
          } catch (e) {}
        }

        return CircleAvatar(
          radius: 25,
          backgroundColor: AppColors.roxo,
          child: Text(
            userName.isNotEmpty ? userName[0].toUpperCase() : '?',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadgeMensagensNaoLidas(String chatId) {
    return Consumer<ChatController>(
      builder: (context, chatController, child) {
        return FutureBuilder<int>(
          future: chatController.contarMensagensNaoLidas(chatId, meuId),
          builder: (context, snapshot) {
            final mensagensNaoLidas = snapshot.hasData ? snapshot.data! : 0;

            if (mensagensNaoLidas > 0) {
              return Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  mensagensNaoLidas > 9 ? '9+' : mensagensNaoLidas.toString(),
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
            return SizedBox.shrink();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatController = Provider.of<ChatController>(context, listen: false);

    final outroUsuarioId = _getOutroUsuarioId();
    final outroUsuarioNomeDoChat =
        chat.usuariosInfo[outroUsuarioId] ?? 'Seu Nome';

    String _formatarHora() {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final messageDate = DateTime(
        chat.timestamp.year,
        chat.timestamp.month,
        chat.timestamp.day,
      );
      if (messageDate == today) {
        return '${chat.timestamp.hour}:${chat.timestamp.minute.toString().padLeft(2, '0')}';
      } else {
        return '${chat.timestamp.day}/${chat.timestamp.month}';
      }
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Stack(
          children: [
            _buildUserAvatarWithFallback(outroUsuarioId),
            Positioned(
              top: 0,
              right: 0,
              child: _buildBadgeMensagensNaoLidas(chat.chatId),
            ),
          ],
        ),
        title: FutureBuilder<Usuario?>(
          // ⭐️ CORREÇÃO DO NOME DO MÉTODO AQUI
          future: usuarioController.buscarUsuarioPorId(outroUsuarioId),
          builder: (context, snapshot) {
            final nome = snapshot.data?.nomeCompleto ?? outroUsuarioNomeDoChat;
            return Text(
              nome,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            );
          },
        ),
        subtitle: Text(
          chat.ultimaMensagem.isNotEmpty
              ? chat.ultimaMensagem
              : 'Conversa iniciada',
          style: TextStyle(fontSize: 14, color: AppColors.cinza),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          _formatarHora(),
          style: TextStyle(fontSize: 12, color: AppColors.cinza),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TelaChat(outroUsuario: outroUsuarioId, chatId: chat.chatId),
            ),
          ).then((_) {
            chatController.carregarChatsUsuario(meuId);
          });
        },
      ),
    );
  }
}
