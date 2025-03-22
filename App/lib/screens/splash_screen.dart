import 'package:flutter/material.dart';
import 'package:baigan/theme/app_colors.dart';
import 'package:baigan/widgets/bottom_splash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: AppColors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // "Baigan" at the top-left in white and bold.
                  Text(
                    "Baigan",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),

                  // Introducing and Baigan on separate lines
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Introducing",
                          style: TextStyle(
                            fontSize: 48,
                            color: AppColors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8), // Small spacing between lines
                        Text(
                          "Baigan",
                          style: TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
          BottomSplash(),
        ],
      ),
    );
  }
}
