import 'package:app_neotalk_portal_rh/models/dependent_model.dart';

class DependentService {
  static final DependentService _instance = DependentService._internal();

  factory DependentService() {
    return _instance;
  }

  DependentService._internal();

  // Dados mockados por usuário
  static final Map<String, List<Dependent>> _dependents = {
    'Ana Silva da Costa': [
      Dependent(
        id: 'DEP001',
        name: 'Fernanda da Costa',
        relationship: 'filha',
        birthDate: '2015-03-15',
        cpf: '123.456.789-10',
        documentType: 'Certidão de Nascimento',
        documentPath: '/documents/fernanda_certidao.pdf',
        documentName: 'Certidão_Nascimento_Fernanda.pdf',
        status: 'Ativo',
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      ),
      Dependent(
        id: 'DEP002',
        name: 'João da Costa',
        relationship: 'filho',
        birthDate: '2018-07-22',
        cpf: '987.654.321-00',
        documentType: 'Certidão de Nascimento',
        documentPath: '/documents/joao_certidao.pdf',
        documentName: 'Certidão_Nascimento_Joao.pdf',
        status: 'Ativo',
        createdAt: DateTime(2024, 2, 10),
        updatedAt: DateTime(2024, 2, 10),
      ),
    ],
    'Carlos Santos': [],
    'Maria Oliveira': [
      Dependent(
        id: 'DEP001',
        name: 'Gabriela Oliveira',
        relationship: 'filha',
        birthDate: '2022-03-15',
        cpf: '173.896.679-11',
        documentType: 'Certidão de Nascimento',
        documentPath: '/documents/gabriela_certidao.pdf',
        documentName: 'Certidão_Nascimento_Gabriela.pdf',
        status: 'Ativo',
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      ),
    ],
    'João Pereira': [],
    'Fernanda Costa': [], // Fernanda é dependente de Ana, não tem dependentes
  };

  // Mapeamento de titulares
  static final Map<String, String> _titularMap = {
    'Fernanda da Costa': 'Ana Silva', // Fernanda é dependente de Ana
  };

  // Obter dependentes de um usuário
  Future<List<Dependent>> getDependents(String userName) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _dependents[userName] ?? [];
  }

  // Obter dependente específico
  Future<Dependent?> getDependent(String userName, String dependentId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final dependents = _dependents[userName] ?? [];
    try {
      return dependents.firstWhere((d) => d.id == dependentId);
    } catch (e) {
      return null;
    }
  }

  // Adicionar novo dependente
  Future<bool> addDependent(String userName, Dependent dependent) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      if (!_dependents.containsKey(userName)) {
        _dependents[userName] = [];
      }
      _dependents[userName]!.add(dependent);
      print('✅ Dependente adicionado: ${dependent.name} para $userName');
      return true;
    } catch (e) {
      print('❌ Erro ao adicionar dependente: $e');
      return false;
    }
  }

  // Atualizar dependente
  Future<bool> updateDependent(
    String userName,
    String dependentId,
    Dependent updated,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final dependents = _dependents[userName] ?? [];
      final index = dependents.indexWhere((d) => d.id == dependentId);
      if (index != -1) {
        dependents[index] = updated;
        print('✅ Dependente atualizado: ${updated.name}');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Erro ao atualizar dependente: $e');
      return false;
    }
  }

  // Remover dependente
  Future<bool> removeDependent(String userName, String dependentId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final dependents = _dependents[userName] ?? [];
      dependents.removeWhere((d) => d.id == dependentId);
      print('✅ Dependente removido: $dependentId');
      return true;
    } catch (e) {
      print('❌ Erro ao remover dependente: $e');
      return false;
    }
  }

  // Verificar se usuário é dependente
  Future<bool> isDependent(String userName) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _titularMap.containsKey(userName);
  }

  // Obter titular do dependente
  Future<String?> getTitular(String dependentUserName) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _titularMap[dependentUserName];
  }

  // Obter estatísticas
  Future<Map<String, dynamic>> getStatistics(String userName) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final dependents = _dependents[userName] ?? [];
    return {
      'totalDependents': dependents.length,
      'activeDependents': dependents.where((d) => d.status == 'Ativo').length,
      'inactiveDependents': dependents
          .where((d) => d.status == 'Inativo')
          .length,
      'childrenCount': dependents
          .where((d) => d.relationship == 'filho' || d.relationship == 'filha')
          .length,
    };
  }

  // Gerar ID único
  String generateId() {
    return 'DEP${DateTime.now().millisecondsSinceEpoch}';
  }

  // Limpar cache (para logout)
  void clearCache() {
    // Se necessário, limpar dados em cache aqui
    print('✅ Cache de dependentes limpo');
  }
}
