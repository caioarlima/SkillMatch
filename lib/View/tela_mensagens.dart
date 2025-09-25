import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Controller/mensagem_controller.dart';
import '../Controller/auth_controller.dart';
import '../Model/Chat.dart';
import 'tela_chat.dart';

class TelaMensagens extends StatefulWidget {
  const TelaMensagens({super.key});

  @override
  State<TelaMensagens> createState() => _TelaMensagensState();
}

class _TelaMensagensState extends State<TelaMensagens> {
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

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MensagemController>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Mensagens'),
      ),
      body: controller.carregando
          ? Center(child: CircularProgressIndicator())
          : controller.chats.isEmpty
              ? Center(child: Text('Nenhuma conversa encontrada'))
              : ListView.builder(
                  itemCount: controller.chats.length,
                  itemBuilder: (context, index) {
                    final chat = controller.chats[index];
                    return _ItemConversa(chat: chat);
                  },
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
    
    String _getNomeOutroUsuario() {
      for (final participanteId in chat.participantes) {
        if (participanteId != meuId) {
          return chat.usuariosInfo[participanteId] ?? 'Usuário';
        }
      }
      return 'Usuário';
    }

    return ListTile(
      leading: CircleAvatar(
        child: Text(_getNomeOutroUsuario()[0]),
      ),
      title: Text(_getNomeOutroUsuario()),
      subtitle: Text(
        chat.ultimaMensagem,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        '${chat.timestamp.hour}:${chat.timestamp.minute.toString().padLeft(2, '0')}',
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TelaChat(
              outroUsuario: _getNomeOutroUsuario(),
              chatId: chat.chatId,
            ),
          ),
        );
      },
    );
  }
}