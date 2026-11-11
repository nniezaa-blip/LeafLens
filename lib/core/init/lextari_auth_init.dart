import 'package:flutter/foundation.dart';
import 'package:lextari/core/config/app_config.dart';
import 'package:lextari/features/auth/data/lextari_auth.dart';

/// Initialises the Supabase client with credentials from [AppConfig]
/// (i.e. the bundled `.env` file).
///
/// Skips silently if URL or anon key is empty (local dev).
Future<void> initLextariAuth() async {
  final url = AppConfig.supabaseUrl;
  final anonKey = AppConfig.supabaseAnonKey;
  if (url.isEmpty || anonKey.isEmpty) {
    debugPrint('[Supabase] URL or anon key empty — skipping initialisation.');
    return;
  }

  await LextariAuth.init(url: url, publishableKey: anonKey);
}
