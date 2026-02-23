import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../domain/repositories/kmy_repository.dart';
import 'repository_providers.dart';

class KmyFileNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // No initialization needed here
  }

  Future<void> loadFile(String path) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(kmyRepositoryProvider);

      await repository.loadFromPath(path);

      state = const AsyncData(null);
    } catch (e, st) {
      // print('ERROR: $e');
      // print(st);
      state = AsyncError(e, st);
    }
  }
}

final kmyFileProvider = AsyncNotifierProvider<KmyFileNotifier, void>(
  KmyFileNotifier.new,
);
