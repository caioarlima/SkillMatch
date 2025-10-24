import 'package:cloud_firestore/cloud_firestore.dart';
import 'Usuario.dart';

class Mensagem {
  final String mensagemId;
  final String texto;
  final String senderId;
  final DateTime timestamp;
  final bool lida;
  final List<String> visualizadaPor;
  final Usuario? remetente;

  Mensagem({
    required this.mensagemId,
    required this.texto,
    required this.senderId,
    required this.timestamp,
    this.lida = false,
    this.visualizadaPor = const [],
    this.remetente,
  });

  Map<String, dynamic> toMap() {
    return {
      'texto': texto,
      'senderId': senderId,
      'timestamp': timestamp,
      'lida': lida,
      'visualizadaPor': visualizadaPor,
    };
  }

  static Mensagem fromMap(String mensagemId, Map<String, dynamic> map) {
    return Mensagem(
      mensagemId: mensagemId,
      texto: map['texto'],
      senderId: map['senderId'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      lida: map['lida'] ?? false,
      visualizadaPor: List<String>.from(map['visualizadaPor'] ?? []),
    );
  }

  Mensagem copyWith({
    String? mensagemId,
    String? texto,
    String? senderId,
    DateTime? timestamp,
    bool? lida,
    List<String>? visualizadaPor,
    Usuario? remetente,
  }) {
    return Mensagem(
      mensagemId: mensagemId ?? this.mensagemId,
      texto: texto ?? this.texto,
      senderId: senderId ?? this.senderId,
      timestamp: timestamp ?? this.timestamp,
      lida: lida ?? this.lida,
      visualizadaPor: visualizadaPor ?? this.visualizadaPor,
      remetente: remetente ?? this.remetente,
    );
  }
}
