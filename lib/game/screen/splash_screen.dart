import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fyp_game/game/screen/main_menu.dart';
import 'package:fyp_game/main.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    mapHive.addListener(() {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainMenu(),
        ),
      );
      ;
    });

    return Scaffold(
      body: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(),
          )
          // Add your splash screen UI components here
          ),
    );
  }
}
