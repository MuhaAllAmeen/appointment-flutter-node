import 'package:appointment/home.dart';
import 'package:appointment/services/certPinnedHTTPS.dart';
import 'package:appointment/services/localAuthService.dart';
import 'package:appointment/services/secureStorageService.dart';
import 'package:appointment/utils/saveAPIkeys.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async{
  //initalize all the singletons
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  // await dotenv.load(fileName: "lib/.env");
  SecureStorage().init();
  await getCertFromServer();
  await BaseHttpClient().init();
  LocalAuthService().init();
  await getAPIKeysandSave();
    // await AuthService().logout();
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

