import 'package:flutter/material.dart';

class FeaturedProductsScreen extends StatelessWidget {
  const FeaturedProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sản phẩm nổi bật")),
      body: const Center(child: Text("Đây là màn hình Sản phẩm nổi bật")),
    );
  }
}
