import 'package:flutter/material.dart';

class FilterScreen extends StatelessWidget {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Nền trắng đồng bộ
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ô tìm kiếm
            _buildSearchBar(),

            const SizedBox(height: 10),

            // Tiêu đề
            const Text(
              "Danh mục sản phẩm",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // Danh sách danh mục
            Expanded(
              child: ListView(
                children: [
                  _buildCategoryTile("🔖 Đang giảm giá", [
                    "👕 Tất cả quần áo",
                    "🆕 Hàng mới về",
                    "🧥 Áo khoác & Áo vest",
                    "👗 Váy đầm",
                    "👖 Quần jean"
                  ]),

                  _buildCategoryTile("🧍 Thời trang Nam & Nữ", [
                    "👚 Áo thun",
                    "👔 Áo sơ mi",
                    "👖 Quần dài",
                    "👟 Giày dép",
                    "👜 Phụ kiện"
                  ]),

                  _buildCategoryTile("👶 Thời trang trẻ em", [
                    "👕 Quần áo bé trai",
                    "👗 Quần áo bé gái",
                    "👟 Giày trẻ em",
                    "🧸 Đồ chơi",
                    "🎒 Ba lô & Túi xách"
                  ]),

                  _buildCategoryTile("🛍️ Phụ kiện thời trang", [
                    "⌚ Đồng hồ",
                    "👜 Túi xách",
                    "🕶️ Kính mắt",
                    "🧢 Mũ & Nón",
                    "💍 Trang sức"
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget ô tìm kiếm
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Tìm kiếm...",
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey.shade500),
              ),
            ),
          ),
          const Icon(Icons.filter_list, color: Colors.grey),
        ],
      ),
    );
  }

  // Widget danh mục sản phẩm
  Widget _buildCategoryTile(String title, List<String> subcategories) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2, // Hiệu ứng đổ bóng nhẹ
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        children: subcategories
            .map((subcategory) => ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 32),
          title: Text(subcategory, style: const TextStyle(fontSize: 16)),
        ))
            .toList(),
      ),
    );
  }
}
