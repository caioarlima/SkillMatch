import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skilmatch/telas/tela_ProcurarTrocas.dart';
import 'package:skilmatch/telas/tela_login.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); 
        }
        if (snapshot.hasData) {
         
          return TelaProcurar(); 
        } else {
          
          return TelaLogin(); 
        }
      },
    );
  }
}