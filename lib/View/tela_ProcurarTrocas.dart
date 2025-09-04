import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skilmatch/Controller/colors.dart';
import 'package:skilmatch/View/tela_MinhasTrocas.dart';
import 'package:skilmatch/View/tela_perfil.dart';
import 'package:skilmatch/View/tela_mensagens.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _currentIndex = 0;

  final List<Widget> _telas = [
    TelaProcuraTrocas(),
    const TelaMinhastrocas(),
    const SizedBox.shrink(),
    const TelaMensagens(),
    const TelaPerfil(),
  ];

  @override
  Widget build(BuildContext context) {
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

  Widget _buildNavItem(IconData icon, String label, int index) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _currentIndex = index;
            });
          },
          child: Container(
            height: 70,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 30,
                  color: _currentIndex == index ? AppColors.roxo : AppColors.black.withOpacity(0.6),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: _currentIndex == index ? AppColors.roxo : AppColors.black.withOpacity(0.6),
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
            Image.asset(
              'assets/images/emoji_skillmatch.png',
              width: 40,
              height: 40,
            ),
            const SizedBox(height: 4),
            const Text(
              '',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class TelaProcuraTrocas extends StatefulWidget {
  @override
  _TelaProcuraTrocasState createState() => _TelaProcuraTrocasState();
}

class _TelaProcuraTrocasState extends State<TelaProcuraTrocas> {
  final TextEditingController _controladorBuscarHabilidades = TextEditingController();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _searchQuery = '';
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  bool _noUsersFound = false;
  String? _currentUserId;

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
      if (mounted) {
        setState(() {
          _currentUserId = user.uid;
        });
      } else {
        _currentUserId = user.uid;
      }
    }
    _carregarUsuarios();
  }

  Future<void> _carregarUsuarios() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _noUsersFound = false;
    });

    try {
      DatabaseReference ref = _database.child('usuarios');
      DatabaseEvent event = await ref.once();
      
      DataSnapshot snapshot = event.snapshot;
      
      if (snapshot.value != null) {
        Map<dynamic, dynamic> usersMap = snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> allUsers = [];
        
        usersMap.forEach((key, value) {
          if (_currentUserId != null && key.toString() == _currentUserId) {
            return;
          }
          
          Map<String, dynamic> userData = {};
          (value as Map<Object?, Object?>).forEach((k, v) {
            userData[k.toString()] = v;
          });
          
          allUsers.add({
            'id': key.toString(),
            ...userData
          });
        });

        List<Map<String, dynamic>> filteredUsers;
        if (_searchQuery.isEmpty) {
          filteredUsers = allUsers;
        } else {
          filteredUsers = allUsers.where((user) {
            final String nome = user['nomeCompleto']?.toString().toLowerCase() ?? '';
            final String bio = user['bio']?.toString().toLowerCase() ?? '';
            final String cidade = user['cidade']?.toString().toLowerCase() ?? '';
            
            return nome.contains(_searchQuery.toLowerCase()) || 
                   bio.contains(_searchQuery.toLowerCase()) ||
                   cidade.contains(_searchQuery.toLowerCase());
          }).toList();
        }

        if (mounted) {
          setState(() {
            _users = filteredUsers;
            _noUsersFound = filteredUsers.isEmpty && _searchQuery.isNotEmpty;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _users = [];
            _noUsersFound = true;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _noUsersFound = true;
        });
      }
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
    _carregarUsuarios();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _controladorBuscarHabilidades,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: "Buscar por nome, bio ou cidade",
              hintStyle: TextStyle(color: AppColors.cinza),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50.0),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              prefixIcon: const Icon(Icons.search),
            ),
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 20),
          
          if (_isLoading)
            Center(child: CircularProgressIndicator(color: AppColors.roxo)),
          
          if (_noUsersFound)
            Center(
              child: Text(
                "Nenhum usuário encontrado",
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 16,
                ),
              ),
            ),
          
          if (!_isLoading && !_noUsersFound && _users.isNotEmpty)
            Text(
              _searchQuery.isEmpty ? "Todos os usuários" : "Resultados da busca",
              style: TextStyle(
                color: AppColors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          
          const SizedBox(height: 10),
          
          if (!_isLoading)
            Column(
              children: _users.map((user) => _buildUserCard(
                name: user['nomeCompleto']?.toString() ?? 'Nome não informado',
                location: user['cidade']?.toString() ?? 'Cidade não informada',
                skill: user['bio']?.toString() ?? 'Bio não informada',
                userId: user['id'] ?? '',
              )).toList(),
            ),

          if (!_isLoading && _searchQuery.isEmpty && _users.isEmpty)
            Center(
              child: Text(
                "Nenhum usuário cadastrado",
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserCard({
    required String name,
    required String location,
    required String skill,
    required String userId,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(location),
                  const SizedBox(height: 4),
                  Text(
                    skill,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.cinza,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(child: Text("Foto")),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.roxo,
                    foregroundColor: AppColors.white,
                  ),
                  child: const Text("Propor Troca"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}