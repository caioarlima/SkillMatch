import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skilmatch/Repository/auth_repository.dart';
import 'package:skilmatch/Repository/usuario_repository.dart';
import 'package:skilmatch/Model/usuario.dart';

class AuthController with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthRepository _authRepository = AuthRepository();
  final UsuarioRepository _usuarioRepository = UsuarioRepository();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Stream<User?> get authStateChanges => _authRepository.authStateChanges;

  static int calcularIdade(DateTime dataNascimento) {
    final hoje = DateTime.now();
    int idade = hoje.year - dataNascimento.year;
    if (hoje.month < dataNascimento.month ||
        (hoje.month == dataNascimento.month && hoje.day < dataNascimento.day)) {
      idade--;
    }
    return idade;
  }

  Future<void> cadastrar(Usuario usuario, String senha) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: usuario.email,
            password: senha,
          );

      Usuario usuarioComId = usuario.copyWith(id: userCredential.user!.uid);

      await _firestore
          .collection('usuarios')
          .doc(usuarioComId.id)
          .set(usuarioComId.toMap());
    } on FirebaseAuthException catch (e) {
      _errorMessage = _handleAuthError(e);
    } catch (e) {
      _errorMessage = 'Erro ao cadastrar: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Este email já está em uso.';
      case 'weak-password':
        return 'Senha muito fraca. Use uma senha mais forte.';
      case 'invalid-email':
        return 'Email inválido.';
      default:
        return 'Erro ao cadastrar: ${e.message}';
    }
  }

  Future<User?> login(String email, String senha) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      return await _authRepository.fazerLoginComEmailSenha(email, senha);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePassword(
    String newPassword,
    String confirmPassword,
    BuildContext context,
  ) async {
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _errorMessage = 'Por favor, preencha ambos os campos.';
      notifyListeners();
      return;
    }

    if (newPassword != confirmPassword) {
      _errorMessage = 'As senhas não coincidem.';
      notifyListeners();
      return;
    }

    if (newPassword.length < 6) {
      _errorMessage = 'A senha deve ter pelo menos 6 caracteres.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.updatePassword(newPassword);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha redefinida com sucesso!')),
      );
    } catch (e) {
      _errorMessage = e.toString();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_errorMessage!)));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> enviarEmailRedefinicao(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authRepository.enviarEmailRedefinicaoSenha(email);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void limparErro() {
    _errorMessage = null;
    notifyListeners();
  }
}
