import 'package:flutter/material.dart';
import 'package:skilmatch/utils/colors.dart';
import 'package:skilmatch/telas/tela_login.dart'; 
import 'package:skilmatch/telas/tela_EsqueciSenha.dart'; 

class TelaMudarSenha extends StatefulWidget {
  const TelaMudarSenha({super.key});

  @override
  State<TelaMudarSenha> createState() => _TelaMudarSenhaState();
}

class _TelaMudarSenhaState extends State<TelaMudarSenha> {
  final TextEditingController _controladorNovaSenha = TextEditingController();
  final TextEditingController _controladorConfirmarNovaSenha = TextEditingController();
  final _chaveFormulario = GlobalKey<FormState>();

  final int _tamanhoMinimoSenha = 6;
  final int _tamanhoMaximoSenha = 20;
  final RegExp _regexSenha = RegExp(r"^(?=.*[0-9])(?=.*[a-zA-Z])(?=\S+$).{8,}$");

  @override
  void dispose() {
    _controladorNovaSenha.dispose();
    _controladorConfirmarNovaSenha.dispose();
    super.dispose();
  }

  void _confirmarRedefinicao() {
    if (_chaveFormulario.currentState!.validate()) {
      final String novaSenha = _controladorNovaSenha.text.trim();
      final String confirmarNovaSenha = _controladorConfirmarNovaSenha.text.trim();

      if (novaSenha != confirmarNovaSenha) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("As senhas não coincidem. Por favor, verifique.")),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Senha mudada com sucesso!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TelaLogin()),
      );
    }
  }

  void _voltarParaEsqueciSenha() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TelaEsqueciSenha()),
    );
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
                const SizedBox(height: 100), 

                Text(
                  "Redefinir Senha",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: 300,
                  child: TextFormField(
                    controller: _controladorNovaSenha,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Senha",
                      hintStyle: TextStyle(color: AppColors.cinza),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      filled: true,
                      fillColor: AppColors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    ),
                    validator: (valor) {
                      if (valor == null || valor.isEmpty) {
                        return 'Por favor insira a nova senha';
                      }
                      if (valor.length < _tamanhoMinimoSenha || valor.length > _tamanhoMaximoSenha) {
                        return 'A senha deve ter entre $_tamanhoMinimoSenha e $_tamanhoMaximoSenha caracteres';
                      }
                      if (!_regexSenha.hasMatch(valor)) {
                        return 'A senha deve ter no mínimo 8 caracteres, incluindo letras maiúsculas, minúsculas e números.';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: 300,
                  child: TextFormField(
                    controller: _controladorConfirmarNovaSenha,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Confirmar Senha",
                      hintStyle: TextStyle(color: AppColors.cinza),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      filled: true,
                      fillColor: AppColors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    ),
                    validator: (valor) {
                      if (valor == null || valor.isEmpty) {
                        return 'Por favor confirme a nova senha';
                      }
                      if (valor != _controladorNovaSenha.text) {
                        return 'As senhas não coincidem. Por favor, verifique.';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 50),

                ElevatedButton(
                  onPressed: _confirmarRedefinicao,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.roxo,
                    minimumSize: const Size(300, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    "Confirmar Redefinição",
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 35),

                ElevatedButton(
                  onPressed: _voltarParaEsqueciSenha, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.roxo,
                    minimumSize: const Size(150, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    "Voltar",
                    style: TextStyle(
                      fontSize: 30,
                      color: AppColors.white,
                    ),
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