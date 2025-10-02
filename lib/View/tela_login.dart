import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skilmatch/Controller/auth_controller.dart';
import 'package:skilmatch/Controller/colors.dart';
import 'package:skilmatch/Services/validadores.dart';
import 'package:skilmatch/View/tela_EsqueciSenha.dart';
import 'package:skilmatch/View/tela_cadastro.dart';
import 'package:skilmatch/View/tela_ProcurarTrocas.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final TextEditingController _controladorEmail = TextEditingController();
  final TextEditingController _controladorSenha = TextEditingController();
  final _chaveFormulario = GlobalKey<FormState>();

  @override
  void dispose() {
    _controladorEmail.dispose();
    _controladorSenha.dispose();
    super.dispose();
  }

  Future<void> _fazerLogin(
    BuildContext context,
    AuthController authController,
  ) async {
    if (_chaveFormulario.currentState!.validate()) {
      try {
        await authController.login(
          _controladorEmail.text.trim(),
          _controladorSenha.text.trim(),
        );

        if (authController.errorMessage == null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TelaProcuraTrocas()),
          );
        }
      } catch (e) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

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
                  "Conecte talentos, troque habilidades.",
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
                  validator: Validators.validarEmail,
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
                  validator: (valor) => Validators.validarSenha(valor, 6),
                ),
                if (authController.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      authController.errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
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
                  onPressed: authController.isLoading
                      ? null
                      : () => _fazerLogin(context, authController),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.roxo,
                    minimumSize: const Size(250, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: authController.isLoading
                      ? CircularProgressIndicator(color: AppColors.white)
                      : Text(
                          "Entrar",
                          style: TextStyle(
                            fontSize: 30,
                            color: AppColors.white,
                          ),
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
