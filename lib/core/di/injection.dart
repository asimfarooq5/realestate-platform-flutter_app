import 'package:get_it/get_it.dart';
import 'package:malkiyat_app/core/services/location_service.dart';
import 'package:malkiyat_app/data/datasources/remote/api_client.dart';
import 'package:malkiyat_app/data/repositories/auth_repository.dart';
import 'package:malkiyat_app/data/repositories/property_repository.dart';
import 'package:malkiyat_app/data/services/token_storage.dart';
import 'package:malkiyat_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:malkiyat_app/presentation/blocs/property/property_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton(() => ApiClient());
  sl.registerLazySingleton(() => TokenStorage());
  sl.registerLazySingleton(() => LocationService());

  // Repositories
  sl.registerLazySingleton(() => AuthRepository(sl(), sl()));
  sl.registerLazySingleton(() => PropertyRepository(sl()));

  // BLoCs
  sl.registerFactory(() => AuthBloc(sl()));
  sl.registerFactory(() => PropertyBloc(sl()));
}
