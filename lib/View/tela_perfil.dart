import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skilmatch/Controller/colors.dart';
import 'package:skilmatch/Controller/usuario_controller.dart';
import 'package:skilmatch/Model/usuario.dart';
import 'package:skilmatch/View/tela_configuracoes.dart';

class TelaPerfil extends StatefulWidget {
  const TelaPerfil({super.key});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  final UsuarioController _usuarioController = UsuarioController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Usuario? _usuario;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  String _getCurrentUserId() {
    return _auth.currentUser!.uid;
  }

  Future<void> _carregarUsuario() async {
    try {
      final usuario = await _usuarioController.buscarUsuarioPorId(_getCurrentUserId());
      print('DEBUG - Usuário carregado: ${usuario?.toMap()}'); // DEBUG
      setState(() {
        _usuario = usuario;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar usuário: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatarDataNascimento(DateTime? data) {
    if (data == null) return 'Não informado';
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
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
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
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
                  // Header do perfil
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  
                  // Card de informações pessoais
                  _buildInfoCard(
                    title: 'Informações Pessoais',
                    children: [
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
                        value: _formatarDataNascimento(_usuario?.dataNascimento),
                      ),
                      _buildInfoItem(
                        icon: Icons.transgender,
                        label: 'Gênero',
                        value: _usuario?.genero ?? 'Não informado',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Card de informações profissionais
                  _buildInfoCard(
                    title: 'Informações Profissionais',
                    children: [
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
                  const SizedBox(height: 16),
                  
                  // Card de estatísticas
                  _buildStatsCard(),
                  const SizedBox(height: 16),
                  
                  // Botão de editar
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.roxo,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        // Navegar para tela de edição
                      },
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

  Widget _buildProfileHeader() {
    return Container(
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
          // Avatar do usuário - VERSÃO SIMPLIFICADA
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              backgroundColor: AppColors.white,
              child: Icon(Icons.person, size: 40, color: AppColors.cinza),
            ),
          ),
          const SizedBox(width: 16),
          
          // Informações do usuário
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
                
                // Rating
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      "4.8",
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Material(
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
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.roxo,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
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
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.cinza,
                  ),
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

  Widget _buildStatsCard() {
    return Material(
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
            _buildStatItem('24', 'Trocas', Icons.swap_horiz),
            _buildStatItem('12', 'Projetos', Icons.work),
          ],
        ),
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