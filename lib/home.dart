import 'package:appointment/pages/functional/appointmentsView.dart';
import 'package:appointment/pages/functional/bookView.dart';
import 'package:appointment/pages/auth/registerView.dart';
import 'package:appointment/services/apiService.dart';
import 'package:appointment/services/authService.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  bool isLoggedIn;
  Home({super.key, this.isLoggedIn=false});

  @override
  State<Home> createState() => _HomeState();
}


class _HomeState extends State<Home> {
  int _page = 0;
  bool isLoading = false;
  late PageController pageController;

  @override
  void initState() {
    
    if(!widget.isLoggedIn) initAuth();
    pageController = PageController();
    super.initState();
  }

  void initAuth() async{
    setState(() {
      isLoading = true;
    });
    bool isAuthenticated = await AuthService().initAuth();
    print("home isauth $isAuthenticated");
    setState(() {
      widget.isLoggedIn = isAuthenticated;
      isLoading = false;
    });
  }
  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body:isLoading ? 
        const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              Text("Please Wait")
            ],
          ),
        )
      : widget.isLoggedIn ? PageView(
        controller: pageController,
        // physics: const NeverScrollableScrollPhysics(),
        children: const [BookView(),Appointmentsview()],
        onPageChanged: (value) {
          setState(() {
            _page = value;
          });
        },
      ):
      const Registerview()
    )
      
    ;
  }
}