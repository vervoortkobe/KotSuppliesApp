import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kotsupplies/app/constants/app_constants.dart';
import 'package:kotsupplies/app/view_models/auth_view_model.dart';
import 'package:kotsupplies/app/widgets/profile_image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final _usernameController = TextEditingController();
  File? _pickedImage;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    _usernameController.text = authViewModel.currentUser?.username ?? '';
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: kErrorColor),
    );
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    bool success = await authViewModel.updateProfile(
      _usernameController.text,
      profileImage: _pickedImage,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: kSuccessColor,
        ),
      );
      Navigator.of(context).pop();
    } else {
      _showErrorSnackBar(
        authViewModel.errorMessage ?? 'Failed to update profile.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile', style: kHeadingStyle),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          if (authViewModel.currentUser == null) {
            return Center(
              child: Text('User not logged in.', style: kBodyTextStyle),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  ProfileImagePicker(
                    initialImageUrl: authViewModel.currentUser!.profileImageUrl,
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
                      prefixIcon: const Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Username cannot be empty';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: kLargePadding),
                  authViewModel.isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _updateProfile,
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
                            'Update Profile',
                            style: kBodyTextStyle,
                          ),
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
