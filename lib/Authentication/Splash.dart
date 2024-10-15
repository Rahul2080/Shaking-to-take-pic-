import 'package:flutter/material.dart';
import 'package:shakingpic/Home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Login.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), ()async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if(prefs.containsKey("userName")){
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) =>Home()),(route)=>false);
      }else{
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) =>Login()),(route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
