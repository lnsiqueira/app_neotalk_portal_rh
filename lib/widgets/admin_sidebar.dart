import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AdminSidebar extends StatefulWidget {
  final String selectedItem;
  final Function(String) onItemSelected;

  const AdminSidebar({
    Key? key,
    required this.selectedItem,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  State<AdminSidebar> createState() => _AdminSidebarState();
}

class _AdminSidebarState extends State<AdminSidebar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: AppTheme.surfaceColor,
      child: Column(
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.business, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Text(
                  'NeoBen',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: AppTheme.textDark),
                ),
              ],
            ),
          ),

          // Badge de Admin
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.primaryRed),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.admin_panel_settings_rounded,
                    color: AppTheme.primaryRed,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Administrador RH',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Painel (Dashboard)
                _buildMenuItem(
                  context,
                  icon: Icons.analytics_rounded,
                  label: 'Painel Administrativo',
                  itemId: 'painel',
                ),
                const SizedBox(height: 8),

                // Divider
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Divider(color: AppTheme.dividerColor),
                ),
                const SizedBox(height: 8),

                // Gestão de Benefícios
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Text(
                    'GESTÃO',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textLight,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.card_giftcard_rounded,
                  label: 'Benefícios',
                  itemId: 'admin_beneficios',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.people_rounded,
                  label: 'Colaboradores',
                  itemId: 'admin_colaboradores',
                ),
                // _buildMenuItem(
                //   context,
                //   icon: Icons.assignment_rounded,
                //   label: 'Solicitações',
                //   itemId: 'admin_solicitacoes',
                // ),
                const SizedBox(height: 8),

                // Divider
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Divider(color: AppTheme.dividerColor),
                ),
                const SizedBox(height: 8),

                // Relatórios
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Text(
                    'RELATÓRIOS',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textLight,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.bar_chart_rounded,
                  label: 'Relatórios Executivos',
                  itemId: 'admin_relatorios',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.trending_up_rounded,
                  label: 'Engajamento',
                  itemId: 'admin_engajamento',
                ),
              ],
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Divider(color: AppTheme.dividerColor),
                const SizedBox(height: 16),
                _buildMenuItem(
                  context,
                  icon: Icons.settings_rounded,
                  label: 'Configurações',
                  itemId: 'configuracoes',
                ),
                const SizedBox(height: 8),

                _buildMenuItem(
                  context,
                  icon: Icons.logout_rounded,
                  label: 'Logout',
                  itemId: 'logout',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String itemId,
  }) {
    final isSelected = widget.selectedItem == itemId;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.veryLightRed : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppTheme.primaryRed : AppTheme.textLight,
        ),
        title: Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: isSelected ? AppTheme.primaryRed : AppTheme.textDark,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        onTap: () => widget.onItemSelected(itemId),
      ),
    );
  }
}
