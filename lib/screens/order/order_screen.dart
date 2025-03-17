import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/myorder_provider.dart';
import '../../providers/user_provider.dart';
// import 'order_detail_screen.dart'; // Giả sử file này chứa màn hình chi tiết đơn hàng

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  _MyOrdersScreenState createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final myOrderProvider = Provider.of<MyOrderProvider>(context, listen: false);
    if (userProvider.token != null) {
      myOrderProvider.loadOrders(userProvider.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đơn hàng của tôi"),
      ),
      body: Consumer<MyOrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (orderProvider.errorMessage != null) {
            return Center(child: Text(orderProvider.errorMessage!));
          }
          if (orderProvider.orders.isEmpty) {
            return const Center(child: Text("Bạn chưa đặt đơn hàng nào."));
          }
          return ListView.builder(
            itemCount: orderProvider.orders.length,
            itemBuilder: (context, index) {
              final order = orderProvider.orders[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text("Đơn hàng #${order['id_donHang']}"),
                  subtitle: Text("Trạng thái: ${order['trangThaiDonHang']}"),
                  trailing: Text("Tổng: ${order['tongTien']} VNĐ"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailScreen(orderId: order['id_donHang']),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Màn hình chi tiết đơn hàng
class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  const OrderDetailScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final myOrderProvider = Provider.of<MyOrderProvider>(context, listen: false);
    if (userProvider.token != null) {
      myOrderProvider.loadOrderDetail(userProvider.token!, widget.orderId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyOrderProvider>(
      builder: (context, orderProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Chi tiết đơn hàng"),
          ),
          body: orderProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : orderProvider.errorMessage != null
              ? Center(child: Text(orderProvider.errorMessage!))
              : orderProvider.orderDetail == null
              ? const Center(child: Text("Không tìm thấy thông tin đơn hàng."))
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Đơn hàng #${orderProvider.orderDetail!['id_donHang']}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text("Người nhận: ${orderProvider.orderDetail!['ten_nguoiNhan']}"),
                Text("SĐT: ${orderProvider.orderDetail!['sdt_nhanHang']}"),
                Text(
                    "Địa chỉ: ${orderProvider.orderDetail!['ten_nha']}, ${orderProvider.orderDetail!['xa']}, ${orderProvider.orderDetail!['huyen']}, ${orderProvider.orderDetail!['tinh']}"),
                Text("Phương thức thanh toán: ${orderProvider.orderDetail!['phuongThucThanhToan']}"),
                Text("Tổng tiền: ${orderProvider.orderDetail!['tongTien']} VNĐ"),
                Text("Trạng thái: ${orderProvider.orderDetail!['trangThaiDonHang']}"),
                const Divider(height: 32),
                const Text("Sản phẩm trong đơn hàng:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                orderProvider.orderDetail!['chiTietDonHang'] != null &&
                    orderProvider.orderDetail!['chiTietDonHang'].isNotEmpty
                    ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orderProvider.orderDetail!['chiTietDonHang'].length,
                  itemBuilder: (context, index) {
                    final item = orderProvider.orderDetail!['chiTietDonHang'][index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(item['sanPham'] != null
                            ? item['sanPham']['tenSanPham']
                            : "Sản phẩm #${item['id_sanPham']}"),
                        subtitle: Text("Số lượng: ${item['soLuong']}"),
                        trailing: Text("${item['gia']} VNĐ"),
                      ),
                    );
                  },
                )
                    : const Text("Không có sản phẩm nào trong đơn hàng."),
                const SizedBox(height: 20),
                // Nút hủy đơn hàng (chỉ hiển thị khi trạng thái là 'cho_xac_nhan')
                if (orderProvider.orderDetail!['trangThaiDonHang'] == 'cho_xac_nhan')
                  ElevatedButton(
                    onPressed: () async {
                      final userProvider = Provider.of<UserProvider>(context, listen: false);
                      final success = await orderProvider.cancelOrder(
                          userProvider.token!, orderProvider.orderDetail!['id_donHang']);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Đã hủy đơn hàng thành công!")));
                        Navigator.pop(context, true);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(orderProvider.errorMessage ??
                                "Lỗi khi hủy đơn hàng")));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text("Hủy đơn hàng"),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
