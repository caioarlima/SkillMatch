import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skilmatch/Controller/usuario_controller.dart';
import 'package:skilmatch/Controller/colors.dart';
import 'package:skilmatch/View/tela_MinhasTrocas.dart';
import 'package:skilmatch/View/tela_perfil.dart';
import 'package:skilmatch/View/tela_mensagens.dart';
import 'package:skilmatch/View/tela_chat.dart';

class TelaProcuraTrocas extends StatefulWidget {
  const TelaProcuraTrocas({super.key});

  @override
  _TelaProcuraTrocasState createState() => _TelaProcuraTrocasState();
}

class _TelaProcuraTrocasState extends State<TelaProcuraTrocas> {
  final TextEditingController _controladorBuscarHabilidades =
      TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _searchQuery = '';
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
      final usuarioController = Provider.of<UsuarioController>(
        context,
        listen: false,
      );
      final usuario = await usuarioController.buscarUsuarioPorId(
        _currentUserId!,
      );

      if (usuario != null && mounted) {
        setState(() {
          _currentUserCity = usuario.cidade;
        });
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

    final usuarioController = Provider.of<UsuarioController>(
      context,
      listen: false,
    );
    usuarioController.realizarBusca(
      value,
      _currentUserCity,
      excludeUserId: _currentUserId,
    );
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
                Icon(
                  icon,
                  size: 30,
                  color: _currentIndex == index
                      ? AppColors.roxo
                      : AppColors.black.withOpacity(0.6),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: _currentIndex == index
                        ? AppColors.roxo
                        : AppColors.black.withOpacity(0.6),
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: Center(
                child: Image.asset("assets/images/emoji_skillmatch.png"),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  String _generateChatId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return "chat_${sortedIds[0]}_${sortedIds[1]}";
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex != 0) {
      return Scaffold(
        backgroundColor: AppColors.fundo,
        body: _telas[_currentIndex],
        bottomNavigationBar: Container(
          height: 70,
          decoration: BoxDecoration(
            color: AppColors.fundo,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildNavItem(Icons.search, 'Procurar Trocas', 0),
              _buildNavItem(Icons.swap_horiz, 'Minhas Trocas', 1),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 30),
            Text(
              "Procurar Trocas",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.black,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _controladorBuscarHabilidades,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: "Buscar por nome, bio ou cidade",
                  hintStyle: TextStyle(color: AppColors.cinza),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 16.0,
                  ),
                  prefixIcon: Icon(Icons.search, color: AppColors.roxo),
                ),
                keyboardType: TextInputType.text,
              ),
            ),
            const SizedBox(height: 24),
            Consumer<UsuarioController>(
              builder: (context, usuarioController, child) {
                if (usuarioController.isLoading) {
                  return Center(
                    child: CircularProgressIndicator(color: AppColors.roxo),
                  );
                }

                if (usuarioController.errorMessage != null) {
                  return Center(
                    child: Text(
                      usuarioController.errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (!usuarioController.isLoading &&
                    usuarioController.usuarios.isEmpty &&
                    _searchQuery.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: AppColors.cinza.withOpacity(0.5),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Nenhum usuário na sua cidade",
                          style: TextStyle(
                            color: AppColors.cinza,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (!usuarioController.isLoading &&
                    usuarioController.usuarios.isEmpty &&
                    _searchQuery.isNotEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppColors.cinza.withOpacity(0.5),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Nenhum usuário encontrado",
                          style: TextStyle(
                            color: AppColors.cinza,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (!usuarioController.isLoading &&
                    usuarioController.usuarios.isNotEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _searchQuery.isEmpty
                            ? "Recomendados - Perto de você!"
                            : "Resultados da busca",
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: usuarioController.usuarios
                            .map((usuario) => _buildUserCard(usuario: usuario))
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
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.fundo,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildNavItem(Icons.search, 'Procurar Trocas', 0),
            _buildNavItem(Icons.swap_horiz, 'Minhas Trocas', 1),
            _buildImageItem(),
            _buildNavItem(Icons.chat_bubble_outline, 'Mensagens', 3),
            _buildNavItem(Icons.person_outline, 'Perfil', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard({required dynamic usuario}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.roxo,
                borderRadius: BorderRadius.circular(12),
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
                    ),
                  ),
                  const SizedBox(height: 4),
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
                      color: AppColors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    final chatId = _generateChatId(
                      _currentUserId!,
                      usuario.id!,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TelaChat(outroUsuario: usuario.id!, chatId: chatId),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.roxo,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(
                    "Propor Troca",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
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
          color: AppColors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
