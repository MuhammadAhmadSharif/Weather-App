import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_weather/theme/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import './provider/weatherProvider.dart';
import 'screens/homeScreen.dart';
import 'screens/sevenDayForecastDetailScreen.dart';

void main() {
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WeatherProvider(),
      child: MaterialApp(
        title: 'Flutter Weather',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: primaryBlue,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.blue),
            elevation: 0,
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          colorScheme: ColorScheme.light(
            primary: primaryBlue,
            secondary: backgroundWhite,
            surface: backgroundBlue,
          ),
          textTheme: GoogleFonts.openSansTextTheme().apply(bodyColor: Colors.black),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: primaryBlue,
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.black,
            iconTheme: IconThemeData(color: Colors.white),
            elevation: 0,
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          colorScheme: ColorScheme.dark(
            primary: primaryBlue,
            secondary: Colors.black,
            surface: Colors.grey.shade800,
          ),
          textTheme: GoogleFonts.openSansTextTheme().apply(bodyColor: Colors.white),
        ),
        themeMode: ThemeMode.system,
        home: HomeScreen(),
        // routes: {
        //   WeeklyScreen.routeName: (ctx) => WeeklyScreen(),
        // },
        onGenerateRoute: (settings) {
          final arguments = settings.arguments;
          if (settings.name == SevenDayForecastDetail.routeName) {
            return PageRouteBuilder(
              settings: settings,
              pageBuilder: (_, __, ___) => SevenDayForecastDetail(
                initialIndex: arguments == null ? 0 : arguments as int,
              ),
              transitionsBuilder: (ctx, a, b, c) => CupertinoPageTransition(
                primaryRouteAnimation: a,
                secondaryRouteAnimation: b,
                linearTransition: false,
                child: c,
              ),
            );
          }
          // Unknown route
          return MaterialPageRoute(builder: (_) => HomeScreen());
        },
      ),
    );
  }
}
