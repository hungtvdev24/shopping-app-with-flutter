import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../routes.dart';
import 'home/home_screen.dart';
import 'home/filter_screen.dart';
import 'home/featured_products_screen.dart';
import 'home/cart_screen.dart';
import 'home/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController(); // ✅ Điều khiển chuyển trang

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index); // ✅ Chuyển trang mà không reset dữ liệu
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ Đồng bộ màu nền
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "BeeStyle",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cursive',
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black, size: 28),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.search);
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black, size: 28),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.notification);
              // Chức năng thông báo
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // ✅ Không cho vuốt ngang
        children: const [
          KeepAliveScreen(child: HomeScreen()),
          KeepAliveScreen(child: FilterScreen()),
          KeepAliveScreen(child: FeaturedProductsScreen()),
          KeepAliveScreen(child: CartScreen()),
          KeepAliveScreen(child: ProfileScreen()),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// ✅ Giữ trạng thái màn hình khi chuyển đổi tab
class KeepAliveScreen extends StatefulWidget {
  final Widget child;
  const KeepAliveScreen({super.key, required this.child});

  @override
  State<KeepAliveScreen> createState() => _KeepAliveScreenState();
}

class _KeepAliveScreenState extends State<KeepAliveScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // ✅ Giữ trạng thái màn hình

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
