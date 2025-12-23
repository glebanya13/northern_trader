import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:northern_trader/common/utils/colors.dart';
import 'package:northern_trader/common/utils/utils.dart';
import 'package:northern_trader/common/widgets/custom_button.dart';
import 'package:northern_trader/features/auth/controller/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const routeName = '/login-screen';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void toggleSignUp() {
    setState(() {
      _isSignUp = !_isSignUp;
    });
  }

  void handleAuth() {
    String email = emailController.text.trim();
    String password = passwordController.text;

    if (email.isEmpty) {
      showSnackBar(context: context, content: 'Пожалуйста, введите email');
      return;
    }
    if (password.isEmpty) {
      showSnackBar(context: context, content: 'Пожалуйста, введите пароль');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    if (_isSignUp) {
      ref
          .read(authControllerProvider)
          .signUpWithEmail(context, email, password)
          .then((_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }).catchError((error) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    } else {
      ref
          .read(authControllerProvider)
          .signInWithEmail(context, email, password)
          .then((_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }).catchError((error) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _isSignUp ? 'Регистрация' : 'Вход',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: const Icon(Icons.email, color: greyColor),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: limeGreen, width: 2),
                    ),
                    fillColor: cardColor,
                    filled: true,
                    hintStyle: TextStyle(color: greyColor),
                  ),
                ),
                const SizedBox(height: 16),
                
                TextField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Пароль',
                    prefixIcon: const Icon(Icons.lock, color: greyColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: greyColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: limeGreen, width: 2),
                    ),
                    fillColor: cardColor,
                    filled: true,
                    hintStyle: TextStyle(color: greyColor),
                  ),
                ),
                
                SizedBox(height: size.height * 0.3),
                SizedBox(
                  width: 200,
                  child: CustomButton(
                    onPressed: _isLoading ? null : handleAuth,
                    text: _isSignUp ? 'РЕГИСТРАЦИЯ' : 'ВОЙТИ',
                    isLoading: _isLoading,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: toggleSignUp,
                  child: Text(
                    _isSignUp
                        ? 'Уже есть аккаунт? Войти'
                        : 'Нет аккаунта? Зарегистрироваться',
                    style: const TextStyle(color: limeGreen),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
