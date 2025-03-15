import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/address_provider.dart';
import '../../providers/user_provider.dart'; // để lấy token
import '../../core/models/address.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({Key? key}) : super(key: key);

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  @override
  void initState() {
    super.initState();
    // Sử dụng BuildContext từ didChangeDependencies để tránh lỗi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);

      final token = userProvider.token;
      if (token != null) {
        addressProvider.fetchAddresses(token);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để xem địa chỉ!')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final addressProvider = Provider.of<AddressProvider>(context);
    final addresses = addressProvider.addresses;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Địa chỉ giao hàng"),
      ),
      body: addressProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : addresses.isEmpty
          ? const Center(child: Text("Chưa có địa chỉ nào"))
          : ListView.builder(
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          final addr = addresses[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(addr.tenNguoiNhan ?? ''),
              subtitle: Text(
                "${addr.tenNha ?? ''}, ${addr.xa ?? ''}, ${addr.huyen ?? ''}, ${addr.tinh ?? ''}\nSDT: ${addr.sdtNhanHang ?? ''}",
              ),
              // trailing: IconButton(
              //   icon: const Icon(Icons.delete, color: Colors.red),
              //   onPressed: () {
              //     final userProvider = Provider.of<UserProvider>(context, listen: false);
              //     final token = userProvider.token;
              //     if (token != null) {
              //       addressProvider.removeAddress(token, addr.idDiaChi);
              //     }
              //   },
              // ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddAddressScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({Key? key}) : super(key: key);

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  final _sdtController = TextEditingController();
  final _tenNguoiNhanController = TextEditingController();
  final _tenNhaController = TextEditingController();
  final _tinhController = TextEditingController();
  final _huyenController = TextEditingController();
  final _xaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thêm địa chỉ"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_sdtController, "Số điện thoại nhận hàng"),
              _buildTextField(_tenNguoiNhanController, "Tên người nhận"),
              _buildTextField(_tenNhaController, "Số nhà / Tên nhà"),
              _buildTextField(_tinhController, "Tỉnh"),
              _buildTextField(_huyenController, "Huyện"),
              _buildTextField(_xaController, "Xã / Phường"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _onSubmit(context),
                child: const Text("Lưu"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Vui lòng nhập $label";
          }
          return null;
        },
      ),
    );
  }

  void _onSubmit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final address = Address(
        idDiaChi: 0,
        sdtNhanHang: _sdtController.text.trim(),
        tenNguoiNhan: _tenNguoiNhanController.text.trim(),
        tenNha: _tenNhaController.text.trim(),
        tinh: _tinhController.text.trim(),
        huyen: _huyenController.text.trim(),
        xa: _xaController.text.trim(),
      );

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);

      final token = userProvider.token;
      if (token != null) {
        addressProvider.addAddress(token, address).then((_) {
          Navigator.pop(context);
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi thêm địa chỉ: $error')),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để thêm địa chỉ!')),
        );
      }
    }
  }
}