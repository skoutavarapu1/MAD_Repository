import 'package:fanpageapp/register.dart';
import 'package:flutter/material.dart';
import 'package:fanpageapp/signin.dart';
import 'main.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _navigatetohome();
  }

  _navigatetohome() async {
    await Future.delayed(Duration(milliseconds: 1500), () {});
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => SignInPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
            // child: Text('Splash Screen', style: TextStyle(
            //     fontSize: 24, fontWeight: FontWeight.bold))
            alignment: Alignment.topCenter,
            padding: EdgeInsets.all(10),
            child: Image.asset("assets/splash.jpg")),
      ),
    );
  }
}
