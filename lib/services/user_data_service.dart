import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/user_model.dart';
import '../models/benefit_model.dart';
import '../models/summary_model.dart';

class UserDataService {
  static Map<String, dynamic>? _cachedData;

  /// Carrega o arquivo JSON mockado
  static Future<Map<String, dynamic>> _loadMockData() async {
    if (_cachedData != null) {
      return _cachedData!;
    }

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/mock_data.json',
      );
      _cachedData = jsonDecode(jsonString);
      return _cachedData!;
    } catch (e) {
      print('Erro ao carregar mock_data.json: $e');
      // Retorna dados padrão se o arquivo não for encontrado
      return _getDefaultMockData();
    }
  }

  /// Obtém dados do usuário logado
  static Future<Map<String, dynamic>> getUserData(String userName) async {
    final mockData = await _loadMockData();
    final users = mockData['users'] as Map<String, dynamic>;

    if (users.containsKey(userName)) {
      return users[userName] as Map<String, dynamic>;
    }

    // Retorna dados de Ana Silva como padrão
    print('Usuário $userName não encontrado. Usando Ana Silva como padrão.');
    return users['Ana Silva'] as Map<String, dynamic>;
  }

  /// Obtém o usuário logado
  static Future<User> getUser(String userName) async {
    final userData = await getUserData(userName);
    final userMap = userData['user'] as Map<String, dynamic>;

    return User(
      id: userMap['id'] ?? 'USR000',
      name: userMap['name'] ?? 'Usuário',
      role: userMap['role'] ?? 'Colaborador',
      email: userMap['email'] ?? 'user@bencorp.com',
      avatar: userMap['avatar'] ?? 'https://i.pravatar.cc/150?img=0',
      isAdmin: userMap['isAdmin'] ?? false,
      adminType: userMap['adminType'],
    );
  }

  /// Obtém o resumo do usuário
  static Future<Summary> getSummary(String userName) async {
    final userData = await getUserData(userName);
    final summaryMap = userData['summary'] as Map<String, dynamic>;

    return Summary(
      activeBenefits: summaryMap['activeBenefits'] ?? 0,
      annualCoparticipation: (summaryMap['annualCoparticipation'] ?? 0.0)
          .toDouble(),
      pendingRequests: summaryMap['pendingRequests'] ?? 0,
    );
  }

  /// Obtém os benefícios ativos do usuário
  static Future<List<Benefit>> getMyBenefits(String userName) async {
    try {
      final userData = await getUserData(userName);

      // Verifica se myBenefits existe e é uma lista
      if (!userData.containsKey('myBenefits')) {
        print('Aviso: myBenefits não encontrado para $userName');
        return [];
      }

      final benefitsData = userData['myBenefits'];

      // Se não for uma lista, retorna lista vazia
      if (benefitsData is! List) {
        print('Aviso: myBenefits não é uma lista para $userName');
        return [];
      }

      return benefitsData
          .map((benefitMap) {
            if (benefitMap is! Map<String, dynamic>) {
              return null;
            }

            try {
              return Benefit(
                id: benefitMap['id'] ?? 'BEN000',
                name: benefitMap['name'] ?? 'Benefício',
                category: benefitMap['category'] ?? 'Geral',
                subcategory: benefitMap['subcategory'] ?? 'Sem categoria',
                status: benefitMap['status'] ?? 'INATIVO',
                icon: benefitMap['icon'] ?? 'default',
                description: benefitMap['description'] ?? 'Sem descrição',
                action: benefitMap['action'],
                planName: benefitMap['planName'],
                dependents: benefitMap['dependents'],
                dueDate: benefitMap['dueDate'],
                monthlyValue: benefitMap['monthlyValue'],
                cardNumber: benefitMap['cardNumber'],
                dailyValue: benefitMap['dailyValue'],
                nextRecharge: benefitMap['nextRecharge'],
                actions: List<String>.from(benefitMap['actions'] ?? []),
              );
            } catch (e) {
              print('Erro ao mapear benefício: $e');
              return null;
            }
          })
          .whereType<Benefit>()
          .toList();
    } catch (e) {
      print('Erro ao carregar benefícios para $userName: $e');
      return [];
    }
  }

  /// Obtém os benefícios disponíveis do usuário
  static Future<List<Benefit>> getAvailableBenefits(String userName) async {
    try {
      final userData = await getUserData(userName);

      if (!userData.containsKey('availableBenefits')) {
        print('Aviso: availableBenefits não encontrado para $userName');
        return [];
      }

      final benefitsData = userData['availableBenefits'];

      if (benefitsData is! List) {
        print('Aviso: availableBenefits não é uma lista para $userName');
        return [];
      }

      return benefitsData
          .map((benefitMap) {
            if (benefitMap is! Map<String, dynamic>) {
              return null;
            }

            try {
              return Benefit(
                id: benefitMap['id'] ?? 'AVBEN000',
                name: benefitMap['name'] ?? 'Benefício',
                category: benefitMap['category'] ?? 'Geral',
                subcategory: benefitMap['subcategory'] ?? 'Sem categoria',
                status: benefitMap['status'] ?? 'DISPONIVEL',
                icon: benefitMap['icon'] ?? 'default',
                description: benefitMap['description'] ?? 'Sem descrição',
              );
            } catch (e) {
              print('Erro ao mapear benefício disponível: $e');
              return null;
            }
          })
          .whereType<Benefit>()
          .toList();
    } catch (e) {
      print('Erro ao carregar benefícios disponíveis para $userName: $e');
      return [];
    }
  }

  /// Obtém os alertas do usuário
  static Future<List<Map<String, dynamic>>> getAlerts(String userName) async {
    try {
      final userData = await getUserData(userName);

      if (!userData.containsKey('alerts')) {
        return [];
      }

      final alertsData = userData['alerts'];

      if (alertsData is! List) {
        return [];
      }

      return alertsData.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Erro ao carregar alertas para $userName: $e');
      return [];
    }
  }

  /// Obtém o histórico de uso do usuário
  static Future<List<Map<String, dynamic>>> getUsageHistory(
    String userName,
  ) async {
    try {
      final userData = await getUserData(userName);

      if (!userData.containsKey('usageHistory')) {
        return [];
      }

      final usageData = userData['usageHistory'];

      if (usageData is! List) {
        return [];
      }

      return usageData.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Erro ao carregar histórico de uso para $userName: $e');
      return [];
    }
  }

  /// Obtém os dados do painel personalizado
  static Future<Map<String, dynamic>> getDashboardData(String userName) async {
    try {
      final userData = await getUserData(userName);
      final summary = userData['summary'] as Map<String, dynamic>;

      return {
        'activeBenefits': summary['activeBenefits'] ?? 0,
        'monthlySpent': summary['monthlySpent'] ?? 0.0,
        'estimatedSavings': summary['estimatedSavings'] ?? 0.0,
        'pendingRequests': summary['pendingRequests'] ?? 0,
        'engagementScore': summary['engagementScore'] ?? 0.0,
        'lastAccessDate': summary['lastAccessDate'] ?? 'N/A',
        'alerts': userData['alerts'] ?? [],
        'usageHistory': userData['usageHistory'] ?? [],
      };
    } catch (e) {
      print('Erro ao carregar dados do painel para $userName: $e');
      return {
        'activeBenefits': 0,
        'monthlySpent': 0.0,
        'estimatedSavings': 0.0,
        'pendingRequests': 0,
        'engagementScore': 0.0,
        'lastAccessDate': 'N/A',
        'alerts': [],
        'usageHistory': [],
      };
    }
  }

  /// Obtém todos os dados do usuário de uma vez
  static Future<Map<String, dynamic>> getAllUserData(String userName) async {
    try {
      final userData = await getUserData(userName);

      return {
        'user': userData['user'] ?? {},
        'summary': userData['summary'] ?? {},
        'myBenefits': userData['myBenefits'] ?? [],
        'availableBenefits': userData['availableBenefits'] ?? [],
        'alerts': userData['alerts'] ?? [],
        'usageHistory': userData['usageHistory'] ?? [],
      };
    } catch (e) {
      print('Erro ao carregar todos os dados para $userName: $e');
      return {
        'user': {},
        'summary': {},
        'myBenefits': [],
        'availableBenefits': [],
        'alerts': [],
        'usageHistory': [],
      };
    }
  }

  /// Limpa o cache de dados
  static void clearCache() {
    _cachedData = null;
  }

  /// Dados padrão em caso de erro ao carregar JSON
  static Map<String, dynamic> _getDefaultMockData() {
    return {
      'users': {
        'Ana Silva': {
          'user': {
            'id': 'USR001',
            'name': 'Ana Silva',
            'role': 'Desenvolvedora Sênior',
            'email': 'ana.silva@bencorp.com',
            'avatar': 'assets/images/ana-costa.jpeg',
            'isAdmin': false,
          },
          'summary': {
            'activeBenefits': 3,
            'annualCoparticipation': 0.0,
            'pendingRequests': 1,
            'monthlySpent': 850.0,
            'estimatedSavings': 2400.0,
            'engagementScore': 95.0,
            'lastAccessDate': '23/02/2025 14:30',
          },
          'myBenefits': [],
          'availableBenefits': [],
          'alerts': [],
          'usageHistory': [],
        },
      },
    };
  }
}
