import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/providers/user_provider.dart';
import 'package:hackathon/screens/login_screen.dart';
import 'package:hackathon/screens/signup_screen.dart';
import 'package:provider/provider.dart';
//import 'package:instagram_flutter/responsive/mobile_screen_layout.dart';
//import 'package:instagram_flutter/responsive/web_screen_layout.dart';
//import 'package:instagram_flutter/responsive/responsive_layout_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyBVbdCNZgFM26ZV91dTj_9Lo52fTgHcevg",
        appId: "1:13022585509:web:c16d9ebebc5e15ce5ce34c",
        messagingSenderId: "13022585509",
        projectId: "hackathon-ddc90",
        storageBucket: "hackathon-ddc90.appspot.com",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Instagram Clone',
        home: LoginScreen(),
      ),
    );
    /*
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Instagram Clone',
      /*
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: mobileBackgroundColor,
      ),
      */
      home: LoginScreen(),
    );
    */
  }
} 