import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import các provider
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/user_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/address_provider.dart';
import 'providers/checkout_provider.dart';
import 'providers/myorder_provider.dart';
// Import file routes
import 'routes.dart';

// Khai báo routeObserver nếu cần
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => ProductProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => AddressProvider()),
        ChangeNotifierProvider(create: (context) => CheckoutProvider()),
        // Nếu bạn có MyOrderProvider, cũng đăng ký tại đây
        ChangeNotifierProvider(create: (context) => MyOrderProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ứng dụng bán hàng',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: AppRoutes.splash, // Hoặc route bạn muốn
      routes: appRoutes, // Map các route
      navigatorObservers: [
        routeObserver,
      ],
    );
  }
}
