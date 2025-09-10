import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skilmatch/Controller/colors.dart';
import 'package:skilmatch/Controller/auth_controller.dart';

class MudarSenha extends StatefulWidget {
  const MudarSenha({super.key});

  @override
  State<MudarSenha> createState() => _MudarSenhaState();
}

class _MudarSenhaState extends State<MudarSenha> {
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController = TextEditingController();

  void _confirmarRedefinicao() {
    final authController = Provider.of<AuthController>(context, listen: false);
    authController.clearError();
    
    authController.updatePassword(
      _senhaController.text,
      _confirmarSenhaController.text,
      context,
    ).then((_) {
      if (authController.errorMessage == null) {
        _senhaController.clear();
        _confirmarSenhaController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        return Scaffold(
          backgroundColor: AppColors.fundo,
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Redefinir Senha",
                    style: TextStyle(
                      fontSize: 36,
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: _senhaController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Nova Senha",
                        hintStyle: const TextStyle(color: AppColors.cinza),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        filled: true,
                        fillColor: AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: _confirmarSenhaController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Confirmar Nova Senha",
                        hintStyle: const TextStyle(color: AppColors.cinza),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        filled: true,
                        fillColor: AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (authController.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        authController.errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  SizedBox(
                    width: 300,
                    height: 60,
                    child: authController.isLoading
                        ? const Center(child: CircularProgressIndicator(color: AppColors.roxo))
                        : ElevatedButton(
                            onPressed: _confirmarRedefinicao,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.roxo,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text(
                              "Confirmar Redefinição",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 150,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: authController.isLoading
                          ? null
                          : () {
                              Navigator.pop(context);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.roxo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        "Voltar",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }
}