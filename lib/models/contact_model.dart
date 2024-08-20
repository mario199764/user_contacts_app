class Contact {
  final int? id;
  final String name;
  final String identification;

  Contact({this.id, required this.name, required this.identification});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'identification': identification,
    };
  }

  static Contact fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      name: map['name'],
      identification: map['identification'],
    );
  }
}
