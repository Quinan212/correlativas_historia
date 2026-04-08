import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/config/feature_flags.dart';
import '../../../shared/supabase/supabase.dart';
import '../data/situated_assistant_repository.dart';

final situatedAssistantRepositoryProvider =
    Provider<SituatedAssistantRepository>(
  (ref) => const SituatedAssistantRepository(),
);

final situatedAssistantReadyProvider = Provider<bool>((ref) {
  if (!FeatureFlags.situatedAssistantEnabled) return false;
  return ref.watch(supabaseClientProvider) != null;
});
