import 'package:app_neotalk_portal_rh/screens/dependent_form_screen.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/dependent_model.dart';
import '../services/dependent_service.dart';

class DependentsListScreen extends StatefulWidget {
  final User user;

  const DependentsListScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<DependentsListScreen> createState() => _DependentsListScreenState();
}

class _DependentsListScreenState extends State<DependentsListScreen> {
  final DependentService _service = DependentService();
  late Future<List<Dependent>> _dependentsFuture;
  late Future<bool> _isDependentFuture;
  late Future<String?> _titularFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _dependentsFuture = _service.getDependents(widget.user.name);
    _isDependentFuture = _service.isDependent(widget.user.name);
    _titularFuture = _service.getTitular(widget.user.name);
  }

  void _refreshList() {
    setState(() {
      _loadData();
    });
  }

  Future<void> _showDeleteConfirmation(Dependent dependent) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remover Dependente'),
          content: Text('Tem certeza que deseja remover ${dependent.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remover', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final success = await _service.removeDependent(
        widget.user.name,
        dependent.id,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${dependent.name} removido com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshList();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao remover dependente'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return FutureBuilder<bool>(
      future: _isDependentFuture,
      builder: (context, isDepSnapshot) {
        if (isDepSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final isDependent = isDepSnapshot.data ?? false;

        if (isDependent) {
          // Se é dependente, mostra titular
          return FutureBuilder<String?>(
            future: _titularFuture,
            builder: (context, titularSnapshot) {
              if (titularSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final titular = titularSnapshot.data;

              return Scaffold(
                appBar: AppBar(
                  title: const Text('Dependentes'),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 0,
                ),
                body: SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mensagem de dependente
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          border: Border.all(color: Colors.blue.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Você é Dependente',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Titular: $titular',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Você pode visualizar informações do titular, mas não pode fazer alterações.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }

        // Se é titular, mostra lista de dependentes
        return FutureBuilder<List<Dependent>>(
          future: _dependentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Erro ao carregar dependentes: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshList,
                      child: const Text('Tentar Novamente'),
                    ),
                  ],
                ),
              );
            }

            final dependents = snapshot.data ?? [];

            return Scaffold(
              appBar: AppBar(
                title: const Text('Meus Dependentes'),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
              ),
              body: dependents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum dependente cadastrado',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context)
                                  .push(
                                    MaterialPageRoute(
                                      builder: (context) => DependentFormScreen(
                                        user: widget.user,
                                      ),
                                    ),
                                  )
                                  .then((_) => _refreshList());
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Adicionar Dependente'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(isMobile ? 16 : 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Botão adicionar
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context)
                                    .push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DependentFormScreen(
                                              user: widget.user,
                                            ),
                                      ),
                                    )
                                    .then((_) => _refreshList());
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Adicionar Dependente'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Lista de dependentes
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: dependents.length,
                            itemBuilder: (context, index) {
                              final dependent = dependents[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Header com nome e status
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${dependent.relationshipIcon} ${dependent.name}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  dependent.relationshipLabel,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade600,
                                                  ),
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
                                              color: dependent.status == 'Ativo'
                                                  ? Colors.green.shade100
                                                  : Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              dependent.status,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    dependent.status == 'Ativo'
                                                    ? Colors.green.shade700
                                                    : Colors.grey.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),

                                      // Informações
                                      Wrap(
                                        spacing: 16,
                                        runSpacing: 12,
                                        children: [
                                          _InfoItem(
                                            label: 'Data de Nascimento',
                                            value: dependent.formattedBirthDate,
                                          ),
                                          _InfoItem(
                                            label: 'Idade',
                                            value: '${dependent.age} anos',
                                          ),
                                          _InfoItem(
                                            label: 'CPF',
                                            value: dependent.cpf,
                                          ),
                                          _InfoItem(
                                            label: 'Documento',
                                            value: dependent.documentType,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),

                                      // Arquivo
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.description,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                dependent.documentName,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      // Botões
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton.icon(
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          DependentFormScreen(
                                                            user: widget.user,
                                                            dependent:
                                                                dependent,
                                                          ),
                                                    ),
                                                  )
                                                  .then((_) => _refreshList());
                                            },
                                            icon: const Icon(Icons.edit),
                                            label: const Text('Editar'),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.blue,
                                            ),
                                          ),
                                          TextButton.icon(
                                            onPressed: () =>
                                                _showDeleteConfirmation(
                                                  dependent,
                                                ),
                                            icon: const Icon(Icons.delete),
                                            label: const Text('Remover'),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
            );
          },
        );
      },
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
