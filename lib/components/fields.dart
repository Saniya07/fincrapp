import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fincr/assets/colors.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final Color fieldBackgroundColor;
  final Color outlineColor;
  final TextInputType keyboardType;
  final TextInputFormatter filteringTextInputFormatter;

  const CustomTextField(
      {super.key,
      required this.hintText,
      required this.fieldBackgroundColor,
      required this.outlineColor,
      required this.keyboardType,
      required this.filteringTextInputFormatter});

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: keyboardType,
      inputFormatters: <TextInputFormatter>[filteringTextInputFormatter],
      decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: CustomColors.appPrimaryColor),
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: CustomColors.appPrimaryColor),
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          fillColor: fieldBackgroundColor,
          filled: true,
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            fontSize: 18,
            color: Colors.white,
          )),
    );
  }
}
