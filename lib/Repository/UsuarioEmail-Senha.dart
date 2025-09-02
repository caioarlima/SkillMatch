import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

Future<void> criarUsuarioComEmailSenha({
  required String email,
  required String senha,
  required String nomeCompleto,
  required String cidade,
  required String bio,
  required String? genero,
}) async {
  try {

    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: senha,
    );
    
    String userUid = userCredential.user!.uid;

    DatabaseReference userRef = FirebaseDatabase.instance.ref('usuarios/$userUid');
    await userRef.set({
      'nomeCompleto': nomeCompleto,
      'cidade': cidade,
      'bio': bio,
      'genero': genero,
      'email': email,
    });
    
    print("Usu\u00E1rio criado e dados salvos com sucesso!");

  } on FirebaseAuthException {
 
    rethrow;
  } catch (e) {
  
    print('Ocorreu um erro geral ao salvar os dados: $e');
    rethrow;
  }
}