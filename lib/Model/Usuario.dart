import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  String? id;
  final String nomeCompleto;
  final String email;
  final String cpf;
  final String cidade;
  final String bio;
  final String? genero;
  final DateTime? dataNascimento;
  final String? fotoUrl;
  final List<Projeto> projetos;

  Usuario({
    this.id,
    required this.nomeCompleto,
    required this.email,
    required this.cpf,
    required this.cidade,
    required this.bio,
    this.genero,
    this.dataNascimento,
    this.fotoUrl,
    this.projetos = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nomeCompleto': nomeCompleto,
      'email': email,
      'cpf': cpf,
      'cidade': cidade,
      'bio': bio,
      'genero': genero,
      'dataNascimento': dataNascimento,
      'fotoUrl': fotoUrl,
      'projetos': projetos.map((projeto) => projeto.toMap()).toList(),
    };
  }

  factory Usuario.fromMap(String id, Map<String, dynamic> map) {
    return Usuario(
      id: id,
      nomeCompleto: map['nomeCompleto'] ?? '',
      email: map['email'] ?? '',
      cpf: map['cpf'] ?? '',
      cidade: map['cidade'] ?? '',
      bio: map['bio'] ?? '',
      genero: map['genero'],
      dataNascimento: map['dataNascimento'] is Timestamp
          ? (map['dataNascimento'] as Timestamp).toDate()
          : null,
      fotoUrl: map['fotoUrl'],
      projetos:
          (map['projetos'] as List?)
              ?.map((projetoMap) => Projeto.fromMap(projetoMap))
              .toList() ??
          [],
    );
  }

  Usuario copyWith({
    String? id,
    String? nomeCompleto,
    String? email,
    String? cpf,
    String? cidade,
    String? bio,
    String? genero,
    DateTime? dataNascimento,
    String? fotoUrl,
    List<Projeto>? projetos,
  }) {
    return Usuario(
      id: id ?? this.id,
      nomeCompleto: nomeCompleto ?? this.nomeCompleto,
      email: email ?? this.email,
      cpf: cpf ?? this.cpf,
      cidade: cidade ?? this.cidade,
      bio: bio ?? this.bio,
      genero: genero ?? this.genero,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      projetos: projetos ?? this.projetos,
    );
  }
}

class Projeto {
  final String id;
  final String titulo;
  final String descricao;
  final String? imagemUrl;
  final String? link;
  final DateTime dataCriacao;

  Projeto({
    required this.id,
    required this.titulo,
    required this.descricao,
    this.imagemUrl,
    this.link,
    required this.dataCriacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'imagemUrl': imagemUrl,
      'link': link,
      'dataCriacao': dataCriacao,
    };
  }

  factory Projeto.fromMap(Map<String, dynamic> map) {
    return Projeto(
      id: map['id'] ?? '',
      titulo: map['titulo'] ?? '',
      descricao: map['descricao'] ?? '',
      imagemUrl: map['imagemUrl'],
      link: map['link'],
      dataCriacao: (map['dataCriacao'] is Timestamp)
          ? (map['dataCriacao'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Projeto copyWith({
    String? id,
    String? titulo,
    String? descricao,
    String? imagemUrl,
    String? link,
    DateTime? dataCriacao,
  }) {
    return Projeto(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      imagemUrl: imagemUrl ?? this.imagemUrl,
      link: link ?? this.link,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }
}
