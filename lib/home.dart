import 'package:appointment/appointmentsView.dart';
import 'package:appointment/bookView.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}


class _HomeState extends State<Home> {
  int _page = 0;
  late PageController pageController;

  @override
  void initState() {
    pageController = PageController();
    super.initState();
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
      
      body: PageView(
        controller: pageController,
        // physics: const NeverScrollableScrollPhysics(),
        children: const [BookView(),Appointmentsview()],
        onPageChanged: (value) {
          setState(() {
            _page = value;
          });
        },
      )
    );
  }
}