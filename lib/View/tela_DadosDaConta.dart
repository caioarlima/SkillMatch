import 'package:flutter/material.dart';
import 'package:skilmatch/Controller/colors.dart';

class TelaDadosConta extends StatefulWidget {
  const TelaDadosConta({super.key});

  @override
  State<TelaDadosConta> createState() => _TelaDadosContaState();
}

class _TelaDadosContaState extends State<TelaDadosConta> {
  final TextEditingController _emailController = TextEditingController(
    text: "neymarjr@gmail.com",
  );
  final TextEditingController _senhaController = TextEditingController(
    text: "******",
  );
  final TextEditingController _bioController = TextEditingController(
    text: "Pintor",
  );
  final TextEditingController _cidadeController = TextEditingController(
    text: "São Paulo",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Center(
              child: Text(
                "Dados da Conta",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),

            _buildTextField("Email", _emailController, false),

            const SizedBox(height: 20),

            _buildTextField("Senha", _senhaController, true),

            const SizedBox(height: 20),

            _buildTextField("Bio", _bioController, false),

            const SizedBox(height: 20),

            _buildTextField("Cidade", _cidadeController, false),

            const SizedBox(height: 40),

           
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Voltar",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    bool obscure,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
