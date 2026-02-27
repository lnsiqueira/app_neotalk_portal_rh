import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class Sidebar extends StatelessWidget {
  final String selectedItem;
  final Function(String) onItemSelected;

  const Sidebar({
    Key? key,
    required this.selectedItem,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: Colors.white,
      child: Column(
        children: [
          // Logo/Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryRed,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'NB',
                      style: TextStyle(
                        color: AppTheme.primaryRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'NeoBen',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Menu Items
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildMenuSection(context, 'MENU PRINCIPAL', [
                    _MenuItem(
                      id: 'painel',
                      label: 'Painel',
                      icon: Icons.dashboard,
                    ),
                    _MenuItem(
                      id: 'beneficios',
                      label: 'Meus Benefícios',
                      icon: Icons.favorite,
                    ),
                    // _MenuItem(
                    //   id: 'historico',
                    //   label: 'Histórico',
                    //   icon: Icons.history,
                    // ),
                    _MenuItem(
                      id: 'dependentes',
                      label: 'Dependentes',
                      icon: Icons.people,
                    ),
                  ]),
                  _buildMenuSection(context, 'CONTA', [
                    _MenuItem(
                      id: 'configuracoes',
                      label: 'Configurações',
                      icon: Icons.settings,
                    ),
                    _MenuItem(
                      id: 'ajuda',
                      label: 'Ajuda',
                      icon: Icons.help_outline,
                    ),
                    _MenuItem(
                      id: 'logout',
                      label: 'Logout',
                      icon: Icons.logout,
                      isLogout: true,
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    String title,
    List<_MenuItem> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...items.map((item) => _buildMenuItem(context, item)),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, _MenuItem item) {
    final isSelected = selectedItem == item.id;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryRed.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (item.isLogout) {
              // Mostrar diálogo apenas uma vez
              _showLogoutConfirmation(context);
            } else {
              // Para outros itens, chamar o callback normalmente
              onItemSelected(item.id);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 20,
                  color: isSelected ? AppTheme.primaryRed : Colors.grey[700],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected
                          ? AppTheme.primaryRed
                          : Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Logout'),
          content: const Text('Você tem certeza que deseja sair?'),
          actions: [
            TextButton(
              onPressed: () {
                // Fechar apenas o diálogo
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Fechar o diálogo
                Navigator.pop(dialogContext);
                // Chamar logout apenas uma vez
                onItemSelected('logout');
              },
              child: Text(
                'Logout',
                style: TextStyle(color: AppTheme.primaryRed),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MenuItem {
  final String id;
  final String label;
  final IconData icon;
  final bool isLogout;

  _MenuItem({
    required this.id,
    required this.label,
    required this.icon,
    this.isLogout = false,
  });
}
