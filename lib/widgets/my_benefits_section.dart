import 'package:flutter/material.dart';
import '../models/benefit_model.dart';
import '../theme/app_theme.dart';

class MyBenefitsSection extends StatelessWidget {
  final List<Benefit> benefits;

  const MyBenefitsSection({Key? key, required this.benefits}) : super(key: key);

  IconData _getIconForBenefit(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'health':
        return Icons.local_hospital_rounded;
      case 'food':
        return Icons.restaurant_rounded;
      case 'transport':
        return Icons.directions_bus_rounded;
      case 'gym':
        return Icons.fitness_center_rounded;
      case 'education':
        return Icons.school_rounded;
      case 'family':
        return Icons.family_restroom_rounded;
      case 'insurance':
        return Icons.security_rounded;
      case 'mental':
        return Icons.psychology_rounded;
      case 'pharmacy':
        return Icons.local_pharmacy_rounded;
      default:
        return Icons.card_giftcard_rounded;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ATIVO':
        return AppTheme.activeGreen;
      case 'EM_ANALISE':
        return AppTheme.warningYellow;
      case 'INATIVO':
        return AppTheme.textLight;
      default:
        return AppTheme.textLight;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'ATIVO':
        return 'ATIVO';
      case 'EM_ANALISE':
        return 'EM ANÁLISE';
      case 'INATIVO':
        return 'INATIVO';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Meus Benefícios',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Ver histórico completo →'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: isMobile ? 1.2 : 0.95,
            ),
            itemCount: benefits.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final benefit = benefits[index];
              return _buildBenefitCard(context, benefit);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitCard(BuildContext context, Benefit benefit) {
    final statusColor = _getStatusColor(benefit.status);
    final statusLabel = _getStatusLabel(benefit.status);
    final isHighlighted = benefit.status == 'EM_ANALISE';

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isHighlighted ? AppTheme.primaryRed : AppTheme.dividerColor,
          width: isHighlighted ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  _getIconForBenefit(benefit.icon),
                  color: AppTheme.primaryRed,
                  size: 28,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              benefit.name,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${benefit.category} • ${benefit.subcategory}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  foregroundColor: Colors.white,
                ),
                child: Text(benefit.action ?? 'Gerenciar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
