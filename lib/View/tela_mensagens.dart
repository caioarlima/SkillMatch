import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Controller/mensagem_controller.dart';
import '../Controller/auth_controller.dart';
import '../Controller/colors.dart';
import '../Model/Chat.dart';
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
    final mensagemController = Provider.of<MensagemController>(context, listen: false);
    
    final user = authController.currentUser;
    if (user != null) {
      mensagemController.carregarChats(user.uid);
    }
  }

  List<Chat> _filtrarChats(List<Chat> chats, String query) {
    if (query.isEmpty) return chats;
    
    return chats.where((chat) {
      final outroUsuarioNome = _getNomeOutroUsuario(chat);
      return outroUsuarioNome.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  String _getNomeOutroUsuario(Chat chat) {
    final authController = Provider.of<AuthController>(context, listen: false);
    final user = authController.currentUser;
    final meuId = user?.uid ?? "";
    
    for (final participanteId in chat.participantes) {
      if (participanteId != meuId) {
        return chat.usuariosInfo[participanteId] ?? 'Usuário';
      }
    }
    return chat.participantes.isNotEmpty ? chat.participantes[0] : '';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MensagemController>(context);
    final chatsFiltrados = _filtrarChats(controller.chats, _searchQuery);
    
    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        backgroundColor: AppColors.roxo,
        foregroundColor: AppColors.white,
        title: Text(
          'Mensagens',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Campo de pesquisa
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
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
                  hintStyle: TextStyle(color: AppColors.cinza),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 16.0,
                  ),
                  prefixIcon: Icon(Icons.search, color: AppColors.roxo),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: AppColors.cinza),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                ),
                keyboardType: TextInputType.text,
              ),
            ),
          ),
          // Lista de chats
          Expanded(
            child: controller.carregando
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.roxo,
                    ),
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
                            SizedBox(height: 16),
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
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: chatsFiltrados.length,
                        itemBuilder: (context, index) {
                          final chat = chatsFiltrados[index];
                          return _ItemConversa(chat: chat);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _ItemConversa extends StatelessWidget {
  final Chat chat;

  _ItemConversa({required this.chat});

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context, listen: false);
    final user = authController.currentUser;
    final meuId = user?.uid ?? "";
    
    String _getOutroUsuarioId() {
      for (final participanteId in chat.participantes) {
        if (participanteId != meuId) {
          return participanteId;
        }
      }
      return chat.participantes.isNotEmpty ? chat.participantes[0] : '';
    }

    String _getNomeOutroUsuario() {
      final outroUsuarioId = _getOutroUsuarioId();
      return chat.usuariosInfo[outroUsuarioId] ?? 'Usuário';
    }

    String _formatarHora() {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final messageDate = DateTime(chat.timestamp.year, chat.timestamp.month, chat.timestamp.day);
      
      if (messageDate == today) {
        return '${chat.timestamp.hour}:${chat.timestamp.minute.toString().padLeft(2, '0')}';
      } else {
        return '${chat.timestamp.day}/${chat.timestamp.month}';
      }
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.roxo,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              _getNomeOutroUsuario()[0].toUpperCase(),
              style: TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          _getNomeOutroUsuario(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        subtitle: Text(
          chat.ultimaMensagem.isNotEmpty ? chat.ultimaMensagem : 'Conversa iniciada',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.cinza,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          _formatarHora(),
          style: TextStyle(
            fontSize: 12,
            color: AppColors.cinza,
          ),
        ),
        onTap: () {
          final outroUsuarioId = _getOutroUsuarioId();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TelaChat(
                outroUsuario: outroUsuarioId,
                chatId: chat.chatId,
              ),
            ),
          );
        },
      ),
    );
  }
}