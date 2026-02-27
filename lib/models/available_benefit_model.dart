class AvailableBenefit {
  final String id;
  final String name;
  final String category;
  final String icon;
  final String description;
  final String details;
  final String discount;
  final String monthlyBenefit;
  final List<String> requirements;
  final String terms;

  AvailableBenefit({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.description,
    required this.details,
    required this.discount,
    required this.monthlyBenefit,
    required this.requirements,
    required this.terms,
  });

  factory AvailableBenefit.fromJson(Map<String, dynamic> json) {
    return AvailableBenefit(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Benefício',
      category: json['category'] ?? 'Geral',
      icon: json['icon'] ?? 'card_giftcard',
      description: json['description'] ?? 'Sem descrição',
      details: json['details'] ?? 'Sem detalhes',
      discount: json['discount'] ?? 'N/A',
      monthlyBenefit: json['monthlyBenefit'] ?? 'Variável',
      requirements: List<String>.from(json['requirements'] ?? []),
      terms: json['terms'] ?? 'Termos padrão',
    );
  }
}

class BenefitEligibility {
  final String benefitId;
  final bool eligible;
  final String reason;

  BenefitEligibility({
    required this.benefitId,
    required this.eligible,
    required this.reason,
  });

  factory BenefitEligibility.fromJson(Map<String, dynamic> json) {
    return BenefitEligibility(
      benefitId: json['benefitId'] ?? '',
      eligible: json['eligible'] ?? false,
      reason: json['reason'] ?? '',
    );
  }
}
