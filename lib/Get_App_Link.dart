import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';

class GetAppLink extends StatefulWidget {
  @override
  _GetAppLinkState createState() => _GetAppLinkState();
}

class _GetAppLinkState extends State<GetAppLink> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
  }

  void _initDeepLinkListener() {
    print('Initializing deep link listener');

    _sub = uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        print('Deep link received: ${uri.toString()}');
      } else {
        print('No deep link received');
      }
    }, onError: (err) {
      print('Failed to receive deep link: $err');
    });
  }


  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.yellow,);
  }
}
