import 'package:appointment/home.dart';
import 'package:appointment/pages/auth/webView.dart';
import 'package:appointment/services/authService.dart';
import 'package:flutter/material.dart';


class Registerview extends StatefulWidget {
  const Registerview({super.key});

  @override
  State<Registerview> createState() => _RegisterviewState();
}

class _RegisterviewState extends State<Registerview> {

  Future<void> signIn() async {
    final authSuccess = await AuthService.instance.login();
    // final authSuccess = await AuthService.instance.loginUsingGooglePackage();
    
    if (authSuccess){

      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder:(context) => Home(isLoggedIn: authSuccess,),), (Route)=>false);
    }
    
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        height: MediaQuery.of(context).size.height-300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Register.",style: TextStyle(fontSize: 35,fontWeight: FontWeight.bold),),
              const SizedBox(height: 30,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: TextButton(onPressed:() {
                  signIn();
                }, 
                style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.red[500])),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.g_mobiledata,size: 40,),
                    Text("Use Google",style: TextStyle(color: Colors.white, fontSize: 20),)
                  ],
                ),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
  
  
}