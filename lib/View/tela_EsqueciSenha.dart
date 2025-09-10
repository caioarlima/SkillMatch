import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skilmatch/Controller/auth_controller.dart';
import 'package:skilmatch/Controller/colors.dart';
import 'package:skilmatch/Services/validadores.dart';
import 'package:skilmatch/View/tela_login.dart';

class TelaEsqueciSenha extends StatefulWidget {
  const TelaEsqueciSenha({super.key});

  @override
  State<TelaEsqueciSenha> createState() => _TelaEsqueciSenhaState();
}

class _TelaEsqueciSenhaState extends State<TelaEsqueciSenha> {
  final TextEditingController _controladorEmailRedefinicao = TextEditingController();
  final _chaveFormulario = GlobalKey<FormState>();

  @override
  void dispose() {
    _controladorEmailRedefinicao.dispose();
    super.dispose();
  }

  Future<void> _enviarLink() async {
    if (!_chaveFormulario.currentState!.validate()) {
      return;
    }

    final authController = Provider.of<AuthController>(context, listen: false);
    
    try {
      await authController.enviarEmailRedefinicao(_controladorEmailRedefinicao.text.trim());
      
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: AppColors.fundo,
            title: const Text('Sucesso!'),
            content: const Text('Se o e-mail estiver cadastrado, um link de redefinição de senha foi enviado para ele.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(backgroundColor: AppColors.roxo),
                child: Text('OK', style: TextStyle(color: AppColors.white)),
              ),
            ],
          );
        },
      ).then((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TelaLogin()),
        );
      });
    } catch (e) {}
  }

  void _voltarParaLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TelaLogin()),
    );
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
                Text(
                  "Redefinir Senha",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.black, fontSize: 36),
                ),
                const SizedBox(height: 10),
                Text(
                  "Para redefinir sua senha \nInsira seu email cadastrado",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, color: AppColors.cinza),
                ),
                const SizedBox(height: 50),
                SizedBox(
                  width: 300,
                  child: TextFormField(
                    controller: _controladorEmailRedefinicao,
                    decoration: InputDecoration(
                      hintText: "Email",
                      hintStyle: TextStyle(color: AppColors.cinza),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                      filled: true,
                      fillColor: AppColors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validarEmail,
                  ),
                ),
                const SizedBox(height: 35),
                ElevatedButton(
                  onPressed: authController.isLoading ? null : _enviarLink,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.roxo,
                    minimumSize: const Size(250, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                  child: authController.isLoading
                      ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                      : Text("Enviar Link", style: TextStyle(fontSize: 30, color: AppColors.white)),
                ),
                const SizedBox(height: 35),
                ElevatedButton(
                  onPressed: _voltarParaLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.roxo,
                    minimumSize: const Size(150, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                  child: Text("Voltar", style: TextStyle(fontSize: 30, color: AppColors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}