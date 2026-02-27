import 'package:flutter/material.dart';
import '../models/benefit_model.dart';
import '../theme/app_theme.dart';

class AvailableBenefitsSection extends StatefulWidget {
  final List<Benefit> benefits;

  const AvailableBenefitsSection({Key? key, required this.benefits})
    : super(key: key);

  @override
  State<AvailableBenefitsSection> createState() =>
      _AvailableBenefitsSectionState();
}

class _AvailableBenefitsSectionState extends State<AvailableBenefitsSection> {
  String selectedFilter = 'Todos';

  List<String> get categories {
    final cats = {'Todos'};
    for (var benefit in widget.benefits) {
      cats.add(benefit.category);
    }
    return cats.toList();
  }

  List<Benefit> get filteredBenefits {
    if (selectedFilter == 'Todos') {
      return widget.benefits;
    }
    return widget.benefits.where((b) => b.category == selectedFilter).toList();
  }

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
      case 'DISPONIVEL':
        return AppTheme.activeGreen;
      case 'NAO_ELEGIVEL':
        return AppTheme.textLight;
      default:
        return AppTheme.textLight;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'DISPONIVEL':
        return 'DISPONÍVEL';
      case 'NAO_ELEGIVEL':
        return 'NÃO ELEGÍVEL';
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
          Text(
            'Benefícios disponíveis',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          // Filtros
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((category) {
                final isSelected = selectedFilter == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedFilter = category;
                      });
                    },
                    backgroundColor: Colors.transparent,
                    selectedColor: AppTheme.veryLightRed,
                    side: BorderSide(
                      color: isSelected
                          ? AppTheme.primaryRed
                          : AppTheme.dividerColor,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppTheme.primaryRed
                          : AppTheme.textLight,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          // Grid de benefícios
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: isMobile ? 1.3 : 1.1,
            ),
            itemCount: filteredBenefits.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final benefit = filteredBenefits[index];
              return _buildAvailableBenefitCard(context, benefit);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableBenefitCard(BuildContext context, Benefit benefit) {
    final statusColor = _getStatusColor(benefit.status);
    final statusLabel = _getStatusLabel(benefit.status);
    final isAvailable = benefit.status == 'DISPONIVEL';

    return Card(
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
              benefit.category,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Text(
                benefit.description,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isAvailable ? () {} : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAvailable
                      ? AppTheme.primaryRed
                      : AppTheme.dividerColor,
                  foregroundColor: isAvailable
                      ? Colors.white
                      : AppTheme.textLight,
                ),
                child: Text(isAvailable ? 'Solicitar' : 'Indisponível'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
