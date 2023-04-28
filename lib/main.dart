//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/screens/login_screen.dart';
import 'package:hackathon/screens/signup_screen.dart';
//import 'package:instagram_flutter/responsive/mobile_screen_layout.dart';
//import 'package:instagram_flutter/responsive/web_screen_layout.dart';
//import 'package:instagram_flutter/screens/login_screen.dart';
//import 'package:instagram_flutter/utils/colors.dart';
//import 'package:instagram_flutter/responsive/responsive_layout_screen.dart';

void main() {
  /* we need to put async follow by main()
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: 'AIzaSyDbsvkLRC8jZz3v3UL0lEXj7caleWtwMQU',
        appId: '1:580047358502:web:fa3ce105873532fa1df4e7',
        messagingSenderId: '580047358502',
        projectId: 'instagram-tut-b3bf9',
        storageBucket: 'instagram-tut-b3bf9.appspot.com',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  */
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Instagram Clone',
      /*
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: mobileBackgroundColor,
      ),
      */
      /* home: const ResponsiveLayout(
        moblieScreenLayout: MoblieScreenLayout(),
        webScreenLayout: WebScreenLayout(),
      ), */
      home: LoginScreen(),
    );
  }
}