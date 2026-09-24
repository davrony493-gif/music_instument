// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:music_intrument/consts/colors/appcolors.dart';
import 'package:music_intrument/screens/history.dart';
import 'package:music_intrument/screens/homescreen.dart';
import 'package:music_intrument/screens/mashq.dart';
import 'package:music_intrument/screens/notalar.dart';
import 'package:native_glass_navbar/native_glass_navbar.dart';

class Mainscreen extends StatefulWidget {
  const Mainscreen({super.key, required this.userName});

  final String userName;

  @override
  State<Mainscreen> createState() => _MainscreenState();
}

class _MainscreenState extends State<Mainscreen> {
  int selected = 0;
 
  late final List<Widget> _pages = [
    Homescreen(userName: widget.userName),
    const Notalar(),
    const Mashq(),
    const History(),
  ];

  Widget _buildAndroidNavBar(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.38),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withOpacity(0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: selected,
              onTap: (index) {
                setState(() {
                  selected = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: theme.colorScheme.primary,
              unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
              showUnselectedLabels: true,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.grid_view_outlined),
                  activeIcon: Icon(Icons.grid_view_rounded),
                  label: 'Asosiy',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu_book_outlined),
                  activeIcon: Icon(Icons.menu_book_rounded),
                  label: 'Notalar',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.timer_outlined),
                  activeIcon: Icon(Icons.timer_rounded),
                  label: 'Mashq',
                ),
              
                BottomNavigationBarItem(
                  icon: Icon(Icons.history_rounded),
                  activeIcon: Icon(Icons.history_rounded),
                  label: 'Tarix',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIosNavBar(BuildContext context) {
   

    return NativeGlassNavBar(
      tintColor: Appcolors.primaryColor,
      currentIndex: selected,
      onTap: (index) {
        setState(() {
          selected = index;
        });
      },
      tabs: const [
        NativeGlassNavBarItem(label: 'Main', symbol: 'square.grid.2x2'),
        NativeGlassNavBarItem(label: 'Notes', symbol: 'book'),
        NativeGlassNavBarItem(label: 'Tasks', symbol: 'timer'),
       
        NativeGlassNavBarItem(label: 'History', symbol: 'clock.arrow.circlepath'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[selected],
      bottomNavigationBar: Platform.isAndroid
          ? _buildAndroidNavBar(context)
          : _buildIosNavBar(context),
    );
  }
}
