import 'package:app_neotalk_portal_rh/models/rh_dashboard_models.dart';
import 'package:app_neotalk_portal_rh/screens/benefits_management_list_screen.dart';
import 'package:app_neotalk_portal_rh/screens/dependents_list_screen.dart';
import 'package:app_neotalk_portal_rh/screens/engagement_screen.dart';
import 'package:app_neotalk_portal_rh/screens/executive_report_screen.dart';
import 'package:app_neotalk_portal_rh/screens/help_screen.dart';
import 'package:app_neotalk_portal_rh/screens/my_benefits_page.dart';
import 'package:app_neotalk_portal_rh/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/benefit_model.dart';
import '../models/summary_model.dart';
import '../services/user_data_service.dart';
import '../widgets/sidebar.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/header.dart';
import '../widgets/available_benefits_widget.dart';
import '../screens/rh_dashboard_screen.dart';
import '../screens/employees_list_screen.dart'; // ← NOVO: Importar
import '../theme/app_theme.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  /// Opção 1: Passar o User object
  final User? loggedInUser;

  /// Opção 2: Passar apenas o nome do usuário
  final String? loggedInUserName;

  const HomeScreen({Key? key, this.loggedInUser, this.loggedInUserName})
    : assert(
        loggedInUser != null || loggedInUserName != null,
        'Deve passar loggedInUser ou loggedInUserName',
      ),
      super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedMenuItem = 'painel';
  late Future<Map<String, dynamic>> _dataFuture;
  late String _userName;
  final userEngagement = RHDashboardService.getUserEngagement();

  @override
  void initState() {
    super.initState();
    // Extrai o nome do usuário de qualquer forma que foi passado
    _userName = widget.loggedInUser?.name ?? widget.loggedInUserName!;
    print('HomeScreen inicializado para: $_userName');
    _dataFuture = _loadAllData();
  }

  /// Carrega todos os dados do usuário do UserDataService
  Future<Map<String, dynamic>> _loadAllData() async {
    try {
      print('Carregando dados para: $_userName');

      // Carrega o usuário pelo nome
      final user = await UserDataService.getUser(_userName);
      print(
        'Usuário carregado: ${user.name}, isAdmin: ${user.isAdmin}, adminType: ${user.adminType}',
      );

      // Carrega resumo
      final summary = await UserDataService.getSummary(_userName);

      // Carrega benefícios ativos
      final myBenefits = await UserDataService.getMyBenefits(_userName);
      print('Benefícios carregados para $_userName: ${myBenefits.length}');

      // Carrega benefícios disponíveis
      final availableBenefits = await UserDataService.getAvailableBenefits(
        _userName,
      );

      // Carrega dados do painel
      final dashboardData = await UserDataService.getDashboardData(_userName);

      return {
        'user': user,
        'summary': summary,
        'myBenefits': myBenefits,
        'availableBenefits': availableBenefits,
        'dashboardData': dashboardData,
      };
    } catch (e) {
      print('Erro ao carregar dados: $e');
      rethrow;
    }
  }

  /// Função para fazer logout
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Logout'),
          content: const Text('Tem certeza que deseja sair?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
              ),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }

  /// ✅ NOVO: Método para renderizar conteúdo do admin
  Widget _buildAdminContent(User user) {
    switch (selectedMenuItem) {
      case 'painel':
        return RHDashboardScreen(user: user);

      // case 'admin_beneficios':
      //   return Center(
      //     child: Text(
      //       'Tela de Gestão de Benefícios',
      //       style: Theme.of(context).textTheme.headlineSmall,
      //     ),
      //   );
      case 'admin_beneficios': // ← ATUALIZADO
        return BenefitsManagementListScreen();

      case 'admin_colaboradores': // ← NOVO
        return EmployeesListScreen();

      case 'admin_solicitacoes':
        return Center(
          child: Text(
            'Tela de Solicitações',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        );

      case 'admin_relatorios':
        // return Center(
        //   child: Text(
        //     'Tela de Relatórios',
        //     style: Theme.of(context).textTheme.headlineSmall,
        //   ),
        // );
        return ExecutiveReportScreen(user: user);

      case 'admin_engajamento':
        // return EngagementScreen(userEngagement, users: userEngagement);
        return EngagementScreen();
      //  _buildEngagementList(context, userEngagement);
      // return Center(
      //   child: Text(
      //     'Tela de Engajamento',
      //     style: Theme.of(context).textTheme.headlineSmall,
      //   ),
      // );

      case 'configuracoes':
        return SettingsScreen(user: user);

      case 'ajuda':
        return Container();

      // return Center(
      //   child: Text(
      //     'Tela de Configurações',
      //     style: Theme.of(context).textTheme.headlineSmall,
      //   ),
      // );

      default:
        return RHDashboardScreen(user: user);
    }
  }

  Widget _buildEngagementList(
    BuildContext context,
    List<UserEngagementData> users,
  ) {
    return Column(
      children: [
        ...users.asMap().entries.map((entry) {
          final index = entry.key;
          final user = entry.value;
          final maxEngagement = 100.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppTheme.dividerColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            user.userName,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getEngagementColor(
                              user.engagementScore,
                            ).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${user.engagementScore.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: _getEngagementColor(user.engagementScore),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${user.accessCount} acessos',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.textLight),
                        ),
                        Text(
                          'Score: ${user.engagementScore.toStringAsFixed(1)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppTheme.textLight,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: user.engagementScore / maxEngagement,
                        minHeight: 8,
                        backgroundColor: AppTheme.dividerColor,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getEngagementColor(user.engagementScore),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Color _getEngagementColor(double score) {
    if (score >= 80) {
      return AppTheme.activeGreen;
    } else if (score >= 60) {
      return const Color(0xFF2196F3);
    } else {
      return AppTheme.warningYellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return FutureBuilder<Map<String, dynamic>>(
      future: _dataFuture,
      builder: (context, snapshot) {
        // Carregando
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryRed),
            ),
          );
        }

        // Erro ao carregar
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppTheme.primaryRed,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar dados',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _dataFuture = _loadAllData();
                      });
                    },
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            ),
          );
        }

        // Dados carregados com sucesso
        final data = snapshot.data!;
        final user = data['user'] as User;
        final summary = data['summary'] as Summary;
        final myBenefits = data['myBenefits'] as List<Benefit>;

        print('Renderizando para: ${user.name}, isAdmin: ${user.isAdmin}');

        // Se é admin de RH, exibe dashboard especial
        if (user.isAdmin && user.adminType == 'rh') {
          print('Exibindo dashboard RH para ${user.name}');
          if (isMobile) {
            return _buildMobileAdminLayout(user);
          } else {
            return _buildDesktopAdminLayout(user);
          }
        }

        // Caso contrário, exibe layout normal
        print('Exibindo layout normal para ${user.name}');
        if (isMobile) {
          return _buildMobileLayout(user, summary, myBenefits);
        } else {
          return _buildDesktopLayout(user, summary, myBenefits);
        }
      },
    );
  }

  /// Layout Desktop Normal
  Widget _buildDesktopLayout(
    User user,
    Summary summary,
    List<Benefit> myBenefits,
  ) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Sidebar(
            selectedItem: selectedMenuItem,
            onItemSelected: (itemId) {
              if (itemId == 'logout') {
                _handleLogout();
              } else {
                setState(() {
                  selectedMenuItem = itemId;
                });
              }
            },
          ),
          // Conteúdo Principal
          Expanded(
            child: selectedMenuItem == 'beneficios'
                ? MyBenefitsPage(user: user)
                : selectedMenuItem == 'dependentes'
                ? DependentsListScreen(user: user)
                : selectedMenuItem == 'configuracoes'
                ? SettingsScreen(user: user)
                : selectedMenuItem == 'ajuda'
                ? HelpScreen(user: user)
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header com saudação
                        Header(user: user),
                        // Conteúdo do Painel
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 24,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Título
                              Text(
                                'Bem-vindo ao seu Painel',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 24),

                              // Cards de Resumo
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildSummaryCard(
                                      'Benefícios Ativos',
                                      '${summary.activeBenefits}',
                                      Icons.favorite,
                                      AppTheme.primaryRed,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  user.role == 'Dependente'
                                      ? Container()
                                      : Expanded(
                                          child: _buildSummaryCard(
                                            'Solicitações Pendentes',
                                            '${summary.pendingRequests}',
                                            Icons.pending_actions,
                                            Colors.orange,
                                          ),
                                        ),
                                ],
                              ),
                              const SizedBox(height: 32),

                              // Seção de Benefícios Ativos
                              Text(
                                'Meus Benefícios Ativos',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 16),
                              if (myBenefits.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    'Nenhum benefício ativo no momento',
                                  ),
                                )
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: myBenefits.length,
                                  itemBuilder: (context, index) {
                                    final benefit = myBenefits[index];
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: ListTile(
                                        leading: Icon(
                                          Icons.card_giftcard,
                                          color: AppTheme.primaryRed,
                                        ),
                                        title: Text(benefit.name),
                                        subtitle: Text(benefit.category),
                                        trailing: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: benefit.status == 'ATIVO'
                                                ? Colors.green
                                                : Colors.orange,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            benefit.status,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              const SizedBox(height: 32),

                              // Seção de Benefícios Disponíveis
                              AvailableBenefitsWidget(
                                userName: user.name,
                                userRole: user.role,
                              ),

                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// Layout Mobile Normal
  Widget _buildMobileLayout(
    User user,
    Summary summary,
    List<Benefit> myBenefits,
  ) {
    return Scaffold(
      drawer: Drawer(
        child: Sidebar(
          selectedItem: selectedMenuItem,
          onItemSelected: (itemId) {
            if (itemId == 'logout') {
              Navigator.pop(context);
              _handleLogout();
            } else {
              setState(() {
                selectedMenuItem = itemId;
              });
              Navigator.pop(context);
            }
          },
        ),
      ),
      appBar: AppBar(
        title: const Text('NeoBen'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryRed),
      ),
      body: selectedMenuItem == 'beneficios'
          ? MyBenefitsPage(user: user)
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Header(user: user),
                    const SizedBox(height: 24),

                    // Cards de Resumo
                    _buildSummaryCard(
                      'Benefícios Ativos',
                      '${summary.activeBenefits}',
                      Icons.favorite,
                      AppTheme.primaryRed,
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryCard(
                      'Solicitações Pendentes',
                      '${summary.pendingRequests}',
                      Icons.pending_actions,
                      Colors.orange,
                    ),
                    const SizedBox(height: 24),

                    // Benefícios Ativos
                    Text(
                      'Meus Benefícios',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    if (myBenefits.isEmpty)
                      const Text('Nenhum benefício ativo')
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: myBenefits.length,
                        itemBuilder: (context, index) {
                          final benefit = myBenefits[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(benefit.name),
                              subtitle: Text(benefit.category),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 24),

                    // Seção de Benefícios Disponíveis
                    AvailableBenefitsWidget(
                      userName: user.name,
                      userRole: user.role,
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  /// Layout Desktop Admin - ✅ CORRIGIDO
  Widget _buildDesktopAdminLayout(User user) {
    return Scaffold(
      body: Row(
        children: [
          AdminSidebar(
            selectedItem: selectedMenuItem,
            onItemSelected: (itemId) {
              if (itemId == 'logout') {
                _handleLogout();
              } else {
                setState(() {
                  selectedMenuItem = itemId;
                });
              }
            },
          ),
          Expanded(
            child: Column(
              children: [
                Header(user: user),
                Expanded(
                  child: _buildAdminContent(user), // ← USE AQUI
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Layout Mobile Admin - ✅ CORRIGIDO
  Widget _buildMobileAdminLayout(User user) {
    return Scaffold(
      drawer: Drawer(
        child: AdminSidebar(
          selectedItem: selectedMenuItem,
          onItemSelected: (itemId) {
            if (itemId == 'logout') {
              Navigator.pop(context);
              _handleLogout();
            } else {
              setState(() {
                selectedMenuItem = itemId;
              });
              Navigator.pop(context);
            }
          },
        ),
      ),
      appBar: AppBar(
        title: const Text('Dashboard RH'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryRed),
      ),
      body: _buildAdminContent(user), // ← USE AQUI
    );
  }

  /// Widget para card de resumo
  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
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
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(value, style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
