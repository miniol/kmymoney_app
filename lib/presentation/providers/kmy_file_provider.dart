import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/kmy_repository.dart';
import 'repository_providers.dart';

class KmyFileNotifier extends AsyncNotifier<void> {
  late final KmyRepository _repository;

  @override
  Future<void> build() async {
    _repository = ref.read(kmyRepositoryProvider);
  }

  Future<void> loadFile(String path) async {
    state = const AsyncLoading();

    try {
      await _repository.loadFromPath(path);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final kmyFileProvider = AsyncNotifierProvider<KmyFileNotifier, void>(
  KmyFileNotifier.new,
);
