import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skilmatch/Controller/colors.dart';
import 'package:skilmatch/View/tela_EsqueciSenha.dart';
import 'package:skilmatch/View/tela_ProcurarTrocas.dart';
import 'package:skilmatch/View/tela_cadastro.dart';

import 'package:skilmatch/Model/LoginEmail-Senha.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final TextEditingController _controladorEmail = TextEditingController();
  final TextEditingController _controladorSenha = TextEditingController();
  final _chaveFormulario = GlobalKey<FormState>();

  final int _tamanhoMinimoSenha = 6;
  final int _tamanhoMaximoSenha = 20;
  final RegExp _regexSenha = RegExp(
    r"^(?=.*[0-9])(?=.*[a-zA-Z])(?=\S+$).{8,}$",
  );

  @override
  void dispose() {
    _controladorEmail.dispose();
    _controladorSenha.dispose();
    super.dispose();
  }

  Future<void> _fazerLogin() async {
    if (_chaveFormulario.currentState!.validate()) {
      try {
        await fazerLoginComEmailSenha(
          _controladorEmail.text.trim(),
          _controladorSenha.text.trim(),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TelaProcurar()),
        );
      } on FirebaseAuthException catch (e) {
        String mensagemDeErro;
        if (e.code == 'invalid-credential') {
          mensagemDeErro = 'E-mail ou senha inválidos.';
        } else {
          mensagemDeErro = 'Ocorreu um erro inesperado: ${e.code}';
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensagemDeErro)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _chaveFormulario,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/images/logo_skillmatch.png',
                  width: 250,
                  height: 192,
                ),
                const SizedBox(height: 15),
                Text(
                  "Olá! Faça login no SkillMatch",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.cinza, fontSize: 30),
                ),
                const SizedBox(height: 30),
                Text(
                  "Conecte talentos, \ntroque habilidades.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.black, fontSize: 30),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _controladorEmail,
                  decoration: InputDecoration(
                    hintText: "Email",
                    hintStyle: TextStyle(color: AppColors.cinza),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (valor) {
                    if (valor == null || valor.isEmpty) {
                      return 'Por favor insira seu email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(valor)) {
                      return 'Por favor insira um email válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _controladorSenha,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Senha",
                    hintStyle: TextStyle(color: AppColors.cinza),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                  ),
                  validator: (valor) {
                    if (valor == null || valor.isEmpty) {
                      return 'Por favor insira sua senha';
                    }
                    if (valor.length < _tamanhoMinimoSenha ||
                        valor.length > _tamanhoMaximoSenha) {
                      return 'A senha deve ter entre $_tamanhoMinimoSenha e $_tamanhoMaximoSenha caracteres';
                    }
                    if (!_regexSenha.hasMatch(valor)) {
                      return 'A senha deve ter no mínimo 8 caracteres, incluindo letras maiúsculas, minúsculas e números.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TelaEsqueciSenha(),
                      ),
                    );
                  },
                  child: Text(
                    "Esqueci minha senha",
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.roxo,
                      decoration: TextDecoration.underline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _fazerLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.roxo,
                    minimumSize: const Size(250, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    "Entrar",
                    style: TextStyle(fontSize: 30, color: AppColors.white),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  "Sem conta?",
                  style: TextStyle(fontSize: 20, color: AppColors.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TelaCadastro(),
                      ),
                    );
                  },
                  child: Text(
                    "Cadastre-se agora!",
                    style: TextStyle(
                      fontSize: 25,
                      color: AppColors.roxo,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
