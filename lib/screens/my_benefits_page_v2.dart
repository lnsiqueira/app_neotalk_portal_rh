import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/benefit_model.dart';
import '../services/user_data_service.dart';
import '../theme/app_theme.dart';

class MyBenefitsPage extends StatefulWidget {
  final User user;

  const MyBenefitsPage({Key? key, required this.user}) : super(key: key);

  @override
  State<MyBenefitsPage> createState() => _MyBenefitsPageState();
}

class _MyBenefitsPageState extends State<MyBenefitsPage> {
  late Future<List<Benefit>> _benefitsFuture;

  @override
  void initState() {
    super.initState();
    _benefitsFuture = UserDataService.getMyBenefits(widget.user.name);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return FutureBuilder<List<Benefit>>(
      future: _benefitsFuture,
      builder: (context, snapshot) {
        // Carregando
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: AppTheme.primaryRed),
          );
        }

        // Erro
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: AppTheme.primaryRed, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar benefícios',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _benefitsFuture = UserDataService.getMyBenefits(
                        widget.user.name,
                      );
                    });
                  },
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          );
        }

        // Dados carregados
        final benefits = snapshot.data ?? [];

        if (benefits.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.card_giftcard, color: Colors.grey, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Nenhum benefício ativo',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Você não possui benefícios ativos no momento',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  'Gestão de Benefícios',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Gerencie seus planos, solicite reembolsos e visualize seu histórico de utilização.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),

                // Seção: Meus Benefícios Ativos
                Text(
                  'Meus Benefícios Ativos.',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                // Lista de benefícios
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: benefits.length,
                  itemBuilder: (context, index) {
                    final benefit = benefits[index];
                    return _buildBenefitCard(context, benefit, isMobile);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Constrói o card de um benefício
  Widget _buildBenefitCard(
    BuildContext context,
    Benefit benefit,
    bool isMobile,
  ) {
    final isActive = benefit.status == 'ATIVO';
    final statusColor = isActive ? Colors.green : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Nome e Status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        benefit.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        benefit.subcategory ?? benefit.category,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    benefit.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Informações do Plano
            if (benefit.planName != null)
              _buildInfoRow('Plano Contratado', benefit.planName!),
            if (benefit.dependents != null)
              _buildInfoRow('Dependentes', benefit.dependents!),
            if (benefit.dueDate != null)
              _buildInfoRow('Data de Vigência', benefit.dueDate!),
            if (benefit.monthlyValue != null)
              _buildInfoRow('Mensalidade', benefit.monthlyValue!),
            if (benefit.cardNumber != null)
              _buildInfoRow('Número do Cartão', benefit.cardNumber!),
            if (benefit.dailyValue != null)
              _buildInfoRow('Valor Diário', benefit.dailyValue!),
            if (benefit.nextRecharge != null)
              _buildInfoRow('Próxima Recarga', benefit.nextRecharge!),

            const SizedBox(height: 16),

            // Botões de Ações
            if (benefit.actions != null && benefit.actions!.isNotEmpty)
              _buildActionsSection(context, benefit, isMobile),
          ],
        ),
      ),
    );
  }

  /// Constrói uma linha de informação
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói a seção de ações
  Widget _buildActionsSection(
    BuildContext context,
    Benefit benefit,
    bool isMobile,
  ) {
    final actions = benefit.actions ?? [];

    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ações', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 12),
        isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: actions
                    .map(
                      (action) => _buildActionButton(context, action, benefit),
                    )
                    .toList(),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: actions
                    .map(
                      (action) => _buildActionButton(context, action, benefit),
                    )
                    .toList(),
              ),
      ],
    );
  }

  /// Constrói um botão de ação
  Widget _buildActionButton(
    BuildContext context,
    String action,
    Benefit benefit,
  ) {
    final isPrimary = action.contains('Cancelar');
    final isSecondary =
        action.contains('Gerenciar') || action.contains('Cancelar');

    return ElevatedButton(
      onPressed: () {
        _handleAction(context, action, benefit);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? Colors.red : AppTheme.primaryRed,
        foregroundColor: Colors.white,
      ),
      child: Text(action),
    );
  }

  /// Trata as ações dos botões
  void _handleAction(BuildContext context, String action, Benefit benefit) {
    if (action.contains('Cancelar')) {
      _showCancelConfirmation(context, benefit);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ação: $action'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Mostra diálogo de confirmação de cancelamento
  void _showCancelConfirmation(BuildContext context, Benefit benefit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Cancelamento'),
          content: Text(
            'Tem certeza que deseja cancelar o benefício "${benefit.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Não'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Solicitação Enviada, aguarde'),
                    duration: Duration(seconds: 4),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Sim, Cancelar'),
            ),
          ],
        );
      },
    );
  }
}

// import 'package:flutter/material.dart';
// import '../models/user_model.dart';
// import '../models/benefit_model.dart';
// import '../data/data_service.dart';
// import '../theme/app_theme.dart';

// class MyBenefitsPage extends StatefulWidget {
//   final User user;

//   const MyBenefitsPage({
//     Key? key,
//     required this.user,
//   }) : super(key: key);

//   @override
//   State<MyBenefitsPage> createState() => _MyBenefitsPageState();
// }

// class _MyBenefitsPageState extends State<MyBenefitsPage> {
//   late Future<List<Benefit>> _myBenefitsFuture;

//   @override
//   void initState() {
//     super.initState();
//     _myBenefitsFuture = DataService.getMyBenefits();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isMobile = MediaQuery.of(context).size.width < 768;

//     return Scaffold(
//       backgroundColor: AppTheme.backgroundColor,
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(isMobile ? 16 : 32),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Título e descrição
//               Text(
//                 'Meus Benefícios Ativos',
//                 style: Theme.of(context).textTheme.displaySmall?.copyWith(
//                       color: AppTheme.textDark,
//                       fontWeight: FontWeight.bold,
//                     ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Gerencie seus planos, solicite reembolsos e visualize seu histórico de utilização.',
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                       color: AppTheme.textLight,
//                     ),
//               ),
//               const SizedBox(height: 32),

//               // Lista de benefícios ativos
//               FutureBuilder<List<Benefit>>(
//                 future: _myBenefitsFuture,
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Center(
//                       child: CircularProgressIndicator(
//                         color: AppTheme.primaryRed,
//                       ),
//                     );
//                   }

//                   if (snapshot.hasError) {
//                     return Center(
//                       child: Text('Erro ao carregar benefícios: ${snapshot.error}'),
//                     );
//                   }

//                   final benefits = snapshot.data ?? [];

//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       ...benefits.map((benefit) {
//                         return Padding(
//                           padding: const EdgeInsets.only(bottom: 24),
//                           child: _buildDetailedBenefitCard(context, benefit, isMobile),
//                         );
//                       }).toList(),
//                     ],
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailedBenefitCard(BuildContext context, Benefit benefit, bool isMobile) {
//     return Card(
//       elevation: 1,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: const BorderSide(color: AppTheme.dividerColor),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header com ícone, nome e status
//             Row(
//               children: [
//                 Container(
//                   width: 56,
//                   height: 56,
//                   decoration: BoxDecoration(
//                     color: _getIconBackgroundColor(benefit.icon),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Center(
//                     child: Icon(
//                       _getIconForBenefit(benefit.icon),
//                       color: Colors.white,
//                       size: 28,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         benefit.name,
//                         style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                               fontWeight: FontWeight.bold,
//                               color: AppTheme.textDark,
//                             ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         benefit.category,
//                         style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                               color: AppTheme.textLight,
//                             ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: AppTheme.activeGreen.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Container(
//                         width: 8,
//                         height: 8,
//                         decoration: BoxDecoration(
//                           color: AppTheme.activeGreen,
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                       const SizedBox(width: 6),
//                       Text(
//                         'Ativo',
//                         style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                               color: AppTheme.activeGreen,
//                               fontWeight: FontWeight.w600,
//                             ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),

//             // Informações do plano em grid
//             _buildInfoGrid(context, benefit, isMobile),
//             const SizedBox(height: 24),

//             // Divider
//             Divider(color: AppTheme.dividerColor),
//             const SizedBox(height: 24),

//             // Ações
//             Text(
//               'AÇÕES',
//               style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                     color: AppTheme.textLight,
//                     fontWeight: FontWeight.w600,
//                     letterSpacing: 0.5,
//                   ),
//             ),
//             const SizedBox(height: 16),

//             if (!isMobile)
//               Row(
//                 children: [
//                   _buildActionButton(context, Icons.receipt, 'Parti Reembolso'),
//                   const SizedBox(width: 12),
//                   _buildActionButton(context, Icons.history, 'Status Reembolsos'),
//                   const SizedBox(width: 12),
//                   _buildActionButton(context, Icons.calendar_today, 'Histórico de Uso'),
//                   const SizedBox(width: 12),
//                   _buildActionButton(context, Icons.card_giftcard, 'Carteirinha Virtual'),
//                   const SizedBox(width: 12),
//                   _buildCancelButton(context, benefit),
//                 ],
//               )
//             else
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   _buildActionButton(context, Icons.receipt, 'Parti Reembolso'),
//                   const SizedBox(height: 12),
//                   _buildActionButton(context, Icons.history, 'Status Reembolsos'),
//                   const SizedBox(height: 12),
//                   _buildActionButton(context, Icons.calendar_today, 'Histórico de Uso'),
//                   const SizedBox(height: 12),
//                   _buildActionButton(context, Icons.card_giftcard, 'Carteirinha Virtual'),
//                   const SizedBox(height: 12),
//                   _buildCancelButton(context, benefit),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoGrid(BuildContext context, Benefit benefit, bool isMobile) {
//     return GridView.count(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisCount: isMobile ? 2 : 4,
//       crossAxisSpacing: 24,
//       mainAxisSpacing: 24,
//       childAspectRatio: 2.5,
//       children: [
//         _buildInfoItem(
//           context,
//           label: 'PLANO CONTRATADO',
//           value: benefit.planName ?? 'Nacional Flex (Enfermaria)',
//         ),
//         _buildInfoItem(
//           context,
//           label: 'DEPENDENTES',
//           value: benefit.dependents ?? '1 (Conjugar)',
//         ),
//         _buildInfoItem(
//           context,
//           label: '!!! DA VIGÊNCIA',
//           value: benefit.dueDate ?? '12/03/2023',
//         ),
//         _buildInfoItem(
//           context,
//           label: 'MENSALIDADE (COTA PARTE)',
//           value: benefit.monthlyValue ?? 'R\$ 145,90',
//         ),
//         if (benefit.cardNumber != null)
//           _buildInfoItem(
//             context,
//             label: 'MODO',
//             value: benefit.cardNumber ?? 'Bilhete Único (SP)',
//           ),
//         if (benefit.dailyValue != null)
//           _buildInfoItem(
//             context,
//             label: 'NÚMERO DO CARTÃO',
//             value: benefit.dailyValue ?? '**** 8842',
//           ),
//         if (benefit.nextRecharge != null)
//           _buildInfoItem(
//             context,
//             label: 'VALOR DIÁRIO',
//             value: benefit.nextRecharge ?? 'R\$ 18,90 (Ida e Volta)',
//           ),
//       ],
//     );
//   }

//   Widget _buildInfoItem(BuildContext context, {required String label, required String value}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Text(
//           label,
//           style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                 color: AppTheme.textLight,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 11,
//                 letterSpacing: 0.3,
//               ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           value,
//           style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                 color: AppTheme.textDark,
//                 fontWeight: FontWeight.w600,
//               ),
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//         ),
//       ],
//     );
//   }

//   Widget _buildActionButton(BuildContext context, IconData icon, String label) {
//     return Expanded(
//       child: OutlinedButton.icon(
//         onPressed: () {},
//         icon: Icon(icon, size: 18),
//         label: Text(
//           label,
//           style: const TextStyle(fontSize: 12),
//         ),
//         style: OutlinedButton.styleFrom(
//           foregroundColor: AppTheme.textDark,
//           side: const BorderSide(color: AppTheme.dividerColor),
//           padding: const EdgeInsets.symmetric(vertical: 12),
//         ),
//       ),
//     );
//   }

//   Widget _buildCancelButton(BuildContext context, Benefit benefit) {
//     return Expanded(
//       child: ElevatedButton.icon(
//         onPressed: () => _showCancelConfirmationDialog(context, benefit),
//         icon: const Icon(Icons.close, size: 18),
//         label: const Text(
//           'Cancelar Plano',
//           style: TextStyle(fontSize: 12),
//         ),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppTheme.primaryRed,
//           foregroundColor: Colors.white,
//           padding: const EdgeInsets.symmetric(vertical: 12),
//         ),
//       ),
//     );
//   }

//   void _showCancelConfirmationDialog(BuildContext context, Benefit benefit) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Confirma cancelamento'),
//           content: Text(
//             'Tem certeza que deseja cancelar o plano ${benefit.name}?',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Não'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 _showSuccessMessage(context);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppTheme.primaryRed,
//               ),
//               child: const Text('Sim'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showSuccessMessage(BuildContext context) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Text('Solicitação Enviada, aguarde'),
//         backgroundColor: AppTheme.activeGreen,
//         duration: const Duration(seconds: 4),
//       ),
//     );
//   }

//   Color _getIconBackgroundColor(String icon) {
//     switch (icon.toLowerCase()) {
//       case 'health':
//         return const Color(0xFF4CAF50); // Verde
//       case 'food':
//         return const Color(0xFF4CAF50); // Verde
//       case 'transport':
//         return const Color(0xFFFFD54F); // Amarelo
//       case 'gym':
//         return const Color(0xFF9C27B0); // Roxo
//       case 'education':
//         return const Color(0xFF00BCD4); // Ciano
//       case 'family':
//         return const Color(0xFFE91E63); // Rosa
//       case 'insurance':
//         return const Color(0xFF673AB7); // Roxo escuro
//       case 'mental':
//         return const Color(0xFF3F51B5); // Índigo
//       case 'pharmacy':
//         return const Color(0xFF009688); // Teal
//       default:
//         return AppTheme.primaryRed;
//     }
//   }

//   IconData _getIconForBenefit(String icon) {
//     switch (icon.toLowerCase()) {
//       case 'health':
//         return Icons.favorite_rounded;
//       case 'food':
//         return Icons.restaurant_rounded;
//       case 'transport':
//         return Icons.directions_bus_rounded;
//       case 'gym':
//         return Icons.fitness_center_rounded;
//       case 'education':
//         return Icons.school_rounded;
//       case 'family':
//         return Icons.people_rounded;
//       case 'insurance':
//         return Icons.security_rounded;
//       case 'mental':
//         return Icons.psychology_rounded;
//       case 'pharmacy':
//         return Icons.local_pharmacy_rounded;
//       default:
//         return Icons.card_giftcard_rounded;
//     }
//   }
// }
