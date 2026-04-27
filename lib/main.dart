import 'package:ecommerce_app/core/storage/token_storage.dart';
import 'package:ecommerce_app/features/categories/presentation/bloc/categories_cubit.dart';
import 'package:ecommerce_app/features/home/data/repositories/recommendation_repository_impl.dart';
import 'package:ecommerce_app/features/home/data/sources/recommendation_api_service.dart';
import 'package:ecommerce_app/features/home/domain/usecases/get_recommendations_usecase.dart';
import 'package:ecommerce_app/features/home/presentation/bloc/home_cubit.dart';
import 'package:ecommerce_app/features/home/presentation/bloc/recommendation_cubit.dart';
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
import 'features/main/presentation/pages/main_screen.dart';
import 'features/product/data/repositories/product_repository_impl.dart';
import 'features/product/domain/usecases/get_top_selling_products.dart';
import 'features/address/data/repositories/address_repository_impl.dart';
import 'features/address/data/sources/address_remote_data_source.dart';
import 'features/address/presentation/bloc/address_cubit.dart';
import 'features/profile/data/repositories/user_repository_impl.dart';
import 'features/profile/data/sources/user_api_service.dart';
import 'features/profile/domain/usecases/get_user.dart';
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
        BlocProvider(
          create: (_) => AppStartCubit(
            authRepository: authRepository,
            tokenStorage: tokenStorage,
          ),
        ),
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
          create: (_) => HomeCubit(
            getTopSellingProducts: GetTopSellingProducts(
              ProductRepositoryImpl(),
            ),
          ),
        ),
        BlocProvider(
          create: (_) => RecommendationCubit(
            getRecommendationsUseCase: GetRecommendationsUseCase(
              repository: RecommendationRepositoryImpl(
                apiService: RecommendationApiService(
                  tokenStorage: tokenStorage,
                ),
              ),
            ),
          ),
        ),
        BlocProvider(
          create: (_) =>
              UserCubit(GetUserUseCase(UserRepositoryImpl(UserApiService()))),
        ),
        BlocProvider(
          create: (_) => AddressCubit(
            repository: AddressRepositoryImpl(
              remoteDataSource: AddressRemoteDataSource(
                tokenStorage: tokenStorage,
              ),
            ),
          ),
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
