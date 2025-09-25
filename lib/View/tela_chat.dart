import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Controller/mensagem_controller.dart';
import '../Controller/auth_controller.dart';
import '../Model/Mensagem.dart';

class TelaChat extends StatefulWidget {
  final String outroUsuario;
  final String chatId;

  const TelaChat({required this.outroUsuario, required this.chatId});

  @override
  State<TelaChat> createState() => _TelaChatState();
}

class _TelaChatState extends State<TelaChat> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<MensagemController>(
        context,
        listen: false,
      );
      controller.carregarMensagens(widget.chatId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MensagemController>(context);
    final authController = Provider.of<AuthController>(context, listen: false);
    final user = authController.currentUser;
    final meuUid = user?.uid ?? "";

    return Scaffold(
      appBar: AppBar(title: Text(widget.outroUsuario)),
      body: Column(
        children: [
          Expanded(
            child: controller.carregando
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    reverse: true,
                    itemCount: controller.mensagens.length,
                    itemBuilder: (context, index) {
                      final mensagem = controller.mensagens[index];
                      return _BalaoMensagem(mensagem: mensagem, meuUid: meuUid);
                    },
                  ),
          ),
          _CampoEnvio(chatId: widget.chatId, meuUid: meuUid),
        ],
      ),
    );
  }
}

class _BalaoMensagem extends StatelessWidget {
  final Mensagem mensagem;
  final String meuUid;

  const _BalaoMensagem({required this.mensagem, required this.meuUid});

  @override
  Widget build(BuildContext context) {
    final isEu = mensagem.senderId == meuUid;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      alignment: isEu ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isEu ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          mensagem.texto,
          style: TextStyle(color: isEu ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}

class _CampoEnvio extends StatefulWidget {
  final String chatId;
  final String meuUid;

  const _CampoEnvio({required this.chatId, required this.meuUid});

  @override
  State<_CampoEnvio> createState() => _CampoEnvioState();
}

class _CampoEnvioState extends State<_CampoEnvio> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Digite uma mensagem...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(icon: Icon(Icons.send), onPressed: _enviarMensagem),
        ],
      ),
    );
  }

  void _enviarMensagem() async {
    if (_textController.text.trim().isEmpty) return;

    final controller = Provider.of<MensagemController>(context, listen: false);

    await controller.enviarMensagem(
      widget.chatId,
      _textController.text.trim(),
      widget.meuUid,
    );

    _textController.clear();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
