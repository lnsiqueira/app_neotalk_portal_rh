import 'package:app_neotalk_portal_rh/models/executive_report_models.dart';

/// Serviço para dados de relatórios executivos
class ExecutiveReportService {
  /// Cache de dados
  static final Map<String, dynamic> _cache = {};

  /// Dados mockados de benefícios com custos
  static final List<Map<String, dynamic>> _benefitsCostData = [
    {
      'benefitId': 'SAUDE001',
      'benefitName': 'Assistência Médica',
      'category': 'Saúde',
      'monthlyCost': 45256.00,
      'annualProjectedCost': 540000.00,
      'costPerEmployee': 300.00,
      'costPerCostCenter': 4500.00,
      'totalEmployees': 150,
      'activeCostCenters': 10,
      'monthlyCostHistory': [
        {
          'month': '1',
          'year': 2024,
          'totalCost': 42000.00,
          'employeesUtilizing': 145,
          'averageCostPerEmployee': 289.66,
        },
        {
          'month': '2',
          'year': 2024,
          'totalCost': 43500.00,
          'employeesUtilizing': 148,
          'averageCostPerEmployee': 293.92,
        },
        {
          'month': '3',
          'year': 2024,
          'totalCost': 44200.00,
          'employeesUtilizing': 149,
          'averageCostPerEmployee': 296.64,
        },
        {
          'month': '4',
          'year': 2024,
          'totalCost': 44800.00,
          'employeesUtilizing': 150,
          'averageCostPerEmployee': 298.67,
        },
        {
          'month': '5',
          'year': 2024,
          'totalCost': 45200.00,
          'employeesUtilizing': 150,
          'averageCostPerEmployee': 301.33,
        },
        {
          'month': '6',
          'year': 2024,
          'totalCost': 45000.00,
          'employeesUtilizing': 150,
          'averageCostPerEmployee': 300.00,
        },
      ],
    },
    {
      'benefitId': 'TRANS001',
      'benefitName': 'VT',
      'category': 'Mobilidade',
      'monthlyCost': 18000.00,
      'annualProjectedCost': 216000.00,
      'costPerEmployee': 120.00,
      'costPerCostCenter': 1800.00,
      'totalEmployees': 150,
      'activeCostCenters': 10,
      'monthlyCostHistory': [
        {
          'month': '1',
          'year': 2024,
          'totalCost': 17500.00,
          'employeesUtilizing': 145,
          'averageCostPerEmployee': 120.69,
        },
        {
          'month': '2',
          'year': 2024,
          'totalCost': 17800.00,
          'employeesUtilizing': 148,
          'averageCostPerEmployee': 120.27,
        },
        {
          'month': '3',
          'year': 2024,
          'totalCost': 18000.00,
          'employeesUtilizing': 150,
          'averageCostPerEmployee': 120.00,
        },
        {
          'month': '4',
          'year': 2024,
          'totalCost': 18200.00,
          'employeesUtilizing': 150,
          'averageCostPerEmployee': 121.33,
        },
        {
          'month': '5',
          'year': 2024,
          'totalCost': 18100.00,
          'employeesUtilizing': 150,
          'averageCostPerEmployee': 120.67,
        },
        {
          'month': '6',
          'year': 2024,
          'totalCost': 18000.00,
          'employeesUtilizing': 150,
          'averageCostPerEmployee': 120.00,
        },
      ],
    },
    {
      'benefitId': 'ALIM001',
      'benefitName': 'VA',
      'category': 'Alimentação',
      'monthlyCost': 30000.00,
      'annualProjectedCost': 360000.00,
      'costPerEmployee': 200.00,
      'costPerCostCenter': 3000.00,
      'totalEmployees': 150,
      'activeCostCenters': 10,
      'monthlyCostHistory': [
        {
          'month': '1',
          'year': 2024,
          'totalCost': 28500.00,
          'employeesUtilizing': 142,
          'averageCostPerEmployee': 200.70,
        },
        {
          'month': '2',
          'year': 2024,
          'totalCost': 29200.00,
          'employeesUtilizing': 146,
          'averageCostPerEmployee': 200.00,
        },
        {
          'month': '3',
          'year': 2024,
          'totalCost': 29800.00,
          'employeesUtilizing': 149,
          'averageCostPerEmployee': 200.00,
        },
        {
          'month': '4',
          'year': 2024,
          'totalCost': 30200.00,
          'employeesUtilizing': 150,
          'averageCostPerEmployee': 201.33,
        },
        {
          'month': '5',
          'year': 2024,
          'totalCost': 30100.00,
          'employeesUtilizing': 150,
          'averageCostPerEmployee': 200.67,
        },
        {
          'month': '6',
          'year': 2024,
          'totalCost': 30000.00,
          'employeesUtilizing': 150,
          'averageCostPerEmployee': 200.00,
        },
      ],
    },
    {
      'benefitId': 'GYM001',
      'benefitName': 'Gympass Gold',
      'category': 'Bem-estar',
      'monthlyCost': 12000.00,
      'annualProjectedCost': 144000.00,
      'costPerEmployee': 80.00,
      'costPerCostCenter': 1200.00,
      'totalEmployees': 150,
      'activeCostCenters': 10,
      'monthlyCostHistory': [
        {
          'month': '1',
          'year': 2024,
          'totalCost': 10500.00,
          'employeesUtilizing': 87,
          'averageCostPerEmployee': 120.69,
        },
        {
          'month': '2',
          'year': 2024,
          'totalCost': 11000.00,
          'employeesUtilizing': 92,
          'averageCostPerEmployee': 119.57,
        },
        {
          'month': '3',
          'year': 2024,
          'totalCost': 11500.00,
          'employeesUtilizing': 96,
          'averageCostPerEmployee': 119.79,
        },
        {
          'month': '4',
          'year': 2024,
          'totalCost': 11800.00,
          'employeesUtilizing': 98,
          'averageCostPerEmployee': 120.41,
        },
        {
          'month': '5',
          'year': 2024,
          'totalCost': 12000.00,
          'employeesUtilizing': 100,
          'averageCostPerEmployee': 120.00,
        },
        {
          'month': '6',
          'year': 2024,
          'totalCost': 12000.00,
          'employeesUtilizing': 100,
          'averageCostPerEmployee': 120.00,
        },
      ],
    },
    {
      'benefitId': 'EDUC001',
      'benefitName': 'Creche',
      'category': 'Educação',
      'monthlyCost': 8000.00,
      'annualProjectedCost': 96000.00,
      'costPerEmployee': 53.33,
      'costPerCostCenter': 800.00,
      'totalEmployees': 150,
      'activeCostCenters': 10,
      'monthlyCostHistory': [
        {
          'month': '1',
          'year': 2024,
          'totalCost': 7000.00,
          'employeesUtilizing': 35,
          'averageCostPerEmployee': 200.00,
        },
        {
          'month': '2',
          'year': 2024,
          'totalCost': 7300.00,
          'employeesUtilizing': 37,
          'averageCostPerEmployee': 197.30,
        },
        {
          'month': '3',
          'year': 2024,
          'totalCost': 7600.00,
          'employeesUtilizing': 38,
          'averageCostPerEmployee': 200.00,
        },
        {
          'month': '4',
          'year': 2024,
          'totalCost': 7900.00,
          'employeesUtilizing': 40,
          'averageCostPerEmployee': 197.50,
        },
        {
          'month': '5',
          'year': 2024,
          'totalCost': 8000.00,
          'employeesUtilizing': 40,
          'averageCostPerEmployee': 200.00,
        },
        {
          'month': '6',
          'year': 2024,
          'totalCost': 8000.00,
          'employeesUtilizing': 40,
          'averageCostPerEmployee': 200.00,
        },
      ],
    },
  ];

  /// Obtém todos os benefícios com custos
  static Future<List<BenefitCostData>> getAllBenefitsCosts() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return _benefitsCostData.map((data) {
      return BenefitCostData.fromJson(data);
    }).toList();
  }

  /// Obtém custo de um benefício específico
  static Future<BenefitCostData?> getBenefitCost(String benefitId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final data = _benefitsCostData.firstWhere(
        (b) => b['benefitId'] == benefitId,
      );
      return BenefitCostData.fromJson(data);
    } catch (e) {
      print('Erro ao carregar custo do benefício: $e');
      return null;
    }
  }

  /// Obtém resumo executivo
  static Future<ExecutiveReportSummary> getExecutiveReportSummary() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final benefitsCosts = await getAllBenefitsCosts();

    double totalMonthlyCost = 0;
    double totalAnnualProjectedCost = 0;

    for (final benefit in benefitsCosts) {
      totalMonthlyCost += benefit.monthlyCost;
      totalAnnualProjectedCost += benefit.annualProjectedCost;
    }

    return ExecutiveReportSummary(
      totalMonthlyCost: totalMonthlyCost,
      totalAnnualProjectedCost: totalAnnualProjectedCost,
      totalBenefits: benefitsCosts.length,
      totalEmployees: 150,
      averageCostPerEmployee: totalMonthlyCost / 150,
      benefitCosts: benefitsCosts,
    );
  }

  /// Obtém histórico mensal para um benefício
  static Future<List<MonthlyCostHistory>> getMonthlyCostHistory(
    String benefitId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final data = _benefitsCostData.firstWhere(
        (b) => b['benefitId'] == benefitId,
      );

      final history =
          (data['monthlyCostHistory'] as List?)
              ?.map((e) => MonthlyCostHistory.fromJson(e))
              .toList() ??
          [];

      return history;
    } catch (e) {
      print('Erro ao carregar histórico: $e');
      return [];
    }
  }

  /// Limpa cache
  static void clearCache() {
    _cache.clear();
  }
}
