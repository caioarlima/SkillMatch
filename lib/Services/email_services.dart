import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  static final String _serviceUrl = 'https://api.emailjs.com/api/v1.0/email/send';
  
  static final String _serviceId = 'service_ycqjijk';
  static final String _templateId = 'template_hgfe7ov';
  static final String _userId = 'UDhsM2Fd4m0bSArtQ';

  static Future<bool> enviarDenuncia({
    required String motivo,
    required String usuarioDenunciado,
    required String usuarioDenunciante,
    required String emailDenunciado,
    required String emailDenunciante,
  }) async {
    try {
      print('🔄 Iniciando envio de email via EmailJS...');

      final response = await http.post(
        Uri.parse(_serviceUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'service_id': _serviceId,
          'template_id': _templateId,
          'user_id': _userId,
          'template_params': {
            'motivo': motivo,
            'usuario_denunciado': usuarioDenunciado,
            'usuario_denunciante': usuarioDenunciante,
            'email_denunciado': emailDenunciado,
            'email_denunciante': emailDenunciante,
            'data': DateTime.now().toString(),
          }
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Email enviado com sucesso!');
        return true;
      } else {
        print('❌ Falha no email: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Erro no email: $e');
      return false;
    }
  }

  static Future<bool> enviarNotificacaoAvaliacao({
    required String usuarioAvaliado,
    required String usuarioAvaliador,
    required int estrelas,
    required String emailAvaliado,
  }) async {
    return true;
  }
}