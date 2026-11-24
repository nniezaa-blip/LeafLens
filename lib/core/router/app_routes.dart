class AppRoutes {
  const AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String dashboard = '/dashboard';
  static const String stats = '/stats';
  static const String settings = '/settings';

  static const Set<String> publicRoutes = <String>{splash, login, signUp};
}
