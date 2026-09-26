import 'package:flutter/material.dart';
import 'package:music_intrument/mock/musical_instruments.dart';

class SignUpProvider extends ChangeNotifier {
  SignUpProvider() {
  
   
    nameFocusNode.addListener(notifyListeners);
    instrumentFocusNode.addListener(notifyListeners);
  }


  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode instrumentFocusNode = FocusNode();

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  final List<String> _instruments = List.from(MockData.instruments);
  String? _selectedInstrument;

  AutovalidateMode get autovalidateMode => _autovalidateMode;
  List<String> get instruments => _instruments;
  String? get selectedInstrument => _selectedInstrument;
  bool get isNameFocused => nameFocusNode.hasFocus;
  bool get isInstrumentFocused => instrumentFocusNode.hasFocus;
  String get name => nameController.text.trim();

  String? validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) {
      return 'Please enter your name';
    }
    if (name.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? validateInstrument(String? value) {
    return value == null ? 'Please choose your musical instrument' : null;
  }

  void selectInstrument(String? instrument) {
    _selectedInstrument = instrument;
    instrumentFocusNode.unfocus();
    notifyListeners();
  }

  void reorderInstruments(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _instruments.removeAt(oldIndex);
    _instruments.insert(newIndex, item);
    notifyListeners();
  }

  
  bool validateForm() {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!formKey.currentState!.validate()) {
      _autovalidateMode = AutovalidateMode.onUserInteraction;
      notifyListeners();
      return false;
    }
    return true;
  }
  

  @override
  void dispose() {
    nameController.dispose();
    nameFocusNode.dispose();
    instrumentFocusNode.dispose();
    super.dispose();
  }
}
