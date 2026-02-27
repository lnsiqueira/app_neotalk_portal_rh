import 'package:app_neotalk_portal_rh/models/my_benefits_modals.dart';
import 'package:app_neotalk_portal_rh/services/unimed_virtual_card.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/benefit_model.dart';
import '../services/user_data_service.dart';
import '../services/reimbursement_service.dart';
import '../theme/app_theme.dart';

class MyBenefitsPage extends StatefulWidget {
  final User user;

  const MyBenefitsPage({Key? key, required this.user}) : super(key: key);

  @override
  State<MyBenefitsPage> createState() => _MyBenefitsPageState();
}

class _MyBenefitsPageState extends State<MyBenefitsPage> {
  late Future<List<Benefit>> _benefitsFuture;
  final ReimbursementService _reimbursementService = ReimbursementService();

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

                // Seção: Ações Rápidas (COM CARTEIRINHA VIRTUAL)
                _buildQuickActionsSection(context, isMobile),
                const SizedBox(height: 32),

                // Seção: Meus Benefícios Ativos
                Text(
                  'Meus Benefícios Ativos',
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

  /// Seção de ações rápidas (COM CARTEIRINHA)
  Widget _buildQuickActionsSection(BuildContext context, bool isMobile) {
    final actions = [
      {
        'title': 'Solicitar Reembolso',
        'icon': Icons.receipt_long,
        'color': Colors.blue,
        'onTap': _showRequestReimbursementModal,
      },
      {
        'title': 'Status Reembolsos',
        'icon': Icons.check_circle,
        'color': Colors.green,
        'onTap': _showReimbursementStatusModal,
      },
      {
        'title': 'Histórico de Uso',
        'icon': Icons.history,
        'color': Colors.orange,
        'onTap': _showUsageHistoryModal,
      },
      {
        'title': 'Carteirinha Virtual',
        'icon': Icons.credit_card,
        'color': const Color(0xFF1B7D3D), // Verde Unimed
        'onTap': _showVirtualCardModal,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ações Rápidas', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        isMobile
            ? Column(
                children: actions.asMap().entries.map((entry) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: entry.key < actions.length - 1 ? 12 : 0,
                    ),
                    child: _buildActionCard(context, entry.value),
                  );
                }).toList(),
              )
            : GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: actions
                    .map((action) => _buildActionCard(context, action))
                    .toList(),
              ),
      ],
    );
  }

  /// Card de ação rápida
  Widget _buildActionCard(BuildContext context, Map<String, dynamic> action) {
    return GestureDetector(
      onTap: action['onTap'] as VoidCallback,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (action['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                action['icon'] as IconData,
                color: action['color'] as Color,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: Text(
                action['title'] as String,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
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
              child: const Text('Cancelar Benefício'),
            ),
          ],
        );
      },
    );
  }

  /// Mostrar modal de Solicitar Reembolso
  void _showRequestReimbursementModal() {
    final benefits = _benefitsFuture;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<List<Benefit>>(
          future: benefits,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return RequestReimbursementModal(
                user: widget.user,
                benefit: snapshot.data!.first,
              );
            }
            return const AlertDialog(
              title: Text('Erro'),
              content: Text('Nenhum benefício disponível'),
            );
          },
        );
      },
    );
  }

  /// Mostrar modal de Status de Reembolsos
  void _showReimbursementStatusModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ReimbursementStatusModal(user: widget.user);
      },
    );
  }

  /// Mostrar modal de Histórico de Uso
  void _showUsageHistoryModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return UsageHistoryModal(user: widget.user);
      },
    );
  }

  /// Mostrar modal de Carteirinha Virtual
  void _showVirtualCardModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return UnimedVirtualCardModal(
          user: widget.user,
          cardNumber: '0 123 123456789012 1',
          cardValidity: '11/12/2027',
          planName: 'EMPRESARIAL',
        );
      },
    );
  }
}


// import 'package:app_neotalk_portal_rh/models/my_benefits_modals.dart';
// import 'package:app_neotalk_portal_rh/services/reimbursement_service.dart';
// import 'package:flutter/material.dart';
// import '../models/user_model.dart';
// import '../models/benefit_model.dart';
// import '../services/user_data_service.dart';
// import '../theme/app_theme.dart';

// class MyBenefitsPage extends StatefulWidget {
//   final User user;

//   const MyBenefitsPage({Key? key, required this.user}) : super(key: key);

//   @override
//   State<MyBenefitsPage> createState() => _MyBenefitsPageState();
// }

// class _MyBenefitsPageState extends State<MyBenefitsPage> {
//   late Future<List<Benefit>> _benefitsFuture;
//   final ReimbursementService _reimbursementService = ReimbursementService();

//   @override
//   void initState() {
//     super.initState();
//     _benefitsFuture = UserDataService.getMyBenefits(widget.user.name);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isMobile = MediaQuery.of(context).size.width < 768;

//     return FutureBuilder<List<Benefit>>(
//       future: _benefitsFuture,
//       builder: (context, snapshot) {
//         // Carregando
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(
//             child: CircularProgressIndicator(color: AppTheme.primaryRed),
//           );
//         }

//         // Erro
//         if (snapshot.hasError) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.error_outline, color: AppTheme.primaryRed, size: 64),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Erro ao carregar benefícios',
//                   style: Theme.of(context).textTheme.titleLarge,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   '${snapshot.error}',
//                   textAlign: TextAlign.center,
//                   style: Theme.of(context).textTheme.bodyMedium,
//                 ),
//                 const SizedBox(height: 24),
//                 ElevatedButton(
//                   onPressed: () {
//                     setState(() {
//                       _benefitsFuture = UserDataService.getMyBenefits(
//                         widget.user.name,
//                       );
//                     });
//                   },
//                   child: const Text('Tentar Novamente'),
//                 ),
//               ],
//             ),
//           );
//         }

//         // Dados carregados
//         final benefits = snapshot.data ?? [];

//         if (benefits.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.card_giftcard, color: Colors.grey, size: 64),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Nenhum benefício ativo',
//                   style: Theme.of(context).textTheme.titleLarge,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Você não possui benefícios ativos no momento',
//                   style: Theme.of(context).textTheme.bodyMedium,
//                 ),
//               ],
//             ),
//           );
//         }

//         return SingleChildScrollView(
//           child: Padding(
//             padding: EdgeInsets.all(isMobile ? 16 : 32),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Título
//                 Text(
//                   'Gestão de Benefícios',
//                   style: Theme.of(context).textTheme.headlineSmall,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Gerencie seus planos, solicite reembolsos e visualize seu histórico de utilização.',
//                   style: Theme.of(context).textTheme.bodyMedium,
//                 ),
//                 const SizedBox(height: 32),

//                 // Seção: Ações Rápidas
//                 _buildQuickActionsSection(context, isMobile),
//                 const SizedBox(height: 32),

//                 // Seção: Meus Benefícios Ativos
//                 Text(
//                   'Meus Benefícios Ativos',
//                   style: Theme.of(context).textTheme.titleLarge,
//                 ),
//                 const SizedBox(height: 16),

//                 // Lista de benefícios
//                 ListView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: benefits.length,
//                   itemBuilder: (context, index) {
//                     final benefit = benefits[index];
//                     return _buildBenefitCard(context, benefit, isMobile);
//                   },
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   /// Seção de ações rápidas
//   Widget _buildQuickActionsSection(BuildContext context, bool isMobile) {
//     final actions = [
//       {
//         'title': 'Solicitar Reembolso',
//         'icon': Icons.receipt_long,
//         'color': Colors.blue,
//         'onTap': _showRequestReimbursementModal,
//       },
//       {
//         'title': 'Status Reembolsos',
//         'icon': Icons.check_circle,
//         'color': Colors.green,
//         'onTap': _showReimbursementStatusModal,
//       },
//       {
//         'title': 'Histórico de Uso',
//         'icon': Icons.history,
//         'color': Colors.orange,
//         'onTap': _showUsageHistoryModal,
//       },
//       {
//         'title': 'Carteirinha Virtual',
//         'icon': Icons.credit_card,
//         'color': Colors.red,
//         'onTap': _showVirtualCardModal,
//       },
//     ];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Ações Rápidas', style: Theme.of(context).textTheme.titleLarge),
//         const SizedBox(height: 16),
//         isMobile
//             ? Column(
//                 children: actions
//                     .map((action) => _buildActionCard(context, action))
//                     .toList()
//                     .asMap()
//                     .entries
//                     .map((entry) {
//                       return Padding(
//                         padding: EdgeInsets.only(
//                           bottom: entry.key < actions.length - 1 ? 12 : 0,
//                         ),
//                         child: entry.value,
//                       );
//                     })
//                     .toList(),
//               )
//             : GridView.count(
//                 crossAxisCount: 4,
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 mainAxisSpacing: 12,
//                 crossAxisSpacing: 12,
//                 children: actions
//                     .map((action) => _buildActionCard(context, action))
//                     .toList(),
//               ),
//       ],
//     );
//   }

//   /// Card de ação rápida
//   Widget _buildActionCard(BuildContext context, Map<String, dynamic> action) {
//     return GestureDetector(
//       onTap: action['onTap'] as VoidCallback,
//       child: Container(
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey.shade300),
//           borderRadius: BorderRadius.circular(12),
//           color: Colors.white,
//         ),
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: (action['color'] as Color).withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(
//                 action['icon'] as IconData,
//                 color: action['color'] as Color,
//                 size: 28,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               action['title'] as String,
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Constrói o card de um benefício
//   Widget _buildBenefitCard(
//     BuildContext context,
//     Benefit benefit,
//     bool isMobile,
//   ) {
//     final isActive = benefit.status == 'ATIVO';
//     final statusColor = isActive ? Colors.green : Colors.orange;

//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header: Nome e Status
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         benefit.name,
//                         style: Theme.of(context).textTheme.titleMedium,
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         benefit.subcategory ?? benefit.category,
//                         style: Theme.of(context).textTheme.bodySmall,
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 6,
//                   ),
//                   decoration: BoxDecoration(
//                     color: statusColor,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     benefit.status,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),

//             // Informações do Plano
//             if (benefit.planName != null)
//               _buildInfoRow('Plano Contratado', benefit.planName!),
//             if (benefit.dependents != null)
//               _buildInfoRow('Dependentes', benefit.dependents!),
//             if (benefit.dueDate != null)
//               _buildInfoRow('Data de Vigência', benefit.dueDate!),
//             if (benefit.monthlyValue != null)
//               _buildInfoRow('Mensalidade', benefit.monthlyValue!),
//             if (benefit.cardNumber != null)
//               _buildInfoRow('Número do Cartão', benefit.cardNumber!),
//             if (benefit.dailyValue != null)
//               _buildInfoRow('Valor Diário', benefit.dailyValue!),
//             if (benefit.nextRecharge != null)
//               _buildInfoRow('Próxima Recarga', benefit.nextRecharge!),

//             const SizedBox(height: 16),

//             // Botões de Ações
//             if (benefit.actions != null && benefit.actions!.isNotEmpty)
//               _buildActionsSection(context, benefit, isMobile),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Constrói uma linha de informação
//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 1,
//             child: Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 12,
//                 color: Colors.grey,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 2,
//             child: Text(
//               value,
//               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// Constrói a seção de ações
//   Widget _buildActionsSection(
//     BuildContext context,
//     Benefit benefit,
//     bool isMobile,
//   ) {
//     final actions = benefit.actions ?? [];

//     if (actions.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Ações', style: Theme.of(context).textTheme.labelLarge),
//         const SizedBox(height: 12),
//         isMobile
//             ? Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: actions
//                     .map(
//                       (action) => _buildActionButton(context, action, benefit),
//                     )
//                     .toList(),
//               )
//             : Wrap(
//                 spacing: 8,
//                 runSpacing: 8,
//                 children: actions
//                     .map(
//                       (action) => _buildActionButton(context, action, benefit),
//                     )
//                     .toList(),
//               ),
//       ],
//     );
//   }

//   /// Constrói um botão de ação
//   Widget _buildActionButton(
//     BuildContext context,
//     String action,
//     Benefit benefit,
//   ) {
//     final isPrimary = action.contains('Cancelar');

//     return ElevatedButton(
//       onPressed: () {
//         _handleAction(context, action, benefit);
//       },
//       style: ElevatedButton.styleFrom(
//         backgroundColor: isPrimary ? Colors.red : AppTheme.primaryRed,
//         foregroundColor: Colors.white,
//       ),
//       child: Text(action),
//     );
//   }

//   /// Trata as ações dos botões
//   void _handleAction(BuildContext context, String action, Benefit benefit) {
//     if (action.contains('Cancelar')) {
//       _showCancelConfirmation(context, benefit);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Ação: $action'),
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     }
//   }

//   /// Mostra diálogo de confirmação de cancelamento
//   void _showCancelConfirmation(BuildContext context, Benefit benefit) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Confirmar Cancelamento'),
//           content: Text(
//             'Tem certeza que deseja cancelar o benefício "${benefit.name}"?',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Não'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Solicitação Enviada, aguarde'),
//                     duration: Duration(seconds: 4),
//                   ),
//                 );
//               },
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//               child: const Text('Cancelar Benefício'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   /// Mostrar modal de Solicitar Reembolso
//   void _showRequestReimbursementModal() {
//     final benefits = _benefitsFuture;

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return FutureBuilder<List<Benefit>>(
//           future: benefits,
//           builder: (context, snapshot) {
//             if (snapshot.hasData && snapshot.data!.isNotEmpty) {
//               return RequestReimbursementModal(
//                 user: widget.user,
//                 benefit: snapshot.data!.first,
//               );
//             }
//             return const AlertDialog(
//               title: Text('Erro'),
//               content: Text('Nenhum benefício disponível'),
//             );
//           },
//         );
//       },
//     );
//   }

//   /// Mostrar modal de Status de Reembolsos
//   void _showReimbursementStatusModal() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return ReimbursementStatusModal(user: widget.user);
//       },
//     );
//   }

//   /// Mostrar modal de Histórico de Uso
//   void _showUsageHistoryModal() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return UsageHistoryModal(user: widget.user);
//       },
//     );
//   }

//   /// Mostrar modal de Carteirinha Virtual
//   void _showVirtualCardModal() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return VirtualCardModal(user: widget.user);
//       },
//     );
//   }
// }




//--------------------------

// import 'package:flutter/material.dart';
// import '../models/user_model.dart';
// import '../models/benefit_model.dart';
// import '../services/user_data_service.dart';
// import '../theme/app_theme.dart';
// //teste

// class MyBenefitsPage extends StatefulWidget {
//   final User user;

//   const MyBenefitsPage({Key? key, required this.user}) : super(key: key);

//   @override
//   State<MyBenefitsPage> createState() => _MyBenefitsPageState();
// }

// class _MyBenefitsPageState extends State<MyBenefitsPage> {
//   late Future<List<Benefit>> _benefitsFuture;

//   @override
//   void initState() {
//     super.initState();
//     _benefitsFuture = UserDataService.getMyBenefits(widget.user.name);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isMobile = MediaQuery.of(context).size.width < 768;

//     return FutureBuilder<List<Benefit>>(
//       future: _benefitsFuture,
//       builder: (context, snapshot) {
//         // Carregando
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(
//             child: CircularProgressIndicator(color: AppTheme.primaryRed),
//           );
//         }

//         // Erro
//         if (snapshot.hasError) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.error_outline, color: AppTheme.primaryRed, size: 64),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Erro ao carregar benefícios',
//                   style: Theme.of(context).textTheme.titleLarge,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   '${snapshot.error}',
//                   textAlign: TextAlign.center,
//                   style: Theme.of(context).textTheme.bodyMedium,
//                 ),
//                 const SizedBox(height: 24),
//                 ElevatedButton(
//                   onPressed: () {
//                     setState(() {
//                       _benefitsFuture = UserDataService.getMyBenefits(
//                         widget.user.name,
//                       );
//                     });
//                   },
//                   child: const Text('Tentar Novamente'),
//                 ),
//               ],
//             ),
//           );
//         }

//         // Dados carregados
//         final benefits = snapshot.data ?? [];

//         if (benefits.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.card_giftcard, color: Colors.grey, size: 64),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Nenhum benefício ativo',
//                   style: Theme.of(context).textTheme.titleLarge,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Você não possui benefícios ativos no momento',
//                   style: Theme.of(context).textTheme.bodyMedium,
//                 ),
//               ],
//             ),
//           );
//         }

//         return SingleChildScrollView(
//           child: Padding(
//             padding: EdgeInsets.all(isMobile ? 16 : 32),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Título
//                 Text(
//                   'Gestão de Benefícios',
//                   style: Theme.of(context).textTheme.headlineSmall,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Gerencie seus planos, solicite reembolsos e visualize seu histórico de utilização.',
//                   style: Theme.of(context).textTheme.bodyMedium,
//                 ),
//                 const SizedBox(height: 32),

//                 // Seção: Meus Benefícios Ativos
//                 Text(
//                   'Meus Benefícios Ativos',
//                   style: Theme.of(context).textTheme.titleLarge,
//                 ),
//                 const SizedBox(height: 16),

//                 // Lista de benefícios
//                 ListView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: benefits.length,
//                   itemBuilder: (context, index) {
//                     final benefit = benefits[index];
//                     return _buildBenefitCard(context, benefit, isMobile);
//                   },
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   /// Constrói o card de um benefício
//   Widget _buildBenefitCard(
//     BuildContext context,
//     Benefit benefit,
//     bool isMobile,
//   ) {
//     final isActive = benefit.status == 'ATIVO';
//     final statusColor = isActive ? Colors.green : Colors.orange;

//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header: Nome e Status
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         benefit.name,
//                         style: Theme.of(context).textTheme.titleMedium,
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         benefit.subcategory ?? benefit.category,
//                         style: Theme.of(context).textTheme.bodySmall,
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 6,
//                   ),
//                   decoration: BoxDecoration(
//                     color: statusColor,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     benefit.status,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),

//             // Informações do Plano
//             if (benefit.planName != null)
//               _buildInfoRow('Plano Contratado', benefit.planName!),
//             if (benefit.dependents != null)
//               _buildInfoRow('Dependentes', benefit.dependents!),
//             if (benefit.dueDate != null)
//               _buildInfoRow('Data de Vigência', benefit.dueDate!),
//             if (benefit.monthlyValue != null)
//               _buildInfoRow('Mensalidade', benefit.monthlyValue!),
//             if (benefit.cardNumber != null)
//               _buildInfoRow('Número do Cartão', benefit.cardNumber!),
//             if (benefit.dailyValue != null)
//               _buildInfoRow('Valor Diário', benefit.dailyValue!),
//             if (benefit.nextRecharge != null)
//               _buildInfoRow('Próxima Recarga', benefit.nextRecharge!),

//             const SizedBox(height: 16),

//             // Botões de Ações
//             if (benefit.actions != null && benefit.actions!.isNotEmpty)
//               _buildActionsSection(context, benefit, isMobile),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Constrói uma linha de informação
//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 1,
//             child: Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 12,
//                 color: Colors.grey,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 2,
//             child: Text(
//               value,
//               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// Constrói a seção de ações
//   Widget _buildActionsSection(
//     BuildContext context,
//     Benefit benefit,
//     bool isMobile,
//   ) {
//     final actions = benefit.actions ?? [];

//     if (actions.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Ações', style: Theme.of(context).textTheme.labelLarge),
//         const SizedBox(height: 12),
//         isMobile
//             ? Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: actions
//                     .map(
//                       (action) => _buildActionButton(context, action, benefit),
//                     )
//                     .toList(),
//               )
//             : Wrap(
//                 spacing: 8,
//                 runSpacing: 8,
//                 children: actions
//                     .map(
//                       (action) => _buildActionButton(context, action, benefit),
//                     )
//                     .toList(),
//               ),
//       ],
//     );
//   }

//   /// Constrói um botão de ação
//   Widget _buildActionButton(
//     BuildContext context,
//     String action,
//     Benefit benefit,
//   ) {
//     final isPrimary = action.contains('Cancelar');
//     final isSecondary =
//         action.contains('Gerenciar') || action.contains('Cancelar');

//     return ElevatedButton(
//       onPressed: () {
//         _handleAction(context, action, benefit);
//       },
//       style: ElevatedButton.styleFrom(
//         backgroundColor: isPrimary ? Colors.red : AppTheme.primaryRed,
//         foregroundColor: Colors.white,
//       ),
//       child: Text(action),
//     );
//   }

//   /// Trata as ações dos botões
//   void _handleAction(BuildContext context, String action, Benefit benefit) {
//     if (action.contains('Cancelar')) {
//       _showCancelConfirmation(context, benefit);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Ação: $action'),
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     }
//   }

//   /// Mostra diálogo de confirmação de cancelamento
//   void _showCancelConfirmation(BuildContext context, Benefit benefit) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Confirmar Cancelamento'),
//           content: Text(
//             'Tem certeza que deseja cancelar o benefício "${benefit.name}"?',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Não'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Solicitação Enviada, aguarde'),
//                     duration: Duration(seconds: 4),
//                   ),
//                 );
//               },
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//               child: const Text('Sim, Cancelar'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
