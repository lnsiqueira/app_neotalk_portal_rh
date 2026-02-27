import 'package:flutter/material.dart';
import '../models/summary_model.dart';
import '../theme/app_theme.dart';

class SummaryCards extends StatelessWidget {
  final Summary summary;

  const SummaryCards({Key? key, required this.summary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.count(
        crossAxisCount: isMobile ? 1 : 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildSummaryCard(
            context,
            icon: Icons.check_circle_rounded,
            iconColor: AppTheme.activeGreen,
            title: '${summary.activeBenefits}',
            subtitle: 'Benefícios Ativos',
          ),
          _buildSummaryCard(
            context,
            icon: Icons.attach_money_rounded,
            iconColor: AppTheme.activeGreen,
            title: 'R\$ ${summary.annualCoparticipation.toStringAsFixed(2)}',
            subtitle: 'Coparticipação Anual',
          ),
          _buildSummaryCard(
            context,
            icon: Icons.info_rounded,
            iconColor: AppTheme.warningYellow,
            title: '${summary.pendingRequests}',
            subtitle: 'Solicitação em Análise',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppTheme.textDark,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
