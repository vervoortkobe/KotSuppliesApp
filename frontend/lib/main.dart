import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kotsupplies/app/constants/app_constants.dart';
import 'package:kotsupplies/app/view_models/auth_view_model.dart';
import 'package:kotsupplies/app/view_models/item_view_model.dart';
import 'package:kotsupplies/app/view_models/list_view_model.dart';
import 'package:kotsupplies/app/view_models/notification_view_model.dart';
import 'package:kotsupplies/app/views/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ListViewModel()),
        ChangeNotifierProvider(create: (_) => ItemViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
      ],
      child: MaterialApp(
        title: 'KOT Supplies',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: kPrimaryColor,
          hintColor: kAccentColor,
          scaffoldBackgroundColor: kBackgroundColor,
          appBarTheme: const AppBarTheme(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            centerTitle: true,
            titleTextStyle: kHeadingStyle,
          ),
          textTheme: const TextTheme(
            headlineMedium: kHeadingStyle,
            titleLarge: kSubtitleStyle,
            bodyLarge: kBodyTextStyle,
            bodyMedium: kBodyTextStyle,
            bodySmall: kSmallTextStyle,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: kSmallPadding,
                horizontal: kDefaultPadding,
              ),
              shape: RoundedRectangleBorder(borderRadius: kDefaultBorderRadius),
              textStyle: kBodyTextStyle,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: kDefaultPadding,
              vertical: kSmallPadding,
            ),
            border: kDefaultInputBorder,
            enabledBorder: kDefaultInputBorder.copyWith(
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: kFocusedInputBorder,
            errorBorder: kDefaultInputBorder.copyWith(
              borderSide: const BorderSide(color: kErrorColor),
            ),
            focusedErrorBorder: kFocusedInputBorder.copyWith(
              borderSide: const BorderSide(color: kErrorColor, width: 2.0),
            ),
            labelStyle: kBodyTextStyle.copyWith(color: Colors.grey.shade700),
            floatingLabelStyle: kBodyTextStyle.copyWith(color: kPrimaryColor),
          ),
          cardTheme: CardThemeData(
            color: kCardColor,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: kDefaultBorderRadius),
            margin: const EdgeInsets.symmetric(
              horizontal: kDefaultPadding,
              vertical: kSmallPadding,
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
