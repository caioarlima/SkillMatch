import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> fazerLoginComEmailSenha(String email, String senha) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        throw Exception('E-mail ou senha inválidos.');
      } else if (e.code == 'user-not-found') {
        throw Exception('Nenhum usuário encontrado com este e-mail.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Senha incorreta.');
      } else {
        throw Exception('Erro ao fazer login: ${e.code}');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  Future<void> enviarEmailRedefinicaoSenha(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('Nenhum usuário encontrado com este e-mail.');
      } else {
        throw Exception('Erro ao enviar email: ${e.code}');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }



  Future<void> updatePassword(String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      } else {
        throw Exception('Usuário não autenticado');
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'requires-recent-login':
        return 'Por favor, faça login novamente antes de redefinir a senha.';
      case 'weak-password':
        return 'A senha é muito fraca. Use uma senha mais forte.';
      case 'invalid-credential':
        return 'Credencial inválida.';
      default:
        return 'Erro ao redefinir senha: ${e.message}';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}