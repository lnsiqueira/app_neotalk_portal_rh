import 'dart:convert';
import 'package:app_neotalk_portal_rh/models/available_benefit_model.dart';
import 'package:flutter/services.dart';

class BenefitEligibilityService {
  static Map<String, dynamic>? _cachedData;

  // Mapa de benefícios para suas chaves no JSON
  static const Map<String, String> _benefitKeyMap = {
    'AVBEN001': 'CRECHE',
    'AVBEN002': 'GYMPASS',
    'AVBEN003': 'ALIMENTACAO',
    'AVBEN004': 'EDUCACAO',
    'AVBEN005': 'DESCONTO_FARMACIA',
    'AVBEN006': 'SEGURO_VIDA',
  };

  /// Carrega o arquivo JSON de elegibilidade
  static Future<Map<String, dynamic>> _loadEligibilityData() async {
    if (_cachedData != null) {
      return _cachedData!;
    }

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/mock_data_eligibility.json',
      );
      _cachedData = jsonDecode(jsonString);
      print('✓ JSON de elegibilidade carregado com sucesso');
      return _cachedData!;
    } catch (e) {
      print('✗ Erro ao carregar mock_data_eligibility.json: $e');
      return _getDefaultEligibilityData();
    }
  }

  /// Obtém a chave do benefício no JSON baseado no ID
  static String _getBenefitKey(String benefitId) {
    return _benefitKeyMap[benefitId] ?? benefitId;
  }

  /// Obtém todos os benefícios disponíveis
  static Future<List<AvailableBenefit>> getAvailableBenefitsDetails() async {
    try {
      final data = await _loadEligibilityData();
      final benefitsMap =
          data['availableBenefitsDetails'] as Map<String, dynamic>;

      return benefitsMap.entries.map((entry) {
        return AvailableBenefit.fromJson(entry.value);
      }).toList();
    } catch (e) {
      print('✗ Erro ao carregar benefícios disponíveis: $e');
      return [];
    }
  }

  /// Obtém detalhes de um benefício específico
  static Future<AvailableBenefit?> getBenefitDetails(String benefitId) async {
    try {
      final data = await _loadEligibilityData();
      final benefitsMap =
          data['availableBenefitsDetails'] as Map<String, dynamic>;

      if (benefitsMap.containsKey(benefitId)) {
        return AvailableBenefit.fromJson(benefitsMap[benefitId]);
      }
      return null;
    } catch (e) {
      print('✗ Erro ao carregar detalhes do benefício: $e');
      return null;
    }
  }

  /// Verifica elegibilidade do usuário para um benefício
  static Future<BenefitEligibility> checkEligibility(
    String userName,
    String benefitId,
  ) async {
    try {
      final data = await _loadEligibilityData();
      final eligibilityMap = data['userEligibility'] as Map<String, dynamic>;

      print('🔍 Verificando elegibilidade: $userName para $benefitId');

      if (eligibilityMap.containsKey(userName)) {
        final userEligibility =
            eligibilityMap[userName] as Map<String, dynamic>;

        // Obtém a chave correta do benefício
        final benefitKey = _getBenefitKey(benefitId);
        print('  - Chave do benefício: $benefitKey');

        if (userEligibility.containsKey(benefitKey)) {
          final benefitEligibility =
              userEligibility[benefitKey] as Map<String, dynamic>;

          final eligible = benefitEligibility['eligible'] ?? false;
          final reason = benefitEligibility['reason'] ?? '';

          print('  ✓ Elegível: $eligible, Motivo: $reason');

          return BenefitEligibility(
            benefitId: benefitId,
            eligible: eligible,
            reason: reason,
          );
        } else {
          print('  ✗ Chave "$benefitKey" não encontrada para $userName');
        }
      } else {
        print('  ✗ Usuário "$userName" não encontrado no JSON');
      }

      // Padrão: elegível
      print('  ⚠ Usando padrão: elegível=true');
      return BenefitEligibility(
        benefitId: benefitId,
        eligible: true,
        reason: '',
      );
    } catch (e) {
      print('✗ Erro ao verificar elegibilidade: $e');
      return BenefitEligibility(
        benefitId: benefitId,
        eligible: true,
        reason: '',
      );
    }
  }

  /// Obtém elegibilidade de todos os benefícios para um usuário
  static Future<Map<String, BenefitEligibility>> getUserEligibility(
    String userName,
  ) async {
    try {
      print('📋 Carregando elegibilidade para: $userName');

      final benefitsDetails = await getAvailableBenefitsDetails();
      final eligibilityMap = <String, BenefitEligibility>{};

      for (final benefit in benefitsDetails) {
        final eligibility = await checkEligibility(userName, benefit.id);
        eligibilityMap[benefit.id] = eligibility;
      }

      print('✓ Elegibilidade carregada: ${eligibilityMap.length} benefícios');
      return eligibilityMap;
    } catch (e) {
      print('✗ Erro ao carregar elegibilidade do usuário: $e');
      return {};
    }
  }

  /// Limpa o cache
  static void clearCache() {
    _cachedData = null;
    print('🗑 Cache de elegibilidade limpo');
  }

  /// Dados padrão em caso de erro
  static Map<String, dynamic> _getDefaultEligibilityData() {
    return {'availableBenefitsDetails': {}, 'userEligibility': {}};
  }
}
