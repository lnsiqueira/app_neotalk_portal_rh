import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Modelo para dados de aderência de benefício
class BenefitAdherenceData {
  final String benefitName;
  final String benefitCategory;
  final int totalEmployees;
  final int employeesWithBenefit;
  final double adherencePercentage;
  final IconData icon;
  final Color color;

  BenefitAdherenceData({
    required this.benefitName,
    required this.benefitCategory,
    required this.totalEmployees,
    required this.employeesWithBenefit,
    required this.icon,
    required this.color,
  }) : adherencePercentage = (employeesWithBenefit / totalEmployees) * 100;
}

class EngagementScreen extends StatefulWidget {
  final List<BenefitAdherenceData>? benefits;

  const EngagementScreen({Key? key, this.benefits}) : super(key: key);

  @override
  State<EngagementScreen> createState() => _EngagementScreenState();
}

class _EngagementScreenState extends State<EngagementScreen> {
  late List<BenefitAdherenceData> _benefits;
  String _selectedFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    _benefits = widget.benefits ?? _getMockedBenefits();
  }

  // Dados mockados de benefícios
  List<BenefitAdherenceData> _getMockedBenefits() {
    return [
      BenefitAdherenceData(
        benefitName: 'Plano de Saúde',
        benefitCategory: 'Saúde',
        totalEmployees: 110,
        employeesWithBenefit: 100,
        icon: Icons.local_hospital,
        color: const Color(0xFF4CAF50),
      ),
      BenefitAdherenceData(
        benefitName: 'Gympass',
        benefitCategory: 'Bem-estar',
        totalEmployees: 110,
        employeesWithBenefit: 50,
        icon: Icons.fitness_center,
        color: const Color(0xFF2196F3),
      ),
      BenefitAdherenceData(
        benefitName: 'Vale Refeição',
        benefitCategory: 'Alimentação',
        totalEmployees: 110,
        employeesWithBenefit: 95,
        icon: Icons.restaurant,
        color: const Color(0xFFFF9800),
      ),
      BenefitAdherenceData(
        benefitName: 'Vale Transporte',
        benefitCategory: 'Transporte',
        totalEmployees: 110,
        employeesWithBenefit: 88,
        icon: Icons.directions_bus,
        color: const Color(0xFF9C27B0),
      ),
      BenefitAdherenceData(
        benefitName: 'Seguro de Vida',
        benefitCategory: 'Proteção',
        totalEmployees: 110,
        employeesWithBenefit: 75,
        icon: Icons.security,
        color: const Color(0xFFF44336),
      ),
      BenefitAdherenceData(
        benefitName: 'Plano Odontológico',
        benefitCategory: 'Saúde',
        totalEmployees: 110,
        employeesWithBenefit: 65,
        icon: Icons.toggle_off,
        color: const Color(0xFF00BCD4),
      ),
      BenefitAdherenceData(
        benefitName: 'Cursos e Treinamentos',
        benefitCategory: 'Desenvolvimento',
        totalEmployees: 110,
        employeesWithBenefit: 42,
        icon: Icons.school,
        color: const Color(0xFF673AB7),
      ),
      BenefitAdherenceData(
        benefitName: 'Auxílio Creche',
        benefitCategory: 'Família',
        totalEmployees: 110,
        employeesWithBenefit: 28,
        icon: Icons.child_friendly,
        color: const Color(0xFFE91E63),
      ),
    ];
  }

  // Filtrar benefícios
  List<BenefitAdherenceData> _getFilteredBenefits() {
    if (_selectedFilter == 'Todos') {
      return _benefits;
    }
    return _benefits
        .where((b) => b.benefitCategory == _selectedFilter)
        .toList();
  }

  // Obter cor baseada na aderência
  Color _getAdherenceColor(double percentage) {
    if (percentage >= 80) {
      return AppTheme.activeGreen;
    } else if (percentage >= 60) {
      return const Color(0xFF2196F3);
    } else if (percentage >= 40) {
      return const Color(0xFFFF9800);
    } else {
      return AppTheme.warningYellow;
    }
  }

  // Obter texto de status
  String _getAdherenceStatus(double percentage) {
    if (percentage >= 80) {
      return 'Excelente';
    } else if (percentage >= 60) {
      return 'Bom';
    } else if (percentage >= 40) {
      return 'Moderado';
    } else {
      return 'Baixo';
    }
  }

  // Calcular estatísticas gerais
  Map<String, dynamic> _calculateStats() {
    double totalAdherence = 0;
    int highAdherence = 0;
    int mediumAdherence = 0;
    int lowAdherence = 0;

    for (var benefit in _benefits) {
      totalAdherence += benefit.adherencePercentage;
      if (benefit.adherencePercentage >= 80) {
        highAdherence++;
      } else if (benefit.adherencePercentage >= 60) {
        mediumAdherence++;
      } else {
        lowAdherence++;
      }
    }

    return {
      'average': totalAdherence / _benefits.length,
      'high': highAdherence,
      'medium': mediumAdherence,
      'low': lowAdherence,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final filteredBenefits = _getFilteredBenefits();
    final stats = _calculateStats();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aderência de Benefícios',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Visualize a adoção de benefícios pelos colaboradores',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.textLight),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Cards de Estatísticas
          if (!isMobile)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Aderência Média',
                      '${stats['average'].toStringAsFixed(1)}%',
                      Icons.trending_up,
                      const Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Excelente',
                      '${stats['high']}',
                      Icons.check_circle,
                      const Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Bom',
                      '${stats['medium']}',
                      Icons.info,
                      const Color(0xFF2196F3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Baixo',
                      '${stats['low']}',
                      Icons.warning,
                      const Color(0xFFFF9800),
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Aderência Média',
                          '${stats['average'].toStringAsFixed(1)}%',
                          Icons.trending_up,
                          const Color(0xFF4CAF50),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Excelente',
                          '${stats['high']}',
                          Icons.check_circle,
                          const Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Bom',
                          '${stats['medium']}',
                          Icons.info,
                          const Color(0xFF2196F3),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Baixo',
                          '${stats['low']}',
                          Icons.warning,
                          const Color(0xFFFF9800),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          // Filtro por Categoria
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filtrar por Categoria',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Todos'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Saúde'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Bem-estar'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Alimentação'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Transporte'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Proteção'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Desenvolvimento'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Família'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Lista de Benefícios
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Benefícios (${filteredBenefits.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...filteredBenefits.map((benefit) {
                  return _buildBenefitCard(benefit);
                }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Widget para card de estatística
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
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
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para chip de filtro
  Widget _buildFilterChip(String category) {
    final isSelected = _selectedFilter == category;
    return FilterChip(
      label: Text(category),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = category;
        });
      },
      backgroundColor: Colors.transparent,
      selectedColor: AppTheme.primaryRed.withOpacity(0.2),
      side: BorderSide(
        color: isSelected ? AppTheme.primaryRed : AppTheme.dividerColor,
        width: isSelected ? 2 : 1,
      ),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryRed : AppTheme.textDark,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
    );
  }

  // Widget para card de benefício
  Widget _buildBenefitCard(BenefitAdherenceData benefit) {
    final adherenceColor = _getAdherenceColor(benefit.adherencePercentage);
    final adherenceStatus = _getAdherenceStatus(benefit.adherencePercentage);

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
              // Cabeçalho do card
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: benefit.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            benefit.icon,
                            color: benefit.color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                benefit.benefitName,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textDark,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                benefit.benefitCategory,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppTheme.textLight),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: adherenceColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${benefit.adherencePercentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: adherenceColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          adherenceStatus,
                          style: TextStyle(
                            color: adherenceColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Informações de aderência
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${benefit.employeesWithBenefit} de ${benefit.totalEmployees} colaboradores',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${benefit.totalEmployees - benefit.employeesWithBenefit} sem aderência',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppTheme.textLight),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Barra de progresso
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: benefit.adherencePercentage / 100,
                  minHeight: 8,
                  backgroundColor: AppTheme.dividerColor,
                  valueColor: AlwaysStoppedAnimation<Color>(adherenceColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:app_neotalk_portal_rh/models/rh_dashboard_models.dart';
// import 'package:app_neotalk_portal_rh/theme/app_theme.dart';
// import 'package:flutter/material.dart';

// class EngagementScreen extends StatefulWidget {
//   final List<UserEngagementData> users;
//   EngagementScreen(
//     List<UserEngagementData> userEngagement, {
//     Key? key,
//     required this.users,
//   }) : super(key: key);

//   @override
//   State<EngagementScreen> createState() => _EngagementScreenState();
// }

// class _EngagementScreenState extends State<EngagementScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,

//         children: [
//           Padding(
//             padding: const EdgeInsets.all(18.0),
//             child: Text(
//               'Engajamento dos Usuários',
//               style: Theme.of(context).textTheme.headlineSmall,
//             ),
//           ),
//           const SizedBox(height: 18),

//           const SizedBox(height: 32),

//           ...widget.users.asMap().entries.map((entry) {
//             final index = entry.key;
//             final user = entry.value;
//             final maxEngagement = 100.0;

//             return SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.only(bottom: 12),
//                 child: Card(
//                   elevation: 1,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     side: const BorderSide(color: AppTheme.dividerColor),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 user.userName,
//                                 style: Theme.of(context).textTheme.titleLarge
//                                     ?.copyWith(
//                                       fontWeight: FontWeight.bold,
//                                       color: AppTheme.textDark,
//                                     ),
//                               ),
//                             ),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 12,
//                                 vertical: 6,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: _getEngagementColor(
//                                   user.engagementScore,
//                                 ).withOpacity(0.2),
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                               child: Text(
//                                 '${user.engagementScore.toStringAsFixed(1)}%',
//                                 style: TextStyle(
//                                   color: _getEngagementColor(
//                                     user.engagementScore,
//                                   ),
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 12),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               '${user.accessCount} acessos',
//                               style: Theme.of(context).textTheme.bodyMedium
//                                   ?.copyWith(color: AppTheme.textLight),
//                             ),
//                             Text(
//                               'Score: ${user.engagementScore.toStringAsFixed(1)}',
//                               style: Theme.of(context).textTheme.bodySmall
//                                   ?.copyWith(
//                                     color: AppTheme.textLight,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 12),
//                         // Progress bar
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(4),
//                           child: LinearProgressIndicator(
//                             value: user.engagementScore / maxEngagement,
//                             minHeight: 8,
//                             backgroundColor: AppTheme.dividerColor,
//                             valueColor: AlwaysStoppedAnimation<Color>(
//                               _getEngagementColor(user.engagementScore),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//         ],
//       ),
//     );
//   }
// }

// Color _getEngagementColor(double score) {
//   if (score >= 80) {
//     return AppTheme.activeGreen;
//   } else if (score >= 60) {
//     return const Color(0xFF2196F3);
//   } else {
//     return AppTheme.warningYellow;
//   }
// }
