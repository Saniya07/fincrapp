import 'package:fincr/components/modals/modals.dart';
import 'package:fincr/pages/split_it_up/friend_details.dart';
import 'package:fincr/pages/split_it_up/friend_transaction.dart';
import 'package:fincr/pages/split_it_up/group_details.dart';
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
  String userId = "1e114504-5f6b-4eb7-9403-fd11776a5bb3";

  final int index;
  final String id;
  final String heading;
  final String time;
  final double amount;
  final bool isExpense;
  final String slideableFirstButtonText;
  final String slideableSecondButtonText;
  String selectedCategoryId;
  String fromAccountId;
  String toAccountId;
  String friendId;
  String groupId;
  String addedBy;
  String paidBy;
  Map<String, double> split;
  Map<String, dynamic> friendData;
  List<Map<String, dynamic>> friendsListData;
  List<Map<String, dynamic>> usersListData;
  Map<String, Map<String, dynamic>> selectedPeopleDataMap;
  final ValueChanged<String> slideableActionPressed;

  final String listViewType;
  final Map<String, dynamic> categoryMappings;
  late List<Map<String, dynamic>> selectedFriendsForTransaction = [];
  String splitMethod;

  final void Function() onClose;

  CustomSlideableCard(
      {super.key,
      this.userId = "1e114504-5f6b-4eb7-9403-fd11776a5bb3",
      required this.index,
      required this.id,
      required this.heading,
      required this.time,
      required this.amount,
      required this.isExpense,
      required this.slideableFirstButtonText,
      required this.slideableSecondButtonText,
      required this.slideableActionPressed,
      required this.onClose,
      this.selectedPeopleDataMap = const {},
      this.selectedCategoryId = "",
      this.fromAccountId = "",
      this.toAccountId = "",
      this.friendId = "",
      this.groupId = "",
      this.addedBy = "",
      this.paidBy = "",
      this.splitMethod = "",
      this.friendData = const {},
      Map<String, double>? split,
      this.friendsListData = const [],
      this.usersListData = const [],
      required this.listViewType,
      required this.categoryMappings})
      : split = split ?? <String, double>{},
        selectedFriendsForTransaction = (friendData?["couple"] ?? [])
            .where((id) => id != userId)
            .map((id) {
              final user = friendsListData.firstWhere(
                (user) => user['FriendUser']['id'] == id,
                orElse: () => <String, dynamic>{},
              );
              // Return the nested "FriendUser" field if it exists, otherwise return an empty map
              return user.isNotEmpty ? user['FriendUser'] : <String, dynamic>{};
            })
            .whereType<Map<String, dynamic>>()
            .toList();

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
                      if (listViewType == "")
                        Row(
                          children: [
                            AppText(
                                text: time,
                                fontSize: 12,
                                textColor: Colors.white),
                            if ((friendId.isNotEmpty || groupId.isNotEmpty) &&
                                listViewType == "") ...[
                              const SizedBox(width: 6),
                              Container(
                                width: 1,
                                height: 20,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              AppText(
                                  text: friendId.isNotEmpty
                                      ? "Split with Friend"
                                      : "Split with Group",
                                  fontSize: 12,
                                  textColor: Colors.white)
                            ]
                          ],
                        )
                      else
                        AppText(
                            text:
                                "${paidBy == userId ? 'You' : 'They'} paid ${amount.abs().toString()}",
                            fontSize: 12,
                            textColor: Colors.white),
                    ],
                  ),
                  tileColor: CustomColors.appColor,
                  onTap: () {
                    if ((friendId.isNotEmpty || groupId.isNotEmpty) &&
                        listViewType == "") {
                      showToast("Can't update split from Tracker",
                          Colors.yellow, Colors.black);
                      return;
                    }

                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return listViewType == ""
                            ? Transaction(
                                transactionId: id,
                                nameController:
                                    TextEditingController(text: heading),
                                amountController: TextEditingController(
                                    text: amount.toStringAsFixed(2)),
                                selectedCategoryId: selectedCategoryId,
                                addState: isExpense ? "expense" : "income",
                              )
                            : FriendTransaction(
                                transactionId: id,
                                nameController:
                                    TextEditingController(text: heading),
                                amountController: TextEditingController(
                                    text: amount.toStringAsFixed(2)),
                                selectedCategoryId: selectedCategoryId,
                                friendsListData: friendsListData,
                                usersListData: usersListData,
                                selectedFriendsForTransaction:
                                    selectedFriendsForTransaction,
                                paidBy: paidBy,
                                split: split,
                                splitMethod: splitMethod,
                                selectedPeopleDataMap: selectedPeopleDataMap,
                                onClose: onClose);
                      },
                    ));
                  },
                  leading: Column(
                    children: [
                      Expanded(
                          child: Container(
                        width: 55.0,
                        decoration: BoxDecoration(
                          color: selectedCategoryId != ''
                              ? Color(convertHexcodeToDartColorFormat(
                                  categoryMappings[selectedCategoryId]
                                      ["color"]))
                              : Colors.white, // Background color
                          border: Border.all(width: 1, color: Colors.white),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: selectedCategoryId != ''
                            ? Icon(
                                getIconDataFromString(
                                    categoryMappings[selectedCategoryId]
                                        ["icon"]),
                                color: Colors.white)
                            : const Icon(Icons.move_up, size: 28),
                      )),
                    ],
                  ),
                  trailing: listViewType == ""
                      ? AppText(
                          text: convertAmountFormat(
                              amount.toDouble(), isExpense, removeSign: true),
                          fontSize: 18,
                          textColor: isExpense
                              ? CustomColors.appRed
                              : (fromAccountId == ''
                                  ? CustomColors.appGreen
                                  : CustomColors.appLightGrey))
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AppText(
                                text: paidBy == userId ? "owes you" : "you owe",
                                fontSize: 16,
                                textColor: CustomColors.appLightGrey),
                            AppText(
                                text: paidBy == userId
                                    ? split.entries
                                        .firstWhere(
                                            (entry) => entry.key != userId)
                                        .value
                                        .toString()
                                    : split[userId].toString(),
                                fontSize: 16,
                                textColor: paidBy == userId
                                    ? CustomColors.appRed
                                    : CustomColors.appGreen)
                          ],
                        ))),
        ));
  }
}

class CategorySettingsCard extends StatefulWidget {
  final int index;
  final String id;
  final String heading;
  final bool isExpense;
  final String icon;
  String color;
  TextEditingController headingController;
  String selectedCategoryId;
  final ValueChanged<String> onDeleteCategory;
  final void Function(BuildContext, String, String, String, String, String)
      onUpdateCategory;

  CategorySettingsCard({
    super.key,
    required this.index,
    required this.id,
    required this.heading,
    required this.icon,
    required this.color,
    required this.isExpense,
    this.selectedCategoryId = "",
    required this.onDeleteCategory,
    required this.onUpdateCategory,
  }) : headingController = TextEditingController(text: heading);

  @override
  State<CategorySettingsCard> createState() => _CategorySettingsCardState();
}

class _CategorySettingsCardState extends State<CategorySettingsCard> {
  final ValueNotifier<Color> _colorNotifier =
      ValueNotifier<Color>(Colors.transparent);
  final ValueNotifier<String> _iconNotifier = ValueNotifier<String>('');

  @override
  void initState() {
    super.initState();
    _colorNotifier.value = Color(convertHexcodeToDartColorFormat(widget.color));
    _iconNotifier.value = widget.icon;
  }

  void _resetChanges() {
    _colorNotifier.value = Color(convertHexcodeToDartColorFormat(widget.color));
    _iconNotifier.value = widget.icon;
    widget.headingController.text = widget.heading;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(0, 4, 0, 0),
        color: CustomColors.appColor,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          title: AppText(
            text: widget.heading,
            fontSize: 20,
            textColor: Colors.white,
          ),
          leading: Icon(
            getIconDataFromString(widget.icon),
            color: Colors.white,
            size: 24.0,
          ),
          trailing: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Color(convertHexcodeToDartColorFormat(widget.color)),
              border: Border.all(
                color: Color(convertHexcodeToDartColorFormat(widget.color)),
              ),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
          ),
          onTap: () {
            displayBottomSheetModalForCategory(
                context,
                widget.id,
                '',
                _colorNotifier,
                _iconNotifier,
                _resetChanges,
                widget.onDeleteCategory,
                widget.onUpdateCategory,
                widget.headingController);
          },
        ),
      ),
    );
  }
}

class AccountsSettingsCard extends StatelessWidget {
  final int index;
  final Map<String, dynamic> accountData;
  final void Function(BuildContext, String) onDeleteAccount;
  final void Function(BuildContext, String, String, String, String)
      onUpdateAccount;

  TextEditingController accountNameController;

  AccountsSettingsCard(
      {super.key,
      required this.index,
      required this.accountData,
      required this.onDeleteAccount,
      required this.onUpdateAccount})
      : accountNameController =
            TextEditingController(text: accountData["name"]);

  String getTrailingTextForAccount() {
    if (accountData["is_credit_card"]) {
      return "Credit";
    } else if (accountData["is_investment_account"]) {
      return "Investment";
    }
    return "Account";
  }

  String getFormattedAmountText() {
    String strAmount = convertAmountFormat(
        accountData["amount"].abs().toDouble(), accountData["amount"] < 0);
    return strAmount;
  }

  void resetChanges() {
    accountNameController.text = accountData["name"];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(0, 4, 0, 0),
        color: CustomColors.appColor,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: accountData["name"],
                fontSize: 20,
                textColor: Colors.white,
              ),
              AppText(
                  text: getFormattedAmountText(),
                  fontSize: 16,
                  textColor: accountData["amount"] < 0
                      ? CustomColors.appRed
                      : CustomColors.appGreen)
            ],
          ),
          // leading: Icon(
          //   getIconDataFromString(widget.icon),
          //   color: Colors.white,
          //   size: 24.0,
          // ),
          trailing: AppText(
              text: getTrailingTextForAccount(),
              fontSize: 16,
              textColor: CustomColors.appLightGrey),
          onTap: () {
            displayBottomSheetModalForAccount(
                context,
                accountData,
                null,
                null,
                resetChanges,
                onDeleteAccount,
                onUpdateAccount,
                accountNameController);
          },
        ),
      ),
    );
  }
}

class SplitListCard extends StatelessWidget {
  final String topFilter;
  final int index;
  final Map<String, dynamic> cardData;
  final void Function() onClose;

  const SplitListCard(
      {super.key,
      required this.topFilter,
      required this.index,
      required this.cardData,
      required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Card(
            elevation: 0,
            margin: const EdgeInsets.fromLTRB(0, 4, 0, 0),
            color: CustomColors.appColor,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => topFilter == "friends"
                            ? FriendTransactionsDetails(
                                friendId: cardData["id"],
                                friendData: cardData,
                                parentOnClose: onClose,
                              )
                            : GroupTransactionsDetails(
                                groupId: cardData["id"],
                                groupData: cardData,
                                parentOnClose: onClose,
                              )));
              },
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: cardData["name"] ?? "",
                    fontSize: 20,
                    textColor: Colors.white,
                  ),
                  // AppText(
                  //     text: getFormattedAmountText(),
                  //     fontSize: 16,
                  //     textColor: accountData["amount"] < 0
                  //         ? CustomColors.appRed
                  //         : CustomColors.appGreen)
                ],
              ),
              leading: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2.0, // Set the color and width of the border
                  ),
                ),
                child: CircleAvatar(
                  backgroundImage: cardData["profile_picture"] != "" &&
                          cardData["profile_picture"] != null &&
                          cardData["profile_picture"].isNotEmpty
                      ? NetworkImage(cardData["profile_picture"])
                          as ImageProvider
                      : const AssetImage("lib/assets/netflix.jpg"),
                  minRadius: 10,
                  maxRadius: 26,
                ),
              ),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (cardData["linked_amount"] != null &&
                      cardData["linked_amount"] != 0) ...[
                    AppText(
                        text: cardData["linked_amount"] < 0
                            ? "you owe"
                            : "owes you",
                        fontSize: 14,
                        textColor: Colors.white),
                    AppText(
                        text: "\₹ ${cardData['linked_amount'].abs()}",
                        fontSize: 14,
                        textColor: cardData["linked_amount"] < 0
                            ? CustomColors.appRed
                            : CustomColors.appGreen)
                  ] else ...[
                    const AppText(
                        text: "Settled", fontSize: 14, textColor: Colors.white),
                  ],
                ],
              ),
            )));
  }
}
