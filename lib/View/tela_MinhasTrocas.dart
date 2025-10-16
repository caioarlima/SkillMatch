import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Controller/avaliacao_controller.dart';
import '../Controller/auth_controller.dart';
import '../Controller/usuario_controller.dart';
import '../Controller/colors.dart';
import '../Model/Avaliacao.dart';
import '../Model/Usuario.dart';

class TelaMinhasTrocas extends StatefulWidget {
  const TelaMinhasTrocas({super.key});

  @override
  State<TelaMinhasTrocas> createState() => _TelaMinhasTrocasState();
}

class _TelaMinhasTrocasState extends State<TelaMinhasTrocas> {
  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final usuarioLogado = authController.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.roxo,
        foregroundColor: AppColors.white,
        title: Text('Minhas Trocas'),
        elevation: 0,
      ),
      body: usuarioLogado == null
          ? Center(
              child: Text(
                'Faça login para ver suas avaliações',
                style: TextStyle(color: AppColors.cinza),
              ),
            )
          : StreamBuilder<List<Avaliacao>>(
              stream: Provider.of<AvaliacaoController>(
                context,
              ).getAvaliacoesUsuario(usuarioLogado.uid),
              builder: (context, snapshot) {
                print('📊 SNAPSHOT: ${snapshot.connectionState}');
                print('📊 HAS ERROR: ${snapshot.hasError}');
                print('📊 ERROR: ${snapshot.error}');
                print('📊 HAS DATA: ${snapshot.hasData}');
                print('📊 DATA LENGTH: ${snapshot.data?.length}');
                print('📊 USER ID: ${usuarioLogado.uid}');

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: AppColors.roxo),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 64),
                        SizedBox(height: 16),
                        Text(
                          'Erro ao carregar avaliações',
                          style: TextStyle(color: Colors.red),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Detalhes: ${snapshot.error}',
                          style: TextStyle(
                            color: AppColors.cinza,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final avaliacoes = snapshot.data ?? [];

                if (avaliacoes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star_outline,
                          size: 64,
                          color: AppColors.cinza.withOpacity(0.5),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Nenhuma avaliação recebida',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.cinza,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Suas avaliações aparecerão aqui',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.cinza.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: avaliacoes.length,
                  itemBuilder: (context, index) {
                    return _AvaliacaoItem(avaliacao: avaliacoes[index]);
                  },
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Procurar'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Minhas Trocas',
          ),
        ],
        selectedItemColor: AppColors.roxo,
        unselectedItemColor: AppColors.cinza,
      ),
    );
  }
}

class _AvaliacaoItem extends StatefulWidget {
  final Avaliacao avaliacao;

  const _AvaliacaoItem({required this.avaliacao});

  @override
  State<_AvaliacaoItem> createState() => _AvaliacaoItemState();
}

class _AvaliacaoItemState extends State<_AvaliacaoItem> {
  Usuario? _usuarioAvaliador;

  @override
  void initState() {
    super.initState();
    _carregarUsuarioAvaliador();
  }

  Future<void> _carregarUsuarioAvaliador() async {
    try {
      final usuarioController = Provider.of<UsuarioController>(
        context,
        listen: false,
      );
      final usuario = await usuarioController.buscarUsuarioPorId(
        widget.avaliacao.usuarioAvaliadorId,
      );

      if (mounted) {
        setState(() {
          _usuarioAvaliador = usuario;
        });
      }
    } catch (e) {
      print('Erro ao carregar usuário avaliador: $e');
    }
  }

  String _formatarData(DateTime data) {
    final now = DateTime.now();
    final difference = now.difference(data);

    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return '${data.day}/${data.month}/${data.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.roxo,
                  child: Text(
                    _usuarioAvaliador?.nomeCompleto.isNotEmpty == true
                        ? _usuarioAvaliador!.nomeCompleto[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _usuarioAvaliador?.nomeCompleto ?? 'Usuário',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _formatarData(widget.avaliacao.dataAvaliacao),
                        style: TextStyle(fontSize: 12, color: AppColors.cinza),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < widget.avaliacao.estrelas
                          ? Icons.star
                          : Icons.star_border,
                      color: AppColors.roxo,
                      size: 20,
                    );
                  }),
                ),
              ],
            ),
            if (widget.avaliacao.comentario.isNotEmpty) ...[
              SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.fundo,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.avaliacao.comentario,
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
