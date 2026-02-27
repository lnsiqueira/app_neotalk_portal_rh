import 'package:flutter/material.dart';
import '../models/available_benefit_model.dart';
import '../services/benefit_eligibility_service.dart';
import '../widgets/benefit_request_modals.dart';
import '../theme/app_theme.dart';

class AvailableBenefitsWidget extends StatefulWidget {
  final String userName;
  final String userRole;

  const AvailableBenefitsWidget({
    Key? key,
    required this.userName,
    required this.userRole,
  }) : super(key: key);

  @override
  State<AvailableBenefitsWidget> createState() =>
      _AvailableBenefitsWidgetState();
}

class _AvailableBenefitsWidgetState extends State<AvailableBenefitsWidget> {
  late Future<List<AvailableBenefit>> _benefitsFuture;
  late Future<Map<String, BenefitEligibility>> _eligibilityFuture;

  @override
  void initState() {
    super.initState();
    _benefitsFuture = BenefitEligibilityService.getAvailableBenefitsDetails();
    _eligibilityFuture = BenefitEligibilityService.getUserEligibility(
      widget.userName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return FutureBuilder<List<AvailableBenefit>>(
      future: _benefitsFuture,
      builder: (context, benefitsSnapshot) {
        if (benefitsSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: AppTheme.primaryRed),
          );
        }

        if (benefitsSnapshot.hasError) {
          print('Erro ao carregar benefícios: ${benefitsSnapshot.error}');
          return Center(child: Text('Erro ao carregar benefícios disponíveis'));
        }

        final benefits = benefitsSnapshot.data ?? [];

        if (benefits.isEmpty) {
          return Center(child: Text('Nenhum benefício disponível'));
        }

        return FutureBuilder<Map<String, BenefitEligibility>>(
          future: _eligibilityFuture,
          builder: (context, eligibilitySnapshot) {
            if (eligibilitySnapshot.connectionState ==
                ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: AppTheme.primaryRed),
              );
            }

            if (eligibilitySnapshot.hasError) {
              print(
                'Erro ao carregar elegibilidade: ${eligibilitySnapshot.error}',
              );
            }

            final eligibilityMap = eligibilitySnapshot.data ?? {};

            print(
              'Elegibilidade carregada para ${widget.userName}: ${eligibilityMap.length} benefícios',
            );

            return widget.userRole == "Dependente"
                ? Container()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Benefícios Disponíveis',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      isMobile
                          ? _buildMobileGrid(context, benefits, eligibilityMap)
                          : _buildDesktopGrid(
                              context,
                              benefits,
                              eligibilityMap,
                            ),
                    ],
                  );
          },
        );
      },
    );
  }

  Widget _buildDesktopGrid(
    BuildContext context,
    List<AvailableBenefit> benefits,
    Map<String, BenefitEligibility> eligibilityMap,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      //   crossAxisCount: 3,
      //   childAspectRatio: 1.1,
      //   crossAxisSpacing: 16,
      //   mainAxisSpacing: 16,
      // ),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        childAspectRatio: 1.1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: benefits.length,
      itemBuilder: (context, index) {
        final benefit = benefits[index];
        final eligibility = eligibilityMap[benefit.id];
        return _buildBenefitCard(context, benefit, eligibility);
      },
    );
  }

  Widget _buildMobileGrid(
    BuildContext context,
    List<AvailableBenefit> benefits,
    Map<String, BenefitEligibility> eligibilityMap,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.9,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: benefits.length,
      itemBuilder: (context, index) {
        final benefit = benefits[index];
        final eligibility = eligibilityMap[benefit.id];
        return _buildBenefitCard(context, benefit, eligibility);
      },
    );
  }

  Widget _buildBenefitCard(
    BuildContext context,
    AvailableBenefit benefit,
    BenefitEligibility? eligibility,
  ) {
    final isEligible = eligibility?.eligible ?? true;
    final ineligibilityReason = eligibility?.reason ?? '';

    print(
      'Card ${benefit.name}: elegível=$isEligible, motivo=$ineligibilityReason',
    );

    return Card(
      child: InkWell(
        onTap: isEligible
            ? () {
                BenefitDetailsModal.show(
                  context,
                  benefit,
                  isEligible,
                  ineligibilityReason,
                  widget.userName,
                  widget.userRole,
                  () {
                    BenefitRequestTermsDialog.show(
                      context,
                      benefit,
                      widget.userName,
                      widget.userRole,
                      () {
                        print('Benefício ${benefit.name} solicitado!');
                      },
                    );
                  },
                );
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícone e Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getIconData(benefit.icon),
                      color: AppTheme.primaryRed,
                      size: 24,
                    ),
                  ),
                  // Ícone de interrogação com tooltip para inelegíveis
                  if (!isEligible)
                    Tooltip(
                      message: ineligibilityReason.isNotEmpty
                          ? ineligibilityReason
                          : 'Você não é elegível para este benefício',
                      showDuration: const Duration(seconds: 5),
                      child: Icon(
                        Icons.help_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Nome
              Text(
                benefit.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 4),

              // Categoria
              Text(
                benefit.category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              const Spacer(),

              // Desconto/Benefício
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  benefit.discount,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Botão Solicitar
              SizedBox(
                width: double.infinity,
                child: isEligible
                    ? ElevatedButton(
                        onPressed: () {
                          BenefitDetailsModal.show(
                            context,
                            benefit,
                            isEligible,
                            ineligibilityReason,
                            widget.userName,
                            widget.userRole,
                            () {
                              BenefitRequestTermsDialog.show(
                                context,
                                benefit,
                                widget.userName,
                                widget.userRole,
                                () {
                                  print(
                                    'Benefício ${benefit.name} solicitado!',
                                  );
                                },
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryRed,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text(
                          'Solicitar',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Tooltip(
                            message: ineligibilityReason.isNotEmpty
                                ? ineligibilityReason
                                : 'Você não é elegível para este benefício',
                            showDuration: const Duration(seconds: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Indisponível',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.help_outline,
                                  color: Colors.grey,
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
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
