import 'package:flutter/material.dart';
import 'package:skilmatch/Controller/colors.dart';
import 'package:skilmatch/View/tela_MinhasTrocas.dart';
import 'package:skilmatch/View/tela_perfil.dart';
import 'package:skilmatch/View/tela_mensagens.dart';

class TelaProcurar extends StatefulWidget {
  const TelaProcurar({super.key});

  @override
  State<TelaProcurar> createState() => _TelaProcurarState();
}

class _TelaProcurarState extends State<TelaProcurar> {
  final TextEditingController _controladorBuscarHabilidades = TextEditingController();
  int _currentIndex = 0; 

  @override
  void dispose() {
    _controladorBuscarHabilidades.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        title: const Text('Procurar Trocas'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.fundo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Search Field
            TextFormField(
              controller: _controladorBuscarHabilidades,
              decoration: InputDecoration(
                hintText: "Buscar Habilidades",
                hintStyle: TextStyle(color: AppColors.cinza),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                suffixIcon: const Icon(Icons.search),
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 20),

            Text(
              "Recomendados",
              style: TextStyle(
                color: AppColors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            _buildUserCard(
              name: "Lucas Moura",
              location: "São Paulo",
              skill: "Pintor",
            ),
            _buildUserCard(
              name: "Neymar Jr",
              location: "São Paulo",
              skill: "Mecânico",
            ),
            _buildUserCard(
              name: "Vitor Roque",
              location: "São Paulo",
              skill: "Eletricista",
            ),
          ],
        ),
      ),
     bottomNavigationBar: BottomNavigationBar(
  currentIndex: _currentIndex,
  onTap: (index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TelaProcurar()),
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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TelaPerfil()),
      );
    }
  },
  type: BottomNavigationBarType.fixed,
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

  Widget _buildUserCard({
    required String name,
    required String location,
    required String skill,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text("Foto"),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(location),
                Text(
                  skill,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  "(Report Troca)",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}