import 'package:flutter/material.dart';
import 'package:kotsupplies/app/constants/app_constants.dart';

class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: CircularProgressIndicator(color: kPrimaryColor));
  }
}
