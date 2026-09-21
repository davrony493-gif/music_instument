import 'package:flutter/material.dart';

class Mashq extends StatefulWidget {
  const Mashq({super.key});

  @override
  State<Mashq> createState() => _MashqState();
}

class _MashqState extends State<Mashq> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('Hello')
        ],
      ),
    );
  }
}