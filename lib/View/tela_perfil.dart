import 'package:flutter/material.dart';
import 'package:skilmatch/Controller/colors.dart';
import 'package:skilmatch/View/tela_MinhasTrocas.dart';
import 'package:skilmatch/View/tela_ProcurarTrocas.dart';
import 'package:skilmatch/View/tela_mensagens.dart';
import 'package:skilmatch/View/tela_DadosDaConta.dart';
import 'package:skilmatch/View/tela_configuracoes.dart'; // 🔹 importa a tela de configurações

class TelaPerfil extends StatefulWidget {
  const TelaPerfil({super.key});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  int _currentIndex = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TelaDadosConta(),
                  ),
                );
              },
            ),
            const Divider(thickness: 2, color: Colors.purple),

            // Card: Configurações
            _buildOptionCard(
              icon: Icons.settings,
              title: "Configurações",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TelaConfiguracoes(),
                  ),
                );
              },
            ),
            const Divider(thickness: 2, color: Colors.purple),

            // Card: Minhas Avaliações
            _buildOptionCard(
              icon: Icons.star,
              title: "Minhas Avaliações",
              onTap: () {
                // Aqui futuramente pode ir para uma tela de avaliações
              },
            ),
            const Divider(thickness: 2, color: Colors.purple),
          ],
        ),
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
