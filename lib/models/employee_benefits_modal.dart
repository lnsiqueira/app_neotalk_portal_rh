import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EmployeeBenefitsModal {
  static void show(
    BuildContext context,
    String employeeName,
    String employeeId,
  ) {
    // Dados mockados de benefícios por colaborador
    final benefitsByEmployee = {
      'EMP001': [
        {
          'name': 'Plano de Saúde',
          'type': 'Saúde',
          'status': 'Ativo',
          'icon': Icons.health_and_safety,
          'color': Colors.green,
        },
        {
          'name': 'Gympass',
          'type': 'Bem-estar',
          'status': 'Ativo',
          'icon': Icons.fitness_center,
          'color': Colors.blue,
        },
        {
          'name': 'Vale Refeição',
          'type': 'Alimentação',
          'status': 'Ativo',
          'icon': Icons.restaurant,
          'color': Colors.orange,
        },
      ],
      'EMP002': [
        {
          'name': 'Plano de Saúde',
          'type': 'Saúde',
          'status': 'Ativo',
          'icon': Icons.health_and_safety,
          'color': Colors.green,
        },
        {
          'name': 'Vale Transporte',
          'type': 'Transporte',
          'status': 'Ativo',
          'icon': Icons.directions_bus,
          'color': Colors.purple,
        },
      ],
      'EMP003': [
        {
          'name': 'Plano de Saúde',
          'type': 'Saúde',
          'status': 'Ativo',
          'icon': Icons.health_and_safety,
          'color': Colors.green,
        },
        {
          'name': 'Plano Odontológico',
          'type': 'Saúde',
          'status': 'Ativo',
          'icon': Icons.toc_outlined,
          'color': Colors.teal,
        },
        {
          'name': 'Seguro de Vida',
          'type': 'Proteção',
          'status': 'Ativo',
          'icon': Icons.security,
          'color': Colors.red,
        },
        {
          'name': 'Cursos e Treinamentos',
          'type': 'Desenvolvimento',
          'status': 'Ativo',
          'icon': Icons.school,
          'color': Colors.indigo,
        },
      ],
      'EMP004': [
        {
          'name': 'Plano de Saúde',
          'type': 'Saúde',
          'status': 'Ativo',
          'icon': Icons.health_and_safety,
          'color': Colors.green,
        },
        {
          'name': 'Vale Transporte',
          'type': 'Transporte',
          'status': 'Ativo',
          'icon': Icons.directions_bus,
          'color': Colors.purple,
        },
      ],
      'EMP005': [
        {
          'name': 'Plano de Saúde',
          'type': 'Saúde',
          'status': 'Ativo',
          'icon': Icons.health_and_safety,
          'color': Colors.green,
        },
      ],
    };

    // Obter benefícios do colaborador
    final benefits = benefitsByEmployee[employeeId] ?? [];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: 600,
          ),
          child: Column(
            children: [
              // Cabeçalho
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Benefícios do Colaborador',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          employeeName,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Lista de Benefícios
              Expanded(
                child: benefits.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.card_giftcard_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum benefício associado',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: benefits.length,
                        itemBuilder: (context, index) {
                          final benefit = benefits[index];
                          return _buildBenefitCard(benefit);
                        },
                      ),
              ),

              // Rodapé
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRed,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Fechar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildBenefitCard(Map<String, dynamic> benefit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Ícone
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (benefit['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                benefit['icon'] as IconData,
                color: benefit['color'] as Color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Informações
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    benefit['name'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          benefit['type'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Ativo',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Ícone de seta
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
