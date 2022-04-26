import 'package:flutter/material.dart';
import 'package:users_app/widgets/simple_app_bar.dart';

class finalScreen extends StatefulWidget {
  const finalScreen({Key? key}) : super(key: key);

  @override
  State<finalScreen> createState() => _finalScreenState();
}

class _finalScreenState extends State<finalScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: SimpleAppBar(
          title: "Order Done",
        ),
        body: Center(
          child: Text(
            "You order is placed successfully!",
            style: TextStyle(fontSize: 30, color: Colors.cyan),
          ),
        ));
  }
}
