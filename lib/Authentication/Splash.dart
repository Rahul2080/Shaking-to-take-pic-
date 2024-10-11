import 'package:flutter/material.dart';
import 'package:shakingpic/Authentication/Login.dart';
import 'package:shakingpic/Authentication/SignUp.dart';
import 'package:shakingpic/Home.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3) ,(){

      Navigator.of(context).push(MaterialPageRoute(builder: (_)=>Login() ));
    });
    return Scaffold(
    );
  }
}
