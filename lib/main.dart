import 'package:ecommerce_app/core/storage/token_storage.dart';
import 'package:ecommerce_app/features/categories/presentation/bloc/categories_cubit.dart';
import 'package:ecommerce_app/features/profile/presentation/bloc/user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'features/app_start/presentation/app_start_screen.dart';
import 'features/app_start/presentation/bloc/app_start_cubit.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/data/sources/auth_api_service.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/refresh_token_usecase.dart';
import 'features/auth/domain/usecases/sign_in_usecase.dart';
import 'features/auth/domain/usecases/sign_up_usecase.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/categories/data/datasources/categories_remote_data_source.dart';
import 'features/categories/data/repositories/categories_repository_impl.dart';
import 'features/categories/domain/usecases/get_categories_usecase.dart';
import 'features/home/presentation/pages/home_screen.dart';
import 'features/main/presentation/pages/main_screen.dart';
import 'features/product/data/sources/product_api_service.dart';
import 'features/product/data/repositories/product_repository_impl.dart';
import 'features/product/domain/usecases/get_top_selling_products.dart';
import 'features/product/presentation/bloc/product_cubit.dart';
import 'features/profile/data/repositories/user_repository_impl.dart';
import 'features/profile/data/sources/user_api_service.dart';
import 'features/profile/domain/usecases/get_user.dart';
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
    final tokenStorage = TokenStorage();
    final authApiService = AuthApiService(tokenStorage: tokenStorage);
    final authRepository = AuthRepositoryImpl(authApiService);
    //final productApiService = ProductApiService();
    //final productRepository = ProductRepositoryImpl(productApiService);
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AppStartCubit()),
        BlocProvider(
          create: (_) => AuthCubit(
            signUpUseCase: SignUpUseCase(authRepository),
            signInUseCase: SignInUseCase(authRepository),
            logoutUseCase: LogoutUseCase(authRepository),
            refreshTokenUseCase: RefreshTokenUseCase(authRepository),
          ),
        ),
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(
          create: (_) => CategoriesCubit(
            GetCategoriesUseCase(
              CategoriesRepositoryImpl(CategoriesRemoteDataSourceImpl()),
            ),
          ),
        ),
        BlocProvider(
          create: (_) =>
              ProductCubit(GetTopSellingProducts(ProductRepositoryImpl())),
        ),
        BlocProvider(
          create: (_) =>
              UserCubit(GetUserUseCase(UserRepositoryImpl(UserApiService()))),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: "Flutter",
            debugShowCheckedModeBanner: false,
            theme: AppThemes.light,
            darkTheme: AppThemes.dark,
            themeMode: themeState.themeMode,
            home: const AppStartScreen(),
            //home: const MainScreen(),
          );
        },
      ),
    );
  }
}
