import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ReimbursementService {
  static const String _reimbursementPrefix = 'reimbursement_';
  static const String _usageHistoryPrefix = 'usage_history_';

  /// Modelo de Reembolso
  static Map<String, dynamic> createReimbursement({
    required String id,
    required String userId,
    required String benefitId,
    required String procedureDate,
    required String description,
    required double value,
    required String documentPath,
    required String documentName,
    String status = 'Pendente',
    String createdAt = '',
  }) {
    return {
      'id': id,
      'userId': userId,
      'benefitId': benefitId,
      'procedureDate': procedureDate,
      'description': description,
      'value': value,
      'documentPath': documentPath,
      'documentName': documentName,
      'status': status,
      'createdAt': createdAt.isEmpty ? DateTime.now().toString() : createdAt,
    };
  }

  /// Modelo de Histórico de Uso
  static Map<String, dynamic> createUsageHistory({
    required String id,
    required String userId,
    required String type,
    required String provider,
    required double value,
    required String date,
  }) {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'provider': provider,
      'value': value,
      'date': date,
    };
  }

  /// Solicitar reembolso
  Future<bool> requestReimbursement(
    String userName,
    String benefitId,
    String procedureDate,
    String description,
    double value,
    String documentPath,
    String documentName,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reimbursementId =
          'RMB${DateTime.now().millisecondsSinceEpoch}';

      final reimbursement = createReimbursement(
        id: reimbursementId,
        userId: userName,
        benefitId: benefitId,
        procedureDate: procedureDate,
        description: description,
        value: value,
        documentPath: documentPath,
        documentName: documentName,
        status: 'Pendente',
      );

      final key = '$_reimbursementPrefix$userName';
      final existingData = prefs.getString(key);
      List<Map<String, dynamic>> reimbursements = [];

      if (existingData != null) {
        final decoded = jsonDecode(existingData) as List;
        reimbursements = List<Map<String, dynamic>>.from(
          decoded.map((item) => Map<String, dynamic>.from(item)),
        );
      }

      reimbursements.add(reimbursement);
      await prefs.setString(key, jsonEncode(reimbursements));

      return true;
    } catch (e) {
      print('Erro ao solicitar reembolso: $e');
      return false;
    }
  }

  /// Obter reembolsos do usuário
  Future<List<Map<String, dynamic>>> getReimbursements(String userName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_reimbursementPrefix$userName';
      final data = prefs.getString(key);

      if (data != null) {
        final decoded = jsonDecode(data) as List;
        return List<Map<String, dynamic>>.from(
          decoded.map((item) => Map<String, dynamic>.from(item)),
        );
      }

      // Retornar dados mockados
      return _getMockedReimbursements();
    } catch (e) {
      print('Erro ao obter reembolsos: $e');
      return _getMockedReimbursements();
    }
  }

  /// Obter reembolsos mockados
  List<Map<String, dynamic>> _getMockedReimbursements() {
    return [
      createReimbursement(
        id: 'RMB001',
        userId: 'user1',
        benefitId: 'benefit1',
        procedureDate: '15/02/2024',
        description: 'Consulta Médica',
        value: 250.00,
        documentPath: '/documents/recibo_001.pdf',
        documentName: 'Recibo_001.pdf',
        status: 'Aprovado',
      ),
      createReimbursement(
        id: 'RMB002',
        userId: 'user1',
        benefitId: 'benefit1',
        procedureDate: '10/02/2024',
        description: 'Exame de Sangue',
        value: 150.00,
        documentPath: '/documents/recibo_002.pdf',
        documentName: 'Recibo_002.pdf',
        status: 'Pendente',
      ),
      createReimbursement(
        id: 'RMB003',
        userId: 'user1',
        benefitId: 'benefit1',
        procedureDate: '05/02/2024',
        description: 'Medicamento',
        value: 500.00,
        documentPath: '/documents/recibo_003.pdf',
        documentName: 'Recibo_003.pdf',
        status: 'Processando',
      ),
      createReimbursement(
        id: 'RMB004',
        userId: 'user1',
        benefitId: 'benefit1',
        procedureDate: '28/01/2024',
        description: 'Fisioterapia',
        value: 300.00,
        documentPath: '/documents/recibo_004.pdf',
        documentName: 'Recibo_004.pdf',
        status: 'Aprovado',
      ),
    ];
  }

  /// Adicionar ao histórico de uso
  Future<bool> addToUsageHistory(
    String userName,
    String type,
    String provider,
    double value,
    String date,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usageId = 'USG${DateTime.now().millisecondsSinceEpoch}';

      final usage = createUsageHistory(
        id: usageId,
        userId: userName,
        type: type,
        provider: provider,
        value: value,
        date: date,
      );

      final key = '$_usageHistoryPrefix$userName';
      final existingData = prefs.getString(key);
      List<Map<String, dynamic>> usageHistory = [];

      if (existingData != null) {
        final decoded = jsonDecode(existingData) as List;
        usageHistory = List<Map<String, dynamic>>.from(
          decoded.map((item) => Map<String, dynamic>.from(item)),
        );
      }

      usageHistory.insert(0, usage); // Adicionar no início (mais recente)
      await prefs.setString(key, jsonEncode(usageHistory));

      return true;
    } catch (e) {
      print('Erro ao adicionar ao histórico: $e');
      return false;
    }
  }

  /// Obter histórico de uso
  Future<List<Map<String, dynamic>>> getUsageHistory(String userName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_usageHistoryPrefix$userName';
      final data = prefs.getString(key);

      if (data != null) {
        final decoded = jsonDecode(data) as List;
        return List<Map<String, dynamic>>.from(
          decoded.map((item) => Map<String, dynamic>.from(item)),
        );
      }

      // Retornar dados mockados
      return _getMockedUsageHistory();
    } catch (e) {
      print('Erro ao obter histórico: $e');
      return _getMockedUsageHistory();
    }
  }

  /// Obter histórico mockado
  List<Map<String, dynamic>> _getMockedUsageHistory() {
    return [
      createUsageHistory(
        id: 'USG001',
        userId: 'user1',
        type: 'Consulta',
        provider: 'Clínica São José',
        value: 150.00,
        date: '20/02/2024',
      ),
      createUsageHistory(
        id: 'USG002',
        userId: 'user1',
        type: 'Exame',
        provider: 'Laboratório Central',
        value: 200.00,
        date: '18/02/2024',
      ),
      createUsageHistory(
        id: 'USG003',
        userId: 'user1',
        type: 'Atendimento PS',
        provider: 'Hospital Municipal',
        value: 500.00,
        date: '15/02/2024',
      ),
      createUsageHistory(
        id: 'USG004',
        userId: 'user1',
        type: 'Consulta',
        provider: 'Consultório Dr. Silva',
        value: 150.00,
        date: '10/02/2024',
      ),
      createUsageHistory(
        id: 'USG005',
        userId: 'user1',
        type: 'Exame',
        provider: 'Laboratório Central',
        value: 100.00,
        date: '05/02/2024',
      ),
    ];
  }

  /// Obter resumo de reembolsos
  Future<Map<String, dynamic>> getReimbursementSummary(
    String userName,
  ) async {
    try {
      final reimbursements = await getReimbursements(userName);

      double totalRequested = 0;
      double totalApproved = 0;
      int pendingCount = 0;

      for (final reimbursement in reimbursements) {
        final value = (reimbursement['value'] as num).toDouble();
        totalRequested += value;

        if (reimbursement['status'] == 'Aprovado') {
          totalApproved += value;
        } else if (reimbursement['status'] == 'Pendente') {
          pendingCount++;
        }
      }

      return {
        'totalRequested': totalRequested,
        'totalApproved': totalApproved,
        'pendingCount': pendingCount,
        'totalReimbursements': reimbursements.length,
      };
    } catch (e) {
      print('Erro ao obter resumo: $e');
      return {
        'totalRequested': 0,
        'totalApproved': 0,
        'pendingCount': 0,
        'totalReimbursements': 0,
      };
    }
  }

  /// Obter resumo de uso
  Future<Map<String, dynamic>> getUsageSummary(String userName) async {
    try {
      final usageHistory = await getUsageHistory(userName);

      double totalSpent = 0;
      final typeCount = <String, int>{};

      for (final usage in usageHistory) {
        totalSpent += (usage['value'] as num).toDouble();
        final type = usage['type'] as String;
        typeCount[type] = (typeCount[type] ?? 0) + 1;
      }

      return {
        'totalSpent': totalSpent,
        'usageCount': usageHistory.length,
        'typeCount': typeCount,
      };
    } catch (e) {
      print('Erro ao obter resumo de uso: $e');
      return {
        'totalSpent': 0,
        'usageCount': 0,
        'typeCount': {},
      };
    }
  }

  /// Cancelar reembolso
  Future<bool> cancelReimbursement(String userName, String reimbursementId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_reimbursementPrefix$userName';
      final data = prefs.getString(key);

      if (data != null) {
        final decoded = jsonDecode(data) as List;
        final reimbursements = List<Map<String, dynamic>>.from(
          decoded.map((item) => Map<String, dynamic>.from(item)),
        );

        for (int i = 0; i < reimbursements.length; i++) {
          if (reimbursements[i]['id'] == reimbursementId) {
            reimbursements[i]['status'] = 'Cancelado';
            break;
          }
        }

        await prefs.setString(key, jsonEncode(reimbursements));
        return true;
      }

      return false;
    } catch (e) {
      print('Erro ao cancelar reembolso: $e');
      return false;
    }
  }

  /// Exportar reembolsos
  Future<String> exportReimbursements(String userName) async {
    try {
      final reimbursements = await getReimbursements(userName);
      return jsonEncode(reimbursements);
    } catch (e) {
      print('Erro ao exportar reembolsos: $e');
      return '';
    }
  }

  /// Limpar histórico
  Future<bool> clearHistory(String userName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_usageHistoryPrefix$userName');
      return true;
    } catch (e) {
      print('Erro ao limpar histórico: $e');
      return false;
    }
  }
}
