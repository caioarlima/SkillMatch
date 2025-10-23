// CHAT.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String chatId;
  final List<String> participantes;
  final String ultimaMensagem;
  final DateTime timestamp;
  final Map<String, String> usuariosInfo;
  final Map<String, String> usuariosFotos;

  Chat({
    required this.chatId,
    required this.participantes,
    required this.ultimaMensagem,
    required this.timestamp,
    required this.usuariosInfo,
    required this.usuariosFotos,
  });

  Map<String, dynamic> toMap() {
    return {
      'participantes': participantes,
      'ultimaMensagem': ultimaMensagem,
      'timestamp': timestamp,
      'usuariosInfo': usuariosInfo,
      'usuariosFotos': usuariosFotos,
    };
  }

  static Chat fromMap(String chatId, Map<String, dynamic> map) {
    return Chat(
      chatId: chatId,
      participantes: List<String>.from(map['participantes']),
      ultimaMensagem: map['ultimaMensagem'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      usuariosInfo: Map<String, String>.from(map['usuariosInfo']),
      usuariosFotos: Map<String, String>.from(map['usuariosFotos'] ?? {}),
    );
  }
}