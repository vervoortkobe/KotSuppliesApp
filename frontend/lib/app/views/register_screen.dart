import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kotsupplies/app/views/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:kotsupplies/app/constants/app_constants.dart';
import 'package:kotsupplies/app/view_models/auth_view_model.dart';
import 'package:kotsupplies/app/widgets/profile_image_picker.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? _pickedImage;

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: kErrorColor),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    bool success = await authViewModel.register(
      _usernameController.text,
      profileImage: _pickedImage,
    );

    if (success) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      _showErrorSnackBar(authViewModel.errorMessage ?? 'Registration failed!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register', style: kHeadingStyle),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ProfileImagePicker(
                  onImagePicked: (image) {
                    setState(() {
                      _pickedImage = image;
                    });
                  },
                ),
                const SizedBox(height: kLargePadding),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: kDefaultInputBorder,
                    focusedBorder: kFocusedInputBorder,
                    prefixIcon: const Icon(Icons.person_add),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: kDefaultPadding),
                Consumer<AuthViewModel>(
                  builder: (context, authViewModel, child) {
                    return authViewModel.isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: kLargePadding,
                                vertical: kSmallPadding,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: kDefaultBorderRadius,
                              ),
                            ),
                            child: const Text(
                              'Register',
                              style: kBodyTextStyle,
                            ),
                          );
                  },
                ),
                const SizedBox(height: kDefaultPadding),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Go back to login
                  },
                  child: Text(
                    'Already have an account? Login',
                    style: kSmallTextStyle.copyWith(color: kPrimaryColor),
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
