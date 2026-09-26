import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:music_intrument/gen/assets.gen.dart';
import 'package:music_intrument/providers/sign_up_provider.dart';
import 'package:music_intrument/screens/mainscreen.dart';
import 'package:music_intrument/screens/signup.dart';
import 'package:music_intrument/services/permission_serivce.dart';
import 'package:provider/provider.dart';

class Onborading extends StatefulWidget {
  const Onborading({super.key});

  @override
  State<Onborading> createState() => _OnboradingState();
}

class _OnboradingState extends State<Onborading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(
    parent: _entrance,
    curve: Curves.easeOut,
  );

  late final Animation<double> _scale = Tween<double>(
    begin: 0.85,
    end: 1,
  ).animate(CurvedAnimation(parent: _entrance, curve: Curves.easeOutBack));

  late final Animation<double> _waveFade = CurvedAnimation(
    parent: _entrance,
    curve: const Interval(0.5, 1, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      PermissionSerivce.requestGallery();
    });

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;

      final savedName = GetStorage().read<String>('userName');
      Navigator.pushReplacement(
        context,
        PageRouteBuilder<void>(
          transitionDuration: const Duration(milliseconds: 700),
          pageBuilder: (context, animation, secondaryAnimation) =>
              savedName == null
              ? ChangeNotifierProvider(
                  create: (_) => SignUpProvider(),
                  child: const Signup(),
                )
              : Mainscreen(userName: savedName),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.15, 0),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Hero(
                tag: 'logo',
                child: FadeTransition(
                  opacity: _fade,
                  child: ScaleTransition(
                    scale: _scale,
                    child: Image.asset(
                      Assets.images.logo.path,
                      fit: BoxFit.cover,
                      width: 80,
                      height: 80,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FadeTransition(
                opacity: _waveFade,
                child: Assets.lotties.wave.lottie(
                  width: 140,
                  height: 46,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
