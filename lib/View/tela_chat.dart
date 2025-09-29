import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Controller/mensagem_controller.dart';
import '../Controller/auth_controller.dart';
import '../Controller/usuario_controller.dart';
import '../Model/Mensagem.dart';
import '../Controller/colors.dart';

class TelaChat extends StatefulWidget {
  final String outroUsuario;
  final String chatId;

  const TelaChat({required this.outroUsuario, required this.chatId});

  @override
  State<TelaChat> createState() => _TelaChatState();
}

class _TelaChatState extends State<TelaChat> {
  final TextEditingController _textController = TextEditingController();
  String? _nomeOutroUsuario;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<MensagemController>(
        context,
        listen: false,
      );
      controller.carregarMensagens(widget.chatId);
      _carregarNomeUsuario();
    });
  }

  Future<void> _carregarNomeUsuario() async {
    try {
      final usuarioController = Provider.of<UsuarioController>(
        context,
        listen: false,
      );
      final usuario = await usuarioController.buscarUsuarioPorId(widget.outroUsuario);
      
      if (usuario != null && mounted) {
        setState(() {
          _nomeOutroUsuario = usuario.nomeCompleto;
        });
      }
    } catch (e) {
      print("Erro ao carregar nome do usuário: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MensagemController>(context);
    final authController = Provider.of<AuthController>(context, listen: false);
    final user = authController.currentUser;
    final meuUid = user?.uid ?? "";

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && controller.mensagens.isNotEmpty) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        backgroundColor: AppColors.roxo,
        foregroundColor: AppColors.white,
        title: Text(
          _nomeOutroUsuario ?? widget.outroUsuario,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(12),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.roxo.withOpacity(0.05),
                    AppColors.fundo,
                  ],
                ),
              ),
              child: controller.carregando
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.roxo,
                      ),
                    )
                  : controller.mensagens.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: AppColors.cinza.withOpacity(0.5),
                              ),
                              SizedBox(height: 16),
                              Text(
                                "Inicie uma conversa",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.cinza,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.all(16),
                          itemCount: controller.mensagens.length,
                          itemBuilder: (context, index) {
                            final mensagem = controller.mensagens[index];
                            return _BalaoMensagem(mensagem: mensagem, meuUid: meuUid);
                          },
                        ),
            ),
          ),
          _CampoEnvio(chatId: widget.chatId, meuUid: meuUid, outroUsuario: widget.outroUsuario),
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
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isEu ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isEu) SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isEu ? AppColors.roxo : AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: isEu ? Radius.circular(16) : Radius.circular(4),
                  bottomRight: isEu ? Radius.circular(4) : Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                mensagem.texto,
                style: TextStyle(
                  color: isEu ? AppColors.white : AppColors.black,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isEu) SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _CampoEnvio extends StatefulWidget {
  final String chatId;
  final String meuUid;
  final String outroUsuario;

  const _CampoEnvio({required this.chatId, required this.meuUid, required this.outroUsuario});

  @override
  State<_CampoEnvio> createState() => _CampoEnvioState();
}

class _CampoEnvioState extends State<_CampoEnvio> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.fundo,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: AppColors.cinza.withOpacity(0.3)),
              ),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Digite uma mensagem...',
                  hintStyle: TextStyle(color: AppColors.cinza),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: TextStyle(color: AppColors.black),
                maxLines: 3,
                minLines: 1,
              ),
            ),
          ),
          SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.roxo,
            ),
            child: IconButton(
              icon: Icon(Icons.send, color: AppColors.white),
              onPressed: _enviarMensagem,
            ),
          ),
        ],
      ),
    );
  }

  void _enviarMensagem() async {
    if (_textController.text.trim().isEmpty) return;

    final controller = Provider.of<MensagemController>(context, listen: false);
    final usuarioController = Provider.of<UsuarioController>(context, listen: false);
    
    final meuUsuario = await usuarioController.buscarUsuarioPorId(widget.meuUid);
    final outroUsuario = await usuarioController.buscarUsuarioPorId(widget.outroUsuario);

    await controller.enviarMensagem(
      widget.chatId,
      _textController.text.trim(),
      widget.meuUid,
      meuUsuario?.nomeCompleto ?? 'Usuário',
      outroUsuario?.nomeCompleto ?? 'Usuário',
    );

    _textController.clear();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}