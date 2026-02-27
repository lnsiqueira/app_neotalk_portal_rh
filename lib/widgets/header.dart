import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';

class Header extends StatelessWidget {
  final User user;

  const Header({Key? key, required this.user}) : super(key: key);

  /// Extrai as iniciais do nome do usuário (fallback)
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';

    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    } else {
      return (parts[0].substring(0, 1) +
              parts[parts.length - 1].substring(0, 1))
          .toUpperCase();
    }
  }

  /// Gera uma cor baseada no nome do usuário
  Color _getAvatarColor(String name) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    final hash = name.hashCode;
    return colors[hash.abs() % colors.length];
  }

  /// Cria o avatar com fallback para iniciais
  Widget _buildAvatar() {
    // Se tem URL de avatar e não está vazia
    if (user.avatar.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey[200],
        // backgroundImage: NetworkImage(user.avatar),
        backgroundImage: AssetImage(user.avatar),
        onBackgroundImageError: (exception, stackTrace) {
          print('✗ Erro ao carregar avatar: $exception');
        },
      );
    } else {
      // Se não tem avatar, mostra iniciais
      return CircleAvatar(
        radius: 24,
        backgroundColor: _getAvatarColor(user.name),
        child: Text(
          _getInitials(user.name),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Saudação
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, ${user.name}! 👋',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Bem-vindo ao seu painel de benefícios',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Avatar
          _buildAvatar(),
        ],
      ),
    );
  }
}
