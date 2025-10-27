class Pessoa {
  int? id;
  String nome;
  String telefone;
  String? fotoPath;

  Pessoa({this.id, required this.nome, required this.telefone, this.fotoPath});

  Map<String, dynamic> toMap() {
    return {'id': id, 'nome': nome, 'telefone': telefone, 'fotoPath': fotoPath};
  }

  factory Pessoa.fromMap(Map<String, dynamic> map) {
    return Pessoa(
      id: map['id'],
      nome: map['nome'],
      telefone: map['telefone'],
      fotoPath: map['fotoPath'],
    );
  }
}
