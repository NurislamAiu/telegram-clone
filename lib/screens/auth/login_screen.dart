import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
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
      body: LoadingOverlay(
        isLoading: isLoading,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: _buildForm(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Container(
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
          const Text("Login to continue", style: TextStyle(fontSize: 16, color: Colors.black54)),
          const SizedBox(height: 32),
          CustomTextField(controller: emailController, hintText: "Email", icon: Icons.email_outlined),
          const SizedBox(height: 16),
          CustomTextField(
            controller: passwordController,
            hintText: "Password",
            icon: Icons.lock_outline,
            obscureText: true,
          ),
          const SizedBox(height: 24),
          GradientButton(
            text: "Login",
            onPressed: _onLogin,
          ),
          const SizedBox(height: 16),
          SwitchAuthText(
            question: "Don't have an account?",
            actionText: "Register",
            onTap: () => context.go('/register'),
          ),
        ],
      ),
    );
  }

  Future<void> _onLogin() async {
    setState(() => isLoading = true);

    final auth = AuthService();
    final error = await auth.login(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    setState(() => isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    } else {
      context.go('/home');
    }
  }
}