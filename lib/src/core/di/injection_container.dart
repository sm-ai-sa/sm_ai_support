import 'package:get_it/get_it.dart';
import 'bloc_injector.dart' as bloc;
import 'core_injector.dart' as core;
import 'use_case_injector.dart' as use_case;
import 'repo_injector.dart' as repo;

final GetIt sl = GetIt.instance;

Future<void> initSL() async {
  await bloc.init(sl);
  await core.init(sl);
  await use_case.init(sl);
  await repo.init(sl);
}
