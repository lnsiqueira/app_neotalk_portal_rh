import 'dart:convert';

/// Modelo de Benefício Corporativo
class CorporateBenefit {
  final String id;
  final String name;
  final String category; // Saúde, Alimentação, Mobilidade, Bem-estar, Educação, Família, Segurança, Fornecedor/Parceiro
  final String type; // Fixo, Flexível, Reembolso
  final String description;
  final String whatIsIncluded;
  final String eligibility; // Ex: "Após 90 dias"
  final bool allowsDependents;
  final double companyCost;
  final double employeeCost;
  final double dependentCost;
  final double coparticipationPercentage;
  final String periodicity; // Mensal, Anual, Pontual
  final bool isRequired;
  final String? policyPdfUrl;
  final String status; // Ativo, Inativo
  final DateTime createdAt;
  final DateTime? updatedAt;

  CorporateBenefit({
    required this.id,
    required this.name,
    required this.category,
    required this.type,
    required this.description,
    required this.whatIsIncluded,
    required this.eligibility,
    required this.allowsDependents,
    required this.companyCost,
    required this.employeeCost,
    required this.dependentCost,
    required this.coparticipationPercentage,
    required this.periodicity,
    required this.isRequired,
    this.policyPdfUrl,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'type': type,
      'description': description,
      'whatIsIncluded': whatIsIncluded,
      'eligibility': eligibility,
      'allowsDependents': allowsDependents,
      'companyCost': companyCost,
      'employeeCost': employeeCost,
      'dependentCost': dependentCost,
      'coparticipationPercentage': coparticipationPercentage,
      'periodicity': periodicity,
      'isRequired': isRequired,
      'policyPdfUrl': policyPdfUrl,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Cria a partir de JSON
  factory CorporateBenefit.fromJson(Map<String, dynamic> json) {
    return CorporateBenefit(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? 'Saúde',
      type: json['type'] ?? 'Fixo',
      description: json['description'] ?? '',
      whatIsIncluded: json['whatIsIncluded'] ?? '',
      eligibility: json['eligibility'] ?? '',
      allowsDependents: json['allowsDependents'] ?? false,
      companyCost: (json['companyCost'] ?? 0).toDouble(),
      employeeCost: (json['employeeCost'] ?? 0).toDouble(),
      dependentCost: (json['dependentCost'] ?? 0).toDouble(),
      coparticipationPercentage:
          (json['coparticipationPercentage'] ?? 0).toDouble(),
      periodicity: json['periodicity'] ?? 'Mensal',
      isRequired: json['isRequired'] ?? false,
      policyPdfUrl: json['policyPdfUrl'],
      status: json['status'] ?? 'Ativo',
      createdAt: DateTime.parse(
          json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  /// Cria cópia com mudanças
  CorporateBenefit copyWith({
    String? id,
    String? name,
    String? category,
    String? type,
    String? description,
    String? whatIsIncluded,
    String? eligibility,
    bool? allowsDependents,
    double? companyCost,
    double? employeeCost,
    double? dependentCost,
    double? coparticipationPercentage,
    String? periodicity,
    bool? isRequired,
    String? policyPdfUrl,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CorporateBenefit(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      type: type ?? this.type,
      description: description ?? this.description,
      whatIsIncluded: whatIsIncluded ?? this.whatIsIncluded,
      eligibility: eligibility ?? this.eligibility,
      allowsDependents: allowsDependents ?? this.allowsDependents,
      companyCost: companyCost ?? this.companyCost,
      employeeCost: employeeCost ?? this.employeeCost,
      dependentCost: dependentCost ?? this.dependentCost,
      coparticipationPercentage:
          coparticipationPercentage ?? this.coparticipationPercentage,
      periodicity: periodicity ?? this.periodicity,
      isRequired: isRequired ?? this.isRequired,
      policyPdfUrl: policyPdfUrl ?? this.policyPdfUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
