class Employee {
  final String id;
  final String fullName;
  final String email;
  final String password; // Em produção, seria criptografada
  final String accessProfile; // Admin, Manager, User, etc
  final String company;
  final String unit;
  final String status; // Ativo, Inativo
  final DateTime createdAt;
  final DateTime? lastAccess;
  final bool twoFactorEnabled;
  final String? ssoProvider; // google, microsoft, null

  Employee({
    required this.id,
    required this.fullName,
    required this.email,
    required this.password,
    required this.accessProfile,
    required this.company,
    required this.unit,
    required this.status,
    required this.createdAt,
    this.lastAccess,
    this.twoFactorEnabled = false,
    this.ssoProvider,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      accessProfile: json['accessProfile'] ?? 'User',
      company: json['company'] ?? '',
      unit: json['unit'] ?? '',
      status: json['status'] ?? 'Ativo',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastAccess: json['lastAccess'] != null ? DateTime.parse(json['lastAccess']) : null,
      twoFactorEnabled: json['twoFactorEnabled'] ?? false,
      ssoProvider: json['ssoProvider'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'password': password,
      'accessProfile': accessProfile,
      'company': company,
      'unit': unit,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'lastAccess': lastAccess?.toIso8601String(),
      'twoFactorEnabled': twoFactorEnabled,
      'ssoProvider': ssoProvider,
    };
  }

  Employee copyWith({
    String? id,
    String? fullName,
    String? email,
    String? password,
    String? accessProfile,
    String? company,
    String? unit,
    String? status,
    DateTime? createdAt,
    DateTime? lastAccess,
    bool? twoFactorEnabled,
    String? ssoProvider,
  }) {
    return Employee(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      accessProfile: accessProfile ?? this.accessProfile,
      company: company ?? this.company,
      unit: unit ?? this.unit,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastAccess: lastAccess ?? this.lastAccess,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      ssoProvider: ssoProvider ?? this.ssoProvider,
    );
  }
}
