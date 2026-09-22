import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:music_intrument/consts/colors/appcolors.dart';

class Notecard extends StatelessWidget {
  const Notecard({
    super.key,
    required this.title,
    required this.details,
    this.pageCount,
    this.isChord = false,
    this.isFavorite = false,
    this.onFavoriteTap,
  });

  final String title;
  final String details;
  final int? pageCount; 
  final bool isChord; 
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  static const Color _pdfRed = Color(0xFFDD524C);
  static const Color _chordBlue = Color(0xFF3662E3);

  Color get _accent => isChord ? _chordBlue : _pdfRed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Appcolors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Appcolors.grey100),
        boxShadow: const [
          BoxShadow(
            color: Colors.white,
            blurRadius: 5,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [_buildPreview(), _buildInfo()],
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      height: 112,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isChord ? const Color(0xFFF6FAFF) : const Color(0xFFFDF7F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isChord ? const Color(0xFFE7F0FD) : const Color(0xFFF9E3E2),
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: 8, left: 8, child: _buildBadge()),
          Positioned(top: 6, right: 6, child: _buildStar()),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isChord
                      ? CupertinoIcons.music_note_2
                      : Icons.description_outlined,
                  size: 44,
                  color: _accent,
                ),
                const SizedBox(height: 4),
                Text(
                  isChord ? 'Chords' : '$pageCount page',
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontFamilyFallback: ['monospace'],
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: _accent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isChord ? 'CHORD' : 'PDF',
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStar() {
    return GestureDetector(
      onTap: onFavoriteTap,
      child: RatingBarIndicator(
        rating: 1, 
        itemCount: 1,
        itemSize: 22,
        itemBuilder: (context, index) => isFavorite
            ? const Icon(Icons.star_rounded, color: Color(0xFFF2C14B))
            : Icon(Icons.star_border_rounded, color: Appcolors.grey300),
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Appcolors.grey900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          details,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            color: Appcolors.grey500,
          ),
        ),
      ],
    );
  }
}
