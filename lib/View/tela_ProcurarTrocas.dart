import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skilmatch/Controller/usuario_controller.dart';
import 'package:skilmatch/Controller/chat_controller.dart';
import 'package:skilmatch/Controller/colors.dart';
import 'package:skilmatch/View/tela_MinhasTrocas.dart';
import 'package:skilmatch/View/tela_perfil.dart';
import 'package:skilmatch/View/tela_mensagens.dart';
import 'package:skilmatch/View/tela_chat.dart';
import 'package:skilmatch/View/tela_perfilUsuario.dart';

class TelaProcuraTrocas extends StatefulWidget {
  const TelaProcuraTrocas({super.key});

  @override
  _TelaProcuraTrocasState createState() => _TelaProcuraTrocasState();
}

class _TelaProcuraTrocasState extends State<TelaProcuraTrocas> {
  final TextEditingController _controladorBuscarHabilidades = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _searchQuery = "";
  String? _currentUserId;
  String? _currentUserCity;
  int _currentIndex = 0;

  final List<Widget> _telas = [
    const SizedBox.shrink(),
    const TelaMinhasTrocas(),
    const SizedBox.shrink(),
    const TelaMensagens(),
    const TelaPerfil(),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  @override
  void dispose() {
    _controladorBuscarHabilidades.dispose();
    super.dispose();
  }

  void _getCurrentUser() {
    final User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
      });
      _carregarDadosUsuarioAtual();
    }
  }

  Future<void> _carregarDadosUsuarioAtual() async {
    if (_currentUserId == null) return;

    try {
      final usuarioController = Provider.of<UsuarioController>(context, listen: false);
      final usuario = await usuarioController.buscarUsuarioPorId(_currentUserId!);
      if (usuario != null && mounted) {
        setState(() {
          _currentUserCity = usuario.cidade;
        });
        // CORREÇÃO: Garantir que o usuário atual seja excluído
        usuarioController.carregarUsuariosPorCidade(
          _currentUserCity!,
          excludeUserId: _currentUserId,
        );
      }
    } catch (e) {
      print("Erro ao carregar dados do usuário: $e");
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });

    final usuarioController = Provider.of<UsuarioController>(context, listen: false);
    // CORREÇÃO: Sempre excluir o usuário atual das buscas
    usuarioController.realizarBusca(value, _currentUserCity, excludedUserId: _currentUserId);
  }

  // CORREÇÃO: Método para filtrar usuários excluindo o usuário atual
  List<dynamic> _filtrarUsuariosExcluindoAtual(List<dynamic> usuarios) {
    if (_currentUserId == null) return usuarios;
    
    return usuarios.where((usuario) => usuario.id != _currentUserId).toList();
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (index != 2) {
              setState(() {
                _currentIndex = index;
              });
            }
          },
          child: Container(
            height: 70,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _currentIndex == index ? AppColors.roxo.withOpacity(0.1) : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: _currentIndex == index ? AppColors.roxo : AppColors.cinza,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: _currentIndex == index ? AppColors.roxo : AppColors.cinza,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageItem() {
    return Expanded(
      child: Container(
        height: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 36, 185, 16).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Image.asset("assets/images/emoji_skillmatch.png"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex != 0) {
      return Scaffold(
        backgroundColor: AppColors.fundo,
        body: SafeArea(
          child: _telas[_currentIndex],
        ),
        bottomNavigationBar: Container(
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildNavItem(Icons.search, 'Procurar', 0),
              _buildNavItem(Icons.swap_horiz, 'Trocas', 1),
              _buildImageItem(),
              _buildNavItem(Icons.chat_bubble_outline, 'Mensagens', 3),
              _buildNavItem(Icons.person_outline, 'Perfil', 4),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.fundo,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                "Encontre Trocas",
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
                "Conecte-se com pessoas próximas para trocar habilidades",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.cinza,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Container(
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
                child: TextField(
                  controller: _controladorBuscarHabilidades,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: "Buscar por nome, bio ou cidade...",
                    hintStyle: TextStyle(color: AppColors.cinza.withOpacity(0.7)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    prefixIcon: Container(
                      margin: const EdgeInsets.only(left: 8, right: 4),
                      child: Icon(Icons.search, color: AppColors.roxo, size: 24),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: AppColors.cinza, size: 20),
                            onPressed: () {
                              _controladorBuscarHabilidades.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                  ),
                  style: TextStyle(color: AppColors.black, fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),
              Consumer<UsuarioController>(
                builder: (context, usuarioController, child) {
                  // CORREÇÃO: Filtrar usuários excluindo o atual
                  final usuariosFiltrados = _filtrarUsuariosExcluindoAtual(usuarioController.usuarios);

                  if (usuarioController.isLoading) {
                    return Container(
                      margin: const EdgeInsets.only(top: 60),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.roxo,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  }

                  if (usuarioController.errorMessage != null) {
                    return Container(
                      margin: const EdgeInsets.only(top: 60),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.error_outline, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              usuarioController.errorMessage!,
                              style: TextStyle(color: Colors.red, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // CORREÇÃO: Usar a lista filtrada para as verificações
                  if (!usuarioController.isLoading && usuariosFiltrados.isEmpty && _searchQuery.isEmpty) {
                    return Container(
                      margin: const EdgeInsets.only(top: 60),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 80,
                              color: AppColors.cinza.withOpacity(0.4),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Nenhum usuário na sua cidade",
                              style: TextStyle(
                                color: AppColors.cinza,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Quando aparecerem usuários próximos,\neles serão exibidos aqui",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.cinza.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // CORREÇÃO: Usar a lista filtrada para as verificações
                  if (!usuarioController.isLoading && usuariosFiltrados.isEmpty && _searchQuery.isNotEmpty) {
                    return Container(
                      margin: const EdgeInsets.only(top: 60),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: AppColors.cinza.withOpacity(0.4),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Nenhum usuário encontrado",
                              style: TextStyle(
                                color: AppColors.cinza,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Tente ajustar os termos da busca",
                              style: TextStyle(
                                color: AppColors.cinza.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // CORREÇÃO: Usar a lista filtrada para exibir os usuários
                  if (!usuarioController.isLoading && usuariosFiltrados.isNotEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _searchQuery.isEmpty ? "🔥 Recomendados perto de você" : "🔍 Resultados da busca",
                          style: TextStyle(
                            color: AppColors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Column(
                          children: usuariosFiltrados
                              .map((usuario) => _buildUserCard(usuario))
                              .toList(),
                        ),
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildNavItem(Icons.search, 'Procurar', 0),
            _buildNavItem(Icons.swap_horiz, 'Trocas', 1),
            _buildImageItem(),
            _buildNavItem(Icons.chat_bubble_outline, 'Mensagens', 3),
            _buildNavItem(Icons.person_outline, 'Perfil', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(dynamic usuario) {
    // CORREÇÃO: Verificação adicional de segurança
    if (usuario.id == _currentUserId) {
      return const SizedBox.shrink(); // Não renderiza o próprio usuário
    }

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TelaPerfilUsuario(usuario: usuario),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.roxo.withOpacity(0.1),
                  ),
                  child: _buildUserAvatar(usuario),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        usuario.nomeCompleto,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: AppColors.cinza),
                          const SizedBox(width: 4),
                          Text(
                            usuario.cidade,
                            style: TextStyle(fontSize: 14, color: AppColors.cinza),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        usuario.bio,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.black.withOpacity(0.8),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Consumer<ChatController>(
                      builder: (context, chatController, child) {
                        return ElevatedButton(
                          onPressed: () async {
                            if (_currentUserId == null) return;
                            
                            final chatId = chatController.gerarChatId(_currentUserId!, usuario.id!);
                            
                            await chatController.verificarECriarChat(
                              chatId: chatId,
                              user1Id: _currentUserId!,
                              user2Id: usuario.id!,
                              user1Nome: 'Seu Nome', // CORREÇÃO: Você deve pegar o nome do usuário atual
                              user2Nome: usuario.nomeCompleto,
                              user1Foto: null,
                              user2Foto: usuario.fotoUrl,
                            );
                            
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TelaChat(
                                  outroUsuario: usuario.id!,
                                  chatId: chatId,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.roxo,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            elevation: 0,
                          ),
                          child: Text(
                            "Propor Troca",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(dynamic usuario) {
    if (usuario.fotoUrl != null && usuario.fotoUrl!.isNotEmpty) {
      try {
        final bytes = base64Decode(usuario.fotoUrl!);
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(bytes, width: 60, height: 60, fit: BoxFit.cover),
        );
      } catch (e) {
        print("Erro ao decodificar imagem Base64: $e");
      }
    }

    return Center(
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
}