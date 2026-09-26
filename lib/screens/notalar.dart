import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:music_intrument/consts/colors/appcolors.dart';
import 'package:music_intrument/gen/assets.gen.dart';
import 'package:music_intrument/providers/notes_provider.dart';
import 'package:music_intrument/screens/note_detail.dart';
import 'package:music_intrument/widgets/notecard.dart';
import 'package:provider/provider.dart';

class Notalar extends StatelessWidget {
  const Notalar({super.key});

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
                  width: double.infinity,
                  child: AdaptiveSegmentedControl(
                    selectedIndex: notesProvider.tab,
                    labels: ['All', 'Favourites', 'Latest'],

                    onValueChanged: (value) =>
                        context.read<NotesProvider>().setTab(value),
                  ),
                ),
                SizedBox(height: 20),
                if (notesProvider.isSearching &&
                    notesProvider.visibleNotes.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      'No notes match "${notesProvider.quest}".',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        height: 1.5,
                        color: Appcolors.grey500,
                      ),
                    ),
                  ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: notesProvider.visibleNotes.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.66, // card width ÷ height
                  ),
                  itemBuilder: (context, index) {
                    final note = notesProvider.visibleNotes[index];
                    return Notecard(
                      title: note['title'],
                      details: note['details'],
                      isChord: note['type'] == 'chord',
                      pageCount: note['pages'],
                      isFavorite: notesProvider.isFavorite(note),
                      onFavoriteTap: () {
                        context.read<NotesProvider>().toggleFavorite(note);
                      },
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => NoteDetail(note: note),
                        ),
                      ),
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
