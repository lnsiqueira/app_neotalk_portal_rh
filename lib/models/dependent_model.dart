import 'package:intl/intl.dart';

class Dependent {
  final String id;
  final String name;
  final String relationship; // Filho, Cônjuge, Pai, Mãe, etc
  final String birthDate; // Formato: yyyy-MM-dd
  final String cpf;
  final String documentType; // Certidão de Nascimento, RG, etc
  final String documentPath; // Caminho do arquivo
  final String documentName; // Nome do arquivo
  final String status; // Ativo, Inativo
  final DateTime createdAt;
  final DateTime updatedAt;

  Dependent({
    required this.id,
    required this.name,
    required this.relationship,
    required this.birthDate,
    required this.cpf,
    required this.documentType,
    required this.documentPath,
    required this.documentName,
    this.status = 'Ativo',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Getter para idade
  int get age {
    final birthDateTime = DateTime.parse(birthDate);
    final today = DateTime.now();
    int age = today.year - birthDateTime.year;
    if (today.month < birthDateTime.month ||
        (today.month == birthDateTime.month && today.day < birthDateTime.day)) {
      age--;
    }
    return age;
  }

  // Getter para data formatada
  String get formattedBirthDate {
    try {
      final date = DateTime.parse(birthDate);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return birthDate;
    }
  }

  // Getter para data de criação formatada
  String get formattedCreatedAt {
    return DateFormat('dd/MM/yyyy HH:mm').format(createdAt);
  }

  // Getter para tipo de relacionamento em português
  String get relationshipLabel {
    switch (relationship) {
      case 'filho':
        return 'Filho(a)';
      case 'conjuge':
        return 'Cônjuge';
      case 'pai':
        return 'Pai';
      case 'mae':
        return 'Mãe';
      case 'irma':
        return 'Irmã';
      case 'irmao':
        return 'Irmão';
      default:
        return relationship;
    }
  }

  // Getter para ícone do relacionamento
  String get relationshipIcon {
    switch (relationship) {
      case 'filho':
        return '👶';
      case 'conjuge':
        return '💑';
      case 'pai':
        return '👨';
      case 'mae':
        return '👩';
      case 'irma':
        return '👧';
      case 'irmao':
        return '👦';
      default:
        return '👤';
    }
  }

  // copyWith
  Dependent copyWith({
    String? id,
    String? name,
    String? relationship,
    String? birthDate,
    String? cpf,
    String? documentType,
    String? documentPath,
    String? documentName,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Dependent(
      id: id ?? this.id,
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      birthDate: birthDate ?? this.birthDate,
      cpf: cpf ?? this.cpf,
      documentType: documentType ?? this.documentType,
      documentPath: documentPath ?? this.documentPath,
      documentName: documentName ?? this.documentName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'relationship': relationship,
      'birthDate': birthDate,
      'cpf': cpf,
      'documentType': documentType,
      'documentPath': documentPath,
      'documentName': documentName,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // fromJson
  factory Dependent.fromJson(Map<String, dynamic> json) {
    return Dependent(
      id: json['id'] as String,
      name: json['name'] as String,
      relationship: json['relationship'] as String,
      birthDate: json['birthDate'] as String,
      cpf: json['cpf'] as String,
      documentType: json['documentType'] as String,
      documentPath: json['documentPath'] as String,
      documentName: json['documentName'] as String,
      status: json['status'] as String? ?? 'Ativo',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'Dependent(id: $id, name: $name, relationship: $relationship, age: $age)';
  }
}
