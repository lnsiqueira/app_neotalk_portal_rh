import 'package:flutter/material.dart';
import '../models/available_benefit_model.dart';
import '../theme/app_theme.dart';

// Modelo para Dependente
class DependentData {
  final String id;
  final String name;
  final String relationship;
  final int age;

  DependentData({
    required this.id,
    required this.name,
    required this.relationship,
    required this.age,
  });
}

// Modelo para Titular com Dependentes
class HolderWithDependents {
  final String id;
  final String name;
  final List<DependentData> dependents;

  HolderWithDependents({
    required this.id,
    required this.name,
    required this.dependents,
  });
}

class BenefitDetailsModal {
  static void show(
    BuildContext context,
    AvailableBenefit benefit,
    bool isEligible,
    String ineligibilityReason,
    String userName,
    String userRole,
    VoidCallback onRequestPressed,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header com ícone e nome
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getIconData(benefit.icon),
                          color: AppTheme.primaryRed,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              benefit.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              benefit.category,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Descrição
                  Text(
                    'Descrição',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    benefit.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),

                  // Detalhes
                  Text(
                    'Detalhes',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    benefit.details,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),

                  // Informações de Benefício
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          'Desconto/Benefício',
                          benefit.discount,
                          AppTheme.primaryRed,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          'Benefício Mensal',
                          benefit.monthlyBenefit,
                          Colors.green,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Requisitos
                  Text(
                    'Requisitos',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: benefit.requirements
                        .map(
                          (req) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    req,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),

                  // Botão de Solicitação
                  if (isEligible)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onRequestPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryRed,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Solicitar Benefício',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.help_outline, color: Colors.red),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Você não é elegível',
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(color: Colors.red),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ineligibilityReason,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Botão Fechar
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Fechar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildInfoRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  static IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'child_care':
        return Icons.child_care;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'restaurant':
        return Icons.restaurant;
      case 'school':
        return Icons.school;
      case 'local_pharmacy':
        return Icons.local_pharmacy;
      case 'security':
        return Icons.security;
      default:
        return Icons.card_giftcard;
    }
  }
}

class BenefitRequestTermsDialog {
  static void show(
    BuildContext context,
    AvailableBenefit benefit,
    final String name,
    final String role,
    VoidCallback onAccept,
  ) {
    bool termsAccepted = false;
    List<String> selectedBeneficiaries = [];

    // Dados mockados de titulares com dependentes
    final holdersWithDependents = _getMockedHoldersWithDependents(name);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Solicitar Benefício'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Nome do benefício
                    Text(
                      'Benefício: ${benefit.name}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Seção de Seleção de Beneficiários
                    Text(
                      'Selecione para quem é este benefício:',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Lista de titulares com dependentes
                    ...holdersWithDependents.map((holder) {
                      return _buildHolderSection(
                        context,
                        holder,
                        selectedBeneficiaries,
                        (selected) {
                          setState(() {
                            if (selected) {
                              selectedBeneficiaries.add(holder.id);
                            } else {
                              selectedBeneficiaries.remove(holder.id);
                            }
                          });
                        },
                        (dependentId, selected) {
                          setState(() {
                            if (selected) {
                              selectedBeneficiaries.add(dependentId);
                            } else {
                              selectedBeneficiaries.remove(dependentId);
                            }
                          });
                        },
                      );
                    }).toList(),

                    const SizedBox(height: 16),

                    // Termos e Condições
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        benefit.terms,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Checkbox de aceitar termos
                    Theme(
                      data: Theme.of(context).copyWith(
                        checkboxTheme: CheckboxThemeData(
                          fillColor: MaterialStateProperty.resolveWith<Color>((
                            Set<MaterialState> states,
                          ) {
                            if (states.contains(MaterialState.selected)) {
                              return AppTheme.primaryRed;
                            }
                            return Colors.grey[300]!;
                          }),
                        ),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: termsAccepted,
                            onChanged: (value) {
                              setState(() {
                                termsAccepted = value ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: Text(
                              'Concordo com os termos e condições',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: (termsAccepted && selectedBeneficiaries.isNotEmpty)
                      ? () {
                          Navigator.of(context).pop();
                          onAccept();
                          _showSuccessMessage(
                            context,
                            benefit.name,
                            selectedBeneficiaries.length,
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryRed,
                  ),
                  child: const Text(
                    'Aceitar e Solicitar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Widget para construir seção do titular com dependentes
  static Widget _buildHolderSection(
    BuildContext context,
    HolderWithDependents holder,
    List<String> selectedBeneficiaries,
    Function(bool) onHolderSelected,
    Function(String, bool) onDependentSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titular
        Theme(
          data: Theme.of(context).copyWith(
            checkboxTheme: CheckboxThemeData(
              fillColor: MaterialStateProperty.resolveWith<Color>((
                Set<MaterialState> states,
              ) {
                if (states.contains(MaterialState.selected)) {
                  return AppTheme.primaryRed;
                }
                return Colors.grey[300]!;
              }),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CheckboxListTile(
              title: Row(
                children: [
                  Icon(Icons.person, color: AppTheme.primaryRed, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      holder.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRed.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Titular',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryRed,
                      ),
                    ),
                  ),
                ],
              ),
              value: selectedBeneficiaries.contains(holder.id),
              onChanged: (value) {
                onHolderSelected(value ?? false);
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Dependentes
        if (holder.dependents.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dependentes:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                ...holder.dependents.map((dependent) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        checkboxTheme: CheckboxThemeData(
                          fillColor: MaterialStateProperty.resolveWith<Color>((
                            Set<MaterialState> states,
                          ) {
                            if (states.contains(MaterialState.selected)) {
                              return AppTheme.primaryRed;
                            }
                            return Colors.grey[300]!;
                          }),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppTheme.dividerColor,
                            width: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.grey[50],
                        ),
                        child: CheckboxListTile(
                          title: Row(
                            children: [
                              Icon(
                                _getDependentIcon(dependent.relationship),
                                color: Colors.blue,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dependent.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      '${dependent.relationship} • ${dependent.age} anos',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: AppTheme.textLight),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          value: selectedBeneficiaries.contains(dependent.id),
                          onChanged: (value) {
                            onDependentSelected(dependent.id, value ?? false);
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 12),
            child: Text(
              'Sem dependentes',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textLight,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }

  // Obter ícone baseado no tipo de dependente
  static IconData _getDependentIcon(String relationship) {
    switch (relationship.toLowerCase()) {
      case 'filho':
      case 'filha':
        return Icons.child_care;
      case 'cônjuge':
      case 'esposa':
      case 'esposo':
        return Icons.favorite;
      case 'pai':
      case 'mãe':
        return Icons.elderly;
      default:
        return Icons.person;
    }
  }

  static void _showSuccessMessage(
    BuildContext context,
    String benefitName,
    int beneficiaryCount,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Solicitação de $benefitName enviada com sucesso para $beneficiaryCount beneficiário(s)!',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Dados mockados de titulares com dependentes
  static List<HolderWithDependents> _getMockedHoldersWithDependents(
    String name,
  ) {
    if (name == 'Ana Silva da Costa') {
      return [
        HolderWithDependents(
          id: 'ana_silva',
          name: 'Ana Silva',
          dependents: [
            DependentData(
              id: 'fernanda_costa',
              name: 'Fernanda da Costa',
              relationship: 'Filha',
              age: 12,
            ),
            DependentData(
              id: 'joao_costa',
              name: 'João da Costa',
              relationship: 'Filho',
              age: 8,
            ),
          ],
        ),
      ];
    } else if (name == 'Maria Oliveira') {
      return [
        HolderWithDependents(
          id: 'maria_oliveira',
          name: 'Maria Oliveira',
          dependents: [
            DependentData(
              id: 'gabriela_oliveira',
              name: 'Gabriela Oliveira',
              relationship: 'Filha',
              age: 15,
            ),
          ],
        ),
      ];
    } else if (name == 'João Pereira') {
      return [
        HolderWithDependents(
          id: 'joao_pereira',
          name: 'João Pereira',
          dependents: [],
        ),
      ];
    } else if (name == 'Carlos Santos') {
      return [
        HolderWithDependents(
          id: 'carlos_santos',
          name: 'Carlos Santos',
          dependents: [],
        ),
      ];
    }

    return [
      HolderWithDependents(
        id: 'ana_silva',
        name: 'Ana Silva',
        dependents: [
          DependentData(
            id: 'fernanda_costa',
            name: 'Fernanda da Costa',
            relationship: 'Filha',
            age: 12,
          ),
          DependentData(
            id: 'joao_costa',
            name: 'João da Costa',
            relationship: 'Filho',
            age: 8,
          ),
        ],
      ),
      HolderWithDependents(
        id: 'maria_oliveira',
        name: 'Maria Oliveira',
        dependents: [
          DependentData(
            id: 'gabriela_oliveira',
            name: 'Gabriela Oliveira',
            relationship: 'Filha',
            age: 15,
          ),
        ],
      ),
      HolderWithDependents(
        id: 'carlos_santos',
        name: 'Carlos Santos',
        dependents: [],
      ),
    ];
  }
}

// import 'package:flutter/material.dart';
// import '../models/available_benefit_model.dart';
// import '../theme/app_theme.dart';

// // Modelo para Dependente
// class DependentData {
//   final String id;
//   final String name;
//   final String relationship;
//   final int age;

//   DependentData({
//     required this.id,
//     required this.name,
//     required this.relationship,
//     required this.age,
//   });
// }

// // Modelo para Titular com Dependentes
// class HolderWithDependents {
//   final String id;
//   final String name;
//   final List<DependentData> dependents;

//   HolderWithDependents({
//     required this.id,
//     required this.name,
//     required this.dependents,
//   });
// }

// class BenefitDetailsModal {
//   static void show(
//     BuildContext context,
//     AvailableBenefit benefit,
//     bool isEligible,
//     String ineligibilityReason,
//     String userName,
//     String userRole,
//     VoidCallback onRequestPressed,
//   ) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Header com ícone e nome
//                   Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: AppTheme.primaryRed.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Icon(
//                           _getIconData(benefit.icon),
//                           color: AppTheme.primaryRed,
//                           size: 32,
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               benefit.name,
//                               style: Theme.of(context).textTheme.titleLarge,
//                             ),
//                             Text(
//                               benefit.category,
//                               style: Theme.of(context).textTheme.bodySmall,
//                             ),
//                           ],
//                         ),
//                       ),
//                       IconButton(
//                         onPressed: () => Navigator.of(context).pop(),
//                         icon: const Icon(Icons.close),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),

//                   // Descrição
//                   Text(
//                     'Descrição',
//                     style: Theme.of(context).textTheme.labelLarge,
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     benefit.description,
//                     style: Theme.of(context).textTheme.bodyMedium,
//                   ),
//                   const SizedBox(height: 24),

//                   // Detalhes
//                   Text(
//                     'Detalhes',
//                     style: Theme.of(context).textTheme.labelLarge,
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     benefit.details,
//                     style: Theme.of(context).textTheme.bodyMedium,
//                   ),
//                   const SizedBox(height: 24),

//                   // Informações de Benefício
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[100],
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _buildInfoRow(
//                           'Desconto/Benefício',
//                           benefit.discount,
//                           AppTheme.primaryRed,
//                         ),
//                         const SizedBox(height: 12),
//                         _buildInfoRow(
//                           'Benefício Mensal',
//                           benefit.monthlyBenefit,
//                           Colors.green,
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 24),

//                   // Requisitos
//                   Text(
//                     'Requisitos',
//                     style: Theme.of(context).textTheme.labelLarge,
//                   ),
//                   const SizedBox(height: 8),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: benefit.requirements
//                         .map(
//                           (req) => Padding(
//                             padding: const EdgeInsets.only(bottom: 8),
//                             child: Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Icon(
//                                   Icons.check_circle,
//                                   color: Colors.green,
//                                   size: 20,
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Expanded(
//                                   child: Text(
//                                     req,
//                                     style: Theme.of(
//                                       context,
//                                     ).textTheme.bodySmall,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         )
//                         .toList(),
//                   ),
//                   const SizedBox(height: 24),

//                   // Botão de Solicitação
//                   if (isEligible)
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: onRequestPressed,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppTheme.primaryRed,
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                         ),
//                         child: const Text(
//                           'Solicitar Benefício',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     )
//                   else
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.red[50],
//                         border: Border.all(color: Colors.red),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(Icons.help_outline, color: Colors.red),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Você não é elegível',
//                                   style: Theme.of(context).textTheme.labelMedium
//                                       ?.copyWith(color: Colors.red),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   ineligibilityReason,
//                                   style: Theme.of(context).textTheme.bodySmall
//                                       ?.copyWith(color: Colors.red),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   const SizedBox(height: 16),

//                   // Botão Fechar
//                   SizedBox(
//                     width: double.infinity,
//                     child: OutlinedButton(
//                       onPressed: () => Navigator.of(context).pop(),
//                       child: const Text('Fechar'),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   static Widget _buildInfoRow(String label, String value, Color color) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: Colors.grey,
//           ),
//         ),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//       ],
//     );
//   }

//   static IconData _getIconData(String iconName) {
//     switch (iconName) {
//       case 'child_care':
//         return Icons.child_care;
//       case 'fitness_center':
//         return Icons.fitness_center;
//       case 'restaurant':
//         return Icons.restaurant;
//       case 'school':
//         return Icons.school;
//       case 'local_pharmacy':
//         return Icons.local_pharmacy;
//       case 'security':
//         return Icons.security;
//       default:
//         return Icons.card_giftcard;
//     }
//   }
// }

// class BenefitRequestTermsDialog {
//   static void show(
//     BuildContext context,
//     AvailableBenefit benefit,
//     final String name,
//     final String role,
//     VoidCallback onAccept,
//   ) {
//     bool termsAccepted = false;
//     List<String> selectedBeneficiaries = [];

//     // Dados mockados de titulares com dependentes
//     final holdersWithDependents = _getMockedHoldersWithDependents(name);

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               title: const Text('Solicitar Benefício'),
//               content: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // Nome do benefício
//                     Text(
//                       'Benefício: ${benefit.name}',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 16),

//                     // Seção de Seleção de Beneficiários
//                     Text(
//                       'Selecione para quem é este benefício:',
//                       style: Theme.of(context).textTheme.labelLarge?.copyWith(
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 12),

//                     // Lista de titulares com dependentes
//                     ...holdersWithDependents.map((holder) {
//                       return _buildHolderSection(
//                         context,
//                         holder,
//                         selectedBeneficiaries,
//                         (selected) {
//                           setState(() {
//                             if (selected) {
//                               selectedBeneficiaries.add(holder.id);
//                             } else {
//                               selectedBeneficiaries.remove(holder.id);
//                             }
//                           });
//                         },
//                         (dependentId, selected) {
//                           setState(() {
//                             if (selected) {
//                               selectedBeneficiaries.add(dependentId);
//                             } else {
//                               selectedBeneficiaries.remove(dependentId);
//                             }
//                           });
//                         },
//                       );
//                     }).toList(),

//                     const SizedBox(height: 16),

//                     // Termos e Condições
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[100],
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         benefit.terms,
//                         style: const TextStyle(fontSize: 12),
//                       ),
//                     ),
//                     const SizedBox(height: 16),

//                     // Checkbox de aceitar termos
//                     Row(
//                       children: [
//                         Checkbox(
//                           value: termsAccepted,
//                           onChanged: (value) {
//                             setState(() {
//                               termsAccepted = value ?? false;
//                             });
//                           },
//                         ),
//                         Expanded(
//                           child: Text(
//                             'Concordo com os termos e condições',
//                             style: Theme.of(context).textTheme.bodySmall,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: const Text(
//                     'Cancelar',
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: (termsAccepted && selectedBeneficiaries.isNotEmpty)
//                       ? () {
//                           Navigator.of(context).pop();
//                           onAccept();
//                           _showSuccessMessage(
//                             context,
//                             benefit.name,
//                             selectedBeneficiaries.length,
//                           );
//                         }
//                       : null,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppTheme.primaryRed,
//                   ),
//                   child: const Text(
//                     'Aceitar e Solicitar',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   // Widget para construir seção do titular com dependentes
//   static Widget _buildHolderSection(
//     BuildContext context,
//     HolderWithDependents holder,
//     List<String> selectedBeneficiaries,
//     Function(bool) onHolderSelected,
//     Function(String, bool) onDependentSelected,
//   ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Titular
//         Container(
//           decoration: BoxDecoration(
//             border: Border.all(color: AppTheme.dividerColor),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: CheckboxListTile(
//             title: Row(
//               children: [
//                 Icon(Icons.person, color: AppTheme.primaryRed, size: 20),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     holder.name,
//                     style: const TextStyle(fontWeight: FontWeight.w600),
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: AppTheme.primaryRed.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: const Text(
//                     'Titular',
//                     style: TextStyle(
//                       fontSize: 10,
//                       fontWeight: FontWeight.w600,
//                       color: AppTheme.primaryRed,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             value: selectedBeneficiaries.contains(holder.id),
//             onChanged: (value) {
//               onHolderSelected(value ?? false);
//             },
//             controlAffinity: ListTileControlAffinity.leading,
//           ),
//         ),
//         const SizedBox(height: 8),

//         // Dependentes
//         if (holder.dependents.isNotEmpty)
//           Padding(
//             padding: const EdgeInsets.only(left: 16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Dependentes:',
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                     color: AppTheme.textLight,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 ...holder.dependents.map((dependent) {
//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                           color: AppTheme.dividerColor,
//                           width: 0.5,
//                         ),
//                         borderRadius: BorderRadius.circular(6),
//                         color: Colors.grey[50],
//                       ),
//                       child: CheckboxListTile(
//                         title: Row(
//                           children: [
//                             Icon(
//                               _getDependentIcon(dependent.relationship),
//                               color: Colors.blue,
//                               size: 18,
//                             ),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     dependent.name,
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.w500,
//                                       fontSize: 14,
//                                     ),
//                                   ),
//                                   Text(
//                                     '${dependent.relationship} • ${dependent.age} anos',
//                                     style: Theme.of(context).textTheme.bodySmall
//                                         ?.copyWith(color: AppTheme.textLight),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         value: selectedBeneficiaries.contains(dependent.id),
//                         onChanged: (value) {
//                           onDependentSelected(dependent.id, value ?? false);
//                         },
//                         controlAffinity: ListTileControlAffinity.leading,
//                         dense: true,
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ],
//             ),
//           )
//         else
//           Padding(
//             padding: const EdgeInsets.only(left: 16, bottom: 12),
//             child: Text(
//               'Sem dependentes',
//               style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                 color: AppTheme.textLight,
//                 fontStyle: FontStyle.italic,
//               ),
//             ),
//           ),
//         const SizedBox(height: 12),
//       ],
//     );
//   }

//   // Obter ícone baseado no tipo de dependente
//   static IconData _getDependentIcon(String relationship) {
//     switch (relationship.toLowerCase()) {
//       case 'filho':
//       case 'filha':
//         return Icons.child_care;
//       case 'cônjuge':
//       case 'esposa':
//       case 'esposo':
//         return Icons.favorite;
//       case 'pai':
//       case 'mãe':
//         return Icons.elderly;
//       default:
//         return Icons.person;
//     }
//   }

//   static void _showSuccessMessage(
//     BuildContext context,
//     String benefitName,
//     int beneficiaryCount,
//   ) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           'Solicitação de $benefitName enviada com sucesso para $beneficiaryCount beneficiário(s)!',
//         ),
//         backgroundColor: Colors.green,
//         duration: const Duration(seconds: 4),
//       ),
//     );
//   }

//   // Dados mockados de titulares com dependentes
//   static List<HolderWithDependents> _getMockedHoldersWithDependents(
//     String name,
//   ) {
//     if (name == 'Ana Silva da Costa') {
//       return [
//         HolderWithDependents(
//           id: 'ana_silva',
//           name: 'Ana Silva',
//           dependents: [
//             DependentData(
//               id: 'fernanda_costa',
//               name: 'Fernanda da Costa',
//               relationship: 'Filha',
//               age: 12,
//             ),
//             DependentData(
//               id: 'joao_costa',
//               name: 'João da Costa',
//               relationship: 'Filho',
//               age: 8,
//             ),
//           ],
//         ),
//       ];
//     } else if (name == 'Maria Oliveira') {
//       return [
//         HolderWithDependents(
//           id: 'maria_oliveira',
//           name: 'Maria Oliveira',
//           dependents: [
//             DependentData(
//               id: 'gabriela_oliveira',
//               name: 'Gabriela Oliveira',
//               relationship: 'Filha',
//               age: 15,
//             ),
//           ],
//         ),
//       ];
//     } else if (name == 'João Pereira') {
//       return [
//         HolderWithDependents(
//           id: 'joao_pereira',
//           name: 'João Pereira',
//           dependents: [],
//         ),
//       ];
//     } else if (name == 'Carlos Santos') {
//       return [
//         HolderWithDependents(
//           id: 'carlos_santos',
//           name: 'Carlos Santos',
//           dependents: [],
//         ),
//       ];
//     }

//     return [
//       HolderWithDependents(
//         id: 'ana_silva',
//         name: 'Ana Silva',
//         dependents: [
//           DependentData(
//             id: 'fernanda_costa',
//             name: 'Fernanda da Costa',
//             relationship: 'Filha',
//             age: 12,
//           ),
//           DependentData(
//             id: 'joao_costa',
//             name: 'João da Costa',
//             relationship: 'Filho',
//             age: 8,
//           ),
//         ],
//       ),
//       HolderWithDependents(
//         id: 'maria_oliveira',
//         name: 'Maria Oliveira',
//         dependents: [
//           DependentData(
//             id: 'gabriela_oliveira',
//             name: 'Gabriela Oliveira',
//             relationship: 'Filha',
//             age: 15,
//           ),
//         ],
//       ),
//       HolderWithDependents(
//         id: 'carlos_santos',
//         name: 'Carlos Santos',
//         dependents: [],
//       ),
//     ];
//   }
// }

//------
// import 'package:flutter/material.dart';
// import '../models/available_benefit_model.dart';
// import '../theme/app_theme.dart';

// class BenefitDetailsModal {
//   static void show(
//     BuildContext context,
//     AvailableBenefit benefit,
//     bool isEligible,
//     String ineligibilityReason,
//     VoidCallback onRequestPressed,
//   ) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Header com ícone e nome
//                   Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: AppTheme.primaryRed.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Icon(
//                           _getIconData(benefit.icon),
//                           color: AppTheme.primaryRed,
//                           size: 32,
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               benefit.name,
//                               style: Theme.of(context).textTheme.titleLarge,
//                             ),
//                             Text(
//                               benefit.category,
//                               style: Theme.of(context).textTheme.bodySmall,
//                             ),
//                           ],
//                         ),
//                       ),
//                       IconButton(
//                         onPressed: () => Navigator.of(context).pop(),
//                         icon: const Icon(Icons.close),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),

//                   // Descrição
//                   Text(
//                     'Descrição',
//                     style: Theme.of(context).textTheme.labelLarge,
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     benefit.description,
//                     style: Theme.of(context).textTheme.bodyMedium,
//                   ),
//                   const SizedBox(height: 24),

//                   // Detalhes
//                   Text(
//                     'Detalhes',
//                     style: Theme.of(context).textTheme.labelLarge,
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     benefit.details,
//                     style: Theme.of(context).textTheme.bodyMedium,
//                   ),
//                   const SizedBox(height: 24),

//                   // Informações de Benefício
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[100],
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _buildInfoRow(
//                           'Desconto/Benefício',
//                           benefit.discount,
//                           AppTheme.primaryRed,
//                         ),
//                         const SizedBox(height: 12),
//                         _buildInfoRow(
//                           'Benefício Mensal',
//                           benefit.monthlyBenefit,
//                           Colors.green,
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 24),

//                   // Requisitos
//                   Text(
//                     'Requisitos',
//                     style: Theme.of(context).textTheme.labelLarge,
//                   ),
//                   const SizedBox(height: 8),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: benefit.requirements
//                         .map(
//                           (req) => Padding(
//                             padding: const EdgeInsets.only(bottom: 8),
//                             child: Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Icon(
//                                   Icons.check_circle,
//                                   color: Colors.green,
//                                   size: 20,
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Expanded(
//                                   child: Text(
//                                     req,
//                                     style: Theme.of(
//                                       context,
//                                     ).textTheme.bodySmall,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         )
//                         .toList(),
//                   ),
//                   const SizedBox(height: 24),

//                   // Botão de Solicitação
//                   if (isEligible)
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: onRequestPressed,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppTheme.primaryRed,
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                         ),
//                         child: const Text(
//                           'Solicitar Benefício',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     )
//                   else
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.red[50],
//                         border: Border.all(color: Colors.red),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(Icons.help_outline, color: Colors.red),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Você não é elegível',
//                                   style: Theme.of(context).textTheme.labelMedium
//                                       ?.copyWith(color: Colors.red),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   ineligibilityReason,
//                                   style: Theme.of(context).textTheme.bodySmall
//                                       ?.copyWith(color: Colors.red),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   const SizedBox(height: 16),

//                   // Botão Fechar
//                   SizedBox(
//                     width: double.infinity,
//                     child: OutlinedButton(
//                       onPressed: () => Navigator.of(context).pop(),
//                       child: const Text('Fechar'),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   static Widget _buildInfoRow(String label, String value, Color color) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: Colors.grey,
//           ),
//         ),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//       ],
//     );
//   }

//   static IconData _getIconData(String iconName) {
//     switch (iconName) {
//       case 'child_care':
//         return Icons.child_care;
//       case 'fitness_center':
//         return Icons.fitness_center;
//       case 'restaurant':
//         return Icons.restaurant;
//       case 'school':
//         return Icons.school;
//       case 'local_pharmacy':
//         return Icons.local_pharmacy;
//       case 'security':
//         return Icons.security;
//       default:
//         return Icons.card_giftcard;
//     }
//   }
// }

// class BenefitRequestTermsDialog {
//   static void show(
//     BuildContext context,
//     AvailableBenefit benefit,
//     VoidCallback onAccept,
//   ) {
//     bool termsAccepted = false;

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               title: const Text('Termos e Condições'),
//               content: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       'Solicitar: ${benefit.name}',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[100],
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         benefit.terms,
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     Row(
//                       children: [
//                         Checkbox(
//                           value: termsAccepted,
//                           onChanged: (value) {
//                             setState(() {
//                               termsAccepted = value ?? false;
//                             });
//                           },
//                         ),
//                         Expanded(
//                           child: Text(
//                             'Concordo com os termos e condições',
//                             style: Theme.of(context).textTheme.bodySmall,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: const Text(
//                     'Cancelar',
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: termsAccepted
//                       ? () {
//                           Navigator.of(context).pop();
//                           onAccept();
//                           _showSuccessMessage(context, benefit.name);
//                         }
//                       : null,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppTheme.primaryRed,
//                   ),
//                   child: const Text(
//                     'Aceitar e Solicitar',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   static void _showSuccessMessage(BuildContext context, String benefitName) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Solicitação de $benefitName enviada com sucesso!'),
//         backgroundColor: Colors.green,
//         duration: const Duration(seconds: 4),
//       ),
//     );
//   }
// }
