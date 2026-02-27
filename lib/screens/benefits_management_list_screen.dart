import 'package:flutter/material.dart';
import '../models/benefit_management_model.dart';
import '../services/benefit_management_service.dart';
import '../theme/app_theme.dart';
import 'benefit_form_screen.dart';

class BenefitsManagementListScreen extends StatefulWidget {
  const BenefitsManagementListScreen({Key? key}) : super(key: key);

  @override
  State<BenefitsManagementListScreen> createState() =>
      _BenefitsManagementListScreenState();
}

class _BenefitsManagementListScreenState
    extends State<BenefitsManagementListScreen> {
  late Future<List<CorporateBenefit>> _benefitsFuture;
  String _searchQuery = '';
  String _selectedCategory = '';
  String _selectedStatus = '';

  @override
  void initState() {
    super.initState();
    _loadBenefits();
  }

  void _loadBenefits() {
    setState(() {
      _benefitsFuture = _getBenefits();
    });
  }

  Future<List<CorporateBenefit>> _getBenefits() async {
    List<CorporateBenefit> benefits =
        await BenefitManagementService.getAllBenefits();

    if (_searchQuery.isNotEmpty) {
      benefits = await BenefitManagementService.searchBenefits(_searchQuery);
    }

    if (_selectedCategory.isNotEmpty) {
      benefits = benefits
          .where((b) => b.category == _selectedCategory)
          .toList();
    }

    if (_selectedStatus.isNotEmpty) {
      benefits = benefits.where((b) => b.status == _selectedStatus).toList();
    }

    return benefits;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gestão de Benefícios',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Administre todos os benefícios corporativos',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (context) => const BenefitFormScreen(),
                        ),
                      )
                      .then((_) => _loadBenefits());
                },
                icon: const Icon(Icons.add),
                label: const Text('Novo Benefício'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Filtros
          if (isMobile)
            Column(
              children: [
                _buildSearchField(),
                const SizedBox(height: 12),
                _buildCategoryFilter(),
                const SizedBox(height: 12),
                _buildStatusFilter(),
              ],
            )
          else
            Row(
              children: [
                Expanded(child: _buildSearchField()),
                const SizedBox(width: 12),
                SizedBox(width: 200, child: _buildCategoryFilter()),
                const SizedBox(width: 12),
                SizedBox(width: 150, child: _buildStatusFilter()),
              ],
            ),
          const SizedBox(height: 24),

          // Lista de Benefícios
          FutureBuilder<List<CorporateBenefit>>(
            future: _benefitsFuture,
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
                      Icon(
                        Icons.error_outline,
                        color: AppTheme.primaryRed,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erro ao carregar benefícios',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadBenefits,
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                );
              }

              final benefits = snapshot.data ?? [];

              if (benefits.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        color: Colors.grey.shade400,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum benefício encontrado',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _selectedCategory = '';
                            _selectedStatus = '';
                            _loadBenefits();
                          });
                        },
                        child: const Text('Limpar Filtros'),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  Text(
                    '${benefits.length} benefício(s) encontrado(s)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: benefits.length,
                    itemBuilder: (context, index) {
                      return _buildBenefitCard(benefits[index]);
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Campo de busca
  Widget _buildSearchField() {
    return TextField(
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
          _loadBenefits();
        });
      },
      decoration: InputDecoration(
        hintText: 'Buscar benefício...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  /// Filtro de categoria
  Widget _buildCategoryFilter() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory.isEmpty ? null : _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Categoria',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      items: [
        const DropdownMenuItem(value: '', child: Text('Todas')),
        ...BenefitManagementService.getCategories().map((category) {
          return DropdownMenuItem(value: category, child: Text(category));
        }),
      ],
      onChanged: (value) {
        setState(() {
          _selectedCategory = value ?? '';
          _loadBenefits();
        });
      },
    );
  }

  /// Filtro de status
  Widget _buildStatusFilter() {
    return DropdownButtonFormField<String>(
      value: _selectedStatus.isEmpty ? null : _selectedStatus,
      decoration: InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      items: [
        const DropdownMenuItem(value: '', child: Text('Todos')),
        const DropdownMenuItem(value: 'Ativo', child: Text('Ativo')),
        const DropdownMenuItem(value: 'Inativo', child: Text('Inativo')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedStatus = value ?? '';
          _loadBenefits();
        });
      },
    );
  }

  /// Card de benefício
  Widget _buildBenefitCard(CorporateBenefit benefit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        benefit.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              benefit.category,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.blue),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              benefit.type,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.green),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: benefit.status == 'Ativo'
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              benefit.status,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: benefit.status == 'Ativo'
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Editar'),
                      onTap: () {
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    BenefitFormScreen(benefit: benefit),
                              ),
                            )
                            .then((_) => _loadBenefits());
                      },
                    ),
                    PopupMenuItem(
                      child: const Text('Remover'),
                      onTap: () {
                        _showDeleteConfirmation(benefit);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Descrição
            Text(
              benefit.description,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Informações de custo
            Row(
              children: [
                Expanded(
                  child: _buildInfoTile(
                    'Custo Empresa',
                    'R\$ ${benefit.companyCost.toStringAsFixed(2)}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoTile(
                    'Custo Colaborador',
                    'R\$ ${benefit.employeeCost.toStringAsFixed(2)}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoTile('Periodicidade', benefit.periodicity),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Tile de informação
  Widget _buildInfoTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// Confirmação de exclusão
  void _showDeleteConfirmation(CorporateBenefit benefit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Benefício'),
        content: Text('Tem certeza que deseja remover "${benefit.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await BenefitManagementService.deleteBenefit(benefit.id);
              _loadBenefits();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Benefício "${benefit.name}" removido'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
