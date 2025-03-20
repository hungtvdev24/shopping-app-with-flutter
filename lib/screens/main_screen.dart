import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/bottom_nav_bar.dart';
import '../routes.dart';
import '../providers/category_provider.dart'; // Thêm CategoryProvider

// Các màn hình con

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
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Tải danh mục khi khởi tạo MainScreen
    Provider.of<CategoryProvider>(context, listen: false).loadCategories();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  final List<Widget> _screens = [
    const KeepAliveScreen(child: HomeScreen()),
    const KeepAliveScreen(child: FilterScreen()),
    const KeepAliveScreen(child: FeaturedProductsScreen()),
    const KeepAliveScreen(child: CartScreen()),
    const KeepAliveScreen(child: ProfileScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

/// Giữ màn hình con “sống” khi chuyển tab
class KeepAliveScreen extends StatefulWidget {
  final Widget child;
  const KeepAliveScreen({super.key, required this.child});

  @override
  State<KeepAliveScreen> createState() => _KeepAliveScreenState();
}

class _KeepAliveScreenState extends State<KeepAliveScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}