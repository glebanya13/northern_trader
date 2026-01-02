import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:northern_trader/common/utils/colors.dart';
import 'package:northern_trader/common/providers/theme_provider.dart';
import 'package:northern_trader/common/widgets/theme_toggle_button.dart';
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
    final isDesktop = size.width > 600;
    final maxWidth = isDesktop ? 400.0 : double.infinity;
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final colors = AppColors(isDark);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colors.backgroundColor,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: const ThemeToggleButton(),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _isSignUp ? 'Регистрация' : 'Вход',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colors.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  
                  TextField(
                    controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: colors.textColor),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: Icon(Icons.email, color: colors.greyColor),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.cardColor, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.cardColor, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.accentColor, width: 2),
                    ),
                    fillColor: colors.inputFieldColor,
                    filled: true,
                    hintStyle: TextStyle(color: colors.greyColor),
                  ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  style: TextStyle(color: colors.textColor),
                  decoration: InputDecoration(
                    hintText: 'Пароль',
                    prefixIcon: Icon(Icons.lock, color: colors.greyColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: colors.greyColor,
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
                      borderSide: BorderSide(color: colors.cardColor, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.cardColor, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.accentColor, width: 2),
                    ),
                    fillColor: colors.inputFieldColor,
                    filled: true,
                    hintStyle: TextStyle(color: colors.greyColor),
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
                      style: TextStyle(color: colors.textColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
