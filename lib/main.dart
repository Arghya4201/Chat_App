import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:we_chat/screens/auth/login_screen.dart';
import 'package:we_chat/screens/auth/splash_screen.dart';
//import 'package:we_chat/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

//global object to access screen size
late Size mq;

void main() {
   WidgetsFlutterBinding.ensureInitialized();
   SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
   //set fixed orientation
   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitDown]).then((value){
     _initializeFirebase();
     runApp(const MyApp());
   });

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'We Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 1,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.normal,
              backgroundColor: Colors.blue
              ,fontSize: 19)
        )
      ),
     home: const SplashScreen(),
     // home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

_initializeFirebase() async{
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);
}
