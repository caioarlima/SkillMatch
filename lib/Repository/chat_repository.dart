import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getTotalTrocasUsuario(String usuarioId) async {
    try {
      print('🔄 Buscando trocas para usuário: $usuarioId');

      final querySnapshot = await _firestore
          .collection('chats')
          .where('participantes', arrayContains: usuarioId)
          .where('status', isEqualTo: 'finalizado')
          .get();

      print('📊 Total de documentos encontrados: ${querySnapshot.docs.length}');

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        print('💬 Chat ID: ${doc.id}');
        print('   Participantes: ${data['participantes']}');
        print('   Status: ${data['status']}');
        print('   Finalizado em: ${data['dataFinalizacao']}');
        print('---');
      }

      return querySnapshot.docs.length;
    } catch (e) {
      print('❌ Erro ao buscar total de trocas: $e');
      return 0;
    }
  }
}
