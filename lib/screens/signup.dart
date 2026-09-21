// ignore_for_file: unused_element, deprecated_member_use, prefer_final_fields, unused_field

import 'package:flutter/material.dart';
import 'package:music_intrument/consts/colors/appcolors.dart';
import 'package:music_intrument/gen/assets.gen.dart';
import 'package:music_intrument/providers/sign_up_provider.dart';
import 'package:music_intrument/screens/mainscreen.dart';
import 'package:music_intrument/widgets/profile_frame.dart';
import 'package:music_intrument/widgets/signup_textfields.dart';
import 'package:provider/provider.dart';

class Signup extends StatelessWidget {
  const Signup({super.key});

  void _submit(BuildContext context) {
    final signUp = context.read<SignUpProvider>();
    if (!signUp.validateForm()) {
      return;
    }

    // Captured now: the controller is disposed once this screen is replaced.
    Navigator.pushReplacement(context, _mainscreenRoute(signUp.name));
  }

  /// Fades and lifts the main screen into place instead of snapping to it.
  Route<void> _mainscreenRoute(String userName) {
    const curve = Curves.easeOutCubic;

    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) =>
          Mainscreen(userName: userName),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: curve).animate(animation),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).chain(CurveTween(curve: curve)).animate(animation),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final signUp = context.watch<SignUpProvider>();
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              child: Form(
                key: signUp.formKey,
                autovalidateMode: signUp.autovalidateMode,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 40),
                        height: 96,
                        width: 96,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? Appcolors.grey900 : Appcolors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark
                                ? Colors.grey.shade300
                                : Colors.grey.shade300,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Appcolors.black.withValues(
                                alpha: isDark ? 0.45 : 0.10,
                              ),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                              spreadRadius: -6,
                            ),
                            BoxShadow(
                              color: Appcolors.black.withValues(
                                alpha: isDark ? 0.30 : 0.06,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                              spreadRadius: -2,
                            ),
                            BoxShadow(
                              color: Appcolors.primaryColor.withValues(
                                alpha: isDark ? 0.18 : 0.08,
                              ),
                              blurRadius: 32,
                              offset: const Offset(0, 16),
                              spreadRadius: -8,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          Assets.images.logo.path,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'Welcome',
                        style: TextStyle(
                          fontFamily: 'Inter',

                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Container(
                        height: 32,
                        width: 240,
                        decoration: const BoxDecoration(),
                        child: Text(
                          'Your personal profile to master your musical instrument performance.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Appcolors.grey500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 23),
                    //!
                    const ProfileFrame(),
                    //!
                    const SizedBox(height: 23),
                    const SignupTextfields(),
                    //*
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Appcolors.primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => _submit(context),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Continue',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
