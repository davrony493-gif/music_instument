import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:music_intrument/consts/colors/appcolors.dart';
import 'package:music_intrument/gen/assets.gen.dart';

/// A single finished practice session in the "Previous tasks" list.
class Taskcard extends StatelessWidget {
  const Taskcard({
    super.key,
    required this.title,
    required this.when,
    required this.duration,
    this.onTap,
  });

  final String title;
  final String when;
  final String duration;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(20);
    final titleColor = isDark ? Appcolors.white : Appcolors.grey900;
    final mutedSurface = isDark ? Appcolors.grey800 : Appcolors.grey100;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Appcolors.grey900 : Appcolors.white,
        borderRadius:BorderRadius.circular(20) ,
        border: Border.all(color: mutedSurface),
        boxShadow: [
          BoxShadow(
            color: Appcolors.black.withValues(alpha: isDark ? 0.40 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -6,
          ),
        ],
      ),
      // Material sits above the decoration so the ink ripple stays visible.
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: radius),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          minVerticalPadding: 14,
          horizontalTitleGap: 14,
          titleAlignment: ListTileTitleAlignment.center,
          leading: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark
                  ? Appcolors.primaryColor.withValues(alpha: 0.18)
                  : Appcolors.blueSurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: SvgPicture.asset(
                Assets.icons.music.path,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  Appcolors.primaryColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          // One paragraph rather than a Row, so it ellipsizes as a unit.
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Appcolors.grey500,
                ),
                children: [
                  TextSpan(text: when),
                  const TextSpan(text: '   •   '),
                  TextSpan(
                    text: duration,
                    style: TextStyle(
                      color: Appcolors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
         
          trailing: IconButton(
            onPressed: onTap,
            icon: const Icon(Icons.chevron_right_rounded),
            iconSize: 18,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
            style: IconButton.styleFrom(
              backgroundColor: mutedSurface,
              foregroundColor: Appcolors.grey500,
              shape: const CircleBorder(),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
      ),
    );
  }
}
