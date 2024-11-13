import 'package:appointment/appointmentsView.dart';
import 'package:appointment/bookView.dart';
import 'package:appointment/pages/auth/registerView.dart';
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
  late PageController pageController;

  @override
  void initState() {
    initAuth();
    pageController = PageController();
    super.initState();
  }

  void initAuth() async{
    bool isAuthenticated = await AuthService().initAuth();
    setState(() {
      widget.isLoggedIn = isAuthenticated;
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
      
      body: widget.isLoggedIn ? PageView(
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