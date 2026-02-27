import 'package:app_neotalk_portal_rh/models/rh_dashboard_models.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/user_model.dart';

class RHDashboardScreen extends StatefulWidget {
  final User user;

  const RHDashboardScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<RHDashboardScreen> createState() => _RHDashboardScreenState();
}

class _RHDashboardScreenState extends State<RHDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final metrics = RHDashboardService.getMetrics();
    final mostUsedBenefits = RHDashboardService.getMostUsedBenefits();
    final leastUsedBenefits = RHDashboardService.getLeastUsedBenefits();
    final userEngagement = RHDashboardService.getUserEngagement();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.analytics_rounded,
                    color: AppTheme.primaryRed,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dashboard Administrativo',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                color: AppTheme.textDark,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Gestão de Benefícios e Engajamento',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.textLight),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // KPIs - Números Gerenciais
              if (!isMobile)
                Row(
                  children: [
                    Expanded(
                      child: _buildKPICard(
                        context,
                        icon: Icons.people_rounded,
                        title: 'Total de Colaboradores',
                        value: '${metrics.totalEmployees}',
                        color: const Color(0xFF2196F3),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildKPICard(
                        context,
                        icon: Icons.card_giftcard_rounded,
                        title: 'Benefícios Ativos',
                        value: '${metrics.totalBenefitsActive}',
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildKPICard(
                        context,
                        icon: Icons.trending_up_rounded,
                        title: 'Taxa de Adoção',
                        value:
                            '${metrics.benefitAdoptionRate.toStringAsFixed(1)}%',
                        color: const Color(0xFFFF9800),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildKPICard(
                        context,
                        icon: Icons.check_circle_rounded,
                        title: 'Engajamento Médio',
                        value:
                            '${metrics.averageEngagement.toStringAsFixed(1)}%',
                        color: const Color(0xFF9C27B0),
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildKPICard(
                            context,
                            icon: Icons.people_rounded,
                            title: 'Colaboradores',
                            value: '${metrics.totalEmployees}',
                            color: const Color(0xFF2196F3),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildKPICard(
                            context,
                            icon: Icons.card_giftcard_rounded,
                            title: 'Benefícios',
                            value: '${metrics.totalBenefitsActive}',
                            color: const Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildKPICard(
                            context,
                            icon: Icons.trending_up_rounded,
                            title: 'Taxa Adoção',
                            value:
                                '${metrics.benefitAdoptionRate.toStringAsFixed(1)}%',
                            color: const Color(0xFFFF9800),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildKPICard(
                            context,
                            icon: Icons.check_circle_rounded,
                            title: 'Engajamento',
                            value:
                                '${metrics.averageEngagement.toStringAsFixed(1)}%',
                            color: const Color(0xFF9C27B0),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 32),

              // Benefícios Mais Utilizados
              Text(
                'Benefícios Mais Utilizados',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildBenefitsList(context, mostUsedBenefits, isHighUsage: true),
              const SizedBox(height: 32),

              // Benefícios Menos Utilizados
              Text(
                'Benefícios Menos Utilizados',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildBenefitsList(
                context,
                leastUsedBenefits,
                isHighUsage: false,
              ),
              const SizedBox(height: 32),
              //*
              // Engajamento de Usuários
              // Text(
              //   'Engajamento de Usuários',
              //   style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              //     color: AppTheme.textDark,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // const SizedBox(height: 16),
              // _buildEngagementList(context, userEngagement),
              // const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKPICard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppTheme.textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textLight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsList(
    BuildContext context,
    List<BenefitUsageData> benefits, {
    required bool isHighUsage,
  }) {
    return Column(
      children: [
        ...benefits.asMap().entries.map((entry) {
          final index = entry.key;
          final benefit = entry.value;
          final maxUsage = benefits.first.usageCount;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppTheme.dividerColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            benefit.benefitName,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isHighUsage
                                ? AppTheme.activeGreen.withOpacity(0.2)
                                : AppTheme.warningYellow.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${benefit.percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: isHighUsage
                                  ? AppTheme.activeGreen
                                  : AppTheme.warningYellow,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${benefit.usageCount} contratos',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.textLight),
                        ),
                        Text(
                          '${index + 1}º lugar',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppTheme.textLight,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: benefit.usageCount / maxUsage,
                        minHeight: 8,
                        backgroundColor: AppTheme.dividerColor,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isHighUsage
                              ? AppTheme.activeGreen
                              : AppTheme.warningYellow,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildEngagementList(
    BuildContext context,
    List<UserEngagementData> users,
  ) {
    return Column(
      children: [
        ...users.asMap().entries.map((entry) {
          final index = entry.key;
          final user = entry.value;
          final maxEngagement = 100.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppTheme.dividerColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            user.userName,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getEngagementColor(
                              user.engagementScore,
                            ).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${user.engagementScore.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: _getEngagementColor(user.engagementScore),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${user.accessCount} acessos',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.textLight),
                        ),
                        Text(
                          'Score: ${user.engagementScore.toStringAsFixed(1)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppTheme.textLight,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: user.engagementScore / maxEngagement,
                        minHeight: 8,
                        backgroundColor: AppTheme.dividerColor,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getEngagementColor(user.engagementScore),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Color _getEngagementColor(double score) {
    if (score >= 80) {
      return AppTheme.activeGreen;
    } else if (score >= 60) {
      return const Color(0xFF2196F3);
    } else {
      return AppTheme.warningYellow;
    }
  }
}
