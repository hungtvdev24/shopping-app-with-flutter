import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // ✅ Màu nền dịu nhẹ

      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 10),
            _buildVoucherSection(),
            const SizedBox(height: 10),
            _buildProfileOptions(context),
            const SizedBox(height: 10),
            _buildHistorySection(),
            const SizedBox(height: 10),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  // ✅ Header tài khoản
  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage("assets/avatar.png"), // ✅ Avatar mẫu
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Trần Văn Hùng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("hungtran@gmail.com", style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ Mục voucher giảm giá
  Widget _buildVoucherSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orangeAccent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("🎉 Bạn có 3 voucher!", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.orange),
            onPressed: () {}, // TODO: Chuyển đến trang voucher
            child: const Text("Xem ngay"),
          ),
        ],
      ),
    );
  }

  // ✅ Các tùy chọn trong tài khoản
  Widget _buildProfileOptions(BuildContext context) {
    return Column(
      children: [
        _buildProfileOption(Icons.shopping_bag, "Đơn hàng của tôi", () {}),
        _buildProfileOption(Icons.favorite, "Sản phẩm yêu thích", () {}),
        _buildProfileOption(Icons.location_on, "Địa chỉ giao hàng", () {}),
        _buildProfileOption(Icons.payment, "Phương thức thanh toán", () {}),
        _buildProfileOption(Icons.settings, "Cài đặt", () {}),
      ],
    );
  }

  // ✅ Widget hiển thị một tùy chọn
  Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // ✅ Mục lịch sử xem sản phẩm
  Widget _buildHistorySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Lịch sử xem gần đây", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildHistoryList(),
        ],
      ),
    );
  }

  // ✅ Danh sách lịch sử xem (Ảnh mẫu)
  Widget _buildHistoryList() {
    List<Map<String, String>> historyItems = [
      {"image": "assets/anh1.png", "name": "Áo sơ mi nam trắng"},
      {"image": "assets/anh2.png", "name": "Áo thun nam cổ tròn"},
      {"image": "assets/anh3.png", "name": "Áo hoodie basic"},
      {"image": "assets/anh4.png", "name": "Quần jeans nam cao cấp"},
    ];

    return Column(
      children: historyItems.map((item) {
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(item["image"]!, width: 50, height: 50, fit: BoxFit.cover),
          ),
          title: Text(item["name"]!),
          trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
          onTap: () {},
        );
      }).toList(),
    );
  }

  // ✅ Nút đăng xuất
  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {}, // TODO: Thêm chức năng đăng xuất
        child: const Text("Đăng xuất", style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }
}
