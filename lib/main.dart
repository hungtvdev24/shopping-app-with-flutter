import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart'; // Đã có
import 'providers/user_provider.dart'; // Thêm UserProvider nếu cần
import 'routes.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()), // Cung cấp AuthProvider
        ChangeNotifierProvider(create: (context) => ProductProvider()), // Cung cấp ProductProvider
        ChangeNotifierProvider(create: (context) => UserProvider()), // Cung cấp UserProvider (thêm mới)
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
      initialRoute: AppRoutes.splash, // Màn hình khởi động
      routes: appRoutes, // Sử dụng map routes đã định nghĩa
    );
  }
}