import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:music_intrument/consts/colors/appcolors.dart';
import 'package:music_intrument/gen/assets.gen.dart';

class Notalar extends StatefulWidget {
  const Notalar({super.key});

  @override
  State<Notalar> createState() => _NotalarState();
}

class _NotalarState extends State<Notalar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _isSearchFocused = false;
  String quest = '';
  int tab = 0;

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

  void _findInfo(String value) {
    setState(() {
      quest = value;
    });
  }

  void _findInfodone(String value) {
    _searchFocusNode.unfocus();
  }

  void _clean() {
    _searchController.clear();
    setState(() {
      quest = '';
    });
    _searchFocusNode.requestFocus();
  }

  //!interesting part
  Widget _segment(String label, bool selected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: selected ? Appcolors.grey900 : Appcolors.grey500,
        ),
      ),
    );
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
        appBar: AppBar(
          toolbarHeight: 80,
          leadingWidth: 180,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NOTES',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '18 sheet music and chords',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Appcolors.grey500,
                  ),
                ),
              ],
            ),
          ),
          actionsPadding: EdgeInsets.only(right: 20, bottom: 10),
          actions: [
            IconButton.filled(
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                fixedSize: const Size(42, 42),
              ),
              onPressed: () {},
              icon: SvgPicture.asset(
                Assets.icons.svg.path,
                width: 20,
                height: 20,
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              CupertinoSearchTextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _findInfo,
                onSubmitted: _findInfodone,
                onSuffixTap: _clean,
                placeholder: 'Composer or piece name...',
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
                    color: _isSearchFocused
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
                suffixInsets: const EdgeInsetsDirectional.only(end: 16),
                itemColor: Appcolors.grey500,
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity, // full width, 3 equal segments
                child: CupertinoSlidingSegmentedControl<int>(
                  groupValue: tab,
                  backgroundColor: const Color(
                    0xFFE8E9ED,
                  ), // track color from your image
                  thumbColor: Colors.white,
                  padding: const EdgeInsets.all(4),
                  onValueChanged: (value) => setState(() => tab = value!),
                  children: {
                    0: _segment('All', tab == 0),
                    1: _segment('Favourite', tab == 1),
                    2: _segment("Latest", tab == 2),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
