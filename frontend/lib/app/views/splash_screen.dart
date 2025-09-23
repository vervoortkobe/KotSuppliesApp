import 'package:flutter/material.dart';
import 'package:kotsupplies/app/views/home_screen.dart';
import 'package:kotsupplies/app/views/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:kotsupplies/app/constants/app_constants.dart';
import 'package:kotsupplies/app/view_models/auth_view_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLogin();
    });
  }

  Future<void> _checkLogin() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    await authViewModel.checkLoginStatus();

    if (mounted) {
      if (authViewModel.currentUser != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.checklist, size: 100, color: Colors.white),
            const SizedBox(height: kDefaultPadding),
            Text(
              'KOT Supplies',
              style: kHeadingStyle.copyWith(color: Colors.white),
            ),
            const SizedBox(height: kLargePadding),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
