import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Danh sách ảnh slide
    final List<String> imagePaths = [
      'assets/images/anh1.png',
      'assets/images/anh2.png',
      'assets/images/anh3.png',
      'assets/images/anh4.png',
    ];

    // Danh sách sản phẩm
    final List<Map<String, dynamic>> products = [
      {
        'image': 'assets/images/anh1.png',
        'brand': 'LIPSY LONDON',
        'name': 'Áo sơ mi xanh lá',
        'price': 390.000,
        'oldPrice': 650.000,
        'discount': 40,
      },
      {
        'image': 'assets/images/anh2.png',
        'brand': 'ZARA',
        'name': 'Áo sơ mi cổ điển',
        'price': 299.000,
        'oldPrice': 500.000,
        'discount': 35,
      },
      {
        'image': 'assets/images/anh3.png',
        'brand': 'H&M',
        'name': 'Áo khoác jean',
        'price': 180.000,
        'oldPrice': 300.000,
        'discount': 40,
      },
      {
        'image': 'assets/images/anh4.png',
        'brand': 'GUCCI',
        'name': 'Túi xách cao cấp',
        'price': 750.000,
        'oldPrice': 1.000000,
        'discount': 25,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSlider(imagePaths, height: 220),
            const SizedBox(height: 15),
            _buildCategorySection(),
            const SizedBox(height: 20),
            _buildProductSection("Sản phẩm phổ biến", products),
            const SizedBox(height: 20),
            _buildProductSection("Giảm giá sốc", products),
            const SizedBox(height: 20),
            _buildImageSlider(imagePaths, height: 150),
            const SizedBox(height: 10),
            _buildImageSlider(imagePaths.reversed.toList(), height: 150),
            const SizedBox(height: 20),
            _buildProductSection("Bán chạy nhất", products),
            const SizedBox(height: 20),
            _buildProductSection("Có thể bạn thích", products),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSlider(List<String> imagePaths, {required double height}) {
    return SizedBox(
      height: height,
      child: PageView(
        children: imagePaths.map((path) => ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(path, fit: BoxFit.cover),
        )).toList(),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Danh mục sản phẩm", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _categoryButton("Sale", Colors.purple, Colors.white),
              _categoryButton("Nữ", Colors.white, Colors.black),
              _categoryButton("Nam", Colors.white, Colors.black),
              _categoryButton("Trẻ em", Colors.white, Colors.black),
            ],
          ),
        ],
      ),
    );
  }

  Widget _categoryButton(String title, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(title, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildProductSection(String title, List<Map<String, dynamic>> products) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SizedBox(
            height: 230,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              itemBuilder: (context, index) {
                return _buildProductCard(products[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                child: Image.asset(product['image'], height: 120, width: double.infinity, fit: BoxFit.cover),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                  child: Text("${product['discount']}% Giảm", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['brand'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(product['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text("${product['price']}đ", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                    const SizedBox(width: 6),
                    Text("${product['oldPrice']}đ", style: const TextStyle(fontSize: 14, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
