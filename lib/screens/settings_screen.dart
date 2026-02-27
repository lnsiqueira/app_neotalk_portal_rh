import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  final User user;

  const SettingsScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _emailController;

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _notificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'Português';
  String _selectedTheme = 'Claro';
  String? _avatarPath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _emailController = TextEditingController(text: widget.user.email);

    _loadSettings();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final settings = await _settingsService.getSettings(widget.user.name);
    setState(() {
      _notificationsEnabled = settings['notificationsEnabled'] ?? true;
      _emailNotificationsEnabled =
          settings['emailNotificationsEnabled'] ?? true;
      _darkModeEnabled = settings['darkModeEnabled'] ?? false;
      _selectedLanguage = settings['language'] ?? 'Português';
      _selectedTheme = settings['theme'] ?? 'Claro';
      _avatarPath = widget.user.avatar; //settings['avatarPath'];
    });
  }

  Future<void> _changePassword() async {
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todos os campos são obrigatórios'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('As senhas não correspondem'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A senha deve ter pelo menos 6 caracteres'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await _settingsService.changePassword(
        widget.user.name,
        _currentPasswordController.text,
        _newPasswordController.text,
      );

      if (success) {
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Senha alterada com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Senha atual incorreta'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao alterar senha: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _changeAvatar() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alterar Avatar'),
          content: const Text('Escolha uma opção:'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _avatarPath = '${widget.user.avatar}';
                });
                _settingsService.saveSettings(widget.user.name, {
                  'avatarPath': _avatarPath,
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Avatar alterado com sucesso'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Câmera', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _avatarPath = '${widget.user.avatar}';
                });
                _settingsService.saveSettings(widget.user.name, {
                  'avatarPath': _avatarPath,
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Avatar alterado com sucesso'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Galeria', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);

    try {
      await _settingsService.saveSettings(widget.user.name, {
        'notificationsEnabled': _notificationsEnabled,
        'emailNotificationsEnabled': _emailNotificationsEnabled,
        'darkModeEnabled': _darkModeEnabled,
        'language': _selectedLanguage,
        'theme': _selectedTheme,
        'email': _emailController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configurações salvas com sucesso'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar configurações: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seção: Perfil
            _buildSectionTitle('Perfil'),
            const SizedBox(height: 16),
            _buildProfileCard(),
            const SizedBox(height: 32),

            // Seção: Segurança
            _buildSectionTitle('Segurança'),
            const SizedBox(height: 16),
            _buildPasswordChangeCard(),
            const SizedBox(height: 32),

            // Seção: Informações Pessoais
            _buildSectionTitle('Informações Pessoais'),
            const SizedBox(height: 16),
            _buildPersonalInfoCard(),
            const SizedBox(height: 32),

            // Seção: Notificações
            _buildSectionTitle('Notificações'),
            const SizedBox(height: 16),
            _buildNotificationsCard(),
            const SizedBox(height: 32),

            // Seção: Aparência
            _buildSectionTitle('Aparência'),
            const SizedBox(height: 16),
            _buildAppearanceCard(),
            const SizedBox(height: 32),

            // Seção: Sistema
            _buildSectionTitle('Sistema'),
            const SizedBox(height: 16),
            _buildSystemCard(),
            const SizedBox(height: 32),

            // Botão Salvar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text('Salvar Configurações'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: AppTheme.primaryRed.withOpacity(0.2),
                  child: _avatarPath != null
                      ? Image.asset(_avatarPath!, fit: BoxFit.cover)
                      : Icon(
                          Icons.person,
                          size: 60,
                          color: AppTheme.primaryRed,
                        ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _changeAvatar,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primaryRed,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.user.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            widget.user.email,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            'Perfil: ${widget.user.role}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordChangeCard() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alterar Senha',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _currentPasswordController,
            obscureText: _obscureCurrentPassword,
            decoration: InputDecoration(
              labelText: 'Senha Atual',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureCurrentPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureCurrentPassword = !_obscureCurrentPassword;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _newPasswordController,
            obscureText: _obscureNewPassword,
            decoration: InputDecoration(
              labelText: 'Nova Senha',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureNewPassword = !_obscureNewPassword;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirmar Nova Senha',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
                foregroundColor: Colors.white,
              ),
              child: const Text('Alterar Senha'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildNotificationsCard() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          CheckboxListTile(
            title: const Text('Ativar Notificações'),
            subtitle: const Text('Receba notificações do sistema'),
            value: _notificationsEnabled,
            activeColor: AppTheme.primaryRed,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value ?? false;
              });
            },
          ),
          Divider(color: Colors.grey.shade300),
          CheckboxListTile(
            title: const Text('Notificações por Email'),
            subtitle: const Text('Receba atualizações por email'),
            value: _emailNotificationsEnabled,
            activeColor: AppTheme.primaryRed,
            onChanged: (value) {
              setState(() {
                _emailNotificationsEnabled = value ?? false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceCard() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tema',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedTheme,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'Claro', child: Text('Claro')),
              DropdownMenuItem(value: 'Escuro', child: Text('Escuro')),
              DropdownMenuItem(value: 'Auto', child: Text('Automático')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedTheme = value ?? 'Claro';
                _darkModeEnabled = _selectedTheme == 'Escuro';
              });
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Idioma',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedLanguage,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'Português', child: Text('Português')),
              DropdownMenuItem(value: 'Inglês', child: Text('Inglês')),
              DropdownMenuItem(value: 'Espanhol', child: Text('Espanhol')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedLanguage = value ?? 'Português';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSystemCard() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            title: const Text('Versão do App'),
            subtitle: const Text('1.0.0'),
            trailing: const Icon(Icons.info_outline),
          ),
          Divider(color: Colors.grey.shade300),
          ListTile(
            title: const Text('Limpar Cache'),
            subtitle: const Text('Liberar espaço em armazenamento'),
            trailing: const Icon(Icons.delete_outline),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache limpo com sucesso'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
          Divider(color: Colors.grey.shade300),
          ListTile(
            title: const Text('Sobre'),
            subtitle: const Text('Informações do aplicativo'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Sobre o App'),
                    content: const Text(
                      'Sistema de Gestão de Benefícios Corporativos\n\n'
                      'Versão: 1.0.0\n'
                      'Desenvolvido por: Seu Nome\n'
                      'Todos os direitos reservados © 2024',
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
            },
          ),
        ],
      ),
    );
  }
}
