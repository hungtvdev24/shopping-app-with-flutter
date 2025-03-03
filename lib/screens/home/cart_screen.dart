import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../core/api/cart_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final formatCurrency = NumberFormat("#,###", "vi_VN");
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.token == null) {
      setState(() {
        isLoading = false;
        errorMessage = 'Vui lòng đăng nhập để xem giỏ hàng.';
      });
      return;
    }

    setState(() => isLoading = true);
    try {
      final response = await CartService.getCart(userProvider.token!);
      print('Cart response in CartScreen: $response');

      if (response['cart'] != null && response['cart']['muc_gio_hangs'] != null) {
        setState(() {
          cartItems = List<Map<String, dynamic>>.from(response['cart']['muc_gio_hangs'].map((item) {
            return {
              'id_mucGioHang': item['id_mucGioHang'],
              'id_sanPham': item['id_sanPham'],
              'soLuong': item['soLuong'],
              'gia': double.tryParse(item['gia'].toString()) ?? 0.0,
              'name': item['product']['tenSanPham'] ?? 'Không có tên',
              'image': item['product']['urlHinhAnh'] ?? 'http://10.0.3.2:8001/images/default.png',
              'selected': false,
            };
          }));
          print('Cart items: $cartItems');
          isLoading = false;
        });
      } else {
        setState(() {
          cartItems = [];
          isLoading = false;
          errorMessage = 'Giỏ hàng trống hoặc không có dữ liệu.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Lỗi khi tải giỏ hàng: $e';
        isLoading = false;
      });
    }
  }

  void _toggleSelect(int index) {
    setState(() {
      cartItems[index]['selected'] = !cartItems[index]['selected'];
    });
  }

  Future<void> _updateQuantity(int index, int change) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để cập nhật giỏ hàng!')),
      );
      return;
    }

    setState(() {
      if (cartItems[index]['soLuong'] + change > 0) {
        cartItems[index]['soLuong'] += change;
      }
    });

    try {
      // Gọi API để cập nhật số lượng trên server
      await CartService.updateCartItemQuantity(
        userProvider.token!,
        cartItems[index]['id_mucGioHang'],
        cartItems[index]['soLuong'],
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật số lượng thành công!')),
      );
    } catch (e) {
      // Nếu lỗi, khôi phục số lượng cũ
      setState(() {
        cartItems[index]['soLuong'] -= change;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi cập nhật số lượng: $e')),
      );
    }
  }

  Future<void> _removeSelectedItems() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để xóa mục!')),
      );
      return;
    }

    final selectedItems = cartItems.where((item) => item['selected'] == true).toList();
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất một mục để xóa!')),
      );
      return;
    }

    setState(() {
      cartItems.removeWhere((item) => item['selected'] == true);
    });

    for (var item in selectedItems) {
      try {
        await CartService.removeCartItem(userProvider.token!, item['id_mucGioHang']);
      } catch (e) {
        // Nếu lỗi, có thể tải lại giỏ hàng để đồng bộ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa mục: $e')),
        );
        _loadCart();
        break;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xóa các mục đã chọn!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? Center(child: Text(errorMessage!))
                : cartItems.isEmpty
                ? const Center(child: Text('Giỏ hàng trống'))
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                return _buildCartItem(cartItems[index], index);
              },
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Checkbox(
                activeColor: Colors.green,
                value: cartItems.every((item) => item['selected'] == true),
                onChanged: (value) {
                  setState(() {
                    for (var item in cartItems) {
                      item['selected'] = value ?? false;
                    }
                  });
                },
              ),
              const Text("Chọn Tất Cả", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          TextButton(
            onPressed: _removeSelectedItems,
            child: const Text("Xóa Mục Đã Chọn", style: TextStyle(color: Colors.red, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> product, int index) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              activeColor: Colors.green,
              value: product['selected'] ?? false,
              onChanged: (value) => _toggleSelect(index),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product['image'],
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading image: $error');
                  return const Icon(Icons.error, size: 50);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? 'Không có tên',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${formatCurrency.format(product['gia'])} ₫",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => _updateQuantity(index, -1),
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                ),
                Text(
                  product['soLuong'].toString(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => _updateQuantity(index, 1),
                  icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    double totalPrice = 0;
    for (var product in cartItems) {
      if (product['selected'] == true) {
        totalPrice += (product['gia'] as num) * product['soLuong'];
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Tổng tiền:", style: TextStyle(fontSize: 14, color: Colors.grey)),
              Text(
                "${formatCurrency.format(totalPrice)} ₫",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: totalPrice > 0 ? () {} : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: totalPrice > 0 ? Colors.orange : Colors.grey,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Thanh Toán", style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}