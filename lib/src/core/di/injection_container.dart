import 'package:get_it/get_it.dart';
import 'bloc_injector.dart' as bloc;
import 'core_injector.dart' as core;
import 'use_case_injector.dart' as use_case;
import 'repo_injector.dart' as repo;

/// Isolated GetIt instance for SM Support package
/// This prevents conflicts with the parent app's GetIt instance
final GetIt sl = GetIt.asNewInstance();

bool _isInitialized = false;

Future<void> initSL() async {
  // Prevent re-initialization if already initialized
  if (_isInitialized) {
    return;
  }

  await bloc.init(sl);
  await core.init(sl);
  await use_case.init(sl);
  await repo.init(sl);

  _isInitialized = true;
}

/// Reset the service locator (useful for testing or re-initialization)
Future<void> resetSL() async {
  if (_isInitialized) {
    await sl.reset();
    _isInitialized = false;
  }
}
