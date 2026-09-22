// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:music_intrument/consts/colors/appcolors.dart';
import 'package:music_intrument/gen/assets.gen.dart';
import 'package:music_intrument/providers/notes_provider.dart';
import 'package:music_intrument/widgets/notecard.dart';
import 'package:provider/provider.dart';

class Notalar extends StatelessWidget {
  const Notalar({super.key});

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
    final notesProvider = context.watch<NotesProvider>();
    final iconColor = notesProvider.isSearchFocused
        ? Appcolors.primaryColor
        : Appcolors.grey500;
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },

      child: Scaffold(
        floatingActionButton: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(context).bottom,
          ),
          child: FloatingActionButton(
            tooltip: 'Add notes ? ',
            shape: const CircleBorder(),
            foregroundColor: Appcolors.primaryColor,
            onPressed: () {},
            child: SvgPicture.asset(
              Assets.icons.plus.path,
              color: Appcolors.white,
            ),
          ),
        ),
        backgroundColor: isDark ? Appcolors.black : const Color(0xFFF2F2F7),
        appBar: AppBar(
          backgroundColor: isDark ? Appcolors.black : const Color(0xFFF2F2F7),
          scrolledUnderElevation: 0,
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
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.paddingOf(context).bottom + 24,
            ),
            child: Column(
              children: [
                ScrollNotificationObserver(
                  child: CupertinoSearchTextField(
                    controller: notesProvider.searchController,
                    focusNode: notesProvider.searchFocusNode,
                    onChanged: (value) =>
                        context.read<NotesProvider>().findInfo(value),
                    onSubmitted: (value) =>
                        context.read<NotesProvider>().findInfoDone(value),
                    onSuffixTap: () => context.read<NotesProvider>().clean(),
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
                      color: isDark
                          ? Appcolors.grey800
                          : const Color(0xFFE8E9ED),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: notesProvider.isSearchFocused
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
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity, // full width, 3 equal segments
                  child: CupertinoSlidingSegmentedControl<int>(
                    groupValue: notesProvider.tab,
                    backgroundColor: const Color(0xFFE8E9ED),
                    thumbColor: Colors.white,
                    padding: const EdgeInsets.all(4),
                    onValueChanged: (value) =>
                        context.read<NotesProvider>().setTab(value!),
                    children: {
                      0: _segment('All', notesProvider.tab == 0),
                      1: _segment('Favourite', notesProvider.tab == 1),
                      2: _segment("Latest", notesProvider.tab == 2),
                    },
                  ),
                ),
                SizedBox(height: 20),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: notesProvider.notes.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.66, // card width ÷ height
                  ),
                  itemBuilder: (context, index) {
                    final note = notesProvider.notes[index];
                    return Notecard(
                      title: note['title'],
                      details: note['details'],
                      isChord: note['type'] == 'chord',
                      pageCount: note['pages'],
                      isFavorite: note['favorite'],
                      onFavoriteTap: () {
                        context.read<NotesProvider>().toggleFavorite(index);
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
