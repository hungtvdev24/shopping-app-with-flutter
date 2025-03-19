import 'package:flutter/material.dart';

// Các màn hình
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/splash/slide_screen.dart';
import 'screens/main_screen.dart';
import 'screens/profile/address_list_screen.dart';
import 'screens/profile/edit_profile_screen.dart'; // Đã import đúng
import 'screens/product/search_screen.dart';
import 'screens/product/notification_screen.dart';

// Màn hình đơn hàng (MyOrdersScreen)
import 'screens/order/order_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String slide = '/slide';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otp = '/otp';
  static const String home = '/main';
  static const String addressList = '/address-list';
  static const String editProfile = '/edit-profile'; // Thêm route cho EditProfileScreen
  static const String order = '/order-list';
  static const String search = '/search';
  static const String notification = '/notification';
// Nếu cần route chi tiết order => '/order-detail', ...
}

Map<String, WidgetBuilder> appRoutes = {
  AppRoutes.splash: (context) => const SplashScreen(),
  AppRoutes.slide: (context) => const SlideScreen(),
  AppRoutes.login: (context) => const LoginScreen(),
  AppRoutes.register: (context) => const RegisterScreen(),
  AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
  AppRoutes.otp: (context) => const OtpScreen(),
  AppRoutes.home: (context) => const MainScreen(),
  AppRoutes.addressList: (context) => const AddressListScreen(),
  AppRoutes.editProfile: (context) => const EditProfileScreen(), // Thêm route cho EditProfileScreen
  AppRoutes.search: (context) => const SearchScreen(),
  AppRoutes.notification: (context) => const NotificationScreen(),
  // Màn hình xem đơn hàng của tôi
  AppRoutes.order: (context) => const MyOrdersScreen(),
};