// import 'package:ecommerce_app/features/splash/presentation/splash_state.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// class SplashCubit extends Cubit<SplashState>{
//   SplashCubit() : super(SplashInitial());
//
//   Future<void> checkLogin() async{
//     emit(SplashLoading());
//     await Future.delayed(const Duration(seconds: 2));
//     //kiểm tra login
//     final bool isAuthenticated = false;
//     if(isAuthenticated){
//       emit(SplashAuthenticated());
//     }else{
//       emit(SplashUnAuthenticated());
//     }
//   }
// }