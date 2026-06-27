import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/groq_service.dart';

const String _apiKeyKey = 'groq_api_key';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

final groqApiKeyProvider = StateProvider<String?>((ref) {
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  return prefsAsync.when(
    data: (prefs) => prefs.getString(_apiKeyKey),
    loading: () => null,
    error: (_, __) => null,
  );
});

final groqServiceProvider = Provider<GroqService?>((ref) {
  final apiKey = ref.watch(groqApiKeyProvider);
  if (apiKey == null || apiKey.isEmpty) return null;
  return GroqService(apiKey);
});

// A helper to save the API key
final groqApiHelperProvider = Provider((ref) {
  return GroqApiHelper(ref);
});

class GroqApiHelper {
  final Ref ref;

  GroqApiHelper(this.ref);

  Future<void> saveApiKey(String apiKey) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(_apiKeyKey, apiKey);
    ref.read(groqApiKeyProvider.notifier).state = apiKey;
  }

  Future<void> removeApiKey() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.remove(_apiKeyKey);
    ref.read(groqApiKeyProvider.notifier).state = null;
  }
}
