import 'dart:developer';

//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:we_chat/screens/auth/login_screen.dart';
import 'package:we_chat/screens/home_screen.dart';
//import 'package:we_chat/screens/home_screen.dart';

import '../../api/apis.dart';
import '../../main.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // bool _isAnimate = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(milliseconds: 2500), () {
      //exit full screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(systemNavigationBarColor: Colors.white , statusBarColor: Colors.white));
      if(APIs.auth.currentUser != null)
        {
          log('\nUSER: ${APIs.auth.currentUser}');
          //navigate to home screen
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> HomeScreen()));
        }
      else
        {
          //navigate to  login screen
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> LoginScreen()));
        }

    });
  }

  @override
  Widget build(BuildContext context) {
    //initializing media query to get device screen size
    mq=MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text('Welcome to We Chat'),
      ),

      body: Stack(children: [
        Positioned(
            top: mq.height * .15,
            width: mq.width * .5,
            right: mq.width * .25,
            // duration: Duration(seconds: 1),
            child: Image.asset('images/icon.png')),

        Positioned(
            bottom: mq.height * .15,
            width: mq.width * .9,
             left: mq.width * .05,
            // height: mq.height*.06,
            child: const Text('REAL TIME CHATTING APP ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
              letterSpacing: .5
            ),))
      ],) ,

    );

  }
}

