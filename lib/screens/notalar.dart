import 'package:flutter/material.dart';

class Notalar extends StatefulWidget {
  const Notalar({super.key});

  @override
  State<Notalar> createState() => _NotalarState();
}

class _NotalarState extends State<Notalar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('Hi')
        ],
      ),
    );
  }
}