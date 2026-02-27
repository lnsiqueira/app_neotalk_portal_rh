class LoginUser {
  final String id;
  final String name;
  final String email;
  final String password;
  final String avatar;
  final String role;
  final bool isAdmin;
  final String? adminType;

  LoginUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.avatar,
    required this.role,
    this.isAdmin = false,
    this.adminType,
  });
}

class LoginService {
  static final List<LoginUser> mockUsers = [
    LoginUser(
      id: 'USR001',
      name: 'Ana Silva da Costa',
      email: 'ana.silva@bencorp.com',
      password: '123456',
      avatar: 'assets/images/ana-costa.jpeg',
      role: 'Desenvolvedora Sênior',
      isAdmin: false,
    ),
    LoginUser(
      id: 'USR002',
      name: 'Carlos Santos',
      email: 'carlos.santos@bencorp.com',
      password: '123456',
      avatar: 'assets/images/carlos.jpeg',
      role: 'Gerente de RH',
      isAdmin: true,
      adminType: 'rh',
    ),
    LoginUser(
      id: 'USR003',
      name: 'Maria Oliveira',
      email: 'maria.oliveira@bencorp.com',
      password: '123456',
      avatar: 'assets/images/maria.jpeg',
      role: 'Analista de Sistemas',
      isAdmin: false,
    ),
    LoginUser(
      id: 'USR004',
      name: 'João Pereira',
      email: 'joao.pereira@bencorp.com',
      password: '123456',
      avatar: 'https://i.pravatar.cc/150?img=3',
      role: 'Especialista em Suprimentos',
      isAdmin: false,
    ),
    LoginUser(
      id: 'USR005',
      name: 'Fernanda da Costa',
      email: 'fernanda.costa@dependente.com',
      password: '123456',
      avatar: 'assets/images/fernanda.jpeg',
      role: 'Dependente',
      isAdmin: false,
    ),
  ];

  static LoginUser? authenticate(String email, String password) {
    try {
      final user = mockUsers.firstWhere(
        (u) => u.email == email && u.password == password,
      );
      return user;
    } catch (e) {
      return null;
    }
  }

  static List<LoginUser> getAllUsers() {
    return mockUsers;
  }
}
