import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Modelo de Titular
class Holder {
  final String id;
  final String name;
  final String email;
  final String cpf;
  final String department;
  final String position;

  Holder({
    required this.id,
    required this.name,
    required this.email,
    required this.cpf,
    required this.department,
    required this.position,
  });
}

/// Modal de Seleção de Titular
class SelectHolderModal extends StatefulWidget {
  final Function(Holder) onHolderSelected;

  const SelectHolderModal({Key? key, required this.onHolderSelected})
    : super(key: key);

  @override
  State<SelectHolderModal> createState() => _SelectHolderModalState();
}

class _SelectHolderModalState extends State<SelectHolderModal> {
  late TextEditingController _searchController;
  List<Holder> _filteredHolders = [];
  Holder? _selectedHolder;

  // Base de dados mockada de titulares
  static final List<Holder> _allHolders = [
    Holder(
      id: '1',
      name: 'Carlos Santos',
      email: 'carlos.santos@empresa.com',
      cpf: '123.456.789-00',
      department: 'Administração',
      position: 'Diretor Executivo',
    ),
    Holder(
      id: '2',
      name: 'Ana Silva da Costa',
      email: 'ana.silva@bencorp.com',
      cpf: '987.654.321-00',
      department: 'Recursos Humanos',
      position: 'Gerente de RH',
    ),
    Holder(
      id: '3',
      name: 'João Pereira',
      email: 'joao.pereira@empresa.com',
      cpf: '456.789.123-00',
      department: 'Tecnologia',
      position: 'Gerente de TI',
    ),
    Holder(
      id: '4',
      name: 'Maria Oliveira',
      email: 'maria.oliveira@empresa.com',
      cpf: '789.123.456-00',
      department: 'Financeiro',
      position: 'Gerente Financeiro',
    ),
    Holder(
      id: '5',
      name: 'Pedro Alves',
      email: 'pedro.alves@empresa.com',
      cpf: '321.654.987-00',
      department: 'Vendas',
      position: 'Gerente de Vendas',
    ),

    Holder(
      id: '7',
      name: 'Roberto Silva',
      email: 'roberto.silva@empresa.com',
      cpf: '147.258.369-00',
      department: 'Operações',
      position: 'Supervisor de Operações',
    ),
    Holder(
      id: '8',
      name: 'Juliana Santos',
      email: 'juliana.santos@empresa.com',
      cpf: '258.369.147-00',
      department: 'Administrativo',
      position: 'Assistente Administrativo',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredHolders = _allHolders;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterHolders(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredHolders = _allHolders;
      } else {
        _filteredHolders = _allHolders
            .where(
              (holder) =>
                  holder.name.toLowerCase().contains(query.toLowerCase()) ||
                  holder.email.toLowerCase().contains(query.toLowerCase()) ||
                  holder.cpf.contains(query) ||
                  holder.department.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  void _selectHolder(Holder holder) {
    setState(() {
      _selectedHolder = holder;
    });
  }

  void _confirmSelection() {
    if (_selectedHolder != null) {
      widget.onHolderSelected(_selectedHolder!);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione um titular'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Dialog(
      insetPadding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 600,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryRed,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Selecionar Titular',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Search Field
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: _filterHolders,
                decoration: InputDecoration(
                  hintText: 'Pesquisar por nome, email, CPF ou departamento...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            // Results Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${_filteredHolders.length} titular(es) encontrado(s)',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ),

            // Holders List
            Expanded(
              child: _filteredHolders.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredHolders.length,
                      itemBuilder: (context, index) {
                        final holder = _filteredHolders[index];
                        final isSelected = _selectedHolder?.id == holder.id;

                        return _buildHolderCard(holder, isSelected);
                      },
                    ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _selectedHolder != null
                        ? _confirmSelection
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryRed,
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    child: const Text(
                      'Confirmar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Nenhum titular encontrado',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente pesquisar por nome, email ou CPF',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildHolderCard(Holder holder, bool isSelected) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryRed : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _selectHolder(holder),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Checkbox
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryRed : Colors.grey,
                    width: 2,
                  ),
                  color: isSelected ? AppTheme.primaryRed : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
              const SizedBox(width: 12),

              // Holder Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      holder.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      holder.position,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryRed,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.business,
                          size: 12,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            holder.department,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey.shade600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.email,
                          size: 12,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            holder.email,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey.shade600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
