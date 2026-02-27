import 'package:app_neotalk_portal_rh/models/employee_benefits_modal.dart';
import 'package:app_neotalk_portal_rh/screens/employee_form_screen.dart';
import 'package:flutter/material.dart';
import '../models/employee_model.dart';
import '../services/employee_service.dart';
import '../theme/app_theme.dart';

class EmployeesListScreen extends StatefulWidget {
  const EmployeesListScreen({Key? key}) : super(key: key);

  @override
  State<EmployeesListScreen> createState() => _EmployeesListScreenState();
}

class _EmployeesListScreenState extends State<EmployeesListScreen> {
  late Future<List<Employee>> _employeesFuture;
  String _searchQuery = '';
  String _filterStatus = 'Todos';
  String _filterProfile = 'Todos';

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  void _loadEmployees() {
    setState(() {
      _employeesFuture = _getFilteredEmployees();
    });
  }

  Future<List<Employee>> _getFilteredEmployees() async {
    List<Employee> employees = await EmployeeService.getAllEmployees();

    // Aplica filtro de busca
    if (_searchQuery.isNotEmpty) {
      employees = await EmployeeService.searchEmployees(_searchQuery);
    }

    // Aplica filtro de status
    if (_filterStatus != 'Todos') {
      employees = employees
          .where((emp) => emp.status == _filterStatus)
          .toList();
    }

    // Aplica filtro de perfil
    if (_filterProfile != 'Todos') {
      employees = employees
          .where((emp) => emp.accessProfile == _filterProfile)
          .toList();
    }

    return employees;
  }

  void _openEmployeeForm({Employee? employee}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeFormScreen(employee: employee),
      ),
    ).then((_) => _loadEmployees());
  }

  void _deleteEmployee(Employee employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja remover ${employee.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await EmployeeService.deleteEmployee(employee.id);
              _loadEmployees();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${employee.fullName} removido com sucesso'),
                ),
              );
            },
            child: Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Colaboradores'),
        backgroundColor: AppTheme.primaryRed,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barra de Ferramentas
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                // Botão Novo Colaborador
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openEmployeeForm(),
                    icon: const Icon(Icons.add),
                    label: const Text('Novo Colaborador'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryRed,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Busca e Filtros
                if (!isMobile)
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          onChanged: (value) {
                            _searchQuery = value;
                            _loadEmployees();
                          },
                          decoration: InputDecoration(
                            hintText: 'Buscar por nome ou email...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFilterDropdown(
                          'Status',
                          ['Todos', 'Ativo', 'Inativo'],
                          _filterStatus,
                          (value) {
                            _filterStatus = value;
                            _loadEmployees();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        //*
                        child: _buildFilterDropdown(
                          'Perfil',
                          [
                            'Todos',
                            'RH Admin',
                            'RH Operacional',
                            'Colaborador',
                            'Dependente',
                          ],
                          _filterProfile,
                          (value) {
                            _filterProfile = value;
                            _loadEmployees();
                          },
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      TextField(
                        onChanged: (value) {
                          _searchQuery = value;
                          _loadEmployees();
                        },
                        decoration: InputDecoration(
                          hintText: 'Buscar...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFilterDropdown(
                              'Status',
                              ['Todos', 'Ativo', 'Inativo'],
                              _filterStatus,
                              (value) {
                                _filterStatus = value;
                                _loadEmployees();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildFilterDropdown(
                              'Perfil',
                              ['Todos', 'User', 'Manager', 'Admin'],
                              _filterProfile,
                              (value) {
                                _filterProfile = value;
                                _loadEmployees();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Lista de Colaboradores
          Expanded(
            child: FutureBuilder<List<Employee>>(
              future: _employeesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryRed,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar colaboradores: ${snapshot.error}',
                    ),
                  );
                }

                final employees = snapshot.data ?? [];

                if (employees.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum colaborador encontrado',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final employee = employees[index];
                    return _buildEmployeeCard(employee);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    List<String> options,
    String currentValue,
    Function(String) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: currentValue,
      items: options
          .map((option) => DropdownMenuItem(value: option, child: Text(option)))
          .toList(),
      onChanged: (value) => onChanged(value ?? 'Todos'),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildEmployeeCard(Employee employee) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        employee.email,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    // Status
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: employee.status == 'Ativo'
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        employee.status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: employee.status == 'Ativo'
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Informações
            Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                _buildInfoItem('Perfil', employee.accessProfile),
                _buildInfoItem('Unidade', employee.unit),
                _buildInfoItem('Empresa', employee.company),
                _buildInfoItem(
                  'Criado em',
                  '${employee.createdAt.day}/${employee.createdAt.month}/${employee.createdAt.year}',
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Recursos
            Wrap(
              spacing: 8,
              children: [
                if (employee.twoFactorEnabled)
                  Chip(
                    label: const Text('2FA'),
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    labelStyle: const TextStyle(fontSize: 12),
                  ),
                if (employee.ssoProvider != null)
                  Chip(
                    label: Text('SSO: ${employee.ssoProvider}'),
                    backgroundColor: Colors.purple.withOpacity(0.1),
                    labelStyle: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Ações
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // ✅ NOVO: Botão Ver Benefícios
                TextButton.icon(
                  onPressed: () => EmployeeBenefitsModal.show(
                    context,
                    employee.fullName,
                    employee.id,
                  ),
                  icon: const Icon(Icons.card_giftcard),
                  label: const Text('Ver Benefícios'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryRed,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _openEmployeeForm(employee: employee),
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar'),
                  style: TextButton.styleFrom(foregroundColor: Colors.blue),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _deleteEmployee(employee),
                  icon: const Icon(Icons.delete),
                  label: const Text('Remover'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

// import 'package:app_neotalk_portal_rh/screens/employee_form_screen.dart';
// import 'package:flutter/material.dart';
// import '../models/employee_model.dart';
// import '../services/employee_service.dart';
// import '../theme/app_theme.dart';

// class EmployeesListScreen extends StatefulWidget {
//   const EmployeesListScreen({Key? key}) : super(key: key);

//   @override
//   State<EmployeesListScreen> createState() => _EmployeesListScreenState();
// }

// class _EmployeesListScreenState extends State<EmployeesListScreen> {
//   late Future<List<Employee>> _employeesFuture;
//   String _searchQuery = '';
//   String _filterStatus = 'Todos';
//   String _filterProfile = 'Todos';

//   @override
//   void initState() {
//     super.initState();
//     _loadEmployees();
//   }

//   void _loadEmployees() {
//     setState(() {
//       _employeesFuture = _getFilteredEmployees();
//     });
//   }

//   Future<List<Employee>> _getFilteredEmployees() async {
//     List<Employee> employees = await EmployeeService.getAllEmployees();

//     // Aplica filtro de busca
//     if (_searchQuery.isNotEmpty) {
//       employees = await EmployeeService.searchEmployees(_searchQuery);
//     }

//     // Aplica filtro de status
//     if (_filterStatus != 'Todos') {
//       employees = employees
//           .where((emp) => emp.status == _filterStatus)
//           .toList();
//     }

//     // Aplica filtro de perfil
//     if (_filterProfile != 'Todos') {
//       employees = employees
//           .where((emp) => emp.accessProfile == _filterProfile)
//           .toList();
//     }

//     return employees;
//   }

//   void _openEmployeeForm({Employee? employee}) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => EmployeeFormScreen(employee: employee),
//       ),
//     ).then((_) => _loadEmployees());
//   }

//   void _deleteEmployee(Employee employee) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Confirmar Exclusão'),
//         content: Text('Tem certeza que deseja remover ${employee.fullName}?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancelar'),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               await EmployeeService.deleteEmployee(employee.id);
//               _loadEmployees();
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text('${employee.fullName} removido com sucesso'),
//                 ),
//               );
//             },
//             child: Text('Remover', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isMobile = MediaQuery.of(context).size.width < 768;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Gestão de Colaboradores'),
//         backgroundColor: AppTheme.primaryRed,
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           // Barra de Ferramentas
//           Container(
//             padding: const EdgeInsets.all(16),
//             color: Colors.grey[100],
//             child: Column(
//               children: [
//                 // Botão Novo Colaborador
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     onPressed: () => _openEmployeeForm(),
//                     icon: const Icon(Icons.add),
//                     label: const Text('Novo Colaborador'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppTheme.primaryRed,
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // Busca e Filtros
//                 if (!isMobile)
//                   Row(
//                     children: [
//                       Expanded(
//                         flex: 2,
//                         child: TextField(
//                           onChanged: (value) {
//                             _searchQuery = value;
//                             _loadEmployees();
//                           },
//                           decoration: InputDecoration(
//                             hintText: 'Buscar por nome ou email...',
//                             prefixIcon: const Icon(Icons.search),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             contentPadding: const EdgeInsets.symmetric(
//                               vertical: 12,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: _buildFilterDropdown(
//                           'Status',
//                           ['Todos', 'Ativo', 'Inativo'],
//                           _filterStatus,
//                           (value) {
//                             _filterStatus = value;
//                             _loadEmployees();
//                           },
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         //*
//                         child: _buildFilterDropdown(
//                           'Perfil',
//                           [
//                             'Todos',
//                             'RH Admin',
//                             'RH Operacional',
//                             'Colaborador',
//                             'Dependente',
//                           ],
//                           _filterProfile,
//                           (value) {
//                             _filterProfile = value;
//                             _loadEmployees();
//                           },
//                         ),
//                       ),
//                     ],
//                   )
//                 else
//                   Column(
//                     children: [
//                       TextField(
//                         onChanged: (value) {
//                           _searchQuery = value;
//                           _loadEmployees();
//                         },
//                         decoration: InputDecoration(
//                           hintText: 'Buscar...',
//                           prefixIcon: const Icon(Icons.search),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(
//                             vertical: 12,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _buildFilterDropdown(
//                               'Status',
//                               ['Todos', 'Ativo', 'Inativo'],
//                               _filterStatus,
//                               (value) {
//                                 _filterStatus = value;
//                                 _loadEmployees();
//                               },
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: _buildFilterDropdown(
//                               'Perfil',
//                               ['Todos', 'User', 'Manager', 'Admin'],
//                               _filterProfile,
//                               (value) {
//                                 _filterProfile = value;
//                                 _loadEmployees();
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//               ],
//             ),
//           ),

//           // Lista de Colaboradores
//           Expanded(
//             child: FutureBuilder<List<Employee>>(
//               future: _employeesFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(
//                     child: CircularProgressIndicator(
//                       color: AppTheme.primaryRed,
//                     ),
//                   );
//                 }

//                 if (snapshot.hasError) {
//                   return Center(
//                     child: Text(
//                       'Erro ao carregar colaboradores: ${snapshot.error}',
//                     ),
//                   );
//                 }

//                 final employees = snapshot.data ?? [];

//                 if (employees.isEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.people_outline,
//                           size: 64,
//                           color: Colors.grey[400],
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'Nenhum colaborador encontrado',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 return ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: employees.length,
//                   itemBuilder: (context, index) {
//                     final employee = employees[index];
//                     return _buildEmployeeCard(employee);
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilterDropdown(
//     String label,
//     List<String> options,
//     String currentValue,
//     Function(String) onChanged,
//   ) {
//     return DropdownButtonFormField<String>(
//       value: currentValue,
//       items: options
//           .map((option) => DropdownMenuItem(value: option, child: Text(option)))
//           .toList(),
//       onChanged: (value) => onChanged(value ?? 'Todos'),
//       decoration: InputDecoration(
//         labelText: label,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 12,
//           vertical: 12,
//         ),
//       ),
//     );
//   }

//   Widget _buildEmployeeCard(Employee employee) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         employee.fullName,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         employee.email,
//                         style: TextStyle(fontSize: 13, color: Colors.grey[600]),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Row(
//                   children: [
//                     // Status
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),
//                       decoration: BoxDecoration(
//                         color: employee.status == 'Ativo'
//                             ? Colors.green.withOpacity(0.1)
//                             : Colors.red.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         employee.status,
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                           color: employee.status == 'Ativo'
//                               ? Colors.green
//                               : Colors.red,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),

//             // Informações
//             Wrap(
//               spacing: 24,
//               runSpacing: 12,
//               children: [
//                 _buildInfoItem('Perfil', employee.accessProfile),
//                 _buildInfoItem('Unidade', employee.unit),
//                 _buildInfoItem('Empresa', employee.company),
//                 _buildInfoItem(
//                   'Criado em',
//                   '${employee.createdAt.day}/${employee.createdAt.month}/${employee.createdAt.year}',
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),

//             // Recursos
//             Wrap(
//               spacing: 8,
//               children: [
//                 if (employee.twoFactorEnabled)
//                   Chip(
//                     label: const Text('2FA'),
//                     backgroundColor: Colors.blue.withOpacity(0.1),
//                     labelStyle: const TextStyle(fontSize: 12),
//                   ),
//                 if (employee.ssoProvider != null)
//                   Chip(
//                     label: Text('SSO: ${employee.ssoProvider}'),
//                     backgroundColor: Colors.purple.withOpacity(0.1),
//                     labelStyle: const TextStyle(fontSize: 12),
//                   ),
//               ],
//             ),
//             const SizedBox(height: 12),

//             // Ações
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 TextButton.icon(
//                   onPressed: () => _openEmployeeForm(employee: employee),
//                   icon: const Icon(Icons.edit),
//                   label: const Text('Editar'),
//                   style: TextButton.styleFrom(foregroundColor: Colors.blue),
//                 ),
//                 const SizedBox(width: 8),
//                 TextButton.icon(
//                   onPressed: () => _deleteEmployee(employee),
//                   icon: const Icon(Icons.delete),
//                   label: const Text('Remover'),
//                   style: TextButton.styleFrom(foregroundColor: Colors.red),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoItem(String label, String value) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.grey[600],
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(height: 2),
//         Text(
//           value,
//           style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
//         ),
//       ],
//     );
//   }
// }
