import 'package:firebase_auth/firebase_auth.dart';

Future<void> fazerLoginComEmailSenha(String email, String senha) async {
  try {
 
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: senha,
    );
    print("Login bem-sucedido: ${credential.user!.uid}");
  } on FirebaseAuthException catch (e) {
    rethrow;
  }
}