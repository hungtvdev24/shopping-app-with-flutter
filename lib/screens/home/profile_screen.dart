import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading) {
          // Màn hình chờ load
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (userProvider.errorMessage != null || userProvider.userData == null) {
          // Màn hình lỗi
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
                    // Xử lý errorMessage dưới dạng Map
                    userProvider.errorMessage?['general']?.toString() ??
                        "Không thể tải thông tin người dùng",
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
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

        // Nếu không lỗi, không loading => đã có userData
        final userData = userProvider.userData!;

        return Scaffold(
          backgroundColor: Colors.grey[100],
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 1) Header
                  _buildProfileHeader(context, userData),

                  // 2) Thẻ "Starter Plan"
                  _buildPlanCard(),

                  // 3) Voucher
                  _buildVoucherSection(),

                  // 4) Tiêu đề "Tài khoản"
                  _buildSectionTitle("Tài khoản"),

                  // 5) Danh sách chức năng
                  _buildProfileOptions(context),

                  // 6) Lịch sử xem
                  _buildHistorySection(),

                  const SizedBox(height: 20),

                  // 7) Đăng xuất
                  _buildLogoutButton(context, userProvider),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --------------------------------------------------------------------------
  // 1) HEADER
  // --------------------------------------------------------------------------
  Widget _buildProfileHeader(BuildContext context, Map<String, dynamic> userData) {
    final String userName = userData['name']?.toString() ?? "Người dùng";
    final String userEmail = userData['email']?.toString() ?? "email@unknown.com";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: SizedBox(
              width: 64,
              height: 64,
              child: Image.asset(
                "assets/avatar.png",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  alignment: Alignment.center,
                  child: const Icon(Icons.person, size: 40, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Tên, email (có thể bấm để chỉnh sửa)
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Khi bấm vào tên, chuyển hướng sang màn hình chỉnh sửa
                Navigator.pushNamed(context, AppRoutes.editProfile);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hi, $userName",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Xóa nút chỉnh sửa (biểu tượng bút)
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 2) PLAN CARD
  // --------------------------------------------------------------------------
  Widget _buildPlanCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7F00FF), Color(0xFFAE52BB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Thông tin Plan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Starter Plan",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "All features unlocked!",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // Logic nâng cấp gói
                  },
                  child: const Text("Upgrade"),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Ảnh minh họa
          Image.asset(
            "assets/upgrade_illustration.png",
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 50,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 3) VOUCHER SECTION
  // --------------------------------------------------------------------------
  Widget _buildVoucherSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orangeAccent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {},
            child: const Text("Xem ngay"),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 4) TIÊU ĐỀ PHẦN "TÀI KHOẢN"
  // --------------------------------------------------------------------------
  Widget _buildSectionTitle(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 5) DANH SÁCH CHỨC NĂNG
  // --------------------------------------------------------------------------
  Widget _buildProfileOptions(BuildContext context) {
    return Column(
      children: [
        _buildProfileOption(
          Icons.shopping_bag,
          "Đơn hàng của tôi",
              () {
            // Khi bấm => sang MyOrdersScreen
            Navigator.pushNamed(context, AppRoutes.order);
          },
        ),
        _buildProfileOption(
          Icons.autorenew,
          "Trả hàng (Returns)",
              () {
            // Mở trang trả hàng
          },
        ),
        _buildProfileOption(
          Icons.favorite,
          "Sản phẩm yêu thích",
              () {
            // Mở danh sách yêu thích
          },
        ),
        _buildProfileOption(
          Icons.location_on,
          "Địa chỉ giao hàng",
              () {
            Navigator.pushNamed(context, AppRoutes.addressList);
          },
        ),
        _buildProfileOption(
          Icons.payment,
          "Phương thức thanh toán",
              () {
            // Mở cài đặt thanh toán
          },
        ),
        _buildProfileOption(
          Icons.settings,
          "Cài đặt",
              () {
            // Mở trang cài đặt
          },
        ),
      ],
    );
  }

  Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title, style: const TextStyle(fontSize: 15)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 6) LỊCH SỬ XEM GẦN ĐÂY
  // --------------------------------------------------------------------------
  Widget _buildHistorySection() {
    final List<Map<String, String>> historyItems = [
      {"image": "assets/anh1.png", "name": "Áo sơ mi nam trắng"},
      {"image": "assets/anh2.png", "name": "Áo thun nam cổ tròn"},
      {"image": "assets/anh3.png", "name": "Áo hoodie basic"},
      {"image": "assets/anh4.png", "name": "Quần jeans nam cao cấp"},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Lịch sử xem gần đây",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Column(
            children: historyItems.map((item) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
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
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: () {
                  // Mở chi tiết sản phẩm đã xem
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 7) NÚT ĐĂNG XUẤT
  // --------------------------------------------------------------------------
  Widget _buildLogoutButton(BuildContext context, UserProvider userProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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