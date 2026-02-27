import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import 'chatbot_screen.dart';

class HelpScreen extends StatefulWidget {
  final User user;

  const HelpScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Central de Ajuda'),
        backgroundColor: AppTheme.primaryRed,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seção de Boas-vindas
              _buildWelcomeSection(),
              const SizedBox(height: 32),

              // Botão do Chatbot
              _buildChatbotButton(context),
              const SizedBox(height: 32),

              // // Seção de Perguntas Frequentes
              // _buildFAQSection(),
              // const SizedBox(height: 32),

              // Seção de Contatos
              _buildContactSection(),
              const SizedBox(height: 32),

              // Seção de Recursos
              _buildResourcesSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// Seção de Boas-vindas
  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bem-vindo à Central de Ajuda',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Aqui você encontra respostas para suas dúvidas sobre benefícios, férias, dissídio, planos de saúde e muito mais!',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.textLight),
        ),
      ],
    );
  }

  /// Botão do Chatbot
  Widget _buildChatbotButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryRed, AppTheme.primaryRed.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryRed.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatbotScreen(user: widget.user),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(Icons.smart_toy, color: Colors.white, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Assistente Virtual Inteligente',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Faça suas perguntas e obtenha respostas instantâneas sobre seus benefícios',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Clique para conversar',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Seção de Perguntas Frequentes
  Widget _buildFAQSection() {
    final faqs = [
      {
        'question': 'Quando são minhas próximas férias?',
        'answer':
            'Suas férias estão marcadas para 15 de julho. Você pode consultar datas específicas através do assistente virtual.',
      },
      {
        'question': 'Como solicitar migração de plano de saúde?',
        'answer':
            'Você pode solicitar através da seção "Benefícios" no portal. A migração depende do seu cargo e tempo de casa.',
      },
      {
        'question': 'Quando é o próximo dissídio?',
        'answer':
            'O dissídio é concedido anualmente em março. Você receberá comunicação formal 30 dias antes.',
      },
      {
        'question': 'Quais cursos estão disponíveis?',
        'answer':
            'Oferecemos cursos de IA, Machine Learning, Gestão de Projetos, Segurança e muito mais. Consulte o assistente!',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Perguntas Frequentes',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: faqs.length,
          itemBuilder: (context, index) {
            final faq = faqs[index];
            return _buildFAQItem(faq['question']!, faq['answer']!);
          },
        ),
      ],
    );
  }

  /// Item de FAQ
  Widget _buildFAQItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          question,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textLight),
            ),
          ),
        ],
      ),
    );
  }

  /// Seção de Contatos
  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Entre em Contato',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 16),
        _buildContactCard(
          icon: Icons.email,
          title: 'Email RH',
          subtitle: 'rh@empresa.com.br',
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildContactCard(
          icon: Icons.phone,
          title: 'Telefone RH',
          subtitle: '(11) 3000-0000',
          color: Colors.green,
        ),
        const SizedBox(height: 12),
        _buildContactCard(
          icon: Icons.location_on,
          title: 'Sala RH',
          subtitle: 'Andar 5, Bloco A',
          color: Colors.orange,
        ),
      ],
    );
  }

  /// Card de Contato
  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppTheme.textLight),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Seção de Recursos
  Widget _buildResourcesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recursos Úteis',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 16),
        _buildResourceCard(
          icon: Icons.description,
          title: 'Políticas da Empresa',
          description: 'Acesse nossas políticas e normas',
        ),
        const SizedBox(height: 12),
        _buildResourceCard(
          icon: Icons.school,
          title: 'Programa de Desenvolvimento',
          description: 'Conheça nossos cursos e treinamentos',
        ),
        const SizedBox(height: 12),
        _buildResourceCard(
          icon: Icons.health_and_safety,
          title: 'Benefícios Corporativos',
          description: 'Saiba mais sobre seus benefícios',
        ),
      ],
    );
  }

  /// Card de Recurso
  Widget _buildResourceCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryRed, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppTheme.textLight),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}
