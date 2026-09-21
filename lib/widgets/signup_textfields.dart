import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:music_intrument/consts/colors/appcolors.dart';
import 'package:music_intrument/gen/assets.gen.dart';
import 'package:music_intrument/providers/sign_up_provider.dart';
import 'package:provider/provider.dart';

class SignupTextfields extends StatelessWidget {
  const SignupTextfields({super.key});

  @override
  Widget build(BuildContext context) {
    final signUp = context.watch<SignUpProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Name:'),
        const SizedBox(height: 6),
        TextFormField(
          controller: signUp.nameController,
          focusNode: signUp.nameFocusNode,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          validator: signUp.validateName,
          decoration: InputDecoration(
            hintText: 'Jasur',
            hintStyle: TextStyle(color: Appcolors.grey500),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(14),
              child: SvgPicture.asset(
                signUp.isNameFocused
                    ? Assets.icons.user.path
                    : Assets.icons.userOkey.path,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  signUp.isNameFocused
                      ? Appcolors.primaryColor
                      : const Color(0xFF8E9BAE),
                  BlendMode.srcIn,
                ),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(19),
              borderSide: BorderSide(color: Appcolors.primaryColor, width: 2),
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
              borderSide: BorderSide(color: Appcolors.red, width: 2),
            ),
            errorStyle: const TextStyle(fontFamily: 'Inter', fontSize: 12),
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
            splashColor: Appcolors.primaryColor.withValues(alpha: 0.1),
            highlightColor: Appcolors.primaryColor.withValues(alpha: 0.1),
          ),
          child: DropdownButtonFormField<String>(
            focusNode: signUp.instrumentFocusNode,
            borderRadius: BorderRadius.circular(27),
            initialValue: signUp.selectedInstrument,
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
                    signUp.isInstrumentFocused
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
                borderSide: BorderSide(color: Appcolors.red, width: 2),
              ),
              errorStyle: const TextStyle(fontFamily: 'Inter', fontSize: 12),
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
            items: signUp.instruments.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            validator: signUp.validateInstrument,
            onChanged: (newValue) {
              context.read<SignUpProvider>().selectInstrument(newValue);
            },
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 40,
          child: ReorderableListView(
            scrollDirection: Axis.horizontal,
            proxyDecorator: (child, index, animation) {
              return Material(color: Colors.transparent, child: child);
            },
            onReorder: (oldIndex, newIndex) {
              context.read<SignUpProvider>().reorderInstruments(
                oldIndex,
                newIndex,
              );
            },
            children: signUp.instruments.map((instrument) {
              final isSelected = instrument == signUp.selectedInstrument;

              return Container(
                key: ValueKey(instrument),
                margin: const EdgeInsets.only(right: 8),
                child: Material(
                  color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF6EA8FE)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
      ],
    );
  }
}
