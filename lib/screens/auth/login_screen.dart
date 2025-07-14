import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/auth_service.dart';
import '../../widgets/loading_indicator.dart';
import 'widgets/custom_text_field.dart';
import 'widgets/gradient_button.dart';
import 'widgets/switch_auth_text.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FA),
      body: Stack(
        children: [
          _buildForm(context),
          if (isLoading) const LoadingIndicator(),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.blue.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade100.withOpacity(0.4),
                  offset: const Offset(0, 8),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 64, color: Colors.blueAccent),
                const SizedBox(height: 16),
                Text("Welcome Back",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    )),
                const SizedBox(height: 8),
                const Text("Login to continue",
                    style: TextStyle(fontSize: 16, color: Colors.black54)),
                const SizedBox(height: 32),

                CustomTextField(controller: emailController, hintText: "Username", icon: Icons.person_outline),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: passwordController,
                  hintText: "Password",
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),
                const SizedBox(height: 24),

                GradientButton(text: "Login", onPressed: _onLogin),
                const SizedBox(height: 16),

                SwitchAuthText(
                  question: "Don't have an account?",
                  actionText: "Register",
                  onTap: () => context.go('/register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onLogin() async {
    setState(() => isLoading = true);
    final authService = AuthService();
    final result = await authService.loginUser(
      username: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
    setState(() => isLoading = false);

    if (result == null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: emailController.text.trim())
          .limit(1)
          .get();
      final user = UserModel.fromMap(doc.docs.first.data());
      if (!mounted) return;
      Provider.of<AuthProvider>(context, listen: false).login(user);
      context.go('/home');
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result), backgroundColor: Colors.red),
      );
    }
  }
}
