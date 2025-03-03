import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (userProvider.errorMessage != null || userProvider.userData == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Hồ sơ của tôi"),
              centerTitle: true,
              backgroundColor: Colors.blueAccent,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    userProvider.errorMessage ?? "Không thể tải thông tin người dùng",
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => userProvider.fetchUserData(),
                    child: const Text("Thử lại"),
                  ),
                ],
              ),
            ),
          );
        }

        final userData = userProvider.userData!;

        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            title: const Text("Hồ sơ của tôi"),
            centerTitle: true,
            backgroundColor: Colors.blueAccent,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileHeader(userData),
                const SizedBox(height: 10),
                _buildVoucherSection(),
                const SizedBox(height: 10),
                _buildProfileOptions(context),
                const SizedBox(height: 10),
                _buildHistorySection(),
                const SizedBox(height: 20),
                _buildLogoutButton(context, userProvider),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> userData) {
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
            backgroundImage: AssetImage("assets/avatar.png"),
            child: Icon(Icons.person, size: 40, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userData['name'] ?? "Người dùng",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  userData['email'] ?? "email@unknown.com",
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  "Số điện thoại: ${userData['phone'] ?? 'Chưa cập nhật'}",
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  "Tuổi: ${userData['tuoi']?.toString() ?? 'Chưa cập nhật'}",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
          const Text(
            "🎉 Bạn có 3 voucher!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.orange,
            ),
            onPressed: () {},
            child: const Text("Xem ngay"),
          ),
        ],
      ),
    );
  }

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

  Widget _buildHistorySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Lịch sử xem gần đây",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildHistoryList(),
        ],
      ),
    );
  }

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
            child: Image.asset(
              item["image"]!,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
            ),
          ),
          title: Text(item["name"]!),
          trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
          onTap: () {},
        );
      }).toList(),
    );
  }

  Widget _buildLogoutButton(BuildContext context, UserProvider userProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          userProvider.logout(context);
        },
        child: const Text(
          "Đăng xuất",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}