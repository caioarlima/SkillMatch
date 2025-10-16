import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  static final String _email = 'skillmatch2025@gmail.com';
  static final String _password = 'acoo ndbw wooi xwng';

  static Future<bool> enviarDenuncia({
    required String motivo,
    required String usuarioDenunciado,
    required String usuarioDenunciante,
    required String emailDenunciado,
    required String emailDenunciante,
  }) async {
    try {
      print('🔄 Iniciando envio de email...');

      
      final smtpServer = SmtpServer(
        'smtp.gmail.com',
        username: _email,
        password: _password,
        port: 587,
        ssl: false,
        allowInsecure: true,
      );

      final message = Message()
        ..from = Address(_email, 'SkillMatch Denúncias')
        ..recipients.add(_email)
        ..subject = '🚨 Denúncia: $usuarioDenunciado'
        ..html =
            '''
<h2>🚨 Nova Denúncia Recebida</h2>
<p><strong>Usuário Denunciado:</strong> $usuarioDenunciado</p>
<p><strong>Email:</strong> $emailDenunciado</p>
<p><strong>Denunciante:</strong> $usuarioDenunciante</p>
<p><strong>Email:</strong> $emailDenunciante</p>
<hr>
<p><strong>Motivo:</strong></p>
<p>$motivo</p>
<hr>
<p><em>Enviado em: ${DateTime.now()}</em></p>
<p><em>SkillMatch - Sistema de Denúncias</em></p>
        ''';

      final sendReport = await send(message, smtpServer);
      print('✅ Email enviado com sucesso!');
      return true;
    } catch (e) {
      print('❌ Falha no email: $e');
     
      return true;
    }
  }

  static Future<bool> enviarNotificacaoAvaliacao({
    required String usuarioAvaliado,
    required String usuarioAvaliador,
    required int estrelas,
    required String emailAvaliado,
  }) async {
    try {
      final smtpServer = gmail(_email, _password);

      final message = Message()
        ..from = Address(_email, 'SkillMatch')
        ..recipients.add(emailAvaliado)
        ..subject = '⭐ Nova Avaliação Recebida'
        ..text =
            '''
Olá $usuarioAvaliado!

Você recebeu uma nova avaliação de $usuarioAvaliador.

Avaliação: ${'⭐' * estrelas} ($estrelas/5)

Acesse o app para ver detalhes!

SkillMatch Team
        ''';

      await send(message, smtpServer);
      return true;
    } catch (e) {
      print('Erro no email de avaliação: $e');
      return true;
    }
  }
}
