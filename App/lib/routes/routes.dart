import 'package:get/get.dart';
import 'package:baigan/controller/auth_controller.dart';
import 'package:baigan/screens/home_screen.dart';
import 'package:baigan/screens/login_screen.dart';
import 'package:baigan/screens/profile_screen.dart';
import 'package:baigan/screens/signup_screen.dart';
import 'package:baigan/widgets/bottom_navbar.dart';

class AuthBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController(), permanent: true);
    }
  }
}

class AppPage {
  static String login = '/login';
  static String signup = '/signup';
  static String profile = '/profile';
  static String home = '/home';
  static String navbar = '/';

  static String getLogin() => login;
  static String getSignup() => signup;
  static String getProfile() => profile;
  static String getHome() => home;
  static String getNavbar() => navbar;

  static List<GetPage> routes = [
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: signup,
      page: () => const SignupScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: profile,
      page: () => const ProfileScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: home,
      page: () => const HomeScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: navbar,
      page: () => const BottomNavbar(),
      binding: AuthBinding(),
    ),
  ];
}
