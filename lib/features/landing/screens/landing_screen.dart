import 'package:flutter/material.dart';
import 'package:northern_trader/common/utils/colors.dart';
import 'package:northern_trader/common/widgets/custom_button.dart';
import 'package:northern_trader/features/auth/screens/login_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({Key? key}) : super(key: key);

  void navigateToLoginScreen(BuildContext context) {
    Navigator.pushNamed(context, LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  const Text(
                    'Добро пожаловать',
                    style: TextStyle(
                      fontSize: 33,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: size.height / 9),
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 200,
                    color: tabColor,
                  ),
                  SizedBox(height: size.height / 9),
                  const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text(
                      'Прочитайте нашу Политику конфиденциальности. Нажмите "Принять и продолжить", чтобы принять Условия использования.',
                      style: TextStyle(color: greyColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: size.width * 0.75,
                    child: CustomButton(
                      text: 'ПРИНЯТЬ И ПРОДОЛЖИТЬ',
                      onPressed: () => navigateToLoginScreen(context),
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

