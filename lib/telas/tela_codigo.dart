import 'package:flutter/material.dart';
import 'package:skilmatch/utils/colors.dart';
import 'package:skilmatch/telas/tela_MudarSenha.dart'; 
import 'package:skilmatch/telas/tela_EsqueciSenha.dart'; 

class TelaCodigo extends StatefulWidget {
  const TelaCodigo({super.key});

  @override
  State<TelaCodigo> createState() => _TelaCodigoState();
}

class _TelaCodigoState extends State<TelaCodigo> {
  final TextEditingController _controladorCodigo = TextEditingController();
  final _chaveFormulario = GlobalKey<FormState>();

  @override
  void dispose() {
    _controladorCodigo.dispose();
    super.dispose();
  }

  void _confirmarCodigo() {
    if (_chaveFormulario.currentState!.validate()) {
      final String codigoDigitado = _controladorCodigo.text.trim();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TelaMudarSenha()),
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
                Text(
                  "Código",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 36,
                  ),
                ),
                const SizedBox(height: 10),

                Text(
                  "Insira o código \nRecebido no seu email",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: AppColors.cinza,
                  ),
                ),
                const SizedBox(height: 50),

                SizedBox(
                  width: 200,
                  child: TextFormField(
                    controller: _controladorCodigo,
                    decoration: InputDecoration(
                      hintText: "Digite o código",
                      hintStyle: TextStyle(color: AppColors.cinza),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      filled: true,
                      fillColor: AppColors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6, 
                    validator: (valor) {
                      if (valor == null || valor.isEmpty) {
                        return 'Por favor, digite o código.';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 50),

                ElevatedButton(
                  onPressed: _confirmarCodigo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.roxo,
                    minimumSize: const Size(300, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    "Confirmar Código",
                    style: TextStyle(
                      fontSize: 25,
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

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
                      fontSize: 25,
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