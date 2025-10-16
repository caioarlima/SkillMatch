import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skilmatch/Controller/colors.dart';
import 'package:skilmatch/Controller/usuario_controller.dart';
import 'package:skilmatch/Controller/avaliacao_controller.dart';
import 'package:skilmatch/Model/Usuario.dart';
import 'package:skilmatch/View/tela_configuracoes.dart';
import 'package:skilmatch/Repository/chat_repository.dart'; // ADICIONAR IMPORT

class TelaPerfil extends StatefulWidget {
  const TelaPerfil({super.key});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  final UsuarioController _usuarioController = UsuarioController();
  final AvaliacaoController _avaliacaoController = AvaliacaoController();
  final ChatRepository _chatRepository = ChatRepository(); // ADICIONAR AQUI
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Usuario? _usuario;
  bool _isLoading = true;
  double _mediaAvaliacoes = 0.0;
  int _totalTrocas = 0;
  int _totalProjetos = 0;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  String _getCurrentUserId() {
    return _auth.currentUser!.uid;
  }

  Future<void> _carregarDadosUsuario() async {
    try {
      final usuario = await _usuarioController.buscarUsuarioPorId(
        _getCurrentUserId(),
      );

      final media = await _avaliacaoController.getMediaAvaliacoes(
        _getCurrentUserId(),
      );

      final trocas = await _carregarTotalTrocas();
      final projetos = await _carregarTotalProjetos();

      print('🔄 Total de trocas carregadas: $trocas');

      setState(() {
        _usuario = usuario;
        _mediaAvaliacoes = media;
        _totalTrocas = trocas;
        _totalProjetos = projetos;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<int> _carregarTotalTrocas() async {
    try {
      return await _chatRepository.getTotalTrocasUsuario(_getCurrentUserId());
    } catch (e) {
      print('Erro ao carregar total de trocas: $e');
      return 0;
    }
  }

  Future<int> _carregarTotalProjetos() async {
    try {
      return 0;
    } catch (e) {
      print('Erro ao carregar total de projetos: $e');
      return 0;
    }
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star, color: Colors.amber, size: 16),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          "${_getTotalAvaliacoes()}",
          style: TextStyle(
            color: AppColors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _getTotalAvaliacoes() {
    if (_mediaAvaliacoes == 0.0) return "0";
    return "";
  }

  String _formatarDataNascimento(DateTime? data) {
    if (data == null) return 'Não informado';
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  Widget _buildProfileAvatar() {
    if (_usuario?.fotoUrl != null && _usuario!.fotoUrl!.isNotEmpty) {
      try {
        final bytes = base64Decode(_usuario!.fotoUrl!);
        return CircleAvatar(radius: 40, backgroundImage: MemoryImage(bytes));
      } catch (e) {
        print("Erro ao decodificar imagem Base64: $e");
      }
    }

    return CircleAvatar(
      radius: 40,
      backgroundColor: AppColors.white,
      child: Icon(Icons.person, size: 40, color: AppColors.cinza),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        backgroundColor: AppColors.roxo,
        foregroundColor: AppColors.white,
        title: Text(
          'Perfil',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: AppColors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TelaConfiguracoes(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.roxo,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.roxo.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _buildProfileAvatar(),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _usuario?.nomeCompleto ?? "Não informado",
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _usuario?.cidade ?? "Não informado",
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildStarRating(_mediaAvaliacoes),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informações Pessoais',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.roxo,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoItem(
                            icon: Icons.person_outline,
                            label: 'Nome Completo',
                            value: _usuario?.nomeCompleto ?? 'Não informado',
                          ),
                          _buildInfoItem(
                            icon: Icons.email_outlined,
                            label: 'E-mail',
                            value: _usuario?.email ?? 'Não informado',
                          ),
                          _buildInfoItem(
                            icon: Icons.credit_card_outlined,
                            label: 'CPF',
                            value: _usuario?.cpf ?? 'Não informado',
                          ),
                          _buildInfoItem(
                            icon: Icons.cake_outlined,
                            label: 'Data de Nascimento',
                            value: _formatarDataNascimento(
                              _usuario?.dataNascimento,
                            ),
                          ),
                          _buildInfoItem(
                            icon: Icons.transgender,
                            label: 'Gênero',
                            value: _usuario?.genero ?? 'Não informado',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informações Profissionais',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.roxo,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoItem(
                            icon: Icons.location_on_outlined,
                            label: 'Cidade',
                            value: _usuario?.cidade ?? 'Não informado',
                          ),
                          _buildInfoItem(
                            icon: Icons.description_outlined,
                            label: 'Bio',
                            value: _usuario?.bio ?? 'Não informado',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.roxo,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            _totalTrocas.toString(),
                            'Trocas',
                            Icons.swap_horiz,
                          ),
                          _buildStatItem(
                            _totalProjetos.toString(),
                            'Projetos',
                            Icons.work,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.roxo,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Editar Perfil',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.roxo.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: AppColors.roxo),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: AppColors.cinza),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: AppColors.white),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
