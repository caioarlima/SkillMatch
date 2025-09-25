class Chat {
  final String chatId;
  final List<String> participantes;
  final String ultimaMensagem;
  final DateTime timestamp;
  final Map<String, String> usuariosInfo;

  Chat({
    required this.chatId,
    required this.participantes,
    required this.ultimaMensagem,
    required this.timestamp,
    required this.usuariosInfo,
  });

  Map<String, dynamic> toMap() {
    return {
      'participantes': participantes,
      'ultimaMensagem': ultimaMensagem,
      'timestamp': timestamp,
      'usuariosInfo': usuariosInfo,
    };
  }

  static Chat fromMap(String chatId, Map<String, dynamic> map) {
    return Chat(
      chatId: chatId,
      participantes: List<String>.from(map['participantes']),
      ultimaMensagem: map['ultimaMensagem'],
      timestamp: map['timestamp'].toDate(),
      usuariosInfo: Map<String, String>.from(map['usuariosInfo']),
    );
  }
}