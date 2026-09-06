import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';
import 'package:malkiyat_app/data/datasources/remote/api_client.dart';
import 'package:malkiyat_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:malkiyat_app/presentation/blocs/property/property_bloc.dart';
import 'package:malkiyat_app/presentation/screens/splash_screen.dart';
import 'package:malkiyat_app/core/di/injection.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = di.sl<AuthBloc>();
    // A 401 anywhere in the app means the session is no longer valid
    // (expired token, deactivated account) — force a sign-out so every
    // screen's existing Unauthenticated handling takes over, instead of
    // leaving screens stuck showing a raw request-failure error.
    di.sl<ApiClient>().onUnauthorized = () => authBloc.add(LogoutRequested());

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => authBloc),
        BlocProvider(create: (_) => di.sl<PropertyBloc>()),
      ],
      child: MaterialApp(
        title: 'Malkiyat',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const SplashScreen(),
      ),
    );
  }
}
