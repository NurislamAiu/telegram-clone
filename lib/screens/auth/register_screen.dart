import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../widgets/loading_indicator.dart';
import 'widgets/custom_text_field.dart';
import 'widgets/gradient_button.dart';
import 'widgets/switch_auth_text.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

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
          const Icon(Icons.person_add_alt_1, size: 64, color: Colors.blueAccent),
          const SizedBox(height: 16),
          Text("Create Account",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              )),
          const SizedBox(height: 8),
          const Text("Join our social world", style: TextStyle(fontSize: 16, color: Colors.black54)),
          const SizedBox(height: 32),
          CustomTextField(controller: nameController, hintText: "Full Name", icon: Icons.person_outline),
          const SizedBox(height: 16),
          CustomTextField(controller: emailController, hintText: "Email", icon: Icons.email_outlined),
          const SizedBox(height: 16),
          CustomTextField(
            controller: passwordController,
            hintText: "Password",
            icon: Icons.lock_outline,
            obscureText: true,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: confirmPasswordController,
            hintText: "Confirm Password",
            icon: Icons.lock_reset_outlined,
            obscureText: true,
          ),
          const SizedBox(height: 24),
          GradientButton(
            text: "Register",
            onPressed: _onRegister,
          ),
          const SizedBox(height: 16),
          SwitchAuthText(
            question: "Already have an account?",
            actionText: "Login",
            onTap: () => context.go('/login'),
          ),
        ],
      ),
    );
  }

  Future<void> _onRegister() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => isLoading = true);

    final auth = AuthService();
    final error = await auth.register(
      name: nameController.text.trim(),
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