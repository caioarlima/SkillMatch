import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skilmatch/Model/usuario.dart';

class UsuarioRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String? validarCPF(String? cpf) {
    if (cpf == null || cpf.isEmpty) return 'Por favor, insira o seu CPF';
    String cpfLimpo = cpf.replaceAll(RegExp(r'\D'), '');
    if (cpfLimpo.length != 11) return 'CPF deve ter 11 digitos';
    if (RegExp(r'^(\d)\1*$').hasMatch(cpfLimpo)) return 'CPF inválido';
    
    int soma = 0;
    for (int i = 1; i <= 9; i++) soma += int.parse(cpfLimpo[i - 1]) * (11 - i);
    int resto = (soma * 10) % 11;
    if (resto == 10 || resto == 11) resto = 0;
    if (resto != int.parse(cpfLimpo[9])) return 'CPF inválido';
    
    soma = 0;
    for (int i = 1; i <= 10; i++) soma += int.parse(cpfLimpo[i - 1]) * (12 - i);
    resto = (soma * 10) % 11;
    if (resto == 10 || resto == 11) resto = 0;
    if (resto != int.parse(cpfLimpo[10])) return 'CPF inválido';
    
    return null;
  }

  Future<void> salvarUsuario(Usuario usuario) async {
    try {
      await _firestore.collection('usuarios').doc(usuario.id).set(usuario.toMap());
    } catch (e) {
      throw Exception('Erro ao salvar usuário: $e');
    }
  }

  Future<Usuario?> buscarUsuarioPorId(String id) async {
    try {
      final doc = await _firestore.collection('usuarios').doc(id).get();
      if (doc.exists) {
        return Usuario.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar usuário: $e');
    }
  }

  Future<List<Usuario>> buscarUsuariosPorCidade(String cidade, {String? excludeUserId}) async {
    try {
      final snapshot = await _firestore
          .collection('usuarios')
          .where('cidade', isEqualTo: cidade)
          .get();

      return snapshot.docs
          .map((doc) => Usuario.fromMap(doc.id, doc.data()!))
          .where((usuario) => usuario.id != excludeUserId) // Filtra usuário atual
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar usuários por cidade: $e');
    }
  }

  Future<List<Usuario>> buscarUsuarios(String query, {String? excludeUserId}) async {
    try {
      final snapshot = await _firestore.collection('usuarios').get();
      
      return snapshot.docs
          .map((doc) => Usuario.fromMap(doc.id, doc.data()!))
          .where((usuario) => usuario.id != excludeUserId) // Filtra usuário atual
          .where((usuario) =>
              usuario.nomeCompleto.toLowerCase().contains(query.toLowerCase()) ||
              usuario.bio.toLowerCase().contains(query.toLowerCase()) ||
              usuario.cidade.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar usuários: $e');
    }
  }

  Stream<List<Usuario>> observarUsuariosPorCidade(String cidade, {String? excludeUserId}) {
    return _firestore
        .collection('usuarios')
        .where('cidade', isEqualTo: cidade)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Usuario.fromMap(doc.id, doc.data()!))
            .where((usuario) => usuario.id != excludeUserId) // Filtra usuário atual
            .toList());
  }
}