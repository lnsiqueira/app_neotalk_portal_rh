import 'package:app_neotalk_portal_rh/models/benefit_management_model.dart';

/// Serviço de gestão de benefícios corporativos
class BenefitManagementService {
  /// Cache de dados
  static final Map<String, dynamic> _cache = {};

  /// Lista de benefícios
  static final List<CorporateBenefit> _benefits = [
    CorporateBenefit(
      id: 'BEN001',
      name: 'Plano de Saúde Unimed',
      category: 'Saúde',
      type: 'Fixo',
      description: 'Plano de saúde com cobertura nacional',
      whatIsIncluded: 'Consultas, exames, internação, procedimentos',
      eligibility: 'Após 90 dias',
      allowsDependents: true,
      companyCost: 450.00,
      employeeCost: 50.00,
      dependentCost: 150.00,
      coparticipationPercentage: 20.0,
      periodicity: 'Mensal',
      isRequired: true,
      policyPdfUrl: null,
      status: 'Ativo',
      createdAt: DateTime(2023, 1, 15),
    ),
    CorporateBenefit(
      id: 'BEN002',
      name: 'Vale Alimentação',
      category: 'Alimentação',
      type: 'Flexível',
      description: 'Vale para alimentação em restaurantes e supermercados',
      whatIsIncluded: 'Refeições em restaurantes, compras em supermercados',
      eligibility: 'Imediato',
      allowsDependents: false,
      companyCost: 300.00,
      employeeCost: 100.00,
      dependentCost: 0.00,
      coparticipationPercentage: 25.0,
      periodicity: 'Mensal',
      isRequired: false,
      policyPdfUrl: null,
      status: 'Ativo',
      createdAt: DateTime(2023, 1, 15),
    ),
    CorporateBenefit(
      id: 'BEN003',
      name: 'Vale Transporte',
      category: 'Mobilidade',
      type: 'Fixo',
      description: 'Vale para transporte público',
      whatIsIncluded: 'Ônibus, metrô, trem',
      eligibility: 'Imediato',
      allowsDependents: false,
      companyCost: 180.00,
      employeeCost: 20.00,
      dependentCost: 0.00,
      coparticipationPercentage: 10.0,
      periodicity: 'Mensal',
      isRequired: false,
      policyPdfUrl: null,
      status: 'Ativo',
      createdAt: DateTime(2023, 1, 15),
    ),
    CorporateBenefit(
      id: 'BEN004',
      name: 'Gympass Gold',
      category: 'Bem-estar',
      type: 'Flexível',
      description: 'Acesso a academias e estúdios de fitness',
      whatIsIncluded: 'Academia, pilates, yoga, dança',
      eligibility: 'Imediato',
      allowsDependents: true,
      companyCost: 120.00,
      employeeCost: 0.00,
      dependentCost: 60.00,
      coparticipationPercentage: 0.0,
      periodicity: 'Mensal',
      isRequired: false,
      policyPdfUrl: null,
      status: 'Ativo',
      createdAt: DateTime(2023, 2, 20),
    ),
    CorporateBenefit(
      id: 'BEN005',
      name: 'Auxílio Educação',
      category: 'Educação',
      type: 'Reembolso',
      description: 'Auxílio para cursos e treinamentos',
      whatIsIncluded: 'Cursos profissionais, idiomas, pós-graduação',
      eligibility: 'Após 12 meses',
      allowsDependents: true,
      companyCost: 200.00,
      employeeCost: 0.00,
      dependentCost: 100.00,
      coparticipationPercentage: 50.0,
      periodicity: 'Anual',
      isRequired: false,
      policyPdfUrl: null,
      status: 'Ativo',
      createdAt: DateTime(2023, 3, 10),
    ),
    CorporateBenefit(
      id: 'BEN006',
      name: 'Auxílio Creche',
      category: 'Família',
      type: 'Reembolso',
      description: 'Auxílio para creche e pré-escola',
      whatIsIncluded: 'Creche, pré-escola, babá',
      eligibility: 'Filhos até 5 anos',
      allowsDependents: true,
      companyCost: 500.00,
      employeeCost: 0.00,
      dependentCost: 0.00,
      coparticipationPercentage: 0.0,
      periodicity: 'Mensal',
      isRequired: false,
      policyPdfUrl: null,
      status: 'Ativo',
      createdAt: DateTime(2023, 4, 5),
    ),
  ];

  /// Obtém todos os benefícios
  static Future<List<CorporateBenefit>> getAllBenefits() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_benefits);
  }

  /// Obtém benefício por ID
  static Future<CorporateBenefit?> getBenefitById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      return _benefits.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Adiciona novo benefício
  static Future<CorporateBenefit> addBenefit(CorporateBenefit benefit) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Gera ID único
    final newId = 'BEN${_benefits.length + 1}';
    final newBenefit = benefit.copyWith(id: newId, createdAt: DateTime.now());

    _benefits.add(newBenefit);
    _cache.clear();

    print('✅ Benefício adicionado: ${newBenefit.name}');
    return newBenefit;
  }

  /// Atualiza benefício
  static Future<CorporateBenefit?> updateBenefit(
    String id,
    CorporateBenefit benefit,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final index = _benefits.indexWhere((b) => b.id == id);
      if (index != -1) {
        final updated = benefit.copyWith(id: id, updatedAt: DateTime.now());
        _benefits[index] = updated;
        _cache.clear();

        print('✅ Benefício atualizado: ${updated.name}');
        return updated;
      }
      return null;
    } catch (e) {
      print('❌ Erro ao atualizar benefício: $e');
      return null;
    }
  }

  /// Remove benefício
  static Future<bool> deleteBenefit(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final index = _benefits.indexWhere((b) => b.id == id);
      if (index != -1) {
        final removed = _benefits.removeAt(index);
        _cache.clear();

        print('✅ Benefício removido: ${removed.name}');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Erro ao remover benefício: $e');
      return false;
    }
  }

  /// Busca benefícios por nome
  static Future<List<CorporateBenefit>> searchBenefits(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (query.isEmpty) {
      return List.from(_benefits);
    }

    return _benefits
        .where(
          (b) =>
              b.name.toLowerCase().contains(query.toLowerCase()) ||
              b.category.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  /// Filtra benefícios por categoria
  static Future<List<CorporateBenefit>> filterByCategory(
    String category,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (category.isEmpty) {
      return List.from(_benefits);
    }

    return _benefits.where((b) => b.category == category).toList();
  }

  /// Filtra benefícios por status
  static Future<List<CorporateBenefit>> filterByStatus(String status) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (status.isEmpty) {
      return List.from(_benefits);
    }

    return _benefits.where((b) => b.status == status).toList();
  }

  /// Obtém estatísticas
  static Future<Map<String, dynamic>> getStatistics() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final totalBenefits = _benefits.length;
    final activeBenefits = _benefits.where((b) => b.status == 'Ativo').length;
    final inactiveBenefits = _benefits
        .where((b) => b.status == 'Inativo')
        .length;

    final categories = <String, int>{};
    for (final benefit in _benefits) {
      categories[benefit.category] = (categories[benefit.category] ?? 0) + 1;
    }

    double totalCost = 0;
    for (final benefit in _benefits) {
      totalCost += benefit.companyCost;
    }

    return {
      'totalBenefits': totalBenefits,
      'activeBenefits': activeBenefits,
      'inactiveBenefits': inactiveBenefits,
      'categories': categories,
      'totalMonthlyCost': totalCost,
    };
  }

  /// Obtém lista de categorias disponíveis
  static List<String> getCategories() {
    return [
      'Saúde',
      'Alimentação',
      'Mobilidade',
      'Bem-estar',
      'Educação',
      'Família',
      'Segurança',
      'Fornec/Parceiro',
    ];
  }

  /// Obtém lista de tipos disponíveis
  static List<String> getTypes() {
    return ['Fixo', 'Flexível', 'Reembolso'];
  }

  /// Obtém lista de periodicidades
  static List<String> getPeriodicities() {
    return ['Mensal', 'Anual', 'Pontual'];
  }

  /// Limpa cache
  static void clearCache() {
    _cache.clear();
  }
}
