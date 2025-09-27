import 'package:flutter/material.dart';

// API Base URL
const String kApiBaseUrl = 'https://2a30ee193c43.ngrok-free.app';

// Paddings
const double kDefaultPadding = 16.0;
const double kSmallPadding = 8.0;
const double kLargePadding = 24.0;

// Text Styles
const TextStyle kHeadingStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: Colors.blueGrey,
);
const TextStyle kSubtitleStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: Colors.blueGrey,
);
const TextStyle kBodyTextStyle = TextStyle(fontSize: 16, color: Colors.black87);
const TextStyle kSmallTextStyle = TextStyle(fontSize: 14, color: Colors.grey);

// Colors
const Color kPrimaryColor = Colors.blue;
const Color kAccentColor = Colors.lightBlueAccent;
const Color kBackgroundColor = Color(0xFFF0F2F5);
const Color kCardColor = Colors.white;
const Color kErrorColor = Colors.red;
const Color kSuccessColor = Colors.green;

// Borders
final BorderRadius kDefaultBorderRadius = BorderRadius.circular(8.0);
final OutlineInputBorder kDefaultInputBorder = OutlineInputBorder(
  borderRadius: kDefaultBorderRadius,
  borderSide: BorderSide(color: Colors.blueGrey.shade200, width: 1.0),
);
final OutlineInputBorder kFocusedInputBorder = OutlineInputBorder(
  borderRadius: kDefaultBorderRadius,
  borderSide: const BorderSide(color: kPrimaryColor, width: 2.0),
);

const TextStyle kErrorTextStyle = TextStyle(color: kErrorColor, fontSize: 14);
