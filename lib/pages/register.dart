import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fincr/assets/colors.dart';
import 'package:fincr/components/buttons.dart';
import 'package:fincr/components/fields.dart';
import 'package:fincr/pages/login_page.dart';
import 'package:fincr/pages/otp.dart';

class Register extends StatelessWidget {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: CustomColors.appColor,
        body: SafeArea(
          // SafeArea avoids notch area
          child: Center(
            child: Column(children: [
              const SizedBox(height: 78),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        "Lets register your account",
                        style: GoogleFonts.poppins(
                          fontSize: 36,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 46),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: SizedBox(
                  height: 52,
                  child: CustomTextField(
                      hintText: "Name",
                      fieldBackgroundColor: CustomColors.appColor,
                      outlineColor: CustomColors.appPrimaryColor,
                      keyboardType: TextInputType.name,
                      filteringTextInputFormatter:
                          FilteringTextInputFormatter.singleLineFormatter),
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  children: [
                    SizedBox(
                      height: 52,
                      child: Container(
                        // margin: const EdgeInsets.all(15.0),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: CustomColors.appPrimaryColor),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: Text(
                          '+91',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                        child: SizedBox(
                            height: 52,
                            child: CustomTextField(
                                hintText: "Enter your phone number",
                                fieldBackgroundColor: CustomColors.appColor,
                                outlineColor: CustomColors.appPrimaryColor,
                                keyboardType: TextInputType.number,
                                filteringTextInputFormatter:
                                    FilteringTextInputFormatter.digitsOnly)))
                  ],
                ),
              ),

              // number input

              const SizedBox(height: 20),

              PrimaryButton(
                buttonText: "Sign Up",
                buttonTextColor: CustomColors.appColor,
                buttonColor: CustomColors.appPrimaryColor,
                buttonOutlineColor: CustomColors.appPrimaryColor,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OTPScreen()),
                ),
              ),

              // log in button
              const SizedBox(height: 24),
              // or
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  children: [
                    const Expanded(child: Divider(color: CustomColors.appGrey)),
                    const SizedBox(width: 16),
                    Text(
                      "or",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: CustomColors.appGrey,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(child: Divider(color: CustomColors.appGrey)),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account ?",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()));
                    },
                    child: Text(
                      "Login",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: CustomColors.appGreen,
                      ),
                    ),
                  ),
                ],
              ),

              Expanded(
                  child: Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Made with",
                          style: GoogleFonts.poppins(
                              fontSize: 16, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.favorite,
                          color: CustomColors.appRed,
                        )
                      ],
                    ),
                    Text(
                      "in BLR",
                      style: GoogleFonts.poppins(
                          fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ))
            ]),
          ),
        ));
  }
}
