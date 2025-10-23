import 'package:cloud_firestore/cloud_firestore.dart';

class Avaliacao {
  String? id;
  final String usuarioAvaliadorId;
  final String usuarioAvaliadoId;
  final int estrelas;
  final String comentario;
  final DateTime dataAvaliacao;

  Avaliacao({
    this.id,
    required this.usuarioAvaliadorId,
    required this.usuarioAvaliadoId,
    required this.estrelas,
    required this.comentario,
    required this.dataAvaliacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'usuarioAvaliadorId': usuarioAvaliadorId,
      'usuarioAvaliadoId': usuarioAvaliadoId,
      'estrelas': estrelas,
      'comentario': comentario,
      // ✅ CORRIGIDO: Envia o DateTime puro.
      'dataAvaliacao': dataAvaliacao,
    };
  }

  // Corrigi o factory para aceitar o map primeiro, como a maioria das suas factories
  factory Avaliacao.fromMap(Map<String, dynamic> map, String id) {
    return Avaliacao(
      id: id,
      usuarioAvaliadorId: map['usuarioAvaliadorId'] ?? '',
      usuarioAvaliadoId: map['usuarioAvaliadoId'] ?? '',
      estrelas: (map['estrelas'] as num?)?.toInt() ?? 0,
      comentario: map['comentario'] ?? '',
      // ✅ CORRIGIDO: Lê o Timestamp do Firestore e o converte para DateTime.
      dataAvaliacao: (map['dataAvaliacao'] is Timestamp)
          ? (map['dataAvaliacao'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}