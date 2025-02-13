import 'package:flutter/material.dart';

class FilterScreen extends StatelessWidget {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lọc sản phẩm")),
      body: const Center(child: Text("Đây là màn hình Lọc sản phẩm")),
    );
  }
}
