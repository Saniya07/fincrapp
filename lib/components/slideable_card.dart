import 'package:fincr/pages/tracker/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fincr/assets/colors.dart';
import 'package:fincr/components/text.dart';
import 'package:fincr/utils.dart';

class CustomSlideableGroupCard extends StatelessWidget {
  final int index;
  final String slideableFirstButtonText;
  final String slideableSecondButtonText;

  const CustomSlideableGroupCard(
      {super.key,
      required this.index,
      required this.slideableFirstButtonText,
      required this.slideableSecondButtonText});

  @override
  Widget build(BuildContext context) {
    return Slidable(
        endActionPane: ActionPane(
          extentRatio: 0.8,
          motion: const ScrollMotion(),
          children: [
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: SizedBox.expand(
                child: OutlinedButton(
                  onPressed: () => {print("Remind")},
                  style: OutlinedButton.styleFrom(
                    backgroundColor: CustomColors.appRed,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    side: BorderSide.none,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        slideableFirstButtonText,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontSize: 20, color: CustomColors.appColor),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: SizedBox.expand(
                child: OutlinedButton(
                  onPressed: () => {print("Settle")},
                  style: OutlinedButton.styleFrom(
                    backgroundColor: CustomColors.appGreen,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    side: BorderSide.none,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        slideableSecondButtonText,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontSize: 20, color: CustomColors.appColor),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        key: Key(index.toString()),
        child: Container(
          color: CustomColors.appColor,
          child: Card(
              elevation: 0,
              shadowColor: CustomColors.appColor,
              margin: const EdgeInsets.fromLTRB(0, 16, 0, 0),
              child: ListTile(
                contentPadding: const EdgeInsets.all(0),
                title: Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Paridhi Gupta",
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                          ),
                        ),
                        const Row(
                          children: [
                            AppFlexibleText(
                                text: "Paridhi G. owes Sonal D.",
                                fontSize: 14,
                                textColor: CustomColors.appGrey),
                            AppText(
                                text: " \$23.3",
                                fontSize: 14,
                                textColor: CustomColors.appGreen),
                          ],
                        ),
                        const Row(
                          children: [
                            AppFlexibleText(
                                text: "You owe Sonal D.",
                                fontSize: 14,
                                textColor: CustomColors.appGrey),
                            AppText(
                                text: " \$100.3",
                                fontSize: 14,
                                textColor: CustomColors.appRed),
                          ],
                        ),
                        const AppText(
                            text: "Plus 3 more balances",
                            fontSize: 14,
                            textColor: CustomColors.appGrey),
                      ],
                    )),
                tileColor: CustomColors.appColor,
                onTap: () {},
                leading: const CircleAvatar(
                  backgroundImage: AssetImage("lib/assets/netflix.jpg"),
                  minRadius: 10,
                  maxRadius: 26,
                ),
                trailing: const Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AppText(
                        text: "owes you",
                        fontSize: 16,
                        textColor: CustomColors.appGrey),
                    AppText(
                        text: "\$123.3",
                        fontSize: 16,
                        textColor: CustomColors.appGreen),
                  ],
                ),
              )),
        ));
  }
}

class CustomSlideableCard extends StatelessWidget {
  final int index;
  final String id;
  final String heading;
  final String time;
  final double amount;
  final bool isExpense;
  final String slideableFirstButtonText;
  final String slideableSecondButtonText;
  String selectedCategoryId;
  final ValueChanged<String> slideableActionPressed;

  CustomSlideableCard(
      {super.key,
      required this.index,
      required this.id,
      required this.heading,
      required this.time,
      required this.amount,
      required this.isExpense,
      required this.slideableFirstButtonText,
      required this.slideableSecondButtonText,
      required this.slideableActionPressed,
      this.selectedCategoryId = ""});

  @override
  Widget build(BuildContext context) {
    return Slidable(
        endActionPane: ActionPane(
          extentRatio: 0.4,
          motion: const ScrollMotion(),
          children: [
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: SizedBox.expand(
                child: OutlinedButton(
                  onPressed: () {
                    slideableActionPressed(id);
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: CustomColors.appRed,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    side: BorderSide.none,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        slideableFirstButtonText,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontSize: 20, color: Colors.white),
                      )
                    ],
                  ),
                ),
              ),
            ),
            // Expanded(
            //   flex: 1,
            //   child: SizedBox.expand(
            //     child: OutlinedButton(
            //       onPressed: () => {print("Settle")},
            //       style: OutlinedButton.styleFrom(
            //         backgroundColor: CustomColors.appGreen,
            //         shape: const RoundedRectangleBorder(
            //           borderRadius: BorderRadius.zero,
            //         ),
            //         side: BorderSide.none,
            //       ),
            //       child: Column(
            //         mainAxisSize: MainAxisSize.min,
            //         children: [
            //           Text(
            //             slideableSecondButtonText,
            //             textAlign: TextAlign.center,
            //             style: GoogleFonts.poppins(
            //                 fontSize: 20, color: CustomColors.appColor),
            //           )
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
        key: Key(index.toString()),
        child: Container(
          color: CustomColors.appColor,
          child: Card(
              elevation: 0,
              shadowColor: CustomColors.appColor,
              margin: const EdgeInsets.fromLTRB(0, 4, 0, 0),
              child: ListTile(
                contentPadding: const EdgeInsets.all(0),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                        text: heading, fontSize: 20, textColor: Colors.white),
                    AppText(text: time, fontSize: 12, textColor: Colors.white)
                  ],
                ),
                tileColor: CustomColors.appColor,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Transaction(
                          transactionId: id,
                          nameController: TextEditingController(text: heading),
                          amountController: TextEditingController(
                              text: amount.toStringAsFixed(2)),
                          selectedCategoryId: selectedCategoryId,
                          addState: isExpense ? "expense" : "income",
                        ),
                      ));
                },
                leading: Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: 55.0,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                              255, 62, 105, 139), // Background color
                          border: Border.all(width: 1, color: Colors.white),
                          borderRadius:
                              BorderRadius.circular(10.0), // Rounded corners
                          image: const DecorationImage(
                            image: AssetImage("lib/assets/netflix.jpg"),
                            fit: BoxFit.cover, // Fit the image in the container
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: AppText(
                    text: convertAmountFormat(amount, isExpense),
                    fontSize: 18,
                    textColor: isExpense
                        ? CustomColors.appGrey
                        : CustomColors.appGreen),
              )),
        ));
  }
}
