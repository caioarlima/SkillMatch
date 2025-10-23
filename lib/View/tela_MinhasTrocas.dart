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
      backgroundColor: AppColors.fundo,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                "Minhas Trocas",
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
                "Acompanhe suas avaliações e trocas realizadas",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.cinza,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              usuarioLogado == null
                  ? Container(
                      padding: const EdgeInsets.all(40),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_outline,
                              color: AppColors.cinza.withOpacity(0.6),
                              size: 70),
                          const SizedBox(height: 20),
                          Text(
                            'Faça login para ver suas avaliações',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.cinza,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : StreamBuilder<List<Avaliacao>>(
                      stream: Provider.of<AvaliacaoController>(
                        context,
                      ).getAvaliacoesUsuario(usuarioLogado.uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            padding: const EdgeInsets.all(40),
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
                            child: Center(
                              child: CircularProgressIndicator(color: AppColors.roxo),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Container(
                            padding: const EdgeInsets.all(24),
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline,
                                    color: Colors.redAccent, size: 72),
                                const SizedBox(height: 20),
                                Text(
                                  'Erro ao carregar avaliações',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tente novamente mais tarde',
                                  style: TextStyle(
                                    color: AppColors.cinza,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final avaliacoes = snapshot.data ?? [];

                        if (avaliacoes.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(40),
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.swap_horiz,
                                    size: 70,
                                    color: AppColors.cinza.withOpacity(0.4)),
                                const SizedBox(height: 20),
                                Text(
                                  'Nenhuma troca registrada ainda',
                                  style: TextStyle(
                                    color: AppColors.cinza,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Quando você concluir trocas com outros usuários, elas aparecerão aqui.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.cinza.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Column(
                          children: avaliacoes.map((avaliacao) => 
                            _AvaliacaoItem(avaliacao: avaliacao)
                          ).toList(),
                        );
                      },
                    ),
            ],
          ),
        ),
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
      final usuario = await usuarioController
          .buscarUsuarioPorId(widget.avaliacao.usuarioAvaliadorId);
      if (mounted) {
        setState(() {
          _usuarioAvaliador = usuario;
        });
      }
    } catch (e) {}
  }

  String _formatarData(DateTime data) {
    final now = DateTime.now();
    final difference = now.difference(data);
    if (difference.inDays == 0) return 'Hoje';
    if (difference.inDays == 1) return 'Ontem';
    if (difference.inDays < 7) return '${difference.inDays} dias atrás';
    return '${data.day}/${data.month}/${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.roxo.withOpacity(0.15),
                  child: Text(
                    _usuarioAvaliador?.nomeCompleto.isNotEmpty == true
                        ? _usuarioAvaliador!.nomeCompleto[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: AppColors.roxo,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _usuarioAvaliador?.nomeCompleto ?? 'Usuário',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatarData(widget.avaliacao.dataAvaliacao),
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.cinza,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < widget.avaliacao.estrelas
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: AppColors.roxo,
                      size: 20,
                    );
                  }),
                ),
              ],
            ),
            if (widget.avaliacao.comentario.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.fundo,
                  borderRadius: BorderRadius.circular(10),
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