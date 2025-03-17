import 'package:flutter/material.dart';
// import 'package:provider/provider.dart'; // chỉ import nếu cần
import '../widgets/bottom_nav_bar.dart';
import '../routes.dart';

// Các màn hình con
import 'home/home_screen.dart';
import 'home/filter_screen.dart';
import 'home/featured_products_screen.dart';
import 'home/cart_screen.dart';
import 'home/profile_screen.dart';

// Nếu bạn dùng CartProvider trong initState, bạn có thể import ở đây
// import '../providers/cart_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  // Nếu bạn cần thao tác CartProvider, có thể làm ở initState
  @override
  void initState() {
    super.initState();
    // ví dụ:
    // Provider.of<CartProvider>(context, listen: false).addListener(_refreshCartIfActive);
  }

  @override
  void dispose() {
    // nếu đã addListener, cần removeListener
    // Provider.of<CartProvider>(context, listen: false).removeListener(_refreshCartIfActive);
    _pageController.dispose();
    super.dispose();
  }

  void _refreshCartIfActive() {
    if (_selectedIndex == 3) {
      setState(() {});
    }
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
    super.build(context); // quan trọng để AutomaticKeepAliveClientMixin hoạt động
    return widget.child;
  }
}
