import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Controller/mensagem_controller.dart';
import '../Controller/auth_controller.dart';
import '../Controller/usuario_controller.dart';
import '../Controller/avaliacao_controller.dart';
import '../Model/Mensagem.dart';
import '../Controller/colors.dart';
import 'package:skilmatch/Repository/chat_repository.dart';

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
  String? _fotoOutroUsuario;
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
      _carregarDadosUsuario();
      _marcarMensagensComoLidas();
    });
  }

  void _marcarMensagensComoLidas() {
    final authController = Provider.of<AuthController>(context, listen: false);
    final mensagemController = Provider.of<MensagemController>(
      context,
      listen: false,
    );
    final user = authController.currentUser;

    if (user != null) {
      Future.delayed(Duration(milliseconds: 500), () {
        mensagemController.marcarMensagensComoLidas(widget.chatId, user.uid);
      });
    }
  }

  Future<void> _carregarDadosUsuario() async {
    try {
      final usuarioController = Provider.of<UsuarioController>(
        context,
        listen: false,
      );
      final usuario = await usuarioController.buscarUsuarioPorId(
        widget.outroUsuario,
      );

      if (usuario != null && mounted) {
        setState(() {
          _nomeOutroUsuario = usuario.nomeCompleto;
          _fotoOutroUsuario = usuario.fotoUrl;
        });
      }
    } catch (e) {
      print("Erro ao carregar dados do usuário: $e");
    }
  }

  Widget _buildAppBarAvatar() {
    if (_fotoOutroUsuario != null && _fotoOutroUsuario!.isNotEmpty) {
      try {
        final bytes = base64Decode(_fotoOutroUsuario!);
        return CircleAvatar(radius: 18, backgroundImage: MemoryImage(bytes));
      } catch (e) {
        print("Erro ao decodificar imagem Base64: $e");
      }
    }

    return CircleAvatar(
      radius: 18,
      backgroundColor: AppColors.white,
      child: Text(
        _nomeOutroUsuario != null && _nomeOutroUsuario!.isNotEmpty
            ? _nomeOutroUsuario![0].toUpperCase()
            : '?',
        style: TextStyle(color: AppColors.roxo, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _mostrarDialogoAvaliacao(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final authController = Provider.of<AuthController>(
          context,
          listen: false,
        );
        final avaliacaoController = Provider.of<AvaliacaoController>(
          context,
          listen: false,
        );
        final usuarioLogado = authController.currentUser;

        if (usuarioLogado != null) {
          bool jaAvaliou = await avaliacaoController.usuarioJaAvaliou(
            usuarioLogado.uid,
            widget.outroUsuario,
          );

          if (jaAvaliou && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Você já avaliou este usuário. Chat encerrado.'),
                backgroundColor: Colors.orange,
              ),
            );
            Navigator.pop(context);
            return;
          }
        }
      } catch (e) {
        print('Erro ao verificar avaliação: $e');
      }
    });

    int estrelas = 0;
    TextEditingController comentarioController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.fundo,
              surfaceTintColor: AppColors.fundo,
              title: Text(
                'Avaliar Usuário',
                style: TextStyle(
                  color: AppColors.roxo,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Como foi sua experiência com ${_nomeOutroUsuario ?? 'este usuário'}?',
                    style: TextStyle(color: AppColors.cinza),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () {
                          setState(() {
                            estrelas = index + 1;
                          });
                        },
                        icon: Icon(
                          index < estrelas ? Icons.star : Icons.star_border,
                          color: AppColors.roxo,
                          size: 32,
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: comentarioController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Deixe um comentário (opcional)...',
                      hintStyle: TextStyle(color: AppColors.cinza),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.cinza),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.roxo),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: AppColors.cinza),
                  ),
                ),
                ElevatedButton(
                  onPressed: estrelas > 0
                      ? () async {
                          await _enviarAvaliacao(
                            estrelas: estrelas,
                            comentario: comentarioController.text,
                          );
                          Navigator.pop(context);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.roxo,
                    foregroundColor: AppColors.white,
                  ),
                  child: Text('Avaliar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarDialogoDenuncia(BuildContext context) {
    TextEditingController motivoController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.fundo,
          surfaceTintColor: AppColors.fundo,
          title: Text(
            'Denunciar Usuário',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Por que você está denunciando ${_nomeOutroUsuario ?? 'este usuário'}?',
                style: TextStyle(color: AppColors.cinza),
              ),
              SizedBox(height: 16),
              TextField(
                controller: motivoController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Descreva o motivo da denúncia...',
                  hintStyle: TextStyle(color: AppColors.cinza),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.cinza),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar', style: TextStyle(color: AppColors.cinza)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (motivoController.text.trim().isNotEmpty) {
                  await _enviarDenuncia(motivoController.text.trim());
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Por favor, digite o motivo da denúncia'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: AppColors.white,
              ),
              child: Text('Enviar Denúncia'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _enviarAvaliacao({
    required int estrelas,
    required String comentario,
  }) async {
    try {
      final authController = Provider.of<AuthController>(
        context,
        listen: false,
      );
      final avaliacaoController = Provider.of<AvaliacaoController>(
        context,
        listen: false,
      );
      final usuarioController = Provider.of<UsuarioController>(
        context,
        listen: false,
      );

      final usuarioLogado = authController.currentUser;
      if (usuarioLogado == null) return;

      final avaliador = await usuarioController.buscarUsuarioPorId(
        usuarioLogado.uid,
      );
      final avaliado = await usuarioController.buscarUsuarioPorId(
        widget.outroUsuario,
      );

      if (avaliador != null && avaliado != null) {
        final sucesso = await avaliacaoController.salvarAvaliacao(
          avaliadorId: usuarioLogado.uid,
          avaliadoId: widget.outroUsuario,
          estrelas: estrelas,
          comentario: comentario,
          usuarioAvaliador: avaliador,
          usuarioAvaliado: avaliado,
        );

        if (sucesso) {
          await _encerrarChat();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Avaliação enviada com sucesso! Chat encerrado.'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pop(context);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar avaliação: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _encerrarChat() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final authController = Provider.of<AuthController>(
        context,
        listen: false,
      );
      final usuarioLogado = authController.currentUser;

      if (usuarioLogado == null) return;

      final chatRef = firestore.collection('chats').doc(widget.chatId);

      final chatDoc = await chatRef.get();

      if (!chatDoc.exists) {
        await chatRef.set({
          'participantes': [usuarioLogado.uid, widget.outroUsuario],
          'status': 'finalizado',
          'finalizadoPor': usuarioLogado.uid,
          'dataFinalizacao': FieldValue.serverTimestamp(),
          'criadoEm': FieldValue.serverTimestamp(),
          'ultimaMensagem': 'Troca realizada',
          'ultimaMensagemEnviadaEm': FieldValue.serverTimestamp(),
          'usuariosInfo': {
            usuarioLogado.uid: _getCurrentUserName(),
            widget.outroUsuario: _nomeOutroUsuario ?? 'Usuário',
          },
        });
        print('✅ Chat criado e finalizado: ${widget.chatId}');
      } else {
        await chatRef.update({
          'status': 'finalizado',
          'finalizadoPor': usuarioLogado.uid,
          'dataFinalizacao': FieldValue.serverTimestamp(),
        });
        print('✅ Chat atualizado para finalizado: ${widget.chatId}');
      }
    } catch (e) {
      print('❌ Erro ao encerrar chat: $e');
    }
  }

  String _getCurrentUserName() {
    final authController = Provider.of<AuthController>(context, listen: false);
    final user = authController.currentUser;
    return user?.displayName ?? 'Usuário';
  }

  Future<void> _enviarDenuncia(String motivo) async {
    try {
      final authController = Provider.of<AuthController>(
        context,
        listen: false,
      );
      final avaliacaoController = Provider.of<AvaliacaoController>(
        context,
        listen: false,
      );
      final usuarioController = Provider.of<UsuarioController>(
        context,
        listen: false,
      );

      final usuarioLogado = authController.currentUser;
      if (usuarioLogado == null) return;

      final denunciante = await usuarioController.buscarUsuarioPorId(
        usuarioLogado.uid,
      );
      final denunciado = await usuarioController.buscarUsuarioPorId(
        widget.outroUsuario,
      );

      if (denunciante != null && denunciado != null) {
        final sucesso = await avaliacaoController.enviarDenuncia(
          motivo: motivo,
          usuarioDenunciado: denunciado,
          usuarioDenunciante: denunciante,
        );

        if (sucesso) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Denúncia enviada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao enviar denúncia. Tente novamente.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar denúncia: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
        title: Row(
          children: [
            _buildAppBarAvatar(),
            SizedBox(width: 12),
            Text(
              _nomeOutroUsuario ?? widget.outroUsuario,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        centerTitle: false,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.white),
            onSelected: (value) {
              if (value == 'avaliar') {
                _mostrarDialogoAvaliacao(context);
              } else if (value == 'denunciar') {
                _mostrarDialogoDenuncia(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'avaliar',
                child: Row(
                  children: [
                    Icon(Icons.star, color: AppColors.roxo),
                    SizedBox(width: 8),
                    Text('Avaliar'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'denunciar',
                child: Row(
                  children: [
                    Icon(Icons.report, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Denunciar'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.roxo.withOpacity(0.05), AppColors.fundo],
                ),
              ),
              child: controller.carregando
                  ? Center(
                      child: CircularProgressIndicator(color: AppColors.roxo),
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
                        return _BalaoMensagem(
                          mensagem: mensagem,
                          meuUid: meuUid,
                        );
                      },
                    ),
            ),
          ),
          _CampoEnvio(
            chatId: widget.chatId,
            meuUid: meuUid,
            outroUsuario: widget.outroUsuario,
            onMensagemEnviada: _marcarMensagensComoLidas,
          ),
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
    final foiLida = mensagem.visualizadaPor.isNotEmpty;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isEu
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
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
              child: Column(
                crossAxisAlignment: isEu
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    mensagem.texto,
                    style: TextStyle(
                      color: isEu ? AppColors.white : AppColors.black,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  if (isEu && foiLida)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.done_all,
                            size: 12,
                            color: AppColors.white.withOpacity(0.7),
                          ),
                          SizedBox(width: 2),
                          Text(
                            'Lida',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
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
  final VoidCallback onMensagemEnviada;

  const _CampoEnvio({
    required this.chatId,
    required this.meuUid,
    required this.outroUsuario,
    required this.onMensagemEnviada,
  });

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
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
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
    final usuarioController = Provider.of<UsuarioController>(
      context,
      listen: false,
    );

    final meuUsuario = await usuarioController.buscarUsuarioPorId(
      widget.meuUid,
    );
    final outroUsuario = await usuarioController.buscarUsuarioPorId(
      widget.outroUsuario,
    );

    await controller.enviarMensagem(
      widget.chatId,
      _textController.text.trim(),
      widget.meuUid,
      meuUsuario?.nomeCompleto ?? 'Usuário',
      outroUsuario?.nomeCompleto ?? 'Usuário',
      meuUsuario?.fotoUrl ?? '',
      outroUsuario?.fotoUrl ?? '',
    );

    _textController.clear();
    widget.onMensagemEnviada();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
