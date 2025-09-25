class Mensagem {
  final String mensagemId;
  final String texto;
  final String senderId;
  final DateTime timestamp;
  final bool lida;

  Mensagem({
    required this.mensagemId,
    required this.texto,
    required this.senderId,
    required this.timestamp,
    this.lida = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'texto': texto,
      'senderId': senderId,
      'timestamp': timestamp,
      'lida': lida,
    };
  }

  static Mensagem fromMap(String mensagemId, Map<String, dynamic> map) {
    return Mensagem(
      mensagemId: mensagemId,
      texto: map['texto'],
      senderId: map['senderId'],
      timestamp: map['timestamp'].toDate(),
      lida: map['lida'] ?? false,
    );
  }
}