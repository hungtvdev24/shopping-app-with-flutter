import 'package:flutter/material.dart';

class FeaturedProductsScreen extends StatelessWidget {
  const FeaturedProductsScreen({super.key});

  final List<Map<String, dynamic>> featuredProducts = const [
    {
      "image": "assets/images/anh1.png",
      "name": "[SPICANIST] Quần suông ống lật - Sublime Pants",
      "price": 950000,
      "voucher": true,
      "guarantee": true,
    },
    {
      "image": "assets/images/anh2.png",
      "name": "Chân váy ngắn chân váy đính nơ xếp ly dễ phối đồ",
      "price": 290000,
      "voucher": false,
      "guarantee": true,
    },
    {
      "image": "assets/images/anh3.png",
      "name": "Áo Dài Hồng Gấm Thêu Cao Cấp Hồng Môn",
      "price": 1198000,
      "voucher": true,
      "guarantee": true,
    },
    {
      "image": "assets/images/anh4.png",
      "name": "Áo Xelo Intention Slim Fit Zip Jacket Icing Mint",
      "price": 1699000,
      "voucher": true,
      "guarantee": false,
    },
    {
      "image": "assets/images/anh1.png",
      "name": "Bộ đồ thể thao cao cấp màu đen",
      "price": 850000,
      "voucher": true,
      "guarantee": true,
    },
    {
      "image": "assets/images/anh2.png",
      "name": "Váy công sở thanh lịch màu pastel",
      "price": 1320000,
      "voucher": false,
      "guarantee": true,
    },
    {
      "image": "assets/images/anh3.png",
      "name": "Áo sơ mi trắng cổ điển thanh lịch",
      "price": 720000,
      "voucher": true,
      "guarantee": false,
    },
    {
      "image": "assets/images/anh4.png",
      "name": "Set đồ dạo phố nữ phong cách Hàn Quốc",
      "price": 950000,
      "voucher": false,
      "guarantee": true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: featuredProducts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) {
            final product = featuredProducts[index];
            return _buildProductCard(product);
          },
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.asset(
                  product["image"]!,
                  width: double.infinity,
                  height: 140,
                  fit: BoxFit.cover,
                ),
              ),
              // Icon yêu thích (tim)
              Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.favorite_border, color: Colors.black54, size: 24),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Giá sản phẩm
                Text(
                  "${product["price"]!.toStringAsFixed(0)} ₫",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 4),
                // Tag Voucher & Đảm bảo
                Row(
                  children: [
                    if (product["voucher"] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "Voucher",
                          style: TextStyle(fontSize: 10, color: Colors.purple, fontWeight: FontWeight.bold),
                        ),
                      ),
                    if (product["guarantee"] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "Đảm bảo",
                          style: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                // Tên sản phẩm
                Text(
                  product["name"]!,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
