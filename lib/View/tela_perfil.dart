import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skilmatch/Controller/colors.dart';
import 'package:skilmatch/Controller/usuario_controller.dart';
import 'package:skilmatch/Controller/avaliacao_controller.dart';
import 'package:skilmatch/Model/Usuario.dart';
import 'package:skilmatch/View/tela_configuracoes.dart';
import 'package:skilmatch/Repository/chat_repository.dart';
import 'package:skilmatch/Services/validadores.dart';

class TelaPerfil extends StatefulWidget {
  const TelaPerfil({super.key});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  final UsuarioController _usuarioController = UsuarioController();
  final AvaliacaoController _avaliacaoController = AvaliacaoController();
  final ChatRepository _chatRepository = ChatRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Usuario? _usuario;
  bool _isLoading = true;
  double _mediaAvaliacoes = 0.0;
  int _totalTrocas = 0;
  int _totalProjetos = 0;
  bool _editando = false;

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _dataNascimentoController =
      TextEditingController();
  final TextEditingController _generoController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

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
      final projetos = usuario?.projetos.length ?? 0;

      setState(() {
        _usuario = usuario;
        _mediaAvaliacoes = media;
        _totalTrocas = trocas;
        _totalProjetos = projetos;
        _isLoading = false;
      });
      _preencherControladores();
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _preencherControladores() {
    if (_usuario != null) {
      _nomeController.text = _usuario!.nomeCompleto;
      _emailController.text = _usuario!.email;
      _cpfController.text = Validators.formatarCPF(_usuario!.cpf);
      _cidadeController.text = _usuario!.cidade;
      _bioController.text = _usuario!.bio;
      _generoController.text = _usuario!.genero ?? '';

      if (_usuario!.dataNascimento != null) {
        _dataNascimentoController.text =
            '${_usuario!.dataNascimento!.day.toString().padLeft(2, '0')}/'
            '${_usuario!.dataNascimento!.month.toString().padLeft(2, '0')}/'
            '${_usuario!.dataNascimento!.year}';
      }
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

  void _alternarEdicao() {
    setState(() {
      _editando = !_editando;
    });
  }

  Future<void> _salvarAlteracoes() async {
    try {
      if (_usuario == null) return;

      final usuarioAtualizado = _usuario!.copyWith(
        email: _emailController.text,
        cidade: _cidadeController.text,
        bio: _bioController.text,
        genero: _generoController.text.isEmpty ? null : _generoController.text,
      );

      await _usuarioController.atualizarUsuario(usuarioAtualizado);

      setState(() {
        _usuario = usuarioAtualizado;
        _editando = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Perfil atualizado com sucesso!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao atualizar perfil: $e')));
    }
  }

  void _mostrarDialogProjetos() {
    showDialog(
      context: context,
      builder: (context) => DialogProjetos(
        usuario: _usuario!,
        usuarioController: _usuarioController,
        onProjetoAdicionado: () {
          _carregarDadosUsuario();
        },
      ),
    );
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
            color: AppColors.black,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
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
      backgroundColor: AppColors.roxo.withOpacity(0.1),
      child: Icon(Icons.person, size: 40, color: AppColors.roxo),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.settings, color: AppColors.roxo),
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
                    Text(
                      "Meu Perfil",
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
                      "Gerencie suas informações e projetos",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.cinza,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(20),
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
                                  style: TextStyle(
                                    color: AppColors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _editando
                                    ? TextField(
                                        controller: _cidadeController,
                                        style: TextStyle(
                                          color: AppColors.cinza,
                                          fontSize: 16,
                                        ),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          border: InputBorder.none,
                                          hintText: 'Cidade',
                                          hintStyle: TextStyle(
                                            color: AppColors.cinza,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        _usuario?.cidade ?? "Não informado",
                                        style: TextStyle(
                                          color: AppColors.cinza,
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
                              editavel: false,
                              controller: _nomeController,
                            ),
                            _buildInfoItem(
                              icon: Icons.email_outlined,
                              label: 'E-mail',
                              value: _usuario?.email ?? 'Não informado',
                              editavel: true,
                              controller: _emailController,
                            ),
                            _buildInfoItem(
                              icon: Icons.credit_card_outlined,
                              label: 'CPF',
                              value: _usuario?.cpf != null
                                  ? Validators.formatarCPF(_usuario!.cpf)
                                  : 'Não informado',
                              editavel: false,
                              controller: _cpfController,
                            ),
                            _buildInfoItem(
                              icon: Icons.cake_outlined,
                              label: 'Data de Nascimento',
                              value: _usuario?.dataNascimento != null
                                  ? '${_usuario!.dataNascimento!.day.toString().padLeft(2, '0')}/${_usuario!.dataNascimento!.month.toString().padLeft(2, '0')}/${_usuario!.dataNascimento!.year}'
                                  : 'Não informado',
                              editavel: false,
                              controller: _dataNascimentoController,
                            ),
                            _buildInfoItem(
                              icon: Icons.transgender,
                              label: 'Gênero',
                              value: _usuario?.genero ?? 'Não informado',
                              editavel: true,
                              controller: _generoController,
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
                              editavel: true,
                              controller: _cidadeController,
                            ),
                            _buildInfoItem(
                              icon: Icons.description_outlined,
                              label: 'Bio',
                              value: _usuario?.bio ?? 'Não informado',
                              editavel: true,
                              controller: _bioController,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: _mostrarDialogProjetos,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.white,
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

                    const SizedBox(height: 16),

                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.roxo,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: _editando
                            ? _salvarAlteracoes
                            : _alternarEdicao,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _editando ? 'Salvar' : 'Editar Perfil',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    if (_editando) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.cinza,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _editando = false;
                              _preencherControladores();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    bool editavel = false,
    TextEditingController? controller,
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
                editavel && _editando
                    ? Container(
                        decoration: BoxDecoration(
                          color: AppColors.fundo,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.roxo),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.all(8),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.black,
                          ),
                        ),
                      )
                    : Text(
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
            color: AppColors.roxo.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: AppColors.roxo),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: AppColors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: TextStyle(color: AppColors.cinza, fontSize: 12)),
      ],
    );
  }
}

class DialogProjetos extends StatefulWidget {
  final Usuario usuario;
  final UsuarioController usuarioController;
  final VoidCallback onProjetoAdicionado;

  const DialogProjetos({
    Key? key,
    required this.usuario,
    required this.usuarioController,
    required this.onProjetoAdicionado,
  }) : super(key: key);

  @override
  State<DialogProjetos> createState() => _DialogProjetosState();
}

class _DialogProjetosState extends State<DialogProjetos> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _imagemController = TextEditingController();

  void _adicionarProjeto() {
    if (_tituloController.text.isEmpty || _descricaoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Título e descrição são obrigatórios'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String? linkFormatado;
    if (_linkController.text.isNotEmpty) {
      String link = _linkController.text.trim();
      linkFormatado = link;
    }

    final novoProjeto = Projeto(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: _tituloController.text,
      descricao: _descricaoController.text,
      link: linkFormatado,
      imagemUrl: _imagemController.text.isNotEmpty
          ? _imagemController.text
          : null,
      dataCriacao: DateTime.now(),
    );

    widget.usuarioController.adicionarProjeto(widget.usuario.id!, novoProjeto);
    widget.onProjetoAdicionado();
    _tituloController.clear();
    _descricaoController.clear();
    _linkController.clear();
    _imagemController.clear();
    Navigator.pop(context);
  }

  void _removerProjeto(String projetoId) {
    widget.usuarioController.removerProjeto(widget.usuario.id!, projetoId);
    widget.onProjetoAdicionado();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Meus Projetos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.roxo,
                ),
              ),
              const SizedBox(height: 16),
              if (widget.usuario.projetos.isNotEmpty) ...[
                Text(
                  'Projetos existentes:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ...widget.usuario.projetos.map(
                  (projeto) => Card(
                    child: ListTile(
                      title: Text(
                        projeto.titulo,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      subtitle: Text(
                        projeto.descricao,
                        style: TextStyle(color: AppColors.cinza),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removerProjeto(projeto.id),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                'Adicionar novo projeto:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Título do projeto',
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _tituloController,
                decoration: InputDecoration(
                  hintText: 'Digite o título do projeto',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Descrição',
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _descricaoController,
                decoration: InputDecoration(
                  hintText: 'Descreva seu projeto',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Text(
                'URL da imagem (opcional)',
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _imagemController,
                decoration: InputDecoration(
                  hintText: 'https://exemplo.com/imagem.jpg',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Link do projeto (opcional)',
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _linkController,
                decoration: InputDecoration(
                  hintText: 'https://exemplo.com',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(color: AppColors.cinza, fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _adicionarProjeto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.roxo,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'Adicionar Projeto',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _linkController.dispose();
    _imagemController.dispose();
    super.dispose();
  }
}