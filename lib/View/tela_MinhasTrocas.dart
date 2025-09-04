import 'package:flutter/material.dart';
import 'package:skilmatch/Controller/colors.dart';
import 'package:skilmatch/View/tela_ProcurarTrocas.dart';
import 'package:skilmatch/View/tela_perfil.dart';

class TelaMinhastrocas extends StatefulWidget {
  const TelaMinhastrocas({super.key});

  @override
  State<TelaMinhastrocas> createState() => _TelaMinhasTrocasState();
}

// ...existing code...
class _TelaMinhasTrocasState extends State<TelaMinhastrocas> {
  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Minhas Trocas'),
         // ajuste conforme seu colors.dart
      ),
      body: Center(
        child: Text('Conteúdo das Minhas Trocas'),
      ),
    );
  }
}
// ...existing code...