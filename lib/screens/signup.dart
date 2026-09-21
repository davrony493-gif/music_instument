// ignore_for_file: unused_element, deprecated_member_use, prefer_final_fields, unused_field

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:music_intrument/consts/colors/appcolors.dart';
import 'package:music_intrument/gen/assets.gen.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:music_intrument/mock/musical_instruments.dart';
import 'package:music_intrument/screens/mainscreen.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  List<String> _draggableInstruments = [];
  String? _selectedInstrument;
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _instrumentFocusNode = FocusNode();

  bool _isNameFocused = false;
  bool _isInstrumentFocused = false;

  @override
  void initState() {
    super.initState();
    _draggableInstruments = List.from(MockData.instruments);

    _selectedInstrument = null;

    _nameFocusNode.addListener(() {
      setState(() {
        _isNameFocused = _nameFocusNode.hasFocus;
      });
    });

    _instrumentFocusNode.addListener(() {
      setState(() {
        _isInstrumentFocused = _instrumentFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    _instrumentFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
      return;
    }

    // Captured now: the controller is disposed once this screen is replaced.
    Navigator.pushReplacement(
      context,
      _mainscreenRoute(_nameController.text.trim()),
    );
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
                key: _formKey,
                autovalidateMode: _autovalidateMode,
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
                    const SizedBox(height: 23),
                    const Text('Name:'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nameController,
                      focusNode: _nameFocusNode,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        final name = value?.trim() ?? '';
                        if (name.isEmpty) {
                          return 'Please enter your name';
                        }
                        if (name.length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Jasur',
                        hintStyle: TextStyle(color: Appcolors.grey500),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(14),
                          child: SvgPicture.asset(
                            _nameFocusNode.hasFocus
                                ? Assets.icons.user.path
                                : Assets.icons.userOkey.path,
                            width: 24,
                            height: 24,
                            colorFilter: ColorFilter.mode(
                              _nameFocusNode.hasFocus
                                  ? Appcolors.primaryColor
                                  : const Color(0xFF8E9BAE),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(19),
                          borderSide: BorderSide(
                            color: Appcolors.primaryColor,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(19),
                          borderSide: BorderSide(color: Appcolors.grey300),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(19),
                          borderSide: BorderSide(color: Appcolors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(19),
                          borderSide: BorderSide(
                            color: Appcolors.red,
                            width: 2,
                          ),
                        ),
                        errorStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Main Musical Instrument:',
                      style: TextStyle(color: Appcolors.grey900),
                    ),
                    const SizedBox(height: 6),
                    Theme(
                      data: Theme.of(context).copyWith(
                        hoverColor: Colors.transparent,
                        splashColor: Appcolors.primaryColor.withValues(
                          alpha: 0.1,
                        ),
                        highlightColor: Appcolors.primaryColor.withValues(
                          alpha: 0.1,
                        ),
                      ),
                      child: DropdownButtonFormField<String>(
                        focusNode: _instrumentFocusNode,
                        borderRadius: BorderRadius.circular(27),
                        value: _selectedInstrument,
                        decoration: InputDecoration(
                          hintText: 'Choose your musical instrument ',
                          hintStyle: TextStyle(color: Appcolors.grey500),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: SvgPicture.asset(
                              Assets.icons.disc.path,
                              colorFilter: ColorFilter.mode(
                                _isInstrumentFocused
                                    ? Appcolors.primaryColor
                                    : const Color(0xFF8E9BAE),
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFF2563EB),
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Appcolors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Appcolors.red,
                              width: 2,
                            ),
                          ),
                          errorStyle: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                          ),
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF8E9BAE),
                          size: 28,
                        ),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        items: _draggableInstruments.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        validator: (value) => value == null
                            ? 'Please choose your musical instrument'
                            : null,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedInstrument = newValue;
                            _instrumentFocusNode.unfocus();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 40,
                      child: ReorderableListView(
                        scrollDirection: Axis.horizontal,
                        proxyDecorator: (child, index, animation) {
                          return Material(
                            color: Colors.transparent,
                            child: child,
                          );
                        },
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (oldIndex < newIndex) {
                              newIndex -= 1;
                            }
                            final item = _draggableInstruments.removeAt(
                              oldIndex,
                            );
                            _draggableInstruments.insert(newIndex, item);
                          });
                        },
                        children: _draggableInstruments.map((instrument) {
                          final isSelected = instrument == _selectedInstrument;

                          return Container(
                            key: ValueKey(instrument),
                            margin: const EdgeInsets.only(right: 8),
                            child: Material(
                              color: isSelected
                                  ? const Color(0xFFEFF6FF)
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isSelected
                                      ? const Color(0xFF6EA8FE)
                                      : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Center(
                                  child: Text(
                                    instrument,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      color: isSelected
                                          ? const Color(0xFF2563EB)
                                          : const Color(0xFF475569),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
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
                        onPressed: _submit,
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
