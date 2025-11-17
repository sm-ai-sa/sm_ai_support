import 'package:get_it/get_it.dart';
import 'package:sm_ai_support/src/features/auth/data/auth_repo.dart';
import 'package:sm_ai_support/src/features/support/data/support_repo.dart';

Future<void> init(GetIt instance) async {
  // Register AuthRepo as a lazy singleton
  if (!instance.isRegistered<AuthRepo>()) {
    instance.registerLazySingleton(() => AuthRepo());
  }
  
  if (!instance.isRegistered<SupportRepo>()) {
    instance.registerLazySingleton(() => SupportRepo());
  }
}
