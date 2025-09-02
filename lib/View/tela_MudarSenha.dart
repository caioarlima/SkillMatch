import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skilmatch/Controller/colors.dart';
import 'package:skilmatch/View/tela_EsqueciSenha.dart';
import 'package:skilmatch/View/tela_login.dart';

class TelaMudarSenha extends StatefulWidget {
  final String actionCode;

  const TelaMudarSenha({super.key, this.actionCode = ''});

  @override
  State<TelaMudarSenha> createState() => _TelaMudarSenhaState();
}

class _TelaMudarSenhaState extends State<TelaMudarSenha> {
  final TextEditingController _controladorNovaSenha = TextEditingController();
  final TextEditingController _controladorConfirmarNovaSenha =
      TextEditingController();
  final _chaveFormulario = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  @override
  void dispose() {
    _controladorNovaSenha.dispose();
    _controladorConfirmarNovaSenha.dispose();
    super.dispose();
  }

  Future<void> _confirmarRedefinicao() async {
    if (!_chaveFormulario.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.actionCode.isEmpty) {
        throw Exception('Código de ação não encontrado.');
      }

      await _auth.confirmPasswordReset(
        code: widget.actionCode,
        newPassword: _controladorNovaSenha.text.trim(),
      );

      _mostrarDialogo(
        'Sucesso!',
        'Sua senha foi redefinida com sucesso. Você pode fazer login com sua nova senha.',
      );
    } on FirebaseAuthException catch (e) {
      _mostrarDialogo(
        'Erro',
        'Não foi possível redefinir a senha. O link pode ser inválido ou já foi usado.',
      );
    } catch (e) {
      _mostrarDialogo('Erro', 'Ocorreu um erro inesperado. Tente novamente.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _voltarParaEsqueciSenha() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TelaEsqueciSenha()),
    );
  }

  void _mostrarDialogo(String titulo, String mensagem) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.fundo,
          title: Text(
            titulo,
            style: TextStyle(
              color: AppColors.roxo,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            mensagem,
            style: TextStyle(color: AppColors.black, fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const TelaLogin()),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.roxo,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text('OK', style: TextStyle(color: AppColors.white)),
            ),
          ],
        );
      },
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
                  style: TextStyle(fontSize: 36, color: AppColors.black),
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                    ),
                    validator: (valor) {
                      if (valor == null || valor.isEmpty) {
                        return 'Por favor insira a nova senha';
                      }
                      if (valor.length < 6 || valor.length > 20) {
                        return 'A senha deve ter entre 6 e 20 caracteres';
                      }
                      if (!RegExp(
                        r"^(?=.*[0-9])(?=.*[a-zA-Z])(?=\S+$).{8,}$",
                      ).hasMatch(valor)) {
                        return 'A senha deve ter no mínimo 8 caracteres, incluindo letras e números.';
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
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
                  onPressed: _isLoading ? null : _confirmarRedefinicao,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.roxo,
                    minimumSize: const Size(300, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        )
                      : Text(
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
                    style: TextStyle(fontSize: 30, color: AppColors.white),
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
