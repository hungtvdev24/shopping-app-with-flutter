import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white, // ✅ Đồng bộ màu với MainScreen
      elevation: 0, // ✅ Xóa bóng để không lệch màu
      selectedItemColor: Colors.blue, // ✅ Màu icon được chọn
      unselectedItemColor: Colors.grey.shade600, // ✅ Màu icon chưa chọn
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold), // ✅ Làm nổi bật tab được chọn
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
        BottomNavigationBarItem(icon: Icon(Icons.filter_list), label: "Lọc"),
        BottomNavigationBarItem(icon: Icon(Icons.star), label: "Nổi bật"),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Giỏ hàng"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Cá nhân"),
      ],
    );
  }
}
