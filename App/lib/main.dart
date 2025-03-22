import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:baigan/controller/auth_controller.dart';
import 'package:baigan/routes/routes.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensures async calls work in main()

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase Initialized Successfully!');
  } catch (e) {
    print('❌ Firebase Initialization Failed: $e');
  }

  // Initialize AuthController before running the app
  Get.put<AuthController>(AuthController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'baigan',
      initialRoute: AppPage.getLogin(),
      getPages: AppPage.routes,
      initialBinding:
          AuthBinding(), // Add this to ensure bindings are available
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
