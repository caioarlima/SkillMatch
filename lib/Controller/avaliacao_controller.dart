import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Repository/avaliacao_repository.dart';
import '../Model/Avaliacao.dart';
import '../Services/email_services.dart';
import '../Model/Usuario.dart';

class AvaliacaoController extends ChangeNotifier {
  final AvaliacaoRepository _avaliacaoRepository = AvaliacaoRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> salvarAvaliacao({
    required String avaliadorId,
    required String avaliadoId,
    required int estrelas,
    required String comentario,
    required Usuario usuarioAvaliador,
    required Usuario usuarioAvaliado,
  }) async {
    try {
      bool jaAvaliou = await _avaliacaoRepository.usuarioJaAvaliou(
        avaliadorId,
        avaliadoId,
      );

      if (jaAvaliou) {
        throw Exception('Você já avaliou este usuário');
      }

      Avaliacao avaliacao = Avaliacao(
        usuarioAvaliadorId: avaliadorId,
        usuarioAvaliadoId: avaliadoId,
        estrelas: estrelas,
        comentario: comentario,
        dataAvaliacao: DateTime.now(),
      );

      await _avaliacaoRepository.salvarAvaliacao(avaliacao);

      await _atualizarMediaAvaliacoes(avaliadoId);

      notifyListeners();
      return true;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Stream<List<Avaliacao>> getAvaliacoesUsuario(String usuarioId) {
    return _avaliacaoRepository.getAvaliacoesPorUsuario(usuarioId);
  }

  Future<double> getMediaAvaliacoes(String usuarioId) async {
    try {
      final avaliacoes = await _avaliacaoRepository.getAvaliacoesPorUsuarioOnce(
        usuarioId,
      );

      if (avaliacoes.isEmpty) return 0.0;

      double soma = 0;
      for (var avaliacao in avaliacoes) {
        soma += avaliacao.estrelas;
      }

      return double.parse((soma / avaliacoes.length).toStringAsFixed(1));
    } catch (e) {
      print('Erro ao calcular média de avaliações: $e');
      return 0.0;
    }
  }

  Future<void> _atualizarMediaAvaliacoes(String usuarioId) async {
    try {
      double media = await getMediaAvaliacoes(usuarioId);

      await _firestore.collection('usuarios').doc(usuarioId).update({
        'mediaAvaliacoes': double.parse(media.toStringAsFixed(1)),
        'totalAvaliacoes': FieldValue.increment(1),
        'ultimaAtualizacao': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erro ao atualizar média: $e');
    }
  }

  Future<bool> usuarioJaAvaliou(String avaliadorId, String avaliadoId) async {
    try {
      return await _avaliacaoRepository.usuarioJaAvaliou(
        avaliadorId,
        avaliadoId,
      );
    } catch (e) {
      print('Erro ao verificar se usuário já avaliou: $e');
      return false;
    }
  }

  Future<bool> excluirAvaliacao(String avaliacaoId, String usuarioId) async {
    try {
      await _avaliacaoRepository.excluirAvaliacao(avaliacaoId);

      await _atualizarMediaAvaliacoes(usuarioId);

      notifyListeners();
      return true;
    } catch (e) {
      print('Erro ao excluir avaliação: $e');
      return false;
    }
  }

  Future<Avaliacao?> getAvaliacaoPorId(String avaliacaoId) async {
    try {
      return await _avaliacaoRepository.getAvaliacaoPorId(avaliacaoId);
    } catch (e) {
      print('Erro ao buscar avaliação: $e');
      return null;
    }
  }

  Future<bool> enviarDenuncia({
    required String motivo,
    required Usuario usuarioDenunciado,
    required Usuario usuarioDenunciante,
  }) async {
    try {
      print('🔄 Iniciando envio de denúncia...');

      await _firestore.collection('denuncias').add({
        'motivo': motivo,
        'usuarioDenunciadoId': usuarioDenunciado.id,
        'usuarioDenunciadoNome': usuarioDenunciado.nomeCompleto,
        'usuarioDenunciadoEmail': usuarioDenunciado.email,
        'usuarioDenuncianteId': usuarioDenunciante.id,
        'usuarioDenuncianteNome': usuarioDenunciante.nomeCompleto,
        'usuarioDenuncianteEmail': usuarioDenunciante.email,
        'data': FieldValue.serverTimestamp(),
        'status': 'pendente',
      });

      print('✅ Denúncia salva no Firestore!');

      try {
        await EmailService.enviarDenuncia(
          motivo: motivo,
          usuarioDenunciado: usuarioDenunciado.nomeCompleto,
          usuarioDenunciante: usuarioDenunciante.nomeCompleto,
          emailDenunciado: usuarioDenunciado.email,
          emailDenunciante: usuarioDenunciante.email,
        );
        print('✅ Email de denúncia enviado!');
      } catch (emailError) {
        print('⚠️ Email falhou, mas denúncia foi salva: $emailError');
      }

      return true;
    } catch (e) {
      print('❌ Erro ao processar denúncia: $e');
      return false;
    }
  }

  Stream<int> getTotalAvaliacoes(String usuarioId) {
    return _firestore
        .collection('avaliacoes')
        .where('usuarioAvaliadoId', isEqualTo: usuarioId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<List<Avaliacao>> getAvaliacoesRecentes(
    String usuarioId, {
    int limite = 5,
  }) {
    return _avaliacaoRepository.getAvaliacoesRecentes(
      usuarioId,
      limite: limite,
    );
  }


  @override
  void dispose() {
    super.dispose();
  }
}
