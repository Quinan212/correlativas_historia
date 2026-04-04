class SupabaseConfig {
  const SupabaseConfig._();

  static const String projectId = 'drluybtjvmnggleqcbgf';
  static const String defaultUrl = 'https://$projectId.supabase.co';

  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: defaultUrl,
  );

  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  static bool get hasPublishableKey => publishableKey.trim().isNotEmpty;
}
