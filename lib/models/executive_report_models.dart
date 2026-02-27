/// Modelo para dados de custo de benefício
class BenefitCostData {
  final String benefitId;
  final String benefitName;
  final String category;
  final double monthlyCost;
  final double annualProjectedCost;
  final double costPerEmployee;
  final double costPerCostCenter;
  final List<MonthlyCostHistory> monthlyCostHistory;
  final int totalEmployees;
  final int activeCostCenters;

  BenefitCostData({
    required this.benefitId,
    required this.benefitName,
    required this.category,
    required this.monthlyCost,
    required this.annualProjectedCost,
    required this.costPerEmployee,
    required this.costPerCostCenter,
    required this.monthlyCostHistory,
    required this.totalEmployees,
    required this.activeCostCenters,
  });

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'benefitId': benefitId,
      'benefitName': benefitName,
      'category': category,
      'monthlyCost': monthlyCost,
      'annualProjectedCost': annualProjectedCost,
      'costPerEmployee': costPerEmployee,
      'costPerCostCenter': costPerCostCenter,
      'monthlyCostHistory': monthlyCostHistory.map((e) => e.toJson()).toList(),
      'totalEmployees': totalEmployees,
      'activeCostCenters': activeCostCenters,
    };
  }

  /// Cria a partir de JSON
  factory BenefitCostData.fromJson(Map<String, dynamic> json) {
    return BenefitCostData(
      benefitId: json['benefitId'] ?? '',
      benefitName: json['benefitName'] ?? '',
      category: json['category'] ?? '',
      monthlyCost: (json['monthlyCost'] ?? 0).toDouble(),
      annualProjectedCost: (json['annualProjectedCost'] ?? 0).toDouble(),
      costPerEmployee: (json['costPerEmployee'] ?? 0).toDouble(),
      costPerCostCenter: (json['costPerCostCenter'] ?? 0).toDouble(),
      monthlyCostHistory: (json['monthlyCostHistory'] as List?)
              ?.map((e) => MonthlyCostHistory.fromJson(e))
              .toList() ??
          [],
      totalEmployees: json['totalEmployees'] ?? 0,
      activeCostCenters: json['activeCostCenters'] ?? 0,
    );
  }

  /// Copia com mudanças
  BenefitCostData copyWith({
    String? benefitId,
    String? benefitName,
    String? category,
    double? monthlyCost,
    double? annualProjectedCost,
    double? costPerEmployee,
    double? costPerCostCenter,
    List<MonthlyCostHistory>? monthlyCostHistory,
    int? totalEmployees,
    int? activeCostCenters,
  }) {
    return BenefitCostData(
      benefitId: benefitId ?? this.benefitId,
      benefitName: benefitName ?? this.benefitName,
      category: category ?? this.category,
      monthlyCost: monthlyCost ?? this.monthlyCost,
      annualProjectedCost: annualProjectedCost ?? this.annualProjectedCost,
      costPerEmployee: costPerEmployee ?? this.costPerEmployee,
      costPerCostCenter: costPerCostCenter ?? this.costPerCostCenter,
      monthlyCostHistory: monthlyCostHistory ?? this.monthlyCostHistory,
      totalEmployees: totalEmployees ?? this.totalEmployees,
      activeCostCenters: activeCostCenters ?? this.activeCostCenters,
    );
  }
}

/// Modelo para histórico mensal de custos
class MonthlyCostHistory {
  final String month;
  final int year;
  final double totalCost;
  final int employeesUtilizing;
  final double averageCostPerEmployee;

  MonthlyCostHistory({
    required this.month,
    required this.year,
    required this.totalCost,
    required this.employeesUtilizing,
    required this.averageCostPerEmployee,
  });

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'year': year,
      'totalCost': totalCost,
      'employeesUtilizing': employeesUtilizing,
      'averageCostPerEmployee': averageCostPerEmployee,
    };
  }

  /// Cria a partir de JSON
  factory MonthlyCostHistory.fromJson(Map<String, dynamic> json) {
    return MonthlyCostHistory(
      month: json['month'] ?? '',
      year: json['year'] ?? 0,
      totalCost: (json['totalCost'] ?? 0).toDouble(),
      employeesUtilizing: json['employeesUtilizing'] ?? 0,
      averageCostPerEmployee:
          (json['averageCostPerEmployee'] ?? 0).toDouble(),
    );
  }

  /// Retorna mês abreviado (Jan, Fev, etc)
  String get monthAbbr {
    const months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez'
    ];
    try {
      final monthNum = int.parse(month);
      return months[monthNum - 1];
    } catch (e) {
      return month;
    }
  }

  /// Retorna mês formatado (Jan/2024)
  String get monthFormatted => '$monthAbbr/$year';
}

/// Modelo para resumo de relatório
class ExecutiveReportSummary {
  final double totalMonthlyCost;
  final double totalAnnualProjectedCost;
  final int totalBenefits;
  final int totalEmployees;
  final double averageCostPerEmployee;
  final List<BenefitCostData> benefitCosts;

  ExecutiveReportSummary({
    required this.totalMonthlyCost,
    required this.totalAnnualProjectedCost,
    required this.totalBenefits,
    required this.totalEmployees,
    required this.averageCostPerEmployee,
    required this.benefitCosts,
  });

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'totalMonthlyCost': totalMonthlyCost,
      'totalAnnualProjectedCost': totalAnnualProjectedCost,
      'totalBenefits': totalBenefits,
      'totalEmployees': totalEmployees,
      'averageCostPerEmployee': averageCostPerEmployee,
      'benefitCosts': benefitCosts.map((e) => e.toJson()).toList(),
    };
  }

  /// Cria a partir de JSON
  factory ExecutiveReportSummary.fromJson(Map<String, dynamic> json) {
    return ExecutiveReportSummary(
      totalMonthlyCost: (json['totalMonthlyCost'] ?? 0).toDouble(),
      totalAnnualProjectedCost:
          (json['totalAnnualProjectedCost'] ?? 0).toDouble(),
      totalBenefits: json['totalBenefits'] ?? 0,
      totalEmployees: json['totalEmployees'] ?? 0,
      averageCostPerEmployee:
          (json['averageCostPerEmployee'] ?? 0).toDouble(),
      benefitCosts: (json['benefitCosts'] as List?)
              ?.map((e) => BenefitCostData.fromJson(e))
              .toList() ??
          [],
    );
  }
}
