import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/splash/slide_screen.dart';
import 'screens/main_screen.dart';
import 'screens/profile/address_list_screen.dart'; // Đã có import này
import 'screens/product/search_screen.dart';
import 'screens/product/notification_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String slide = '/slide';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otp = '/otp';
  static const String home = '/main'; // Trang chủ với Bottom Navigation Bar
  static const String addressList = '/address-list'; // Thêm hằng số này
  static const String search = '/search';
  static const String notification = '/notification';
  // Thêm route riêng cho HomeScreen nếu cần (tùy chọn)
  static const String homeDetail = '/home-detail';
}

Map<String, WidgetBuilder> appRoutes = {
  AppRoutes.splash: (context) => const SplashScreen(),
  AppRoutes.slide: (context) => const SlideScreen(),
  AppRoutes.login: (context) => const LoginScreen(),
  AppRoutes.register: (context) => const RegisterScreen(),
  AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
  AppRoutes.otp: (context) => const OtpScreen(),
  AppRoutes.home: (context) => const MainScreen(), // Dùng MainScreen chứa Bottom Navigation Bar
  AppRoutes.addressList: (context) => const AddressListScreen(), // Thêm ánh xạ này
  AppRoutes.search: (context) => const SearchScreen(),
  AppRoutes.notification: (context) => const NotificationScreen(),
  // Thêm route cho HomeScreen nếu cần (tùy chọn)
  // AppRoutes.homeDetail: (context) => const HomeScreen(),
};