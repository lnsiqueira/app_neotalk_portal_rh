import 'package:app_neotalk_portal_rh/models/select_holder_modal.dart';
import 'package:flutter/material.dart';
import '../models/employee_model.dart';
import '../services/employee_service.dart';
import '../theme/app_theme.dart';

class EmployeeFormScreen extends StatefulWidget {
  final Employee? employee;

  const EmployeeFormScreen({Key? key, this.employee}) : super(key: key);

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _companyController;
  late TextEditingController _matriculaController;
  late TextEditingController _cpfController;
  late TextEditingController _phoneController;
  late TextEditingController _cargoController;
  late TextEditingController _centroCustoController;
  late TextEditingController _salarioController;
  late TextEditingController _gestorController;
  late TextEditingController _dataAdmissaoController;

  String _selectedProfile = 'Colaborador';
  String _selectedUnit = 'São Paulo';
  String _selectedStatus = 'Ativo';
  String _selectedContractType = 'CLT';
  String _selectedFunctionalStatus = 'Ativo';
  bool _twoFactorEnabled = false;
  String? _selectedSsoProvider;
  bool _isLoading = false;

  // Novo: Titular selecionado para dependente
  Holder? _selectedHolder;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(
      text: widget.employee?.fullName ?? '',
    );
    _emailController = TextEditingController(
      text: widget.employee?.email ?? '',
    );
    _passwordController = TextEditingController(
      text: widget.employee?.password ?? '',
    );
    _companyController = TextEditingController(
      text: widget.employee?.company ?? 'NeoBen',
    );
    _matriculaController = TextEditingController();
    _cpfController = TextEditingController();
    _phoneController = TextEditingController();
    _cargoController = TextEditingController();
    _centroCustoController = TextEditingController();
    _salarioController = TextEditingController();
    _gestorController = TextEditingController();
    _dataAdmissaoController = TextEditingController();

    if (widget.employee != null) {
      _selectedProfile = widget.employee!.accessProfile;
      _selectedUnit = widget.employee!.unit;
      _selectedStatus = widget.employee!.status;
      _twoFactorEnabled = widget.employee!.twoFactorEnabled;
      _selectedSsoProvider = widget.employee!.ssoProvider;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _companyController.dispose();
    _matriculaController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    _cargoController.dispose();
    _centroCustoController.dispose();
    _salarioController.dispose();
    _gestorController.dispose();
    _dataAdmissaoController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Validar se titular foi selecionado para dependente
    if (_selectedProfile == 'Dependente' && _selectedHolder == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione um titular para o dependente'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final isEmailUnique = await EmployeeService.isEmailUnique(
      _emailController.text,
      excludeId: widget.employee?.id,
    );

    if (!isEmailUnique) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este email já está cadastrado')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final employee = Employee(
        id: widget.employee?.id ?? '',
        fullName: _fullNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        accessProfile: _selectedProfile,
        company: _companyController.text,
        unit: _selectedUnit,
        status: _selectedStatus,
        createdAt: widget.employee?.createdAt ?? DateTime.now(),
        lastAccess: widget.employee?.lastAccess,
        twoFactorEnabled: _twoFactorEnabled,
        ssoProvider: _selectedSsoProvider,
      );

      if (widget.employee == null) {
        await EmployeeService.addEmployee(employee);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _selectedProfile == 'Dependente'
                  ? '${employee.fullName} adicionado como dependente de ${_selectedHolder!.name}'
                  : '${employee.fullName} adicionado com sucesso',
            ),
          ),
        );
      } else {
        await EmployeeService.updateEmployee(employee);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${employee.fullName} atualizado com sucesso'),
          ),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSelectHolderModal() {
    showDialog(
      context: context,
      builder: (context) => SelectHolderModal(
        onHolderSelected: (holder) {
          setState(() {
            _selectedHolder = holder;
          });
        },
      ),
    );
  }

  void _showImportModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Importação via Planilha'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selecione o arquivo para importar',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                _buildImportOption(
                  icon: Icons.cloud_upload,
                  title: 'Fazer Upload de Arquivo',
                  subtitle: 'Selecione um arquivo Excel ou CSV',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Arquivo selecionado: dados_colaboradores.xlsx',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildImportOption(
                  icon: Icons.description,
                  title: 'Baixar Template',
                  subtitle: 'Baixe o modelo de planilha',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Template baixado: template_colaboradores.xlsx',
                        ),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildImportOption(
                  icon: Icons.history,
                  title: 'Histórico de Importações',
                  subtitle: 'Visualize importações anteriores',
                  onTap: () {
                    Navigator.pop(context);
                    _showImportHistoryModal();
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  void _showImportHistoryModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Histórico de Importações'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHistoryItem(
                  date: '25/02/2024 14:30',
                  file: 'dados_colaboradores_v2.xlsx',
                  status: 'Sucesso',
                  records: 15,
                ),
                const SizedBox(height: 12),
                _buildHistoryItem(
                  date: '20/02/2024 10:15',
                  file: 'dados_colaboradores_v1.xlsx',
                  status: 'Sucesso',
                  records: 8,
                ),
                const SizedBox(height: 12),
                _buildHistoryItem(
                  date: '15/02/2024 09:00',
                  file: 'dados_colaboradores_teste.xlsx',
                  status: 'Erro',
                  records: 0,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppTheme.primaryRed),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem({
    required String date,
    required String file,
    required String status,
    required int records,
  }) {
    final isSuccess = status == 'Sucesso';
    final statusColor = isSuccess ? Colors.green : Colors.red;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(date, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (isSuccess) ...[
              const SizedBox(height: 8),
              Text(
                '$records registros importados',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.employee == null ? 'Novo Colaborador' : 'Editar Colaborador',
        ),
        backgroundColor: AppTheme.primaryRed,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seção: Informações Pessoais
              _buildSectionTitle('Informações Pessoais'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'Nome Completo *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Nome é obrigatório';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'E-mail (Login) *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.email),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Email é obrigatório';
                  if (!value!.contains('@')) return 'Email inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha (Criptografada) *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                  helperText: 'Mínimo 6 caracteres',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Senha é obrigatória';
                  if (value!.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Seção: Acesso e Permissões
              _buildSectionTitle('Acesso e Permissões'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedProfile,
                items:
                    ['RH Admin', 'RH Operacional', 'Colaborador', 'Dependente']
                        .map(
                          (profile) => DropdownMenuItem(
                            value: profile,
                            child: Text(profile),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() => _selectedProfile = value ?? 'RH Admin');

                  // Abrir modal quando Dependente é selecionado
                  if (value == 'Dependente') {
                    Future.delayed(const Duration(milliseconds: 300), () {
                      _showSelectHolderModal();
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Perfil de Acesso *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.security),
                ),
              ),

              // Mostrar titular selecionado se for dependente
              if (_selectedProfile == 'Dependente' &&
                  _selectedHolder != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    border: Border.all(color: Colors.green.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Titular Selecionado',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedHolder!.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _selectedHolder!.position,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: _showSelectHolderModal,
                        child: const Text('Alterar'),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Autenticação 2FA'),
                subtitle: const Text('Ativar autenticação de dois fatores'),
                value: _twoFactorEnabled,
                onChanged: (value) =>
                    setState(() => _twoFactorEnabled = value ?? false),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                value: _selectedSsoProvider,
                items: [
                  const DropdownMenuItem(value: null, child: Text('Nenhum')),
                  const DropdownMenuItem(
                    value: 'google',
                    child: Text('Google'),
                  ),
                  const DropdownMenuItem(
                    value: 'microsoft',
                    child: Text('Microsoft'),
                  ),
                ].toList(),
                onChanged: (value) =>
                    setState(() => _selectedSsoProvider = value),
                decoration: InputDecoration(
                  labelText: 'SSO (Opcional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.cloud),
                ),
              ),
              const SizedBox(height: 32),

              // Seção: Informações da Empresa
              _buildSectionTitle('Informações da Empresa'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _companyController,
                decoration: InputDecoration(
                  labelText: 'Empresa *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.business),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Empresa é obrigatória';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedUnit,
                items:
                    [
                          'São Paulo',
                          'Rio de Janeiro',
                          'Belo Horizonte',
                          'Curitiba',
                          'Brasília',
                        ]
                        .map(
                          (unit) =>
                              DropdownMenuItem(value: unit, child: Text(unit)),
                        )
                        .toList(),
                onChanged: (value) =>
                    setState(() => _selectedUnit = value ?? 'São Paulo'),
                decoration: InputDecoration(
                  labelText: 'Unidade/Filial *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                items: ['Ativo', 'Inativo']
                    .map(
                      (status) =>
                          DropdownMenuItem(value: status, child: Text(status)),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedStatus = value ?? 'Ativo'),
                decoration: InputDecoration(
                  labelText: 'Status *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.check_circle),
                ),
              ),
              const SizedBox(height: 32),

              // Seção: Informações Funcionais
              _buildSectionTitle('Informações Funcionais'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _matriculaController,
                decoration: InputDecoration(
                  labelText: 'Matrícula *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.badge),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Matrícula é obrigatória';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cpfController,
                decoration: InputDecoration(
                  labelText: 'CPF *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.card_membership),
                  hintText: '000.000.000-00',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'CPF é obrigatório';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Telefone *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                  hintText: '(11) 99999-9999',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Telefone é obrigatório';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cargoController,
                decoration: InputDecoration(
                  labelText: 'Cargo *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.work),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Cargo é obrigatório';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _centroCustoController,
                decoration: InputDecoration(
                  labelText: 'Centro de Custo *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true)
                    return 'Centro de custo é obrigatório';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedContractType,
                items: ['CLT', 'PJ', 'Estágio', 'Terceirizado']
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedContractType = value ?? 'CLT'),
                decoration: InputDecoration(
                  labelText: 'Tipo de Contrato *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dataAdmissaoController,
                decoration: InputDecoration(
                  labelText: 'Data de Admissão *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.calendar_today),
                  hintText: 'DD/MM/YYYY',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true)
                    return 'Data de admissão é obrigatória';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule, color: AppTheme.primaryRed),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tempo de Função',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '2 anos, 3 meses e 15 dias',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _salarioController,
                decoration: InputDecoration(
                  labelText: 'Salário (Opcional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.monetization_on),
                  hintText: 'R 0.00',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _gestorController,
                decoration: InputDecoration(
                  labelText: 'Gestor Imediato *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Gestor é obrigatório';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedFunctionalStatus,
                items: ['Ativo', 'Afastado', 'Desligado']
                    .map(
                      (status) =>
                          DropdownMenuItem(value: status, child: Text(status)),
                    )
                    .toList(),
                onChanged: (value) => setState(
                  () => _selectedFunctionalStatus = value ?? 'Ativo',
                ),
                decoration: InputDecoration(
                  labelText: 'Status Funcional *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.verified_user),
                ),
              ),
              const SizedBox(height: 32),

              // Botões de Ação
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: _showImportModal,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Importação via Planilha'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  Row(
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
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryRed,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                widget.employee == null
                                    ? 'Adicionar'
                                    : 'Atualizar',
                                style: const TextStyle(color: Colors.white),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}

// import 'package:flutter/material.dart';
// import '../models/employee_model.dart';
// import '../services/employee_service.dart';
// import '../theme/app_theme.dart';

// class EmployeeFormScreen extends StatefulWidget {
//   final Employee? employee;

//   const EmployeeFormScreen({Key? key, this.employee}) : super(key: key);

//   @override
//   State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
// }

// class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
//   late TextEditingController _fullNameController;
//   late TextEditingController _emailController;
//   late TextEditingController _passwordController;
//   late TextEditingController _companyController;
//   late TextEditingController _matriculaController;
//   late TextEditingController _cpfController;
//   late TextEditingController _phoneController;
//   late TextEditingController _cargoController;
//   late TextEditingController _centroCustoController;
//   late TextEditingController _salarioController;
//   late TextEditingController _gestorController;
//   late TextEditingController _dataAdmissaoController;

//   String _selectedProfile = 'Colaborador';
//   String _selectedUnit = 'São Paulo';
//   String _selectedStatus = 'Ativo';
//   String _selectedContractType = 'CLT';
//   String _selectedFunctionalStatus = 'Ativo';
//   bool _twoFactorEnabled = false;
//   String? _selectedSsoProvider;
//   bool _isLoading = false;

//   final _formKey = GlobalKey<FormState>();

//   @override
//   void initState() {
//     super.initState();
//     _fullNameController = TextEditingController(
//       text: widget.employee?.fullName ?? '',
//     );
//     _emailController = TextEditingController(
//       text: widget.employee?.email ?? '',
//     );
//     _passwordController = TextEditingController(
//       text: widget.employee?.password ?? '',
//     );
//     _companyController = TextEditingController(
//       text: widget.employee?.company ?? 'NeoBen',
//     );
//     _matriculaController = TextEditingController();
//     _cpfController = TextEditingController();
//     _phoneController = TextEditingController();
//     _cargoController = TextEditingController();
//     _centroCustoController = TextEditingController();
//     _salarioController = TextEditingController();
//     _gestorController = TextEditingController();
//     _dataAdmissaoController = TextEditingController();

//     if (widget.employee != null) {
//       _selectedProfile = widget.employee!.accessProfile;
//       _selectedUnit = widget.employee!.unit;
//       _selectedStatus = widget.employee!.status;
//       _twoFactorEnabled = widget.employee!.twoFactorEnabled;
//       _selectedSsoProvider = widget.employee!.ssoProvider;
//     }
//   }

//   @override
//   void dispose() {
//     _fullNameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _companyController.dispose();
//     _matriculaController.dispose();
//     _cpfController.dispose();
//     _phoneController.dispose();
//     _cargoController.dispose();
//     _centroCustoController.dispose();
//     _salarioController.dispose();
//     _gestorController.dispose();
//     _dataAdmissaoController.dispose();
//     super.dispose();
//   }

//   Future<void> _submitForm() async {
//     if (!_formKey.currentState!.validate()) return;

//     final isEmailUnique = await EmployeeService.isEmailUnique(
//       _emailController.text,
//       excludeId: widget.employee?.id,
//     );

//     if (!isEmailUnique) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Este email já está cadastrado')),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final employee = Employee(
//         id: widget.employee?.id ?? '',
//         fullName: _fullNameController.text,
//         email: _emailController.text,
//         password: _passwordController.text,
//         accessProfile: _selectedProfile,
//         company: _companyController.text,
//         unit: _selectedUnit,
//         status: _selectedStatus,
//         createdAt: widget.employee?.createdAt ?? DateTime.now(),
//         lastAccess: widget.employee?.lastAccess,
//         twoFactorEnabled: _twoFactorEnabled,
//         ssoProvider: _selectedSsoProvider,
//       );

//       if (widget.employee == null) {
//         await EmployeeService.addEmployee(employee);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('${employee.fullName} adicionado com sucesso'),
//           ),
//         );
//       } else {
//         await EmployeeService.updateEmployee(employee);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('${employee.fullName} atualizado com sucesso'),
//           ),
//         );
//       }

//       Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Erro: $e')));
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   void _showImportModal() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Importação via Planilha'),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Selecione o arquivo para importar',
//                   style: Theme.of(context).textTheme.bodyMedium,
//                 ),
//                 const SizedBox(height: 24),
//                 // Opção 1: Fazer upload
//                 _buildImportOption(
//                   icon: Icons.cloud_upload,
//                   title: 'Fazer Upload de Arquivo',
//                   subtitle: 'Selecione um arquivo Excel ou CSV',
//                   onTap: () {
//                     Navigator.pop(context);
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text(
//                           'Arquivo selecionado: dados_colaboradores.xlsx',
//                         ),
//                         backgroundColor: Colors.green,
//                       ),
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 12),
//                 // Opção 2: Usar template
//                 _buildImportOption(
//                   icon: Icons.description,
//                   title: 'Baixar Template',
//                   subtitle: 'Baixe o modelo de planilha',
//                   onTap: () {
//                     Navigator.pop(context);
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text(
//                           'Template baixado: template_colaboradores.xlsx',
//                         ),
//                         backgroundColor: Colors.blue,
//                       ),
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 12),
//                 // Opção 3: Ver histórico
//                 _buildImportOption(
//                   icon: Icons.history,
//                   title: 'Histórico de Importações',
//                   subtitle: 'Visualize importações anteriores',
//                   onTap: () {
//                     Navigator.pop(context);
//                     _showImportHistoryModal();
//                   },
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Fechar'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showImportHistoryModal() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Histórico de Importações'),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _buildHistoryItem(
//                   date: '25/02/2024 14:30',
//                   file: 'dados_colaboradores_v2.xlsx',
//                   status: 'Sucesso',
//                   records: 15,
//                 ),
//                 const SizedBox(height: 12),
//                 _buildHistoryItem(
//                   date: '20/02/2024 10:15',
//                   file: 'dados_colaboradores_v1.xlsx',
//                   status: 'Sucesso',
//                   records: 8,
//                 ),
//                 const SizedBox(height: 12),
//                 _buildHistoryItem(
//                   date: '15/02/2024 09:00',
//                   file: 'dados_colaboradores_teste.xlsx',
//                   status: 'Erro',
//                   records: 0,
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Fechar'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildImportOption({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required VoidCallback onTap,
//   }) {
//     return Card(
//       child: InkWell(
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: AppTheme.primaryRed.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(icon, color: AppTheme.primaryRed),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: const TextStyle(fontWeight: FontWeight.w600),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       subtitle,
//                       style: Theme.of(context).textTheme.bodySmall,
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHistoryItem({
//     required String date,
//     required String file,
//     required String status,
//     required int records,
//   }) {
//     final isSuccess = status == 'Sucesso';
//     final statusColor = isSuccess ? Colors.green : Colors.red;

//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         file,
//                         style: const TextStyle(fontWeight: FontWeight.w600),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 4),
//                       Text(date, style: Theme.of(context).textTheme.bodySmall),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: statusColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: Text(
//                     status,
//                     style: TextStyle(
//                       color: statusColor,
//                       fontWeight: FontWeight.w600,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             if (isSuccess) ...[
//               const SizedBox(height: 8),
//               Text(
//                 '$records registros importados',
//                 style: Theme.of(context).textTheme.bodySmall,
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isMobile = MediaQuery.of(context).size.width < 768;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           widget.employee == null ? 'Novo Colaborador' : 'Editar Colaborador',
//         ),
//         backgroundColor: AppTheme.primaryRed,
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(isMobile ? 16 : 32),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Seção: Informações Pessoais
//               _buildSectionTitle('Informações Pessoais'),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _fullNameController,
//                 decoration: InputDecoration(
//                   labelText: 'Nome Completo *',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   prefixIcon: const Icon(Icons.person),
//                 ),
//                 validator: (value) {
//                   if (value?.isEmpty ?? true) return 'Nome é obrigatório';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _emailController,
//                 decoration: InputDecoration(
//                   labelText: 'E-mail (Login) *',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   prefixIcon: const Icon(Icons.email),
//                 ),
//                 validator: (value) {
//                   if (value?.isEmpty ?? true) return 'Email é obrigatório';
//                   if (!value!.contains('@')) return 'Email inválido';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _passwordController,
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   labelText: 'Senha (Criptografada) *',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   prefixIcon: const Icon(Icons.lock),
//                   helperText: 'Mínimo 6 caracteres',
//                 ),
//                 validator: (value) {
//                   if (value?.isEmpty ?? true) return 'Senha é obrigatória';
//                   if (value!.length < 6) return 'Mínimo 6 caracteres';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 32),

//               // Seção: Acesso e Permissões
//               _buildSectionTitle('Acesso e Permissões'),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 value: _selectedProfile,
//                 items:
//                     ['RH Admin', 'RH Operacional', 'Colaborador', 'Dependente']
//                         .map(
//                           (profile) => DropdownMenuItem(
//                             value: profile,
//                             child: Text(profile),
//                           ),
//                         )
//                         .toList(),
//                 onChanged: (value) =>
//                     setState(() => _selectedProfile = value ?? 'RH Admin'),
//                 decoration: InputDecoration(
//                   labelText: 'Perfil de Acesso *',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   prefixIcon: const Icon(Icons.security),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               CheckboxListTile(
//                 title: const Text('Autenticação 2FA'),
//                 subtitle: const Text('Ativar autenticação de dois fatores'),
//                 value: _twoFactorEnabled,
//                 onChanged: (value) =>
//                     setState(() => _twoFactorEnabled = value ?? false),
//               ),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String?>(
//                 value: _selectedSsoProvider,
//                 items: [
//                   const DropdownMenuItem(value: null, child: Text('Nenhum')),
//                   const DropdownMenuItem(
//                     value: 'google',
//                     child: Text('Google'),
//                   ),
//                   const DropdownMenuItem(
//                     value: 'microsoft',
//                     child: Text('Microsoft'),
//                   ),
//                 ].toList(),
//                 onChanged: (value) =>
//                     setState(() => _selectedSsoProvider = value),
//                 decoration: InputDecoration(
//                   labelText: 'SSO (Opcional)',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   prefixIcon: const Icon(Icons.cloud),
//                 ),
//               ),
//               const SizedBox(height: 32),

//               // Seção: Informações da Empresa
//               _buildSectionTitle('Informações da Empresa'),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _companyController,
//                 decoration: InputDecoration(
//                   labelText: 'Empresa *',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   prefixIcon: const Icon(Icons.business),
//                 ),
//                 validator: (value) {
//                   if (value?.isEmpty ?? true) return 'Empresa é obrigatória';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 value: _selectedUnit,
//                 items:
//                     [
//                           'São Paulo',
//                           'Rio de Janeiro',
//                           'Belo Horizonte',
//                           'Curitiba',
//                           'Brasília',
//                         ]
//                         .map(
//                           (unit) =>
//                               DropdownMenuItem(value: unit, child: Text(unit)),
//                         )
//                         .toList(),
//                 onChanged: (value) =>
//                     setState(() => _selectedUnit = value ?? 'São Paulo'),
//                 decoration: InputDecoration(
//                   labelText: 'Unidade/Filial *',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   prefixIcon: const Icon(Icons.location_on),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 value: _selectedStatus,
//                 items: ['Ativo', 'Inativo']
//                     .map(
//                       (status) =>
//                           DropdownMenuItem(value: status, child: Text(status)),
//                     )
//                     .toList(),
//                 onChanged: (value) =>
//                     setState(() => _selectedStatus = value ?? 'Ativo'),
//                 decoration: InputDecoration(
//                   labelText: 'Status *',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   prefixIcon: const Icon(Icons.check_circle),
//                 ),
//               ),
//               const SizedBox(height: 32),

//               // Seção: Informações Funcionais
//               _buildSectionTitle('Informações Funcionais'),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _matriculaController,
//                 decoration: InputDecoration(
//                   labelText: 'Matrícula *',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   prefixIcon: const Icon(Icons.badge),
//                 ),
//                 validator: (value) {
//                   if (value?.isEmpty ?? true) return 'Matrícula é obrigatória';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _cpfController,
//                 decoration: InputDecoration(
//                   labelText: 'CPF *',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   prefixIcon: const Icon(Icons.card_membership),
//                   hintText: '000.000.000-00',
//                 ),
//                 validator: (value) {
//                   if (value?.isEmpty ?? true) return 'CPF é obrigatório';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _phoneController,
//                 decoration: InputDecoration(
//                   labelText: 'Telefone *',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   prefixIcon: const Icon(Icons.phone),
//                   hintText: '(11) 99999-9999',
//                 ),
//                 validator: (value) {
//                   if (value?.isEmpty ?? true) return 'Telefone é obrigatório';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _cargoController,
//                 decoration: InputDecoration(
//                   labelText: 'Cargo *',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   prefixIcon: const Icon(Icons.work),
//                 ),
//                 validator: (value) {
//                   if (value?.isEmpty ?? true) return 'Cargo é obrigatório';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _centroCustoController,
//                 decoration: InputDecoration(
//                   labelText: 'Centro de Custo *',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   prefixIcon: const Icon(Icons.attach_money),
//                 ),
//                 validator: (value) {
//                   if (value?.isEmpty ?? true)
//                     return 'Centro de custo é obrigatório';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 value: _selectedContractType,
//                 items: ['CLT', 'PJ', 'Estágio', 'Terceirizado']
//                     .map(
//                       (type) =>
//                           DropdownMenuItem(value: type, child: Text(type)),
//                     )
//                     .toList(),
//                 onChanged: (value) =>
//                     setState(() => _selectedContractType = value ?? 'CLT'),
//                 decoration: InputDecoration(
//                   labelText: 'Tipo de Contrato *',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   prefixIcon: const Icon(Icons.description),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _dataAdmissaoController,
//                 decoration: InputDecoration(
//                   labelText: 'Data de Admissão *',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   prefixIcon: const Icon(Icons.calendar_today),
//                   hintText: 'DD/MM/YYYY',
//                 ),
//                 validator: (value) {
//                   if (value?.isEmpty ?? true)
//                     return 'Data de admissão é obrigatória';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade100,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.grey.shade300),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.schedule, color: AppTheme.primaryRed),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Tempo de Função',
//                             style: TextStyle(fontWeight: FontWeight.w600),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             '2 anos, 3 meses e 15 dias',
//                             style: Theme.of(context).textTheme.bodySmall,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _salarioController,
//                 decoration: InputDecoration(
//                   labelText: 'Salário (Opcional)',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   prefixIcon: const Icon(Icons.monetization_on),
//                   hintText: ' 0.00',
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _gestorController,
//                 decoration: InputDecoration(
//                   labelText: 'Gestor Imediato *',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   prefixIcon: const Icon(Icons.person_outline),
//                 ),
//                 validator: (value) {
//                   if (value?.isEmpty ?? true) return 'Gestor é obrigatório';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 value: _selectedFunctionalStatus,
//                 items: ['Ativo', 'Afastado', 'Desligado']
//                     .map(
//                       (status) =>
//                           DropdownMenuItem(value: status, child: Text(status)),
//                     )
//                     .toList(),
//                 onChanged: (value) => setState(
//                   () => _selectedFunctionalStatus = value ?? 'Ativo',
//                 ),
//                 decoration: InputDecoration(
//                   labelText: 'Status Funcional *',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   prefixIcon: const Icon(Icons.verified_user),
//                 ),
//               ),
//               const SizedBox(height: 32),

//               // Botões de Ação
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Botão de Importação (esquerda)
//                   ElevatedButton.icon(
//                     onPressed: _showImportModal,
//                     icon: const Icon(Icons.upload_file),
//                     label: const Text('Importação via Planilha'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue,
//                       foregroundColor: Colors.white,
//                     ),
//                   ),
//                   // Botões de Cancelar e Ação (direita)
//                   Row(
//                     children: [
//                       TextButton(
//                         onPressed: () => Navigator.pop(context),
//                         child: const Text(
//                           'Cancelar',
//                           style: TextStyle(color: Colors.grey),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       ElevatedButton(
//                         onPressed: _isLoading ? null : _submitForm,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppTheme.primaryRed,
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 32,
//                             vertical: 12,
//                           ),
//                         ),
//                         child: _isLoading
//                             ? const SizedBox(
//                                 width: 20,
//                                 height: 20,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   valueColor: AlwaysStoppedAnimation(
//                                     Colors.white,
//                                   ),
//                                 ),
//                               )
//                             : Text(
//                                 widget.employee == null
//                                     ? 'Adicionar'
//                                     : 'Atualizar',
//                                 style: const TextStyle(color: Colors.white),
//                               ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Text(
//       title,
//       style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import '../models/employee_model.dart';
// import '../services/employee_service.dart';
// import '../theme/app_theme.dart';

// class EmployeeFormScreen extends StatefulWidget {
//   final Employee? employee;

//   const EmployeeFormScreen({Key? key, this.employee}) : super(key: key);

//   @override
//   State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
// }

// class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
//   late TextEditingController _fullNameController;
//   late TextEditingController _emailController;
//   late TextEditingController _passwordController;
//   late TextEditingController _companyController;

//   String _selectedProfile = 'Colaborador';
//   String _selectedUnit = 'São Paulo';
//   String _selectedStatus = 'Ativo';
//   bool _twoFactorEnabled = false;
//   String? _selectedSsoProvider;
//   bool _isLoading = false;

//   final _formKey = GlobalKey<FormState>();

//   @override
//   void initState() {
//     super.initState();
//     _fullNameController = TextEditingController(
//       text: widget.employee?.fullName ?? '',
//     );
//     _emailController = TextEditingController(
//       text: widget.employee?.email ?? '',
//     );
//     _passwordController = TextEditingController(
//       text: widget.employee?.password ?? '',
//     );
//     _companyController = TextEditingController(
//       text: widget.employee?.company ?? 'NeoBen',
//     );

//     if (widget.employee != null) {
//       _selectedProfile = widget.employee!.accessProfile;
//       _selectedUnit = widget.employee!.unit;
//       _selectedStatus = widget.employee!.status;
//       _twoFactorEnabled = widget.employee!.twoFactorEnabled;
//       _selectedSsoProvider = widget.employee!.ssoProvider;
//     }
//   }

//   @override
//   void dispose() {
//     _fullNameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _companyController.dispose();
//     super.dispose();
//   }

//   Future<void> _submitForm() async {
//     if (!_formKey.currentState!.validate()) return;

//     // Valida email único
//     final isEmailUnique = await EmployeeService.isEmailUnique(
//       _emailController.text,
//       excludeId: widget.employee?.id,
//     );

//     if (!isEmailUnique) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Este email já está cadastrado')),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final employee = Employee(
//         id: widget.employee?.id ?? '',
//         fullName: _fullNameController.text,
//         email: _emailController.text,
//         password: _passwordController.text,
//         accessProfile: _selectedProfile,
//         company: _companyController.text,
//         unit: _selectedUnit,
//         status: _selectedStatus,
//         createdAt: widget.employee?.createdAt ?? DateTime.now(),
//         lastAccess: widget.employee?.lastAccess,
//         twoFactorEnabled: _twoFactorEnabled,
//         ssoProvider: _selectedSsoProvider,
//       );

//       if (widget.employee == null) {
//         // Novo colaborador
//         await EmployeeService.addEmployee(employee);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('${employee.fullName} adicionado com sucesso'),
//           ),
//         );
//       } else {
//         // Atualizar colaborador
//         await EmployeeService.updateEmployee(employee);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('${employee.fullName} atualizado com sucesso'),
//           ),
//         );
//       }

//       Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Erro: $e')));
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isMobile = MediaQuery.of(context).size.width < 768;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           widget.employee == null ? 'Novo Colaborador' : 'Editar Colaborador',
//         ),
//         backgroundColor: AppTheme.primaryRed,
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(isMobile ? 16 : 32),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Seção: Informações Pessoais
//               _buildSectionTitle('Informações Pessoais'),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _fullNameController,
//                 decoration: InputDecoration(
//                   labelText: 'Nome Completo *',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   prefixIcon: const Icon(Icons.person),
//                 ),
//                 validator: (value) {
//                   if (value?.isEmpty ?? true) return 'Nome é obrigatório';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _emailController,
//                 decoration: InputDecoration(
//                   labelText: 'E-mail (Login) *',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   prefixIcon: const Icon(Icons.email),
//                 ),
//                 validator: (value) {
//                   if (value?.isEmpty ?? true) return 'Email é obrigatório';
//                   if (!value!.contains('@')) return 'Email inválido';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _passwordController,
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   labelText: 'Senha (Criptografada) *',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   prefixIcon: const Icon(Icons.lock),
//                   helperText: 'Mínimo 6 caracteres',
//                 ),
//                 validator: (value) {
//                   if (value?.isEmpty ?? true) return 'Senha é obrigatória';
//                   if (value!.length < 6) return 'Mínimo 6 caracteres';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 32),

//               // Seção: Acesso e Permissões
//               _buildSectionTitle('Acesso e Permissões'),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 value: _selectedProfile,
//                 items:
//                     ['RH Admin', 'RH Operacional', 'Colaborador', 'Dependente']
//                         .map(
//                           (profile) => DropdownMenuItem(
//                             value: profile,
//                             child: Text(profile),
//                           ),
//                         )
//                         .toList(),
//                 onChanged: (value) =>
//                     setState(() => _selectedProfile = value ?? 'RH Admin'),
//                 decoration: InputDecoration(
//                   labelText: 'Perfil de Acesso *',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   prefixIcon: const Icon(Icons.security),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               CheckboxListTile(
//                 title: const Text('Autenticação 2FA'),
//                 subtitle: const Text('Ativar autenticação de dois fatores'),
//                 value: _twoFactorEnabled,
//                 onChanged: (value) =>
//                     setState(() => _twoFactorEnabled = value ?? false),
//               ),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String?>(
//                 value: _selectedSsoProvider,
//                 items: [
//                   const DropdownMenuItem(value: null, child: Text('Nenhum')),
//                   const DropdownMenuItem(
//                     value: 'google',
//                     child: Text('Google'),
//                   ),
//                   const DropdownMenuItem(
//                     value: 'microsoft',
//                     child: Text('Microsoft'),
//                   ),
//                 ].toList(),
//                 onChanged: (value) =>
//                     setState(() => _selectedSsoProvider = value),
//                 decoration: InputDecoration(
//                   labelText: 'SSO (Opcional)',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   prefixIcon: const Icon(Icons.cloud),
//                 ),
//               ),
//               const SizedBox(height: 32),

//               // Seção: Informações da Empresa
//               _buildSectionTitle('Informações da Empresa'),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _companyController,
//                 decoration: InputDecoration(
//                   labelText: 'Empresa *',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   prefixIcon: const Icon(Icons.business),
//                 ),
//                 validator: (value) {
//                   if (value?.isEmpty ?? true) return 'Empresa é obrigatória';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 value: _selectedUnit,
//                 items:
//                     [
//                           'São Paulo',
//                           'Rio de Janeiro',
//                           'Belo Horizonte',
//                           'Curitiba',
//                           'Brasília',
//                         ]
//                         .map(
//                           (unit) =>
//                               DropdownMenuItem(value: unit, child: Text(unit)),
//                         )
//                         .toList(),
//                 onChanged: (value) =>
//                     setState(() => _selectedUnit = value ?? 'São Paulo'),
//                 decoration: InputDecoration(
//                   labelText: 'Unidade/Filial *',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   prefixIcon: const Icon(Icons.location_on),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 value: _selectedStatus,
//                 items: ['Ativo', 'Inativo']
//                     .map(
//                       (status) =>
//                           DropdownMenuItem(value: status, child: Text(status)),
//                     )
//                     .toList(),
//                 onChanged: (value) =>
//                     setState(() => _selectedStatus = value ?? 'Ativo'),
//                 decoration: InputDecoration(
//                   labelText: 'Status *',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   prefixIcon: const Icon(Icons.check_circle),
//                 ),
//               ),
//               const SizedBox(height: 32),

//               // Botões de Ação
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: const Text(
//                       'Cancelar',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   ElevatedButton(
//                     onPressed: _isLoading ? null : _submitForm,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppTheme.primaryRed,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 32,
//                         vertical: 12,
//                       ),
//                     ),
//                     child: _isLoading
//                         ? const SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor: AlwaysStoppedAnimation(Colors.white),
//                             ),
//                           )
//                         : Text(
//                             widget.employee == null ? 'Adicionar' : 'Atualizar',
//                             style: const TextStyle(color: Colors.white),
//                           ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Text(
//       title,
//       style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//     );
//   }
// }
