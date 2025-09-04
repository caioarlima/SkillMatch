import 'package:flutter/material.dart';
import 'package:skilmatch/Controller/colors.dart';
import 'package:skilmatch/View/tela_MinhasTrocas.dart';
import 'package:skilmatch/View/tela_ProcurarTrocas.dart';
import 'package:skilmatch/View/tela_mensagens.dart';

class TelaPerfil extends StatefulWidget {
  const TelaPerfil({super.key});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  int _currentIndex = 3; // Perfil é o último item

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TelaPrincipal()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TelaMinhastrocas()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TelaMensagens()),
      );
    } else if (index == 3) {
      // já está na tela Perfil
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        title: const Text("Perfil"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.fundo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dados do usuário
            ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.white,
                child: const Icon(Icons.person, size: 40, color: Colors.black),
              ),
              title: const Text(
                "Neymar Jr",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: const Text("Pintor"),
            ),
            const Divider(thickness: 2, color: Colors.purple),

            // Card: Dados da conta
            _buildOptionCard(
              icon: Icons.description_outlined,
              title: "Dados da Conta",
              subtitle: "Minhas Informações de Conta",
              onTap: () {},
            ),
            const Divider(thickness: 2, color: Colors.purple),

            // Card: Configurações
            _buildOptionCard(
              icon: Icons.settings,
              title: "Configurações",
              onTap: () {},
            ),
            const Divider(thickness: 2, color: Colors.purple),

            // Card: Minhas Avaliações
            _buildOptionCard(
              icon: Icons.star,
              title: "Minhas Avaliações",
              onTap: () {},
            ),
            const Divider(thickness: 2, color: Colors.purple),
          ],
        ),
      ),

      // Barra de navegação inferior
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Procurar Trocas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Minhas Trocas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Mensagens',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 28, color: AppColors.black),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      onTap: onTap,
    );
  }
}
