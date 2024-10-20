import 'package:fincr/assets/colors.dart';
import 'package:fincr/components/text.dart';
import 'package:fincr/constants/constants.dart';
import 'package:fincr/pages/settings/accounts_settings.dart';
import 'package:fincr/pages/settings/categories_settings.dart';
import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  GestureDetector generateSettingBox(settingText, context, nextPage) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => nextPage));
      },
      child: Container(
        // child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            AppText(text: settingText, fontSize: 20, textColor: Colors.white),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.white)
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: CustomColors.appColor,
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                    child: Column(
                  children: [
                    const AppText(
                        text: "Tracker Settings",
                        fontSize: 20,
                        textColor: Colors.white),
                    generateSettingBox(
                        "Categories", context, CategoriesSettings()),
                    generateSettingBox(
                        TABLENAMES.ACCOUNTS, context, AccountsSettings())
                  ],
                )))));
  }
}
