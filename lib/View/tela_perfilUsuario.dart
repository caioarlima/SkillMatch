import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:skilmatch/Controller/colors.dart';
import 'package:skilmatch/Controller/avaliacao_controller.dart';
import 'package:skilmatch/Model/Usuario.dart';
import 'package:skilmatch/Repository/chat_repository.dart';

class TelaPerfilUsuario extends StatefulWidget {
  final Usuario usuario;

  const TelaPerfilUsuario({Key? key, required this.usuario}) : super(key: key);

  @override
  State<TelaPerfilUsuario> createState() => _TelaPerfilUsuarioState();
}

class _TelaPerfilUsuarioState extends State<TelaPerfilUsuario> {
  final AvaliacaoController _avaliacaoController = AvaliacaoController();
  final ChatRepository _chatRepository = ChatRepository();
  double _mediaAvaliacoes = 0.0;
  int _totalTrocas = 0;
  int _totalProjetos = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  Future<void> _carregarDadosUsuario() async {
    try {
      final media = await _avaliacaoController.getMediaAvaliacoes(
        widget.usuario.id!,
      );
      final trocas = await _chatRepository.getTotalTrocasUsuario(
        widget.usuario.id!,
      );

      setState(() {
        _mediaAvaliacoes = media;
        _totalTrocas = trocas;
        _totalProjetos = widget.usuario.projetos.length;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, color: Colors.amber, size: 16),
        SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildUserAvatar(Usuario usuario) {
    if (usuario.fotoUrl != null && usuario.fotoUrl!.isNotEmpty) {
      try {
        final bytes = base64Decode(usuario.fotoUrl!);
        return CircleAvatar(radius: 40, backgroundImage: MemoryImage(bytes));
      } catch (e) {
        print("Erro ao decodificar imagem Base64: $e");
      }
    }

    return CircleAvatar(
      radius: 40,
      backgroundColor: AppColors.white,
      child: Text(
        usuario.nomeCompleto[0].toUpperCase(),
        style: TextStyle(
          color: AppColors.roxo,
          fontSize: 20,
          fontWeight: FontWeight.bold,
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
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: AppColors.cinza),
                ),
                SizedBox(height: 2),
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
        SizedBox(height: 8),
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

  Future<void> _launchURL(String url) async {
    try {
      String cleanedUrl = url.trim();
      
      if (cleanedUrl.isEmpty) {
        _showErrorSnackBar('URL inválida ou vazia');
        return;
      }

      if (!cleanedUrl.startsWith('http://') && !cleanedUrl.startsWith('https://')) {
        cleanedUrl = 'https://$cleanedUrl';
      }

      final uri = Uri.parse(cleanedUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Não foi possível abrir o link');
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao abrir o link');
    }
  }

  void _showErrorSnackBar(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildProjetoCard(Projeto projeto) {
    bool hasValidLink = projeto.link != null && 
                        projeto.link!.isNotEmpty && 
                        (projeto.link!.startsWith('http://') || 
                         projeto.link!.startsWith('https://'));

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              projeto.titulo,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.roxo,
              ),
            ),
            SizedBox(height: 8),
            Text(
              projeto.descricao,
              style: TextStyle(fontSize: 14, color: AppColors.black),
            ),
            SizedBox(height: 8),

            if (projeto.imagemUrl != null && projeto.imagemUrl!.isNotEmpty)
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(projeto.imagemUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            SizedBox(height: 8),

            if (hasValidLink)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.roxo.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.roxo.withOpacity(0.3)),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _launchURL(projeto.link!);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      width: double.infinity,
                      child: Row(
                        children: [
                          Icon(Icons.link, size: 20, color: AppColors.roxo),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ver Projeto Online',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.roxo,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  projeto.link!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.cinza,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.open_in_new, size: 16, color: AppColors.roxo),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else if (projeto.link != null && projeto.link!.isNotEmpty)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, size: 20, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Link inválido ou formato incorreto',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _mostrarProjetos() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Projetos de ${widget.usuario.nomeCompleto}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.roxo,
                ),
              ),
              const SizedBox(height: 16),

              if (widget.usuario.projetos.isNotEmpty) ...[
                Container(
                  height: 400,
                  width: 400,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.usuario.projetos.length,
                    itemBuilder: (context, index) {
                      return _buildProjetoCard(widget.usuario.projetos[index]);
                    },
                  ),
                ),
              ] else ...[
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.work_outline,
                        size: 64,
                        color: AppColors.cinza,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Nenhum projeto cadastrado',
                        style: TextStyle(color: AppColors.cinza),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 120,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.roxo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Fechar',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        backgroundColor: AppColors.roxo,
        foregroundColor: AppColors.white,
        title: Text('Perfil'),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.roxo,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        _buildUserAvatar(widget.usuario),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.usuario.nomeCompleto,
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                widget.usuario.cidade,
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              _buildStarRating(_mediaAvaliacoes),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: _mostrarProjetos,
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
                  ),

                  SizedBox(height: 24),

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
                          SizedBox(height: 12),
                          _buildInfoItem(
                            icon: Icons.person_outline,
                            label: 'Nome Completo',
                            value: widget.usuario.nomeCompleto,
                          ),
                          _buildInfoItem(
                            icon: Icons.email_outlined,
                            label: 'E-mail',
                            value: widget.usuario.email,
                          ),
                          _buildInfoItem(
                            icon: Icons.transgender,
                            label: 'Gênero',
                            value: widget.usuario.genero ?? 'Não informado',
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

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
                          SizedBox(height: 12),
                          _buildInfoItem(
                            icon: Icons.location_on_outlined,
                            label: 'Cidade',
                            value: widget.usuario.cidade,
                          ),
                          _buildInfoItem(
                            icon: Icons.description_outlined,
                            label: 'Bio',
                            value: widget.usuario.bio,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}