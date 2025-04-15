class Usuario {
  final int id;
  final String nome;
  final String email;
  final String senha;
  final String tipoUsuario; // aluno, professor ou responsavel
  final DateTime? dataNascimento;
  final String? genero;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.senha,
    required this.tipoUsuario,
    this.dataNascimento,
    this.genero,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      senha: json['senha'],
      tipoUsuario: json['tipo_usuario'],
      dataNascimento: json['data_nascimento'] != null
          ? DateTime.parse(json['data_nascimento'])
          : null,
      genero: json['genero'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha': senha,
      'tipo_usuario': tipoUsuario,
      'data_nascimento': dataNascimento?.toIso8601String(),
      'genero': genero,
    };
  }
}
