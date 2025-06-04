class RegisterData {
  String? objetivo;
  String? nivelActividad;
  String? genero;
  double? altura;
  int? edad;
  double? peso;
  List<String>? intereses;
  String? nombre;
  String? username;
  String? tipoUsuario;
  int? anosExperiencia;

  RegisterData({
    this.objetivo,
    this.nivelActividad,
    this.genero,
    this.altura,
    this.edad,
    this.peso,
    this.intereses,
    this.nombre,
    this.username,
    this.tipoUsuario,
    this.anosExperiencia,
  });

  RegisterData copyWith({
    String? objetivo,
    String? nivelActividad,
    String? genero,
    double? altura,
    int? edad,
    double? peso,
    List<String>? intereses,
    String? nombre,
    String? username,
    String? tipoUsuario,
    int? anosExperiencia,
  }) {
    return RegisterData(
      objetivo: objetivo ?? this.objetivo,
      nivelActividad: nivelActividad ?? this.nivelActividad,
      genero: genero ?? this.genero,
      altura: altura ?? this.altura,
      edad: edad ?? this.edad,
      peso: peso ?? this.peso,
      intereses: intereses ?? this.intereses,
      nombre: nombre ?? this.nombre,
      username: username ?? this.username,
      tipoUsuario: tipoUsuario ?? this.tipoUsuario,
      anosExperiencia: anosExperiencia ?? this.anosExperiencia,
    );
  }
} 