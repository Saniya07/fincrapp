import 'package:fincr/assets/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrimaryButton extends StatelessWidget {
  final String buttonText;
  final Color buttonTextColor;
  final Color buttonColor;
  final Color buttonOutlineColor;
  double width = 380;
  double height = 52;
  final VoidCallback? onPressed;

  PrimaryButton({
    super.key,
    required this.buttonText,
    required this.buttonTextColor,
    required this.buttonColor,
    required this.buttonOutlineColor,
    this.width = 380,
    this.height = 52,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        // foregroundColor: colorScheme.onError,
        foregroundColor: CustomColors.appColor,
        backgroundColor: buttonColor,
        fixedSize: Size(width, height),
        shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            side: BorderSide(color: buttonOutlineColor, width: 2)),
      ),
      onPressed: onPressed,
      child: Text(
        buttonText,
        style: GoogleFonts.poppins(
          fontSize: 20,
          color: buttonTextColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class MultiButtonRow extends StatelessWidget {
  final List<String> buttonTexts;
  final List<Icon> buttonIcons;

  const MultiButtonRow(
      {super.key, required this.buttonTexts, required this.buttonIcons});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(buttonTexts.length, (index) {
        return Column(
          children: [
            CircleAvatar(
                minRadius: 10, maxRadius: 20, child: buttonIcons[index])
          ],
        );
      }),
    );
  }
}
