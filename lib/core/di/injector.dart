import 'package:field_operations_app/core/utils/services/local_auth/local_auth_service.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> inject() async {
  getIt.registerLazySingleton(() => LocalAuthServices());
}
