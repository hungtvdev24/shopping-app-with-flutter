import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool agreePolicy = false; // cho checkbox "đồng ý điều khoản"

  void _register() async {
    // Kiểm tra form
    if (!_formKey.currentState!.validate()) return;

    // Kiểm tra checkbox điều khoản
    if (!agreePolicy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bạn cần đồng ý với điều khoản để tiếp tục.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success = await authProvider.register(
      nameController.text.trim(),
      emailController.text.trim(),
      phoneController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() {
      isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đăng ký thành công! Đang chuyển đến trang đăng nhập...")),
      );
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.login,
          arguments: {
            "email": emailController.text.trim(),
            "password": passwordController.text.trim(),
          },
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage ?? "Lỗi đăng ký")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Màu ghi nhạt tổng thể
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 1) Ảnh trên cùng (trung tâm, cao 180)
              const SizedBox(height: 16),
              Center(
                child: Image.asset(
                  'assets/login_header.png',
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                ),
              ),
              const SizedBox(height: 24),

              // 2) Tiêu đề
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Hãy bắt đầu nào!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 3) Mô tả ngắn
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Vui lòng nhập thông tin hợp lệ để tạo tài khoản.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 4) Form đăng ký (trắng)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white, // nền trắng
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Tên
                      _buildTextField(
                        nameController,
                        "Tên",
                        Icons.person,
                        "Vui lòng nhập tên",
                      ),
                      // Email
                      _buildTextField(
                        emailController,
                        "Địa chỉ Email",
                        Icons.email,
                        "Vui lòng nhập email",
                        isEmail: true,
                      ),
                      // SĐT
                      _buildTextField(
                        phoneController,
                        "Số điện thoại",
                        Icons.phone,
                        "Vui lòng nhập số điện thoại",
                      ),
                      // Mật khẩu
                      _buildTextField(
                        passwordController,
                        "Mật khẩu",
                        Icons.lock,
                        "Vui lòng nhập mật khẩu",
                        isPassword: true,
                      ),
                      // Xác nhận mật khẩu
                      _buildTextField(
                        confirmPasswordController,
                        "Xác nhận mật khẩu",
                        Icons.lock,
                        "Vui lòng xác nhận mật khẩu",
                        isPassword: true,
                        confirmPasswordOf: passwordController,
                      ),
                      const SizedBox(height: 12),

                      // 5) Checkbox điều khoản
                      Row(
                        children: [
                          Checkbox(
                            value: agreePolicy,
                            onChanged: (val) {
                              setState(() {
                                agreePolicy = val ?? false;
                              });
                            },
                          ),
                          Flexible(
                            child: Text.rich(
                              TextSpan(
                                text: "Tôi đồng ý với ",
                                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                children: [
                                  TextSpan(
                                    text: "Điều khoản dịch vụ",
                                    style: TextStyle(fontSize: 14, color: Colors.blue),
                                  ),
                                  const TextSpan(text: " & "),
                                  TextSpan(
                                    text: "chính sách bảo mật.",
                                    style: TextStyle(fontSize: 14, color: Colors.blue),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 6) Nút đăng ký
                      isLoading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            // Button màu xanh nhạt
                            backgroundColor: Colors.lightBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Tiếp tục",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 7) Đã có tài khoản? Log in
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Bạn đã có tài khoản? ",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                            child: const Text(
                              "Đăng nhập",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.lightBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Hàm dựng TextFormField tái sử dụng
  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon,
      String errorText, {
        bool isEmail = false,
        bool isPassword = false,
        TextEditingController? confirmPasswordOf,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          hintText: label,
          prefixIcon: Icon(icon, color: Colors.grey[700]),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none, // không viền, bo góc
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return errorText;
          }
          if (isEmail) {
            final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
            if (!emailRegExp.hasMatch(value.trim())) {
              return "Email không hợp lệ";
            }
          }
          if (isPassword && value.length < 6) {
            return "Mật khẩu tối thiểu 6 ký tự";
          }
          if (confirmPasswordOf != null) {
            // Kiểm tra trùng mật khẩu
            if (value.trim() != confirmPasswordOf.text.trim()) {
              return "Mật khẩu không khớp";
            }
          }
          return null;
        },
      ),
    );
  }
}
