import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:music_intrument/consts/colors/appcolors.dart';
import 'package:music_intrument/gen/assets.gen.dart';
import 'package:music_intrument/widgets/practicecard.dart';
import 'package:music_intrument/widgets/taskcard.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key, required this.userName});

  final String userName;

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _isSearchFocused = false;
  String _query = '';

  @override
  void initState() {
    super.initState();

    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _query = value;
    });
  }

  void _onSearchSubmitted(String value) {
    _searchFocusNode.unfocus();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _query = '';
    });
    _searchFocusNode.requestFocus();
  }

  void _startVoiceSearch() {}

  static const List<String> _months = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];
  //* Gotta change down here !

  String get _todayLabel {
    final now = DateTime.now();
    return 'TODAY, ${now.day} ${_months[now.month - 1]}';
  }

  String get _initial {
    final name = widget.userName.trim();
    return name.isEmpty ? 'No name' : name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = _isSearchFocused
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
              padding: EdgeInsets.only(
                bottom: MediaQuery.paddingOf(context).bottom + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    textInputAction: TextInputAction.search,
                    cursorColor: Appcolors.primaryColor,
                    onChanged: _onSearchChanged,
                    onSubmitted: _onSearchSubmitted,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Appcolors.white : Appcolors.grey900,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? Appcolors.grey800 : Appcolors.grey100,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      hintText: 'Search (notes, tasks)',
                      hintStyle: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Appcolors.grey500,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 12),
                        child: SvgPicture.asset(
                          Assets.icons.search.path,
                          width: 20,
                          height: 20,
                          colorFilter: ColorFilter.mode(
                            iconColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),
                      suffixIcon: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _query.isEmpty
                            ? _startVoiceSearch
                            : _clearSearch,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
                          child: _query.isEmpty
                              ? SvgPicture.asset(
                                  Assets.icons.voice.path,
                                  width: 20,
                                  height: 20,
                                  colorFilter: ColorFilter.mode(
                                    iconColor,
                                    BlendMode.srcIn,
                                  ),
                                )
                              : Icon(
                                  Icons.close_rounded,
                                  size: 20,
                                  color: Appcolors.grey500,
                                ),
                        ),
                      ),
                      suffixIconConstraints: const BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Appcolors.primaryColor,
                          width: 2,
                        ),
                      ),
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
                              _todayLabel,
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
                              'Welcome, ${widget.userName}!',
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
                            _initial,
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
