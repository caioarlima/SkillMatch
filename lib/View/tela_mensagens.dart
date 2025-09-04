import 'package:flutter/material.dart';
import 'package:skilmatch/Controller/colors.dart';
import 'package:skilmatch/View/tela_ProcurarTrocas.dart';
import 'package:skilmatch/View/tela_perfil.dart';

class TelaMensagens extends StatefulWidget {
  const TelaMensagens({super.key});

  @override
  State<TelaMensagens> createState() => _TelaMensagensState();
}

class _TelaMensagensState extends State<TelaMensagens> {
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mensagens'),
        // ajuste conforme seu colors.dart
      ),
      body: Center(
        child: Text('Conteúdo das Mensagens'),
      ),
    );
   }
}