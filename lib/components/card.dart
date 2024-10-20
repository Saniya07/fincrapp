import 'package:fincr/utils.dart';
import 'package:flutter/material.dart';
import 'package:fincr/assets/colors.dart';
import 'package:fincr/components/text.dart';

class ActivityCard extends StatelessWidget {
  final int index;

  const ActivityCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CustomColors.appColor,
      child: Card(
          elevation: 0,
          shadowColor: CustomColors.appColor,
          margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
          child: ListTile(
              contentPadding: const EdgeInsets.all(0),
              title: const Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppFlexibleFadeText(
                          text: "Paridhi G. added McDonalds in Joint Account",
                          fontSize: 18,
                          textColor: Colors.white),
                      AppFlexibleFadeText(
                          text: "You get back \$204.00",
                          fontSize: 16,
                          textColor: CustomColors.appGreen),
                      SizedBox(height: 10),
                      AppFlexibleText(
                          text: "17 May, 2024 at 18:07",
                          fontSize: 12,
                          textColor: CustomColors.appGrey),
                    ],
                  )),
              tileColor: CustomColors.appColor,
              onTap: () {},
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(0.0),
                child: Image.asset(
                  "lib/assets/netflix.jpg",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ))),
    );
  }
}

class TrackerTopCard extends StatelessWidget {
  final String heading;
  final Icon icon;
  final double amount;
  final Color mainColor;
  final ValueChanged<String> onFilterChange;

// _updateTransactionTypeFilter
  const TrackerTopCard({
    super.key,
    required this.heading,
    required this.icon,
    required this.amount,
    required this.mainColor,
    required this.onFilterChange,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          onFilterChange(heading.toLowerCase());
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
          decoration: BoxDecoration(
            border: Border.all(width: 2, color: Colors.white),
            borderRadius: BorderRadius.circular(12),
            color: CustomColors.appColor, // Background color for the card
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: mainColor,
                  border: Border.all(width: 2, color: mainColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: icon,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: heading,
                      fontSize: 16,
                      textColor: Colors.white,
                    ),
                    AppBoldText(
                      text: convertAmountFormat(amount.toDouble(), false),
                      fontSize: 20,
                      textColor: mainColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
