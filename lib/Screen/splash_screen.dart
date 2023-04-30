import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart' as getX;
import 'package:transmission_surgicals/Utils/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo/logo.png', width: 200),
            SizedBox(height: 5,),
            Text("Transmission Surgicals", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),)
          ],
        ),
      ),
    );
  }

  
  @override
  void initState() {
    Timer(Duration(seconds: 1), () {
      readSharedPreferences(ISLOGIN, "0").then((value) {
          if(value=="1"){
          getX.Get.offAndToNamed('/dashboard');
        }else{
          getX.Get.offAndToNamed('/login');
        }
      });

    });
    super.initState();
  }


}
