class ApiEndpoints {
  const ApiEndpoints._();

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String google = '/auth/google';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  static const String devices = '/api/devices';
  static const String healthScore = '/api/health-score';
  static const String rpc = '/api/rpc';
  static String telemetryHistory(String key) => '/api/telemetry/$key';
}
