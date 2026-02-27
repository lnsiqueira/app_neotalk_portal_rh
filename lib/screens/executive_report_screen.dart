import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/executive_report_service.dart';
import '../models/executive_report_models.dart';
import '../theme/app_theme.dart';

class ExecutiveReportScreen extends StatefulWidget {
  final User user;

  const ExecutiveReportScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ExecutiveReportScreen> createState() => _ExecutiveReportScreenState();
}

class _ExecutiveReportScreenState extends State<ExecutiveReportScreen> {
  late Future<ExecutiveReportSummary> _reportFuture;
  String? _selectedBenefitId;

  @override
  void initState() {
    super.initState();
    _reportFuture = ExecutiveReportService.getExecutiveReportSummary();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return FutureBuilder<ExecutiveReportSummary>(
      future: _reportFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: AppTheme.primaryRed),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: AppTheme.primaryRed, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar relatório',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _reportFuture =
                          ExecutiveReportService.getExecutiveReportSummary();
                    });
                  },
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          );
        }

        final report = snapshot.data!;
        _selectedBenefitId ??= report.benefitCosts.first.benefitId;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Text(
                'Relatórios Executivos',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Análise de custos de benefícios corporativos',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),

              // Cards de Resumo Geral
              if (isMobile)
                Column(
                  children: [
                    _buildSummaryCard(
                      'Custo Mensal Total',
                      'R\$ ${report.totalMonthlyCost.toStringAsFixed(2)}',
                      Icons.trending_down,
                      AppTheme.primaryRed,
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryCard(
                      'Custo Anual Projetado',
                      'R\$ ${report.totalAnnualProjectedCost.toStringAsFixed(2)}',
                      Icons.calendar_today,
                      Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryCard(
                      'Custo por Colaborador',
                      'R\$ ${report.averageCostPerEmployee.toStringAsFixed(2)}',
                      Icons.person,
                      Colors.green,
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Custo Mensal Total',
                        'R\$ ${report.totalMonthlyCost.toStringAsFixed(2)}',
                        Icons.trending_down,
                        AppTheme.primaryRed,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        'Custo Anual Projetado',
                        'R\$ ${report.totalAnnualProjectedCost.toStringAsFixed(2)}',
                        Icons.calendar_today,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        'Custo por Colaborador',
                        'R\$ ${report.averageCostPerEmployee.toStringAsFixed(2)}',
                        Icons.person,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 32),

              // Seletor de Benefício
              Text(
                'Análise por Benefício',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: _selectedBenefitId,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: report.benefitCosts.map((benefit) {
                    return DropdownMenuItem<String>(
                      value: benefit.benefitId,
                      child: Text(benefit.benefitName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedBenefitId = value;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Detalhes do Benefício Selecionado
              _buildBenefitDetailsSection(
                report.benefitCosts.firstWhere(
                  (b) => b.benefitId == _selectedBenefitId,
                ),
                isMobile,
              ),
              const SizedBox(height: 32),

              // Gráfico de Histórico
              _buildHistoryChartSection(
                report.benefitCosts.firstWhere(
                  (b) => b.benefitId == _selectedBenefitId,
                ),
                isMobile,
              ),
              const SizedBox(height: 32),

              // Comparativo de Todos os Benefícios
              _buildBenefitsComparisonSection(report.benefitCosts, isMobile),
            ],
          ),
        );
      },
    );
  }

  /// Card de resumo
  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
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

  /// Seção de detalhes do benefício
  Widget _buildBenefitDetailsSection(BenefitCostData benefit, bool isMobile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        benefit.benefitName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        benefit.category,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Grid de Métricas
            if (isMobile)
              Column(
                children: [
                  _buildMetricTile(
                    'Custo Total Mensal',
                    'R\$ ${benefit.monthlyCost.toStringAsFixed(2)}',
                    Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildMetricTile(
                    'Custo Anual Projetado',
                    'R\$ ${benefit.annualProjectedCost.toStringAsFixed(2)}',
                    Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildMetricTile(
                    'Custo por Colaborador',
                    'R\$ ${benefit.costPerEmployee.toStringAsFixed(2)}',
                    Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  _buildMetricTile(
                    'Custo por Centro de Custo',
                    'R\$ ${benefit.costPerCostCenter.toStringAsFixed(2)}',
                    Colors.purple,
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      'Custo Total Mensal',
                      'R\$ ${benefit.monthlyCost.toStringAsFixed(2)}',
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(
                      'Custo Anual Projetado',
                      'R\$ ${benefit.annualProjectedCost.toStringAsFixed(2)}',
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(
                      'Custo por Colaborador',
                      'R\$ ${benefit.costPerEmployee.toStringAsFixed(2)}',
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(
                      'Custo por Centro de Custo',
                      'R\$ ${benefit.costPerCostCenter.toStringAsFixed(2)}',
                      Colors.purple,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),

            // Informações Adicionais
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Colaboradores Utilizando',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${benefit.totalEmployees}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Centros de Custo Ativos',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${benefit.activeCostCenters}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Tile de métrica
  Widget _buildMetricTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Seção de gráfico de histórico
  Widget _buildHistoryChartSection(BenefitCostData benefit, bool isMobile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Histórico de Custos - Últimos 6 Meses',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: isMobile ? 300 : 400,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() <
                              benefit.monthlyCostHistory.length) {
                            return Text(
                              benefit
                                  .monthlyCostHistory[value.toInt()]
                                  .monthAbbr,
                              style: Theme.of(context).textTheme.bodySmall,
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            'R\$ ${(value / 1000).toStringAsFixed(0)}k',
                            style: Theme.of(context).textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        benefit.monthlyCostHistory.length,
                        (index) => FlSpot(
                          index.toDouble(),
                          benefit.monthlyCostHistory[index].totalCost,
                        ),
                      ),
                      isCurved: true,
                      color: AppTheme.primaryRed,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.primaryRed.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Seção de comparativo de benefícios
  Widget _buildBenefitsComparisonSection(
    List<BenefitCostData> benefits,
    bool isMobile,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comparativo de Custos - Todos os Benefícios',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  barGroups: List.generate(
                    benefits.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: benefits[index].monthlyCost,
                          color: AppTheme.primaryRed,
                          width: 16,
                        ),
                      ],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < benefits.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                benefits[value.toInt()].benefitName
                                    .split(' ')
                                    .first,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            'R\$ ${(value / 1000).toStringAsFixed(0)}k',
                            style: Theme.of(context).textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
