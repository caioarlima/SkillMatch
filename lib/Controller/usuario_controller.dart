import 'package:flutter/material.dart';
import 'package:skilmatch/Repository/usuario_repository.dart';
import 'package:skilmatch/Model/usuario.dart';

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

  Future<void> carregarUsuariosPorCidade(String cidade, {String? excludeUserId}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      _usuarios = await _usuarioRepository.buscarUsuariosPorCidade(
        cidade, 
        excludeUserId: excludeUserId
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
        excludeUserId: excludeUserId
      );
    } catch (e) {
      _errorMessage = 'Erro na busca: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void realizarBusca(String query, String? cidadeUsuario, {String? excludeUserId}) {
    _searchQuery = query;
    notifyListeners();
    
    if (query.isEmpty) {
      carregarUsuariosPorCidade(cidadeUsuario ?? '', excludeUserId: excludeUserId);
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
}