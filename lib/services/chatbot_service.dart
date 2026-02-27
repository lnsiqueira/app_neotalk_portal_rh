import '../models/user_model.dart';

/// Modelo de Mensagem do Chat
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? actionType; // Ex: 'vacation', 'dissidio', 'courses', etc

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.actionType,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Serviço de Chatbot Inteligente
class ChatbotService {
  /// Gera resposta baseada na pergunta do usuário
  static Future<ChatMessage> generateResponse(
    String userMessage,
    User user,
  ) async {
    // Simular delay de digitação
    await Future.delayed(const Duration(milliseconds: 800));

    final lowerMessage = userMessage.toLowerCase();

    // Detectar intenção e gerar resposta
    if (_containsKeywords(lowerMessage, [
      'férias',
      'feria',
      'vacation',
      'próximas férias',
    ])) {
      return _handleVacationQuestion(user);
    } else if (_containsKeywords(lowerMessage, [
      'dissídio',
      'dissidio',
      'aumento',
      'reajuste',
    ])) {
      return _handleDissidioQuestion(user);
    } else if (_containsKeywords(lowerMessage, [
      'migração',
      'migracao',
      'plano',
      'saúde',
      'saude',
      'mudar plano',
    ])) {
      return _handlePlanMigrationQuestion(user);
    } else if (_containsKeywords(lowerMessage, [
      'cursos',
      'curso',
      'treinamento',
      'capacitação',
      'capacitacao',
      'aprendizado',
    ])) {
      return _handleCoursesQuestion(user);
    } else if (_containsKeywords(lowerMessage, [
      'oi',
      'olá',
      'ola',
      'opa',
      'e aí',
      'e ai',
      'tudo bem',
      'como vai',
    ])) {
      return _handleGreeting(user);
    } else if (_containsKeywords(lowerMessage, [
      'ajuda',
      'help',
      'socorro',
      'não entendi',
      'nao entendi',
      'como funciona',
    ])) {
      return _handleHelpRequest();
    } else {
      return _handleUnknownQuestion();
    }
  }

  /// Verifica se a mensagem contém palavras-chave
  static bool _containsKeywords(String message, List<String> keywords) {
    return keywords.any((keyword) => message.contains(keyword));
  }

  /// Responde sobre férias
  static ChatMessage _handleVacationQuestion(User user) {
    final vacationDate = _calculateVacationDate();
    final daysUntilVacation = vacationDate.difference(DateTime.now()).inDays;

    String response =
        ''
        '''
// Ótimo! 🏖️

// Suas próximas férias estão marcadas para:
// 📅 **${_formatDate(vacationDate)}**

// Faltam **$daysUntilVacation dias** para você aproveitar seu merecido descanso!

// 💡 **Dica:** Lembre-se de comunicar seu gestor com antecedência e verificar se há projetos pendentes antes de sair.

// Precisa de mais informações sobre férias?
// ''';

    return ChatMessage(text: response, isUser: false, actionType: 'vacation');
  }

  /// Responde sobre dissídio
  static ChatMessage _handleDissidioQuestion(User user) {
    const dissidioMonth = 3; // Março
    final currentDate = DateTime.now();
    final nextDissidio = DateTime(
      currentDate.month >= dissidioMonth
          ? currentDate.year + 1
          : currentDate.year,
      dissidioMonth,
      1,
    );
    final daysUntilDissidio = nextDissidio.difference(currentDate).inDays;

    String response =
        '''
Ótima pergunta! 💰

O próximo dissídio está previsto para:
📅 **${_formatDate(nextDissidio)}**

Faltam **$daysUntilDissidio dias** para o reajuste salarial!

📊 **Informações importantes:**
• O dissídio é concedido anualmente em **março**
• O percentual depende do resultado da empresa
• Você receberá comunicação formal 30 dias antes

💡 **Dica:** Acompanhe seu desempenho e realize suas metas para estar preparado para negociações futuras!

Tem mais dúvidas sobre remuneração?
''';

    return ChatMessage(text: response, isUser: false, actionType: 'dissidio');
  }

  /// Responde sobre migração de plano
  static ChatMessage _handlePlanMigrationQuestion(User user) {
    String response = '''
Entendi! 🏥

A migração de plano de saúde depende de alguns fatores:

📋 **Critérios para migração:**
• **Tempo de casa:** Mínimo 6 meses
• **Cargo:** Alguns planos são exclusivos para cargos específicos
• **Departamento:** Alguns benefícios variam por área

🔄 **Processo de migração:**
1. Acesse a seção "Benefícios" no portal
2. Clique em "Solicitar Migração de Plano"
3. Escolha o novo plano desejado
4. Aguarde aprovação do RH (3-5 dias úteis)

💡 **Dica:** Você pode solicitar uma análise comparativa entre planos antes de decidir!

Qual é seu cargo e tempo de casa? Posso ajudar com recomendações específicas!
''';

    return ChatMessage(
      text: response,
      isUser: false,
      actionType: 'plan_migration',
    );
  }

  /// Responde sobre cursos
  static ChatMessage _handleCoursesQuestion(User user) {
    final courses = _getCoursesForDepartment(user.role);

    String coursesList = courses
        .map((course) => '• **${course['name']}** - ${course['duration']}')
        .join('\n');

    String response =
        '''
Excelente! 📚

Aqui estão os cursos disponíveis para seu departamento (**${user.role}**):

$coursesList

🎯 **Como se inscrever:**
1. Acesse a seção "Desenvolvimento" no portal
2. Clique em "Cursos Disponíveis"
3. Selecione o curso desejado
4. Clique em "Solicitar Inscrição"
5. Aguarde aprovação do seu gestor

💡 **Dica:** Você pode se inscrever em até 2 cursos por trimestre!

Qual curso te interessa mais?
''';

    return ChatMessage(text: response, isUser: false, actionType: 'courses');
  }

  /// Responde a saudações
  static ChatMessage _handleGreeting(User user) {
    final greetings = [
      // 'Olá ${user.name}! 👋 Bem-vindo ao assistente virtual! Como posso ajudá-lo hoje?',
      // 'Oi ${user.name}! 😊 Estou aqui para responder suas dúvidas sobre benefícios, férias, cursos e muito mais!',
      // 'E aí ${user.name}! 🚀 Tudo bem? Faça-me uma pergunta sobre seus benefícios corporativos!',
      // 'Olá! 👋 Sou seu assistente virtual. Posso ajudá-lo com informações sobre férias, dissídio, planos de saúde e cursos!',
    ];

    final random = greetings[DateTime.now().millisecond % greetings.length];

    return ChatMessage(text: random, isUser: false);
  }

  /// Responde a pedidos de ajuda
  static ChatMessage _handleHelpRequest() {
    String response = '''
Claro! 🤝

Sou um assistente virtual inteligente e posso ajudá-lo com:

📅 **Férias**
Pergunte: "Quando são minhas próximas férias?"

💰 **Dissídio**
Pergunte: "Quando é o próximo dissídio?"

🏥 **Plano de Saúde**
Pergunte: "Como faço para migrar de plano?"

📚 **Cursos e Treinamentos**
Pergunte: "Quais cursos estão disponíveis?"

💡 **Outras dúvidas:**
Você também pode fazer perguntas sobre:
• Benefícios corporativos
• Políticas da empresa
• Processos administrativos

Qual é sua dúvida? 😊
''';

    return ChatMessage(text: response, isUser: false);
  }

  /// Responde a perguntas desconhecidas
  static ChatMessage _handleUnknownQuestion() {
    String response = '';
    // Hmm, não tenho certeza sobre isso... 🤔

    // Mas posso ajudá-lo com:
    // • 📅 Informações sobre férias
    // • 💰 Dissídio e reajustes
    // • 🏥 Migração de plano de saúde
    // • 📚 Cursos e treinamentos

    // Ou você pode entrar em contato com o RH diretamente para dúvidas mais específicas!

    // Posso ajudá-lo com algo desses tópicos?
    // ''';

    return ChatMessage(text: response, isUser: false);
  }

  /// Calcula a data das próximas férias (data fixa)
  static DateTime _calculateVacationDate() {
    // Próximas férias em 15 de julho
    final currentDate = DateTime.now();
    var vacationDate = DateTime(currentDate.year, 7, 15);

    if (vacationDate.isBefore(currentDate)) {
      vacationDate = DateTime(currentDate.year + 1, 7, 15);
    }

    return vacationDate;
  }

  /// Formata data para exibição
  static String _formatDate(DateTime date) {
    const months = [
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  /// Retorna cursos disponíveis para um departamento
  static List<Map<String, String>> _getCoursesForDepartment(String department) {
    final allCourses = {
      'TI': [
        {'name': 'Curso de IA e Machine Learning', 'duration': '40 horas'},
        {'name': 'Segurança da Informação Avançada', 'duration': '30 horas'},
        {'name': 'Cloud Computing com AWS', 'duration': '35 horas'},
        {'name': 'DevOps e CI/CD', 'duration': '25 horas'},
        {'name': 'Python para Data Science', 'duration': '40 horas'},
      ],
      'RH': [
        {'name': 'Gestão de Pessoas', 'duration': '20 horas'},
        {'name': 'Recrutamento e Seleção', 'duration': '15 horas'},
        {'name': 'Legislação Trabalhista', 'duration': '25 horas'},
        {'name': 'Desenvolvimento de Lideranças', 'duration': '30 horas'},
      ],
      'Financeiro': [
        {'name': 'Análise Financeira Avançada', 'duration': '35 horas'},
        {'name': 'Planejamento Orçamentário', 'duration': '20 horas'},
        {'name': 'Contabilidade Gerencial', 'duration': '30 horas'},
        {'name': 'Gestão de Riscos Financeiros', 'duration': '25 horas'},
      ],
      'Vendas': [
        {'name': 'Técnicas de Vendas Consultivas', 'duration': '20 horas'},
        {'name': 'Negociação Estratégica', 'duration': '25 horas'},
        {'name': 'CRM e Gestão de Clientes', 'duration': '15 horas'},
        {'name': 'Inteligência Comercial', 'duration': '30 horas'},
      ],
      'Marketing': [
        {'name': 'Marketing Digital e Social Media', 'duration': '30 horas'},
        {'name': 'Análise de Dados para Marketing', 'duration': '25 horas'},
        {'name': 'Branding e Posicionamento', 'duration': '20 horas'},
        {'name': 'Inbound Marketing', 'duration': '25 horas'},
      ],
    };

    // Retorna cursos do departamento ou cursos gerais
    return allCourses[department] ?? _getGeneralCourses();
  }

  /// Retorna cursos gerais para todos os departamentos
  static List<Map<String, String>> _getGeneralCourses() {
    return [
      {'name': 'Gestão de Projetos (PMP)', 'duration': '40 horas'},
      {'name': 'Liderança e Gestão de Equipes', 'duration': '30 horas'},
      {'name': 'Comunicação Efetiva', 'duration': '20 horas'},
      {'name': 'Inteligência Emocional', 'duration': '25 horas'},
      {'name': 'Segurança da Informação', 'duration': '15 horas'},
      {'name': 'Conformidade e Compliance', 'duration': '20 horas'},
    ];
  }
}
