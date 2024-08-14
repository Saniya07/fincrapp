import 'package:fincr/components/text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fincr/assets/colors.dart';
import 'package:fincr/components/buttons.dart';
import 'package:fincr/components/card.dart';
import 'package:fincr/components/slideable_card.dart';
import 'package:fincr/utils.dart';

class CustomListView extends StatelessWidget {
  final int itemCount;
  final String slideableFirstButtonText;
  final String slideableSecondButtonText;
  final String slideableCardType;

  const CustomListView(
      {super.key,
      required this.itemCount,
      required this.slideableFirstButtonText,
      required this.slideableSecondButtonText,
      required this.slideableCardType});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == itemCount && slideableCardType != "activity") {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Text(
                  "Hiding friends you settled up with over 7 days ago",
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: CustomColors.appGrey),
                ),
                const SizedBox(
                  height: 8,
                ),
                PrimaryButton(
                    buttonText: "Show 21 settled-up $slideableCardType",
                    buttonTextColor: CustomColors.appPrimaryColor,
                    buttonColor: CustomColors.appColor,
                    buttonOutlineColor: CustomColors.appPrimaryColor),
                const SizedBox(height: 40),
              ],
            ),
          );
        }

        return slideableCardType == "friends"
            ? CustomSlideableCard(
                index: index,
                id: "",
                heading: "as",
                time: "11:00",
                amount: 1212.00,
                isExpense: true,
                slideableFirstButtonText: slideableFirstButtonText,
                slideableSecondButtonText: slideableSecondButtonText,
                slideableActionPressed: (String id) => {print("")})
            : slideableCardType == "groups"
                ? CustomSlideableGroupCard(
                    index: index,
                    slideableFirstButtonText: slideableFirstButtonText,
                    slideableSecondButtonText: slideableSecondButtonText,
                  )
                : ActivityCard(
                    index: index,
                  );
      },
    );
  }
}

class DateSeparatedListView extends StatelessWidget {
  final Map<String, List<List<dynamic>>> dateSeparatedTransactions;
  final ValueChanged<String> slideableActionPressed;

  const DateSeparatedListView(
      {super.key,
      required this.dateSeparatedTransactions,
      required this.slideableActionPressed});

  String _getDayTotal(transacs) {
    double total = 0.0;

    for (var trans in transacs) {
      if (trans[4]) {
        total -= trans[3];
      } else {
        total += trans[3];
      }
    }

    String totalStr = convertAmountFormat(total.abs(), total < 0.0);
    return totalStr;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: dateSeparatedTransactions.length,
      itemBuilder: (context, index) {
        String date = dateSeparatedTransactions.keys.elementAt(index);
        List<List<dynamic>> transactions = dateSeparatedTransactions[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AppText(
                            text: date,
                            fontSize: 16,
                            textColor: CustomColors.appLightGrey),
                        const Spacer(),
                        AppText(
                            text: _getDayTotal(transactions),
                            fontSize: 16,
                            textColor: CustomColors.appLightGrey)
                      ],
                    ),
                    const Divider(color: CustomColors.appLightGrey),
                  ],
                )),
            ...transactions.map((transaction) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 0),
                child: CustomSlideableCard(
                  index: index,
                  id: transaction[0],
                  heading: transaction[1],
                  time: transaction[2],
                  amount: transaction[3],
                  isExpense: transaction[4],
                  slideableFirstButtonText: "Delete",
                  slideableSecondButtonText: "",
                  slideableActionPressed: slideableActionPressed,
                  selectedCategoryId: transaction[5],
                ))),
            const SizedBox(height: 4),
          ],
        );
      },
    );
  }
}

class SingleLineListView extends StatelessWidget {
  final Map<String, List<List<dynamic>>> data;
  final ValueChanged<String> slideableActionPressed;

  const SingleLineListView(
      {super.key, required this.data, required this.slideableActionPressed});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AppText(
                            text: "",
                            fontSize: 16,
                            textColor: CustomColors.appLightGrey),
                        const Spacer(),
                        AppText(
                            text: "1",
                            fontSize: 16,
                            textColor: CustomColors.appLightGrey)
                      ],
                    ),
                    const Divider(color: CustomColors.appLightGrey),
                  ],
                )),
            ...data.map((transaction) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 0),
                child: CustomSlideableCard(
                  index: index,
                  id: transaction[0],
                  heading: transaction[1],
                  time: transaction[2],
                  amount: transaction[3],
                  isExpense: transaction[4],
                  slideableFirstButtonText: "Delete",
                  slideableSecondButtonText: "",
                  slideableActionPressed: slideableActionPressed,
                  selectedCategoryId: transaction[5],
                ))),
            const SizedBox(height: 4),
          ],
        );
      },
    );
  }
}
