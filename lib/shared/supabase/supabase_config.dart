class SupabaseConfig {
  const SupabaseConfig._();

  static const String projectId = 'drluybtjvmnggleqcbgf';
  static const String defaultUrl = 'https://$projectId.supabase.co';
  static const String defaultPublishableKey =
      'sb_publishable_j6N9fb38c5Kas2WAmfvWFg_GdOsXbY_';

  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: defaultUrl,
  );

  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: defaultPublishableKey,
    ),
  );

  static bool get hasPublishableKey => publishableKey.trim().isNotEmpty;
}
