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
                slideableActionPressed: (String id) => {print("")},
                listViewType: "",
                onClose: () {},
                categoryMappings: {},
              )
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
  final Map<String, dynamic> categoryMappings;

  String listViewType = "";
  Map<String, dynamic> friendData;
  List<Map<String, dynamic>> friendsListData = [];
  List<Map<String, dynamic>> usersListData = [];
  Map<String, Map<String, dynamic>> selectedPeopleDataMap = {};

  final void Function() onClose;

  DateSeparatedListView(
      {super.key,
      required this.dateSeparatedTransactions,
      required this.slideableActionPressed,
      required this.categoryMappings,
      this.selectedPeopleDataMap = const {},
      this.listViewType = "",
      this.friendData = const {},
      this.friendsListData = const [],
      this.usersListData = const [],
      required this.onClose});

  String _getDayTotal(transacs) {
    double total = 0.0;

    for (var trans in transacs) {
      if (trans[6] != '') {
        continue;
      }
      if (trans[4]) {
        total -= trans[3];
      } else {
        total += trans[3];
      }
    }

    String totalStr = convertAmountFormat(total.abs().toDouble(), total < 0.0);
    return totalStr;
  }

  @override
  Widget build(BuildContext context) {
    if (dateSeparatedTransactions.isEmpty) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppText(
              text: "No Transactions",
              fontSize: 24,
              textColor: CustomColors.appLightGrey)
        ],
      );
    }

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
                        if (listViewType == "")
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
                    fromAccountId: transaction[6],
                    toAccountId: transaction[7],
                    friendId: transaction[8],
                    groupId: transaction[9],
                    addedBy: transaction[10],
                    paidBy: transaction[11],
                    split: (transaction[12] as Map<String, dynamic>).map(
                      (key, value) => MapEntry(
                        key,
                        value is double ? value : value.toDouble(),
                      ),
                    ),
                    splitMethod: transaction[13],
                    listViewType: listViewType,
                    friendsListData: friendsListData,
                    usersListData: usersListData,
                    friendData: friendData,
                    categoryMappings: categoryMappings,
                    selectedPeopleDataMap: selectedPeopleDataMap,
                    onClose: onClose))),
            const SizedBox(height: 4),
          ],
        );
      },
    );
  }
}

class CategoryListView extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final ValueChanged<String> onDeleteCategory;
  final void Function(BuildContext, String, String, String, String, String)
      onUpdateCategory;

  const CategoryListView(
      {super.key,
      required this.data,
      required this.onDeleteCategory,
      required this.onUpdateCategory});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        var d = data[index]; // Get the item at the current index
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: CategorySettingsCard(
              index: index,
              id: d["id"].toString(),
              heading: d["name"].toString(),
              icon: d["icon"],
              color: d["color"],
              isExpense: d["category_for"] == "EXPENSE",
              selectedCategoryId: "",
              onDeleteCategory: onDeleteCategory,
              onUpdateCategory: onUpdateCategory),
        );
      },
    );
  }
}

class AccountsSettingsListView extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final void Function(BuildContext, String) onDeleteAccount;
  final void Function(BuildContext, String, String, String, String)
      onUpdateAccount;

  const AccountsSettingsListView(
      {super.key,
      required this.data,
      required this.onDeleteAccount,
      required this.onUpdateAccount});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        var d = data[index]; // Get the item at the current index
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: AccountsSettingsCard(
              index: index,
              accountData: d,
              onDeleteAccount: onDeleteAccount,
              onUpdateAccount: onUpdateAccount),
        );
      },
    );
  }
}

class SplitListView extends StatelessWidget {
  final String topFilter;
  final List<Map<String, dynamic>> data;
  final void Function() onClose;

  const SplitListView(
      {super.key,
      required this.topFilter,
      required this.data,
      required this.onClose});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        var d = data[index]; // Get the item at the current index
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: SplitListCard(
              index: index,
              topFilter: topFilter,
              cardData: d,
              onClose: onClose),
        );
      },
    );
  }
}
