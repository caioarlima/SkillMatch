import 'package:cloud_firestore/cloud_firestore.dart';
import '../Model/Avaliacao.dart';

class AvaliacaoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> usuarioJaAvaliou(String avaliadorId, String avaliadoId) async {
    try {
      final querySnapshot = await _firestore
          .collection('avaliacoes')
          .where('usuarioAvaliadorId', isEqualTo: avaliadorId)
          .where('usuarioAvaliadoId', isEqualTo: avaliadoId)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Erro ao verificar se usuário já avaliou: $e');
      return false;
    }
  }

  Future<void> salvarAvaliacao(Avaliacao avaliacao) async {
    await _firestore.collection('avaliacoes').add(avaliacao.toMap());
  }

  Stream<List<Avaliacao>> getAvaliacoesPorUsuario(String usuarioId) {
    return _firestore
        .collection('avaliacoes')
        .where('usuarioAvaliadoId', isEqualTo: usuarioId)
        .orderBy('dataAvaliacao', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Avaliacao.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<List<Avaliacao>> getAvaliacoesPorUsuarioOnce(String usuarioId) async {
    final snapshot = await _firestore
        .collection('avaliacoes')
        .where('usuarioAvaliadoId', isEqualTo: usuarioId)
        .get();

    return snapshot.docs
        .map((doc) => Avaliacao.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> excluirAvaliacao(String avaliacaoId) async {
    await _firestore.collection('avaliacoes').doc(avaliacaoId).delete();
  }

  Future<Avaliacao?> getAvaliacaoPorId(String avaliacaoId) async {
    final doc = await _firestore
        .collection('avaliacoes')
        .doc(avaliacaoId)
        .get();
    if (doc.exists) {
      return Avaliacao.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Stream<List<Avaliacao>> getAvaliacoesRecentes(
    String usuarioId, {
    int limite = 5,
  }) {
    return _firestore
        .collection('avaliacoes')
        .where('usuarioAvaliadoId', isEqualTo: usuarioId)
        .orderBy('dataAvaliacao', descending: true)
        .limit(limite)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Avaliacao.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
