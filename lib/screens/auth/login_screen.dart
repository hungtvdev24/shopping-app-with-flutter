import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? errorMessage;
  bool _obscurePassword = true; // To toggle password visibility

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    if (args != null) {
      emailController.text = args["email"] ?? "";
      passwordController.text = args["password"] ?? "";
      print('Pre-filled login: email=${args["email"]}, password=${args["password"]}');
    }
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    print(
        'Login attempt: email=${emailController.text.trim()}, password=${passwordController.text.trim()}');
    bool success = await authProvider.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() {
      isLoading = false;
      errorMessage = authProvider.errorMessage;
    });

    print(
        'Login result: success=$success, error=$errorMessage, token=${authProvider.token}');
    if (success) {
      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.setToken(authProvider.token!);
        print('Token saved to UserProvider: ${userProvider.token}');
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } catch (e) {
        print('Error saving token to UserProvider: $e');
        setState(() {
          errorMessage = 'Lỗi khi lưu token: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // PHẦN TRÊN (nền hồng, chứa hình minh hoạ)
            Container(
              height: 280,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFFCE4EC), // Màu hồng nhạt
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      'assets/login_header.png', // Giữ nguyên hình ảnh của bạn
                      height: 280,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error),
                    ),
                  ),
                ],
              ),
            ),
            // Close button at the top-left
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            // PHẦN DƯỚI (Form đăng nhập)
            Padding(
              padding: const EdgeInsets.only(top: 280), // Đẩy form xuống dưới banner
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    const Text(
                      "Đăng nhập",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Roboto', // Sử dụng font Roboto
                      ),
                    ),
                    const SizedBox(height: 24),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Email
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: "Email",
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) => (value == null || value.isEmpty)
                                ? "Vui lòng nhập địa chỉ Email"
                                : null,
                            style: const TextStyle(fontFamily: 'Roboto'),
                          ),
                          const SizedBox(height: 16),

                          // Password
                          TextFormField(
                            controller: passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: "Mật khẩu",
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) => (value == null || value.isEmpty)
                                ? "Vui lòng nhập mật khẩu"
                                : null,
                            style: const TextStyle(fontFamily: 'Roboto'),
                          ),
                          const SizedBox(height: 24),

                          // Error Message
                          if (errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  side: const BorderSide(color: Colors.black),
                                ),
                                elevation: 0,
                              ),
                              onPressed: isLoading ? null : _login,
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                color: Colors.black,
                              )
                                  : const Text(
                                "Đăng nhập",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Forgot Password and Register Links
                          Center(
                            child: Column(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    // Handle forgot password
                                  },
                                  child: const Text(
                                    "Quên mật khẩu?",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Không có tài khoản? ",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          AppRoutes.register,
                                        );
                                      },
                                      child: const Text(
                                        "Đăng ký",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.pink,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Roboto',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}