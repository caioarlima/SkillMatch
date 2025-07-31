import 'package:flutter/material.dart';
import 'package:skilmatch/utils/colors.dart';

class TelaProcurar extends StatefulWidget { 
  const TelaProcurar({super.key});

  @override
  State<TelaProcurar> createState() => _TelaProcurarState(); 
}

class _TelaProcurarState extends State<TelaProcurar> { 
  final TextEditingController _controladorBuscarHabilidades = TextEditingController();

  @override
  void dispose() {
    _controladorBuscarHabilidades.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "Procurar Trocas",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 36,
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: 360,
                child: TextFormField(
                  controller: _controladorBuscarHabilidades,
                  decoration: InputDecoration(
                    hintText: "🔍︎ Buscar Habilidades/Pessoas",
                    hintStyle: TextStyle(color: AppColors.cinza),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  ),
                  keyboardType: TextInputType.text,
                ),
              ),
              const SizedBox(height: 10),

              Text(
                "Recomendados",
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}