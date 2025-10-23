import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:skilmatch/Controller/auth_controller.dart';
import 'package:skilmatch/Controller/usuario_controller.dart';
import 'package:skilmatch/Controller/mensagem_controller.dart';
import 'package:skilmatch/Controller/avaliacao_controller.dart';
import 'package:skilmatch/Controller/chat_controller.dart';
import 'package:skilmatch/View/tela_login.dart';
import 'package:skilmatch/View/tela_ProcurarTrocas.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => UsuarioController()),
        ChangeNotifierProvider(create: (context) => ChatController()),
        ChangeNotifierProvider(create: (_) => MensagemController()),
        ChangeNotifierProvider(create: (_) => AvaliacaoController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SkillMatch',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const AuthCheck(),
      ),
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    return StreamBuilder<User?>(
      stream: authController.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          return const TelaProcuraTrocas();
        } else {
          return const TelaLogin();
        }
      },
    );
  }
}
