import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/udhar_entry.dart';
import '../../../data/providers/repositories_provider.dart';

final udharEntriesProvider = StreamProvider<List<UdharEntry>>((ref) {
  final repo = ref.watch(udharRepositoryProvider);
  if (repo == null) return const Stream.empty();
  return repo.watchUdharEntries();
});

final udharGaveProvider = Provider<double>((ref) {
  final entries = ref.watch(udharEntriesProvider).value ?? [];
  return entries.where((e) => e.iGave && !e.isSettled).fold(0.0, (sum, e) => sum + e.amount);
});

final udharTookProvider = Provider<double>((ref) {
  final entries = ref.watch(udharEntriesProvider).value ?? [];
  return entries.where((e) => !e.iGave && !e.isSettled).fold(0.0, (sum, e) => sum + e.amount);
});
