class BenefitUsageData {
  final String benefitName;
  final int usageCount;
  final double percentage;

  BenefitUsageData({
    required this.benefitName,
    required this.usageCount,
    required this.percentage,
  });
}

class UserEngagementData {
  final String userName;
  final int accessCount;
  final double engagementScore;

  UserEngagementData({
    required this.userName,
    required this.accessCount,
    required this.engagementScore,
  });
}

class RHDashboardMetrics {
  final int totalEmployees;
  final int totalBenefitsActive;
  final double averageEngagement;
  final int totalRequests;
  final double benefitAdoptionRate;
  final int pendingApprovals;

  RHDashboardMetrics({
    required this.totalEmployees,
    required this.totalBenefitsActive,
    required this.averageEngagement,
    required this.totalRequests,
    required this.benefitAdoptionRate,
    required this.pendingApprovals,
  });
}

class RHDashboardService {
  static RHDashboardMetrics getMetrics() {
    return RHDashboardMetrics(
      totalEmployees: 150,
      totalBenefitsActive: 12,
      averageEngagement: 78.5,
      totalRequests: 245,
      benefitAdoptionRate: 85.3,
      pendingApprovals: 12,
    );
  }

  static List<BenefitUsageData> getMostUsedBenefits() {
    return [
      BenefitUsageData(
        benefitName: 'Plano de Saúde',
        usageCount: 145,
        percentage: 96.7,
      ),
      BenefitUsageData(
        benefitName: 'Vale Transporte',
        usageCount: 128,
        percentage: 85.3,
      ),
      BenefitUsageData(
        benefitName: 'Vale Alimentação',
        usageCount: 142,
        percentage: 94.7,
      ),
      BenefitUsageData(
        benefitName: 'Auxílio Educação',
        usageCount: 67,
        percentage: 44.7,
      ),
      BenefitUsageData(
        benefitName: 'Gympass',
        usageCount: 89,
        percentage: 59.3,
      ),
    ];
  }

  static List<BenefitUsageData> getLeastUsedBenefits() {
    return [
      BenefitUsageData(
        benefitName: 'Creche Auxílio',
        usageCount: 12,
        percentage: 8.0,
      ),
      BenefitUsageData(
        benefitName: 'Seguro de Vida',
        usageCount: 28,
        percentage: 18.7,
      ),
      BenefitUsageData(
        benefitName: 'Bem-estar Mental',
        usageCount: 35,
        percentage: 23.3,
      ),
      BenefitUsageData(
        benefitName: 'Desconto Farmácia',
        usageCount: 42,
        percentage: 28.0,
      ),
      BenefitUsageData(
        benefitName: 'Programa Bem-estar',
        usageCount: 51,
        percentage: 34.0,
      ),
    ];
  }

  static List<UserEngagementData> getUserEngagement() {
    return [
      UserEngagementData(
        userName: 'Ana Silva',
        accessCount: 45,
        engagementScore: 95.0,
      ),
      UserEngagementData(
        userName: 'Carlos Santos',
        accessCount: 38,
        engagementScore: 88.5,
      ),
      UserEngagementData(
        userName: 'Maria Oliveira',
        accessCount: 52,
        engagementScore: 98.0,
      ),
      UserEngagementData(
        userName: 'João Pereira',
        accessCount: 28,
        engagementScore: 72.3,
      ),
      UserEngagementData(
        userName: 'Fernanda Costa',
        accessCount: 41,
        engagementScore: 91.5,
      ),
      UserEngagementData(
        userName: 'Pedro Silva',
        accessCount: 15,
        engagementScore: 45.0,
      ),
      UserEngagementData(
        userName: 'Juliana Costa',
        accessCount: 33,
        engagementScore: 82.0,
      ),
      UserEngagementData(
        userName: 'Roberto Alves',
        accessCount: 22,
        engagementScore: 61.5,
      ),
    ];
  }

  static Map<String, int> getMonthlyAccessData() {
    return {
      'Jan': 1200,
      'Fev': 1400,
      'Mar': 1350,
      'Abr': 1600,
      'Mai': 1550,
      'Jun': 1800,
      'Jul': 1900,
      'Ago': 2100,
      'Set': 2050,
      'Out': 2200,
      'Nov': 2150,
      'Dez': 2300,
    };
  }
}
