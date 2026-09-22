import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:music_intrument/consts/colors/appcolors.dart';
import 'package:music_intrument/gen/assets.gen.dart';
import 'package:music_intrument/providers/homescreen_provider.dart';
import 'package:music_intrument/widgets/practicecard.dart';
import 'package:music_intrument/widgets/taskcard.dart';
import 'package:provider/provider.dart';

class Homescreen extends StatelessWidget {
  const Homescreen({super.key, required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final homeProvider = context.watch<HomescreenProvider>();
    final iconColor = homeProvider.isSearchFocused
        ? Appcolors.primaryColor
        : Appcolors.grey500;

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        body: SafeArea(
          // extendBody on Mainscreen inflates MediaQuery bottom padding to the
          // nav bar height; opting out lets content scroll behind the glass.
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                bottom: MediaQuery.paddingOf(context).bottom + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  ScrollNotificationObserver(
                    child: CupertinoSearchTextField(
                      controller: homeProvider.searchController,
                      focusNode: homeProvider.searchFocusNode,
                      onChanged: (value) => context
                          .read<HomescreenProvider>()
                          .onSearchChanged(value),
                      onSubmitted: (value) => context
                          .read<HomescreenProvider>()
                          .onSearchSubmitted(value),
                      placeholder: 'Search (notes, tasks)',
                      placeholderStyle: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Appcolors.grey500,
                      ),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Appcolors.white : Appcolors.grey900,
                      ),
                      cursorColor: Appcolors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      decoration: BoxDecoration(
                        color: isDark ? Appcolors.grey800 : Appcolors.grey100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: homeProvider.isSearchFocused
                              ? Appcolors.primaryColor
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      prefixInsets: const EdgeInsetsDirectional.only(
                        start: 16,
                        end: 12,
                      ),
                      prefixIcon: SvgPicture.asset(
                        Assets.icons.search.path,
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                      ),
                      // Mic while empty, clear button once there is text.
                      suffixMode: OverlayVisibilityMode.always,
                      suffixIcon: homeProvider.query.isEmpty
                          ? Icon(CupertinoIcons.mic, color: iconColor)
                          : Icon(
                              CupertinoIcons.xmark_circle_fill,
                              color: Appcolors.grey500,
                            ),
                      onSuffixTap: () =>
                          context.read<HomescreenProvider>().onSuffixTap(),
                      suffixInsets: const EdgeInsetsDirectional.only(end: 16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              homeProvider.todayLabel,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                                color: Appcolors.grey500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Welcome, $userName!',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                height: 1.15,
                                color: isDark
                                    ? Appcolors.white
                                    : Appcolors.grey900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Appcolors.indigo, Appcolors.primaryColor],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Appcolors.primaryColor.withValues(
                                alpha: 0.30,
                              ),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                              spreadRadius: -4,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            homeProvider.initialOf(userName),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Appcolors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Practicecard(
                    completedHours: 8,
                    goalHours: 10,
                    daysCompleted: 4,
                    totalDays: 5,
                    dailyPlanMinutes: 45,
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Previous tasks',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Appcolors.grey500,
                        ),
                      ),
                      // Styling comes from Appthemes.textButtonTheme.
                      TextButton(onPressed: () {}, child: Text('View all')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Mock sessions until practice history is stored.
                  Taskcard(
                    title: 'Mozart — Sonata No. 16',
                    when: 'Yesterday, 18:30',
                    duration: '45 min',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  Taskcard(
                    title: 'Bach — Prelude in C',
                    when: 'Yesterday, 09:15',
                    duration: '30 min',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  Taskcard(
                    title: 'Scales — C major',
                    when: 'Monday, 20:00',
                    duration: '20 min',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
