import 'package:fincr/assets/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFlexibleText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color textColor;

  const AppFlexibleText(
      {super.key,
      required this.text,
      required this.fontSize,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Flexible(
        child: Text(
      text,
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.poppins(fontSize: fontSize, color: textColor),
    ));
  }
}

class AppFlexibleFadeText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color textColor;

  const AppFlexibleFadeText(
      {super.key,
      required this.text,
      required this.fontSize,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Flexible(
        child: Text(
      text,
      softWrap: true,
      overflow: TextOverflow.fade,
      style: GoogleFonts.poppins(fontSize: fontSize, color: textColor),
    ));
  }
}

class AppText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color textColor;

  const AppText(
      {super.key,
      required this.text,
      required this.fontSize,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.poppins(fontSize: fontSize, color: textColor),
    );
  }
}

class AppBoldText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color textColor;

  const AppBoldText(
      {super.key,
      required this.text,
      required this.fontSize,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.poppins(
          fontSize: fontSize, color: textColor, fontWeight: FontWeight.bold),
    );
  }
}

class AppTextInput extends StatelessWidget {
  final String placeholder;
  final TextInputType keyboardType;
  final TextEditingController controller;
  double fontSize = 36;

  AppTextInput(
      {super.key,
      required this.placeholder,
      required this.keyboardType,
      required this.controller,
      this.fontSize = 36});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 36),
        decoration: InputDecoration(
          labelText: placeholder,
          hintText: placeholder,
          hintStyle: TextStyle(color: Colors.white, fontSize: fontSize),
          labelStyle: const TextStyle(color: Colors.white),
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
      ),
    );
  }
}

class DecimalInputField extends StatefulWidget {
  final TextEditingController controller;
  final Color textColor;
  void Function(String)? onChanged;

  DecimalInputField({
    Key? key,
    required this.controller,
    this.textColor = Colors.white,
    this.onChanged,
  }) : super(key: key);

  @override
  _DecimalInputFieldState createState() => _DecimalInputFieldState();
}

class _DecimalInputFieldState extends State<DecimalInputField> {
  bool _hasFocus = false;

  void _onChanged(String value) {
    if (value.isEmpty) {
      widget.controller.text = '0.00';
      widget.controller.selection = const TextSelection.collapsed(offset: 4);
      return;
    }

    // Remove any non-digit characters (except for the decimal point).
    String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    // Remove leading zeros
    digitsOnly = digitsOnly.replaceFirst(RegExp(r'^0+(?=\d)'), '');

    // If there are less than 3 digits, pad with leading zeros.
    while (digitsOnly.length < 3) {
      digitsOnly = '0$digitsOnly';
    }

    // Insert the decimal point.
    String formattedValue =
        '${digitsOnly.substring(0, digitsOnly.length - 2)}.${digitsOnly.substring(digitsOnly.length - 2)}';

    // Update the controller text and move the cursor to the end.
    widget.controller.value = TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller.text.isEmpty) {
      widget.controller.text = '0.00';
    }
    widget.controller.addListener(() {
      _onChanged(widget.controller.text);
    });
  }

  // @override
  // void dispose() {
  //   widget.controller.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() {
            _hasFocus = hasFocus;
          });
        },
        child: TextField(
          onChanged: (String text) {
            if (widget.onChanged != null) {
              widget.onChanged!(text);
            }
          },
          controller: widget.controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: 'Enter amount',
            labelStyle: TextStyle(color: widget.textColor),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: CustomColors.appGrey, width: 2.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: widget.textColor, width: 2.0),
            ),
          ),
          style: TextStyle(
              color: _hasFocus ? widget.textColor : CustomColors.appGrey,
              fontSize: 36),
          textAlign: TextAlign.right,
        ),
      ),
    );
  }
}
