import 'package:get_it/get_it.dart';
import 'package:sm_ai_support/src/features/auth/cubit/auth_cubit.dart';
import 'package:sm_ai_support/src/support/cubit/single_session_cubit.dart';
import 'package:sm_ai_support/src/support/cubit/sm_support_cubit.dart';

Future<void> init(GetIt instance) async {
  // Register AuthCubit as a lazy singleton
  if (!instance.isRegistered<AuthCubit>()) {
    instance.registerLazySingleton(() => AuthCubit());
  }
  
  if (!instance.isRegistered<SMSupportCubit>()) {
    instance.registerCachedFactory(() => SMSupportCubit());
  }
  
  // SingleSessionCubit is registered as a factory since it requires sessionId parameter
  if (!instance.isRegistered<SingleSessionCubit>()) {
    instance.registerFactoryParam<SingleSessionCubit, String, void>(
      (sessionId, _) => SingleSessionCubit(sessionId: sessionId),
    );
  }
}
