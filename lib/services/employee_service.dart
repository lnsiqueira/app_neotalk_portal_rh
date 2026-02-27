import 'package:app_neotalk_portal_rh/models/employee_model.dart';

class EmployeeService {
  static final List<Employee> _employees = [
    Employee(
      id: 'EMP001',
      fullName: 'Ana Silva',
      email: 'ana.silva@bencorp.com',
      password: '123456',
      accessProfile: 'Colaborador',
      company: 'NeoBen',
      unit: 'São Paulo',
      status: 'Ativo',
      createdAt: DateTime(2023, 1, 15),
      lastAccess: DateTime.now().subtract(const Duration(hours: 2)),
      twoFactorEnabled: false,
      ssoProvider: null,
    ),
    Employee(
      id: 'EMP002',
      fullName: 'Carlos Santos',
      email: 'carlos.santos@bencorp.com',
      password: '123456',
      accessProfile: 'RH Admin',
      company: 'NeoBen',
      unit: 'São Paulo',
      status: 'Ativo',
      createdAt: DateTime(2022, 6, 10),
      lastAccess: DateTime.now().subtract(const Duration(minutes: 30)),
      twoFactorEnabled: true,
      ssoProvider: 'google',
    ),
    Employee(
      id: 'EMP003',
      fullName: 'Maria Oliveira',
      email: 'maria.oliveira@bencorp.com',
      password: '123456',
      accessProfile: 'Colaborador',
      company: 'NeoBen',
      unit: 'Rio de Janeiro',
      status: 'Ativo',
      createdAt: DateTime(2023, 3, 20),
      lastAccess: DateTime.now().subtract(const Duration(days: 1)),
      twoFactorEnabled: false,
      ssoProvider: null,
    ),
    Employee(
      id: 'EMP004',
      fullName: 'João Pereira',
      email: 'joao.pereira@bencorp.com',
      password: '123456',
      accessProfile: 'Colaborador',
      company: 'NeoBen',
      unit: 'Belo Horizonte',
      status: 'Ativo',
      createdAt: DateTime(2023, 5, 12),
      lastAccess: DateTime.now().subtract(const Duration(hours: 5)),
      twoFactorEnabled: true,
      ssoProvider: 'microsoft',
    ),
    Employee(
      id: 'EMP005',
      fullName: 'Fernanda Costa',
      email: 'fernanda.costa@dependente.com',
      password: '123456',
      accessProfile: 'Dependente',
      company: 'NeoBen',
      unit: 'Curitiba',
      status: 'Ativo',
      createdAt: DateTime(2023, 2, 8),
      lastAccess: DateTime.now().subtract(const Duration(hours: 12)),
      twoFactorEnabled: false,
      ssoProvider: null,
    ),
  ];

  /// Obtém todos os colaboradores
  static Future<List<Employee>> getAllEmployees() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_employees);
  }

  /// Obtém um colaborador por ID
  static Future<Employee?> getEmployeeById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _employees.firstWhere((emp) => emp.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Adiciona um novo colaborador
  static Future<Employee> addEmployee(Employee employee) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Gera ID único
    final newId = 'EMP${(_employees.length + 1).toString().padLeft(3, '0')}';
    final newEmployee = employee.copyWith(id: newId);

    _employees.add(newEmployee);
    print('✓ Colaborador adicionado: ${newEmployee.fullName}');

    return newEmployee;
  }

  /// Atualiza um colaborador
  static Future<Employee?> updateEmployee(Employee employee) async {
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final index = _employees.indexWhere((emp) => emp.id == employee.id);
      if (index != -1) {
        _employees[index] = employee;
        print('✓ Colaborador atualizado: ${employee.fullName}');
        return employee;
      }
      return null;
    } catch (e) {
      print('✗ Erro ao atualizar colaborador: $e');
      return null;
    }
  }

  /// Remove um colaborador
  static Future<bool> deleteEmployee(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      _employees.removeWhere((emp) => emp.id == id);
      print('✓ Colaborador removido: $id');
      return true;
    } catch (e) {
      print('✗ Erro ao remover colaborador: $e');
      return false;
    }
  }

  /// Busca colaboradores por nome ou email
  static Future<List<Employee>> searchEmployees(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final lowerQuery = query.toLowerCase();
    return _employees
        .where(
          (emp) =>
              emp.fullName.toLowerCase().contains(lowerQuery) ||
              emp.email.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  /// Filtra colaboradores por status
  static Future<List<Employee>> filterByStatus(String status) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _employees.where((emp) => emp.status == status).toList();
  }

  /// Filtra colaboradores por perfil
  static Future<List<Employee>> filterByProfile(String profile) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _employees.where((emp) => emp.accessProfile == profile).toList();
  }

  /// Filtra colaboradores por unidade
  static Future<List<Employee>> filterByUnit(String unit) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _employees.where((emp) => emp.unit == unit).toList();
  }

  /// Obtém lista de unidades únicas
  static Future<List<String>> getUnits() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final units = _employees.map((emp) => emp.unit).toSet().toList();
    return units..sort();
  }

  /// Obtém lista de perfis únicos
  static Future<List<String>> getProfiles() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return ['RH Admin', 'RH Operacional', 'Colaborador', 'Dependente'];
  }

  /// Obtém lista de empresas únicas
  static Future<List<String>> getCompanies() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final companies = _employees.map((emp) => emp.company).toSet().toList();
    return companies..sort();
  }

  /// Valida email único
  static Future<bool> isEmailUnique(String email, {String? excludeId}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return !_employees.any(
      (emp) =>
          emp.email.toLowerCase() == email.toLowerCase() &&
          (excludeId == null || emp.id != excludeId),
    );
  }

  /// Obtém estatísticas
  static Future<Map<String, dynamic>> getStatistics() async {
    await Future.delayed(const Duration(milliseconds: 200));

    final total = _employees.length;
    final active = _employees.where((emp) => emp.status == 'Ativo').length;
    final inactive = _employees.where((emp) => emp.status == 'Inativo').length;
    final twoFactorEnabled = _employees
        .where((emp) => emp.twoFactorEnabled)
        .length;

    return {
      'total': total,
      'active': active,
      'inactive': inactive,
      'twoFactorEnabled': twoFactorEnabled,
      'percentageActive': (active / total * 100).toStringAsFixed(1),
    };
  }
}
