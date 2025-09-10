class Usuario {
  String? id;
  final String nomeCompleto;
  final String email;
  final String cpf;
  final String cidade;
  final String bio;
  final String? genero;
  final DateTime? dataNascimento;

  Usuario({
    this.id,
    required this.nomeCompleto,
    required this.email,
    required this.cpf,
    required this.cidade,
    required this.bio,
    this.genero,
    this.dataNascimento,
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
      'dataNascimento': dataNascimento?.toIso8601String(),
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
      dataNascimento: map['dataNascimento'] != null 
          ? DateTime.parse(map['dataNascimento'])
          : null,
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
    );
  }
}