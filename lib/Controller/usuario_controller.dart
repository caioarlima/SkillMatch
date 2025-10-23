import 'package:flutter/material.dart';
import 'package:skilmatch/Repository/usuario_repository.dart';
import 'package:skilmatch/Model/Usuario.dart';

class UsuarioController with ChangeNotifier {
  final UsuarioRepository _usuarioRepository = UsuarioRepository();

  List<Usuario> _usuarios = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<Usuario> get usuarios => _usuarios;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  Future<Usuario?> buscarUsuarioPorId(String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final usuario = await _usuarioRepository.buscarUsuarioPorId(userId);
      return usuario;
    } catch (e) {
      _errorMessage = 'Erro ao buscar usuário: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> atualizarUsuario(Usuario usuario) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _usuarioRepository.salvarUsuario(usuario);

      final usuarioIndex = _usuarios.indexWhere((u) => u.id == usuario.id);
      if (usuarioIndex != -1) {
        _usuarios[usuarioIndex] = usuario;
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao atualizar usuário: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> adicionarProjeto(String userId, Projeto projeto) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _usuarioRepository.adicionarProjeto(userId, projeto);

      final usuarioIndex = _usuarios.indexWhere((u) => u.id == userId);
      if (usuarioIndex != -1) {
        final usuarioAtualizado = _usuarios[usuarioIndex].copyWith(
          projetos: [..._usuarios[usuarioIndex].projetos, projeto],
        );
        _usuarios[usuarioIndex] = usuarioAtualizado;
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao adicionar projeto: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removerProjeto(String userId, String projetoId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _usuarioRepository.removerProjeto(userId, projetoId);

      final usuarioIndex = _usuarios.indexWhere((u) => u.id == userId);
      if (usuarioIndex != -1) {
        final projetosAtualizados = _usuarios[usuarioIndex].projetos
            .where((projeto) => projeto.id != projetoId)
            .toList();
        final usuarioAtualizado = _usuarios[usuarioIndex].copyWith(
          projetos: projetosAtualizados,
        );
        _usuarios[usuarioIndex] = usuarioAtualizado;
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao remover projeto: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> carregarUsuariosPorCidade(
    String cidade, {
    String? excludeUserId,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _usuarios = await _usuarioRepository.buscarUsuariosPorCidade(
        cidade,
        excludeUserId: excludeUserId,
      );
    } catch (e) {
      _errorMessage = 'Erro ao carregar usuários: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> buscarUsuarios(String query, {String? excludeUserId}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _usuarios = await _usuarioRepository.buscarUsuarios(
        query,
        excludeUserId: excludeUserId,
      );
    } catch (e) {
      _errorMessage = 'Erro na busca: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void realizarBusca(
    String query,
    String? cidadeUsuario, {
    String? excludeUserId,
    String? excludedUserId,
  }) {
    _searchQuery = query;
    notifyListeners();

    if (query.isEmpty) {
      carregarUsuariosPorCidade(
        cidadeUsuario ?? '',
        excludeUserId: excludeUserId,
      );
    } else {
      buscarUsuarios(query, excludeUserId: excludeUserId);
    }
  }

  void limparUsuarios() {
    _usuarios = [];
    notifyListeners();
  }

  void limparErro() {
    _errorMessage = null;
    notifyListeners();
  }

  void limparBusca() {
    _searchQuery = '';
    notifyListeners();
  }

  Future<void> reportarUsuario({
    required String usuarioDenunciadoId,
    required String usuarioDenuncianteId,
    required String motivo,
    required String usuarioDenunciadoNome,
    required String usuarioDenuncianteNome,
    required String emailDenunciado,
    required String emailDenunciante,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _usuarioRepository.reportarUsuario(
        usuarioDenunciadoId: usuarioDenunciadoId,
        usuarioDenuncianteId: usuarioDenuncianteId,
        motivo: motivo,
        usuarioDenunciadoNome: usuarioDenunciadoNome,
        usuarioDenuncianteNome: usuarioDenuncianteNome,
        emailDenunciado: emailDenunciado,
        emailDenunciante: emailDenunciante,
      );

      print('✅ Denúncia registrada e email enviado com sucesso!');
    } catch (e) {
      _errorMessage = 'Erro ao reportar usuário: $e';
      print('❌ Erro na denúncia: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
