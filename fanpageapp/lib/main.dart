import 'package:fanpageapp/googleAuth.dart';
import 'package:fanpageapp/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'signin.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyBo0tEH1QO5a5qz8rOL_yUu-KDn-2sBb2c',
          appId: '1:305185203353:android:1ff02e586205f1fa4c8408',
          messagingSenderId: '305185203353',
          projectId: 'fanpageassignment'));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GoogleSignInClass(),
      child: const MaterialApp(
        title: 'Fan Page App',
        home: SignInPage(),
      ),
    );
  }
}
