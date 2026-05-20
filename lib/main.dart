import 'package:ecommerce_app/core/services/notification_service.dart';
import 'package:ecommerce_app/core/storage/token_storage.dart';
import 'package:ecommerce_app/features/address/data/repositories/address_repository_impl.dart';
import 'package:ecommerce_app/features/address/data/sources/address_remote_data_source.dart';
import 'package:ecommerce_app/features/address/presentation/bloc/address_cubit.dart';
import 'package:ecommerce_app/features/app_start/presentation/app_start_screen.dart';
import 'package:ecommerce_app/features/app_start/presentation/bloc/app_start_cubit.dart';
import 'package:ecommerce_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ecommerce_app/features/auth/data/sources/auth_api_service.dart';
import 'package:ecommerce_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:ecommerce_app/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:ecommerce_app/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:ecommerce_app/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:ecommerce_app/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:ecommerce_app/features/categories/data/datasources/categories_remote_data_source.dart';
import 'package:ecommerce_app/features/categories/data/repositories/categories_repository_impl.dart';
import 'package:ecommerce_app/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:ecommerce_app/features/categories/presentation/bloc/categories_cubit.dart';
import 'package:ecommerce_app/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:ecommerce_app/features/cart/data/sources/cart_api_service.dart';
import 'package:ecommerce_app/features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:ecommerce_app/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:ecommerce_app/features/cart/presentation/bloc/cart_cubit.dart';
import 'package:ecommerce_app/features/home/data/repositories/recommendation_repository_impl.dart';
import 'package:ecommerce_app/features/home/data/sources/recommendation_api_service.dart';
import 'package:ecommerce_app/features/home/domain/usecases/get_recommendations_usecase.dart';
import 'package:ecommerce_app/features/home/presentation/bloc/home_cubit.dart';
import 'package:ecommerce_app/features/home/presentation/bloc/recommendation_cubit.dart';
import 'package:ecommerce_app/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:ecommerce_app/features/notifications/data/sources/notification_api_service.dart';
import 'package:ecommerce_app/features/notifications/presentation/bloc/notification_cubit.dart';
import 'package:ecommerce_app/features/profile/data/repositories/user_repository_impl.dart';
import 'package:ecommerce_app/features/profile/data/sources/user_api_service.dart';
import 'package:ecommerce_app/features/profile/domain/usecases/get_user.dart';
import 'package:ecommerce_app/features/profile/domain/usecases/update_user.dart';
import 'package:ecommerce_app/features/profile/presentation/bloc/user_cubit.dart';
import 'package:ecommerce_app/features/product/data/repositories/product_repository_impl.dart';
import 'package:ecommerce_app/features/product/domain/usecases/get_latest_products.dart';
import 'package:ecommerce_app/features/product/domain/usecases/get_top_selling_products.dart';
import 'package:ecommerce_app/features/theme/presentation/bloc/theme_cubit.dart';
import 'package:ecommerce_app/features/theme/presentation/bloc/theme_state.dart';
import 'package:ecommerce_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';

/// Background notification handler must live at the top level.
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Handling a background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  final navigatorKey = GlobalKey<NavigatorState>();
  final tokenStorage = TokenStorage();
  final notificationService = NotificationService(
    navigatorKey: navigatorKey,
    tokenStorage: tokenStorage,
  );

  runApp(
    MyApp(
      navigatorKey: navigatorKey,
      tokenStorage: tokenStorage,
      notificationService: notificationService,
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.navigatorKey,
    required this.tokenStorage,
    required this.notificationService,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final TokenStorage tokenStorage;
  final NotificationService notificationService;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Initialize FCM after the first frame so the navigator is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.notificationService.init();
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final authApiService = AuthApiService(
      tokenStorage: widget.tokenStorage,
      notificationService: widget.notificationService,
    );
    final authRepository = AuthRepositoryImpl(authApiService);
    final cartApiService = CartApiService(tokenStorage: widget.tokenStorage);
    final cartRepository = CartRepositoryImpl(apiService: cartApiService);
    final notificationRepository = NotificationRepositoryImpl(
      apiService: NotificationApiService(tokenStorage: widget.tokenStorage),
    );
    //final productApiService = ProductApiService();
    //final productRepository = ProductRepositoryImpl(productApiService);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AppStartCubit(
            authRepository: authRepository,
            tokenStorage: widget.tokenStorage,
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
          create: (_) => CartCubit(
            getCartUseCase: GetCartUseCase(repository: cartRepository),
            addToCartUseCase: AddToCartUseCase(repository: cartRepository),
            repository: cartRepository,
          ),
        ),
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
            getLatestProducts: GetLatestProducts(ProductRepositoryImpl()),
          ),
        ),
        BlocProvider(
          create: (_) => RecommendationCubit(
            getRecommendationsUseCase: GetRecommendationsUseCase(
              repository: RecommendationRepositoryImpl(
                apiService: RecommendationApiService(
                  tokenStorage: widget.tokenStorage,
                ),
              ),
            ),
          ),
        ),
        BlocProvider(
          create: (_) => UserCubit(
            getUserUseCase: GetUserUseCase(
              UserRepositoryImpl(UserApiService()),
            ),
            updateUserUseCase: UpdateUserUseCase(
              UserRepositoryImpl(UserApiService()),
            ),
          ),
        ),
        BlocProvider(
          create: (_) => AddressCubit(
            repository: AddressRepositoryImpl(
              remoteDataSource: AddressRemoteDataSource(
                tokenStorage: widget.tokenStorage,
              ),
            ),
          ),
        ),
        BlocProvider(
          create: (_) => NotificationCubit(
            repository: notificationRepository,
            tokenStorage: widget.tokenStorage,
          )..refreshUnreadForCurrentUser(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'KIDS STORE',
            debugShowCheckedModeBanner: false,
            navigatorKey: widget.navigatorKey,
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
