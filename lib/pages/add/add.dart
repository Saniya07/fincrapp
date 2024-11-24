import 'package:fincr/assets/colors.dart';
import 'package:fincr/components/buttons.dart';
import 'package:fincr/components/dropdown.dart';
import 'package:fincr/components/filters.dart';
import 'package:fincr/components/listview.dart';
import 'package:fincr/components/modals/modals.dart';
import 'package:fincr/components/navigation.dart';
import 'package:fincr/components/text.dart';
import 'package:fincr/constants/constants.dart';
import 'package:fincr/pages/tracker/tracker.dart';
import 'package:fincr/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class DynamicAdd extends StatefulWidget {
  final int fromScreenNumber;

  final String trackerTopRightFilter = "month";
  final String trackerTransactionTypeFilter = "income";

  DynamicAdd({super.key, this.fromScreenNumber = 0});

  @override
  _DynamicAddState createState() => _DynamicAddState();
}

class _DynamicAddState extends State<DynamicAdd> {
  bool isExpense = true;
  String addState = "";

  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  String selectedCategory = TABLENAMES.CATEGORY;
  String selectedCategoryId = "";

  // variables for expense
  String expenseFromAccount = "";

  // variabled for income
  String incomeToAccount = "";

  // variables for transfer
  Map<String, String> accountsNameToIdMap = {};
  Map<String, String> accountsIdToNameMap = {};
  String transferFromAccountId = "";
  String transferToAccountId = "";

  // variables for friend split add
  List<Map<String, dynamic>> friendsListData = [];
  List<Map<String, dynamic>> usersListData = [];
  List<Map<String, dynamic>> groupsListData = [];
  List<Map<String, dynamic>> selectedFriendsForTransaction = [];
  Map<String, dynamic> splitPaidBy = {};
  String splitMethod = "";
  Map<String, double> amountSplit = {};
  late Map<String, Map<String, dynamic>> selectedPeopleDataMap;

  Map<String, dynamic> liuData = {
    "created_at": "2024-08-17T20:10:45.429442+00:00",
    "updated_at": "2024-08-17T20:10:45.429442+00:00",
    "name": "Saniya",
    "phone_number": "9319759310",
    "profile_picture": "",
    "id": "1e114504-5f6b-4eb7-9403-fd11776a5bb3"
  };

  bool isLoading = true;
  String userId = "1e114504-5f6b-4eb7-9403-fd11776a5bb3";

  @override
  void initState() {
    super.initState();
    if (widget.fromScreenNumber == 0) {
      _getAndSetAccounts();
      addState = "expense";
    } else {
      _getAndSetAccounts();
      addState = "expense";
      getAndSetFriendsAndGroupsData(listFor: "friends");
    }
  }

  void _setAddState(String state) {
    setState(() {
      if (addState != state) {
        addState = state.toLowerCase();
        isExpense = (addState == "expense");
      }
    });
  }

  _getAndSetAccounts() async {
    var data = await getFromTable(TABLENAMES.ACCOUNTS);
    Map<String, String> nameToId = {};
    Map<String, String> IdToName = {};

    for (var d in data) {
      nameToId[d["name"]] = d["id"];
      IdToName[d["id"]] = d["name"];
    }
    await getAndSetPeopleData();
    setState(() {
      accountsNameToIdMap.clear();
      accountsIdToNameMap.clear();

      accountsNameToIdMap = nameToId;
      accountsIdToNameMap = IdToName;

      transferFromAccountId = accountsIdToNameMap.keys.toList()[0];
      transferToAccountId = accountsIdToNameMap.keys.toList()[0];

      expenseFromAccount = accountsIdToNameMap.keys.toList()[0];
      incomeToAccount = accountsIdToNameMap.keys.toList()[0];

      isLoading = false;
    });
  }

  void _done() async {
    String transactionName = nameController.text;
    String transactionAmount = amountController.text;

    String errorMessage = "Please fill ";
    int count = 0;
    if (transactionName.isEmpty) {
      errorMessage += "transaction name";
      count += 1;
    }
    if (transactionAmount.isEmpty) {
      if (count != 0) {
        errorMessage += ", ";
      }
      count += 1;
      errorMessage += "amount";
    }
    if (selectedCategory == TABLENAMES.CATEGORY && addState != "transfer") {
      if (count != 0) {
        errorMessage += " and ";
      }
      errorMessage += TABLENAMES.CATEGORY;
    }

    if (transactionName.isEmpty ||
        transactionAmount.isEmpty ||
        (selectedCategory == TABLENAMES.CATEGORY && addState != "transfer")) {
      showToast(errorMessage, Colors.red, Colors.white);
      return;
    }

    if (addState == "transfer") {
      if (transferFromAccountId == transferToAccountId) {
        showToast(
            "How do you expect me to transfer money from and to same account?",
            Colors.yellow,
            Colors.black);
        return;
      }

      // move money between accounts
      List<Map<String, dynamic>> accountFrom = await getFromTableViaFilter(
          TABLENAMES.ACCOUNTS, "id", transferFromAccountId);
      List<Map<String, dynamic>> accountTo = await getFromTableViaFilter(
          TABLENAMES.ACCOUNTS, "id", transferToAccountId);

      double doubAmount = parseAmountFromString(transactionAmount);
      updateObjectInTable(TABLENAMES.ACCOUNTS, "id", transferFromAccountId,
          {"amount": accountFrom[0]["amount"] - doubAmount});
      updateObjectInTable(TABLENAMES.ACCOUNTS, "id", transferToAccountId,
          {"amount": accountTo[0]["amount"] + doubAmount});
    } else if (addState == "expense") {
      if (expenseFromAccount == "" || expenseFromAccount == null) {
        showToast(
            "What account did you use to pay it?", Colors.yellow, Colors.black);
        return;
      }

      // debit money from the account
      List<Map<String, dynamic>> accountFrom = await getFromTableViaFilter(
          TABLENAMES.ACCOUNTS, "id", expenseFromAccount);
      double doubAmount = parseAmountFromString(transactionAmount);
      updateObjectInTable(TABLENAMES.ACCOUNTS, "id", expenseFromAccount,
          {"amount": accountFrom[0]["amount"] - doubAmount});
    } else if (addState == "income") {
      if (incomeToAccount == "" || incomeToAccount == null) {
        showToast("What account did that money come to?", Colors.yellow,
            Colors.black);
        return;
      }

      // credit money to the account
      List<Map<String, dynamic>> accountTo = await getFromTableViaFilter(
          TABLENAMES.ACCOUNTS, "id", incomeToAccount);
      double doubAmount = parseAmountFromString(transactionAmount);
      updateObjectInTable(TABLENAMES.ACCOUNTS, "id", incomeToAccount,
          {"amount": accountTo[0]["amount"] + doubAmount});
    }

    insertInTable(TABLENAMES.TRANSACTION, {
      "name": transactionName,
      "amount": parseAmountFromString(transactionAmount),
      "is_expense": isExpense,
      "category_id": addState != "transfer" ? selectedCategoryId : null,
      "from_account": addState == "transfer"
          ? transferFromAccountId
          : (addState == "expense" ? expenseFromAccount : null),
      "to_account": addState == "transfer"
          ? transferToAccountId
          : (addState == "income" ? incomeToAccount : null),
    });
  }

  void onExpenseFromAccountSelect(String accountId) {
    setState(() {
      expenseFromAccount = accountId;
    });
  }

  void onIncomeToAccountSelect(String accountId) {
    setState(() {
      incomeToAccount = accountId;
    });
  }

  void onTransferFromSelect(String accountId) {
    setState(() {
      transferFromAccountId = accountId;
    });
  }

  void onTransferToSelect(String accountId) {
    setState(() {
      transferToAccountId = accountId;
    });
  }

  void getAndSetFriendsAndGroupsData({listFor = "all"}) async {
    List<Map<String, dynamic>> friendsData = [];
    List<Map<String, dynamic>> groupsData = [];
    List<Map<String, dynamic>> usersData = [];
    double fOverall = 0.0;
    double gOverall = 0.0;

    var _splitPaidBy = await getFromTableViaFilter(
        "Users", "id", "1e114504-5f6b-4eb7-9403-fd11776a5bb3");

    if (listFor == "friends" || listFor == "all") {
      friendsData = await getFriendsWithReferences(
          "1e114504-5f6b-4eb7-9403-fd11776a5bb3");

      for (var data in friendsData) {
        fOverall += data["linked_amount"];
        usersData.add(data["FriendUser"]);
      }
    }
    if (listFor == "groups" || listFor == "all") {
      groupsData = await getFromTable(TABLENAMES.GROUPS);
    }

    await getAndSetPeopleData();

    setState(() {
      if (listFor == "friends" || listFor == "all") {
        friendsListData = friendsData;
        usersListData = usersData;
        splitPaidBy = _splitPaidBy[0];
      }
      if (listFor == "groups" || listFor == "all") {
        groupsListData = groupsData;
      }
    });

    isLoading = false;
  }

  void onSelectFromListView(
      List<Map<String, dynamic>> _selectedItems, String whatIsSelected) {
    setState(() {
      isLoading = true;
      if (whatIsSelected == "friend_list") {
        setState(() {
          selectedFriendsForTransaction = _selectedItems;
        });
      } else {
        if (_selectedItems.isNotEmpty) {
          setState(() {
            splitPaidBy = _selectedItems[0];
          });
        }
      }
    });
    getAndSetPeopleData();
    isLoading = false;
  }

  // done for friend transaction
  void createFriendSplitTransaction() async {
    String transactionName = nameController.text;
    String transactionAmount = amountController.text;

    String errorMessage = "Please fill ";
    List<String> missingFields = [];
    int count = 0;
    if (transactionName.isEmpty) {
      errorMessage += "transaction name";
      count += 1;
    }
    if (transactionAmount.isEmpty) {
      if (count != 0) {
        errorMessage += ", ";
      }
      errorMessage += "amount";
    }
    if (selectedFriendsForTransaction.isEmpty) {
      if (count != 0) {
        errorMessage += ", ";
      }
      count += 1;
      errorMessage += "friend list";
    }
    if (selectedCategory == TABLENAMES.CATEGORY) {
      if (count != 0) {
        errorMessage += " and ";
      }
      errorMessage += "category";
    }

    if (transactionName.isEmpty ||
        transactionAmount.isEmpty ||
        selectedCategory == TABLENAMES.CATEGORY ||
        selectedFriendsForTransaction.isEmpty) {
      showToast(errorMessage, Colors.red, Colors.white);
      return;
    }

    var friend = await getFromTableViaFilter(TABLENAMES.FRIENDS, "couple",
        [userId, selectedFriendsForTransaction[0]["id"]],
        filterType: "contains");

    var payload = {
      "name": transactionName,
      "amount": parseAmountFromString(transactionAmount),
      "added_by": userId,
      "paid_by": splitPaidBy["id"],
      "friend_id": friend[0]["id"] ?? "",
      "split_method": splitMethod,
      "category_id": selectedCategoryId,
      "split": amountSplit
    };
    if (splitPaidBy["id"] == liuData["id"]) {
      payload["accountId"] = expenseFromAccount;
      // debit from account
      List<Map<String, dynamic>> accountFrom = await getFromTableViaFilter(
          TABLENAMES.ACCOUNTS, "id", expenseFromAccount);
      double doubAmount = parseAmountFromString(transactionAmount);
      updateObjectInTable(TABLENAMES.ACCOUNTS, "id", expenseFromAccount,
          {"amount": accountFrom[0]["amount"] - doubAmount});
    }

    Map<String, dynamic> friendSplitData =
        await insertInTable(TABLENAMES.FRIEND_SPLITS, payload);

    for (var key in amountSplit.keys) {
      payload = {
        "name": transactionName,
        "note": "",
        "amount": amountSplit[key],
        "category_id": selectedCategoryId,
        "is_expense": true,
        "friend_id": friend[0]["id"] ?? "",
        "friend_split_id": friendSplitData["id"],
        "user_id": key,
      };

      // if current user is liuData who paid the split, then add account id
      if (key == splitPaidBy["id"] && splitPaidBy["id"] == liuData["id"]) {
        payload["from_account"] = expenseFromAccount;
      }

      insertInTable(TABLENAMES.TRANSACTION, payload);
    }
  }

  void createGroupSplitTransaction() async {
    String transactionName = nameController.text;
    String transactionAmount = amountController.text;

    String errorMessage = "Please fill ";
    List<String> missingFields = [];
    int count = 0;
    if (transactionName.isEmpty) {
      errorMessage += "transaction name";
      count += 1;
    }
    if (transactionAmount.isEmpty) {
      if (count != 0) {
        errorMessage += ", ";
      }
      errorMessage += "amount";
    }
    if (selectedFriendsForTransaction.isEmpty) {
      if (count != 0) {
        errorMessage += ", ";
      }
      count += 1;
      errorMessage += "friend list";
    }
    if (selectedCategory == TABLENAMES.CATEGORY) {
      if (count != 0) {
        errorMessage += " and ";
      }
      errorMessage += "category";
    }

    if (transactionName.isEmpty ||
        transactionAmount.isEmpty ||
        selectedCategory == TABLENAMES.CATEGORY ||
        selectedFriendsForTransaction.isEmpty) {
      showToast(errorMessage, Colors.red, Colors.white);
      return;
    }

    var group = await getFromTableViaFilter(TABLENAMES.GROUPS, "couple",
        [userId, selectedFriendsForTransaction[0]["id"]],
        filterType: "contains");

    var payload = {
      "name": transactionName,
      "amount": parseAmountFromString(transactionAmount),
      "added_by": userId,
      "paid_by": splitPaidBy["id"],
      "group_id": group[0]["id"] ?? "",
      "split_method": splitMethod,
      "category_id": selectedCategoryId,
      "split": amountSplit
    };
    if (splitPaidBy["id"] == liuData["id"]) {
      payload["accountId"] = expenseFromAccount;
      // debit from account
      List<Map<String, dynamic>> accountFrom = await getFromTableViaFilter(
          TABLENAMES.ACCOUNTS, "id", expenseFromAccount);
      double doubAmount = parseAmountFromString(transactionAmount);
      updateObjectInTable(TABLENAMES.ACCOUNTS, "id", expenseFromAccount,
          {"amount": accountFrom[0]["amount"] - doubAmount});
    }

    Map<String, dynamic> groupSplitData =
        await insertInTable(TABLENAMES.GROUP_SPLITS, payload);

    for (var key in amountSplit.keys) {
      payload = {
        "name": transactionName,
        "note": "",
        "amount": amountSplit[key],
        "category_id": selectedCategoryId,
        "is_expense": true,
        "group_id": group[0]["id"] ?? "",
        "group_split_id": groupSplitData["id"],
        "user_id": key,
      };
      // if current user is liuData who paid the split, then add account id
      if (key == splitPaidBy["id"] && splitPaidBy["id"] == liuData["id"]) {
        payload["from_account"] = expenseFromAccount;
      }
      insertInTable(TABLENAMES.TRANSACTION, payload);
    }
  }

  void onTransSplitSelect(String splitSelected, Map<String, double> split) {
    setState(() {
      splitMethod = splitSelected.toLowerCase();
      amountSplit = split;
    });
  }

  getAndSetPeopleData() async {
    List<Map<String, dynamic>> _selectedPeopleData =
        await getFromTableViaFilter(
            TABLENAMES.USERS,
            "id",
            (selectedFriendsForTransaction + [liuData])
                .map((people) => people["id"].toString()) // Cast to String
                .toList(),
            filterType: "in");
    Map<String, Map<String, dynamic>> peopleMap = {};
    for (var data in _selectedPeopleData) {
      peopleMap[data["id"]] = data;
    }

    setState(() {
      selectedPeopleDataMap = peopleMap;
    });
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
                    if (widget.fromScreenNumber == 0) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                              onPressed: () {
                                print("close clicked");
                              },
                              icon:
                                  const Icon(Icons.close, color: Colors.white)),
                          const Icon(Icons.refresh, color: Colors.white)
                        ],
                      ),
                      const SizedBox(height: 20),
                      FilterSwitchTab(
                        tabTitles: const ["Expense", "Income", "Transfer"],
                        onFilterChange: _setAddState,
                      ),
                    ] else ...[
                      Row(
                        children: [
                          IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.close,
                                  color: Colors.white, size: 32))
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const AppText(
                              text: "With you and: ",
                              fontSize: 14,
                              textColor: Colors.white),
                          GestureDetector(
                            onTap: () {
                              openSelectableListView(
                                  context,
                                  usersListData,
                                  selectedFriendsForTransaction,
                                  onSelectFromListView,
                                  "friend_list",
                                  isMultiSelect: true);
                            },
                            child: const AppText(
                                text: "Select People",
                                fontSize: 14,
                                textColor: CustomColors.appGrey),
                          )
                        ],
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children:
                                selectedFriendsForTransaction.map((person) {
                              return Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width:
                                        2.0, // Set the color and width of the border
                                  ),
                                ),
                                child: CircleAvatar(
                                  backgroundImage: person["profile_picture"] !=
                                              "" &&
                                          person["profile_picture"].isNotEmpty
                                      ? NetworkImage(person["profile_picture"])
                                          as ImageProvider
                                      : const AssetImage(
                                          "lib/assets/netflix.jpg"),
                                  minRadius: 10,
                                  maxRadius: 26,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      if (!isLoading)
                        GestureDetector(
                            onTap: () {
                              openSelectableListView(
                                  context,
                                  selectedFriendsForTransaction +
                                      [
                                        {...liuData, "FriendUser": liuData}
                                      ],
                                  [],
                                  onSelectFromListView,
                                  "split_paid_by",
                                  isMultiSelect: false);
                            },
                            child: Card(
                                elevation: 0,
                                margin: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                                color: CustomColors.appColor,
                                child: ListTile(
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AppText(
                                        text: splitPaidBy["name"],
                                        fontSize: 20,
                                        textColor: Colors.white,
                                      ),
                                    ],
                                  ),
                                  leading: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width:
                                            2.0, // Set the color and width of the border
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      backgroundImage:
                                          splitPaidBy["profile_picture"] !=
                                                      "" &&
                                                  splitPaidBy["profile_picture"]
                                                      .isNotEmpty
                                              ? NetworkImage(splitPaidBy[
                                                      "profile_picture"])
                                                  as ImageProvider
                                              : const AssetImage(
                                                  "lib/assets/netflix.jpg"),
                                      minRadius: 10,
                                      maxRadius: 26,
                                    ),
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios,
                                      size: 24, color: Colors.white),
                                )))
                    ],
                    const SizedBox(height: 32),
                    Row(children: [
                      Expanded(
                          child: AppTextInput(
                              controller: nameController,
                              placeholder: "Name the transaction",
                              keyboardType: TextInputType.text)),
                    ]),
                    const SizedBox(height: 20),
                    Row(children: [
                      Expanded(
                        child: DecimalInputField(controller: amountController),
                      ),
                    ]),
                    const SizedBox(height: 30),

                    if (!isLoading &&
                        ((addState != "transfer" &&
                                widget.fromScreenNumber == 0) ||
                            (widget.fromScreenNumber == 1 &&
                                splitPaidBy["id"] == liuData["id"]))) ...[
                      Column(
                        children: [
                          Row(
                            children: [
                              AppText(
                                  text: addState == "expense" ? "From" : "To",
                                  fontSize: 14,
                                  textColor: Colors.white),
                              const SizedBox(width: 10),
                              DropdownFilter(
                                currenFilter: addState == "expense"
                                    ? expenseFromAccount
                                    : incomeToAccount,
                                onFilterChange: addState == "expense"
                                    ? onExpenseFromAccountSelect
                                    : onIncomeToAccountSelect,
                                dropdownMenuEntries: accountsNameToIdMap,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],

                    if (!isLoading && addState == "transfer")
                      Column(
                        children: [
                          Row(
                            children: [
                              const AppText(
                                  text: "From",
                                  fontSize: 14,
                                  textColor: Colors.white),
                              const SizedBox(width: 10),
                              DropdownFilter(
                                currenFilter: transferFromAccountId,
                                onFilterChange: onTransferFromSelect,
                                dropdownMenuEntries: accountsNameToIdMap,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const AppText(
                                  text: "To",
                                  fontSize: 14,
                                  textColor: Colors.white),
                              const SizedBox(width: 10),
                              DropdownFilter(
                                currenFilter: transferToAccountId,
                                onFilterChange: onTransferToSelect,
                                dropdownMenuEntries: accountsNameToIdMap,
                              ),
                            ],
                          )
                        ],
                      ),
                    const SizedBox(height: 10),
                    // if (!isLoading)
                    if (widget.fromScreenNumber == 1)
                      if (!isLoading)
                        IconButtonRow(
                            selectedPeopleDataMap: selectedPeopleDataMap,
                            selectedPeopleIds: (selectedFriendsForTransaction +
                                        [liuData])
                                    .isNotEmpty
                                ? (selectedFriendsForTransaction + [liuData])
                                    .map((people) => people["id"]
                                        .toString()) // Cast to String
                                    .toList()
                                : [],
                            userId: userId,
                            amountToSplitController: amountController,
                            alreadySplit: amountSplit,
                            iconsMap: const <String, IconData>{
                              "split": Icons.call_split,
                              "share": Icons.bar_chart,
                              "percent": Icons.percent,
                              "manual": Icons.confirmation_num
                            },
                            onIconSelected: onTransSplitSelect),
                    const Spacer(),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.description,
                              color: Colors.white, size: 44),
                          PrimaryButton(
                              buttonText: "Done",
                              buttonTextColor: CustomColors.appColor,
                              buttonColor: Colors.white,
                              buttonOutlineColor: Colors.white,
                              width: 100,
                              height: 52,
                              onPressed: widget.fromScreenNumber == 0
                                  ? _done
                                  : (selectedFriendsForTransaction.length == 1
                                      ? createFriendSplitTransaction
                                      : createGroupSplitTransaction)),
                          if (addState != "transfer")
                            Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20))),
                                child: CategoryBox(
                                  categoryIdentifier: addState.toUpperCase(),
                                  onCategorySelected:
                                      (String categoryId, String category) {
                                    setState(() {
                                      selectedCategory = category;
                                      selectedCategoryId = categoryId;
                                    });
                                  },
                                ))
                        ]),
                    const SizedBox(height: 20)
                  ],
                )))));
  }
}
