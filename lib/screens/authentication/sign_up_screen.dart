import 'package:flutter/material.dart';

import '../../services/auth/auth_service.dart';
import '../../utils/validators.dart';
import '../../widgets/auth_action_button.dart';
import '../../widgets/auth_screen_shell.dart';
import '../../widgets/auth_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthService _authService = const AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    if (!_authService.isAvailable) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      Navigator.of(context).pop(true);
      return;
    }

    final result = await _authService.signUp(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenShell(
      title: 'Create account',
      subtitle: 'Set up your FloraMind AI profile to explore plant care tools later.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthTextField(
              controller: _nameController,
              labelText: 'Full Name',
              hintText: 'Enter your full name',
              prefixIcon: Icons.person_outline,
              textInputAction: TextInputAction.next,
              validator: (value) => Validators.requiredField(value, 'Full name'),
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _emailController,
              labelText: 'Email',
              hintText: 'name@example.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: Validators.email,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _phoneController,
              labelText: 'Phone Number',
              hintText: '+91 98765 43210',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              validator: Validators.phone,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _passwordController,
              labelText: 'Password',
              hintText: 'Create a password',
              prefixIcon: Icons.lock_outline,
              textInputAction: TextInputAction.next,
              obscureText: _obscurePassword,
              validator: Validators.password,
              suffixIcon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              ),
              onSuffixIconPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _confirmPasswordController,
              labelText: 'Confirm Password',
              hintText: 'Re-enter your password',
              prefixIcon: Icons.lock_reset_outlined,
              textInputAction: TextInputAction.done,
              obscureText: _obscureConfirmPassword,
              validator: (value) => Validators.confirmPassword(
                value,
                _passwordController.text,
              ),
              onFieldSubmitted: (_) => _createAccount(),
              suffixIcon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onSuffixIconPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            const SizedBox(height: 24),
            AuthActionButton(
              label: 'Create Account',
              isLoading: _isLoading,
              onPressed: _createAccount,
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account?',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Login'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
