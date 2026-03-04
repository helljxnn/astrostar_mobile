class User {
  final int id;
  final String email;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String? secondLastName;
  final String phoneNumber;
  final String address;
  final DateTime birthDate;
  final int age;
  final String identification;
  final String status;
  final int? avatarColorIndex;
  final DocumentType documentType;
  final Role role;
  final Employee? employee;
  final Athlete? athlete;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    this.middleName,
    required this.lastName,
    this.secondLastName,
    required this.phoneNumber,
    required this.address,
    required this.birthDate,
    required this.age,
    required this.identification,
    required this.status,
    this.avatarColorIndex,
    required this.documentType,
    required this.role,
    this.employee,
    this.athlete,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      middleName: json['middleName'],
      lastName: json['lastName'],
      secondLastName: json['secondLastName'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      birthDate: DateTime.parse(json['birthDate']),
      age: json['age'],
      identification: json['identification'],
      status: json['status'],
      avatarColorIndex: json['avatarColorIndex'],
      documentType: DocumentType.fromJson(json['documentType']),
      role: Role.fromJson(json['role']),
      employee: json['employee'] != null ? Employee.fromJson(json['employee']) : null,
      athlete: json['athlete'] != null ? Athlete.fromJson(json['athlete']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'secondLastName': secondLastName,
      'phoneNumber': phoneNumber,
      'address': address,
      'birthDate': birthDate.toIso8601String(),
      'age': age,
      'identification': identification,
      'status': status,
      'avatarColorIndex': avatarColorIndex,
      'documentType': documentType.toJson(),
      'role': role.toJson(),
      'employee': employee?.toJson(),
      'athlete': athlete?.toJson(),
    };
  }

  String get fullName {
    final parts = [firstName, middleName, lastName, secondLastName];
    return parts.where((p) => p != null && p.isNotEmpty).join(' ');
  }

  bool get isActive => status == 'Active';
}

class Role {
  final int id;
  final String name;
  final String? description;
  final Map<String, dynamic>? permissions;

  Role({
    required this.id,
    required this.name,
    this.description,
    this.permissions,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      permissions: json['permissions'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'permissions': permissions,
    };
  }

  // Helpers para verificar permisos
  bool hasPermission(String module, String action) {
    if (permissions == null) return false;
    final modulePerms = permissions![module] as Map<String, dynamic>?;
    if (modulePerms == null) return false;
    return modulePerms[action] == true;
  }

  bool canView(String module) => hasPermission(module, 'Ver');
  bool canCreate(String module) => hasPermission(module, 'Crear');
  bool canEdit(String module) => hasPermission(module, 'Editar');
  bool canDelete(String module) => hasPermission(module, 'Eliminar');
}

class DocumentType {
  final int id;
  final String name;

  DocumentType({required this.id, required this.name});

  factory DocumentType.fromJson(Map<String, dynamic> json) {
    return DocumentType(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class Employee {
  final int id;
  final String position;

  Employee({required this.id, required this.position});

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      position: json['position'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'position': position};
  }
}

class Athlete {
  final int id;
  final String category;

  Athlete({required this.id, required this.category});

  factory Athlete.fromJson(Map<String, dynamic> json) {
    return Athlete(
      id: json['id'],
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'category': category};
  }
}
