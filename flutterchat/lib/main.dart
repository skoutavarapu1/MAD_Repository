import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutterchat/googleAuth.dart';
import 'package:flutterchat/signin.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyAdFDdh4sNStxKuqDWoeWK7DfPyHQnA1rw',
          appId: '1:925390021434:android:bff02cfdfa19b2f8a2e603',
          messagingSenderId: '925390021434',
          projectId: 'flutterchat'));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GoogleSignInClass(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'My Chat App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          // scaffoldBackgroundColor: const Color(0xff1F1F1F),
        ),
        home: SignInPage(),
      ),
    );
  }
}
