class SupabaseConfig {
  const SupabaseConfig._();

  static const String projectId = 'drluybtjvmnggleqcbgf';
  static const String defaultUrl = 'https://$projectId.supabase.co';
  static const String defaultLegacyAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
      'eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRybHV5YnRqdm1uZ2dsZXFjYmdmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUyNDE3NTMsImV4cCI6MjA5MDgxNzc1M30.'
      'QgSe50OfKOhVfRn_gVMrX6ByFkX6yLtAuIvhzAN7Khk';

  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: defaultUrl,
  );

  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: defaultLegacyAnonKey,
  );

  static String get clientKey {
    final publishable = publishableKey.trim();
    if (publishable.startsWith('eyJ')) return publishable;
    final anon = anonKey.trim();
    if (anon.isNotEmpty) return anon;
    return publishable;
  }

  static bool get hasClientKey => clientKey.trim().isNotEmpty;
}
