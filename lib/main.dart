import 'package:ecommerce_app/features/categories/presentation/bloc/categories_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'features/app_start/presentation/app_start_screen.dart';
import 'features/app_start/presentation/bloc/app_start_cubit.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/home/presentation/pages/home_screen.dart';
import 'features/product/presentation/bloc/product_cubit.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'features/theme/presentation/bloc/theme_cubit.dart';
import 'features/theme/presentation/bloc/theme_state.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AppStartCubit()),
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => CategoriesCubit()),
        BlocProvider(create: (_) => ProductCubit())
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: "Flutter",
            debugShowCheckedModeBanner: false,
            theme: AppThemes.light,
            darkTheme: AppThemes.dark,
            themeMode: themeState.themeMode,
            //home: const AppStartScreen(),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
