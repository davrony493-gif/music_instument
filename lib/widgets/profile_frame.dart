import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:music_intrument/consts/colors/appcolors.dart';
import 'package:music_intrument/gen/assets.gen.dart';

class ProfileFrame extends StatefulWidget {
  const ProfileFrame({super.key});

  @override
  State<ProfileFrame> createState() => _ProfileFrameState();
}

class _ProfileFrameState extends State<ProfileFrame> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: DottedBorder(
                    options: const CircularDottedBorderOptions(
                      color: Color(0xFF6EA8FE),
                      strokeWidth: 3.0,
                      dashPattern: [8, 6],
                      strokeCap: StrokeCap.round,
                      padding: EdgeInsets.zero,
                    ),
                    child: GestureDetector(
                      onTap: () {},
                      child: SizedBox(
                        width: 88,
                        height: 88,
                        child: Center(
                          child: SvgPicture.asset(
                            Assets.icons.user.path,
                            width: 44,
                            height: 44,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF8E9BAE),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF2563EB,
                          ).withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Assets.icons.plus.svg(
                        width: 14,
                        height: 14,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {},
          child: Center(
            child: Text(
              'Upload your image',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Appcolors.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
