import 'package:appointment/home.dart';
import 'package:appointment/pages/auth/webView.dart';
import 'package:appointment/services/certPinnedHTTPS.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();

  await dotenv.load(fileName: "lib/.env");
  await BaseHttpClient().init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(   
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 2, color: Colors.grey)
                    )
                    )
      ),
      home: Home(),
    );
  }
}

