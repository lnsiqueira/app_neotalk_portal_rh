import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _settingsPrefix = 'settings_';
  static const String _passwordPrefix = 'password_';

  // Dados mockados de usuários com senhas
  static final Map<String, String> _userPasswords = {
    'Carlos Santos': '123456',
    'Ana Silva': '123456',
    'João Pedro': '123456',
    'Maria Oliveira': '123456',
  };

  /// Obter configurações do usuário
  Future<Map<String, dynamic>> getSettings(String userName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('$_settingsPrefix$userName');

      if (settingsJson != null) {
        return jsonDecode(settingsJson);
      }

      // Retornar configurações padrão
      return {
        'notificationsEnabled': true,
        'emailNotificationsEnabled': true,
        'darkModeEnabled': false,
        'language': 'Português',
        'theme': 'Claro',
        'avatarPath': null,
      };
    } catch (e) {
      print('Erro ao carregar configurações: $e');
      return {};
    }
  }

  /// Salvar configurações do usuário
  Future<bool> saveSettings(
    String userName,
    Map<String, dynamic> settings,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = jsonEncode(settings);
      await prefs.setString('$_settingsPrefix$userName', settingsJson);
      return true;
    } catch (e) {
      print('Erro ao salvar configurações: $e');
      return false;
    }
  }

  /// Alterar senha do usuário
  Future<bool> changePassword(
    String userName,
    String currentPassword,
    String newPassword,
  ) async {
    try {
      // Simular verificação de senha
      final storedPassword = _userPasswords[userName];

      if (storedPassword == null) {
        return false;
      }

      // Verificar se a senha atual está correta
      if (storedPassword != currentPassword) {
        return false;
      }

      // Atualizar a senha
      _userPasswords[userName] = newPassword;

      // Salvar no SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_passwordPrefix$userName', newPassword);

      return true;
    } catch (e) {
      print('Erro ao alterar senha: $e');
      return false;
    }
  }

  /// Verificar se a senha está correta
  Future<bool> verifyPassword(String userName, String password) async {
    try {
      final storedPassword = _userPasswords[userName];
      return storedPassword == password;
    } catch (e) {
      print('Erro ao verificar senha: $e');
      return false;
    }
  }

  /// Limpar cache
  Future<bool> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      return true;
    } catch (e) {
      print('Erro ao limpar cache: $e');
      return false;
    }
  }

  /// Obter versão do app
  String getAppVersion() {
    return '1.0.0';
  }

  /// Obter informações do sistema
  Future<Map<String, dynamic>> getSystemInfo() async {
    return {
      'version': '1.0.0',
      'buildNumber': '1',
      'platform': 'Flutter',
      'releaseDate': '2024-02-25',
    };
  }

  /// Exportar configurações
  Future<String> exportSettings(String userName) async {
    try {
      final settings = await getSettings(userName);
      return jsonEncode(settings);
    } catch (e) {
      print('Erro ao exportar configurações: $e');
      return '';
    }
  }

  /// Importar configurações
  Future<bool> importSettings(String userName, String settingsJson) async {
    try {
      final settings = jsonDecode(settingsJson);
      return await saveSettings(userName, settings);
    } catch (e) {
      print('Erro ao importar configurações: $e');
      return false;
    }
  }

  /// Resetar configurações para padrão
  Future<bool> resetToDefault(String userName) async {
    try {
      final defaultSettings = {
        'notificationsEnabled': true,
        'emailNotificationsEnabled': true,
        'darkModeEnabled': false,
        'language': 'Português',
        'theme': 'Claro',
        'avatarPath': null,
      };
      return await saveSettings(userName, defaultSettings);
    } catch (e) {
      print('Erro ao resetar configurações: $e');
      return false;
    }
  }

  /// Obter temas disponíveis
  List<String> getAvailableThemes() {
    return ['Claro', 'Escuro', 'Automático'];
  }

  /// Obter idiomas disponíveis
  List<String> getAvailableLanguages() {
    return ['Português', 'Inglês', 'Espanhol'];
  }

  /// Ativar/Desativar notificações
  Future<bool> setNotificationsEnabled(String userName, bool enabled) async {
    try {
      final settings = await getSettings(userName);
      settings['notificationsEnabled'] = enabled;
      return await saveSettings(userName, settings);
    } catch (e) {
      print('Erro ao alterar notificações: $e');
      return false;
    }
  }

  /// Ativar/Desativar notificações por email
  Future<bool> setEmailNotificationsEnabled(
    String userName,
    bool enabled,
  ) async {
    try {
      final settings = await getSettings(userName);
      settings['emailNotificationsEnabled'] = enabled;
      return await saveSettings(userName, settings);
    } catch (e) {
      print('Erro ao alterar notificações de email: $e');
      return false;
    }
  }

  /// Alterar tema
  Future<bool> setTheme(String userName, String theme) async {
    try {
      final settings = await getSettings(userName);
      settings['theme'] = theme;
      settings['darkModeEnabled'] = theme == 'Escuro';
      return await saveSettings(userName, settings);
    } catch (e) {
      print('Erro ao alterar tema: $e');
      return false;
    }
  }

  /// Alterar idioma
  Future<bool> setLanguage(String userName, String language) async {
    try {
      final settings = await getSettings(userName);
      settings['language'] = language;
      return await saveSettings(userName, settings);
    } catch (e) {
      print('Erro ao alterar idioma: $e');
      return false;
    }
  }

  /// Alterar avatar
  Future<bool> setAvatarPath(String userName, String avatarPath) async {
    try {
      final settings = await getSettings(userName);
      settings['avatarPath'] = avatarPath;
      return await saveSettings(userName, settings);
    } catch (e) {
      print('Erro ao alterar avatar: $e');
      return false;
    }
  }
}
