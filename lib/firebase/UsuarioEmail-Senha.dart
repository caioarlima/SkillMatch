import 'package:firebase_auth/firebase_auth.dart';

Future<void> criarUsuarioComEmailSenha(String email, String senha) async {
  try {
    final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: senha,
    );
    print("Usuário criado: ${credential.user!.uid}");
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      print('A senha fornecida é muito fraca.');
    } else if (e.code == 'email-already-in-use') {
      print('Já existe uma conta com este e-mail.');
    }
  } catch (e) {
    print(e);
  }
}