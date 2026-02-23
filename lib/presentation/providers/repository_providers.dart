import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/kmy_repository.dart';
import '../../data/repositories/kmy_repository_impl.dart';

final kmyRepositoryProvider = Provider<KmyRepository>((ref) {
  return KmyRepositoryImpl();
});
