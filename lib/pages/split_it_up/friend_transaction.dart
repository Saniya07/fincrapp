import 'package:fincr/assets/colors.dart';
import 'package:fincr/components/buttons.dart';
import 'package:fincr/components/dropdown.dart';
import 'package:fincr/components/modals/modals.dart';
import 'package:fincr/components/text.dart';
import 'package:fincr/constants/constants.dart';
import 'package:fincr/utils.dart';
import 'package:flutter/material.dart';

class FriendTransaction extends StatefulWidget {
  String userId = "1e114504-5f6b-4eb7-9403-fd11776a5bb3";

  final String transactionId;
  final TextEditingController nameController;
  final TextEditingController amountController;
  String selectedCategoryId;
  final String paidBy;
  final List<Map<String, dynamic>> friendsListData;
  final List<Map<String, dynamic>> usersListData;
  List<Map<String, dynamic>> selectedFriendsForTransaction;
  Map<String, dynamic> splitPaidBy;
  final Map<String, double> originalSplit;
  Map<String, double> split;
  String splitMethod;
  Map<String, Map<String, dynamic>> selectedPeopleDataMap;

  Map<String, dynamic> liuData;

  void Function() onClose;

  FriendTransaction({
    super.key,
    required this.transactionId,
    required this.nameController,
    required this.amountController,
    required this.selectedCategoryId,
    required this.friendsListData,
    required this.usersListData,
    required this.paidBy,
    required this.split,
    required this.splitMethod,
    required this.onClose,
    this.selectedPeopleDataMap = const {},
    this.liuData = const {
      "created_at": "2024-08-17T20:10:45.429442+00:00",
      "updated_at": "2024-08-17T20:10:45.429442+00:00",
      "name": "Saniya",
      "phone_number": "9319759310",
      "profile_picture": "",
      "id": "1e114504-5f6b-4eb7-9403-fd11776a5bb3"
    },
    required this.selectedFriendsForTransaction,
  })  : originalSplit = split,
        splitPaidBy = (usersListData + [liuData])
            .where((user) => user["id"] == paidBy)
            .toList()[0];

  @override
  _FriendTransactionState createState() => _FriendTransactionState();
}

class _FriendTransactionState extends State<FriendTransaction> {
  String trackerTopRightFilter = "month";
  String trackerTransactionTypeFilter = "all";
  late bool isExpense;
  Key categoryBoxKey = UniqueKey();

  @override
  void initState() {
    super.initState();

    // widget.split = widget.split.map((key, value) {
    //   String newKey;
    //   if (key == widget.userId || key == "user_id") {
    //     newKey = "user_id";
    //   } else {
    //     newKey = "friend_id";
    //   }

    //   return MapEntry(newKey, value);
    // });
    // isExpense = widget.addState.toLowerCase() == "expense";
  }

  getAndSetPeopleData() async {
    List<Map<String, dynamic>> _selectedPeopleData =
        await getFromTableViaFilter(
            TABLENAMES.USERS,
            "id",
            (widget.selectedFriendsForTransaction + [widget.liuData])
                .map((people) => people["id"].toString()) // Cast to String
                .toList(),
            filterType: "in");
    Map<String, Map<String, dynamic>> peopleMap = {};
    for (var data in _selectedPeopleData) {
      peopleMap[data["id"]] = data;
    }

    setState(() {
      widget.selectedPeopleDataMap = peopleMap;
    });
  }

  void onSelectFromListView(
      List<Map<String, dynamic>> _selectedItems, String whatIsSelected) {
    setState(() {
      print(1);
      if (whatIsSelected == "friend_list") {
        setState(() {
          widget.selectedFriendsForTransaction = _selectedItems;
        });
      } else {
        if (_selectedItems != null && _selectedItems.isNotEmpty) {
          setState(() {
            widget.splitPaidBy =
                _selectedItems[0]?["FriendUser"] ?? _selectedItems[0];
          });
        }
      }
    });
    getAndSetPeopleData();
  }

  void _done() async {
    String transactionName = widget.nameController.text;
    String transactionAmount = widget.amountController.text;

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
    if (widget.selectedFriendsForTransaction.isEmpty) {
      if (count != 0) {
        errorMessage += ", ";
      }
      count += 1;
      errorMessage += "friend list";
    }
    if (widget.selectedCategoryId.isEmpty) {
      if (count != 0) {
        errorMessage += " and ";
      }
      errorMessage += "category";
    }

    if (transactionName.isEmpty ||
        transactionAmount.isEmpty ||
        widget.selectedCategoryId.isEmpty) {
      showToast(errorMessage, Colors.red, Colors.white);
      return;
    }

    var friend = await getFromTableViaFilter(TABLENAMES.FRIENDS, "couple",
        [widget.userId, widget.selectedFriendsForTransaction[0]["id"]],
        filterType: "contains");

    var payload = {
      "name": transactionName,
      "amount": parseAmountFromString(transactionAmount),
      "added_by": widget.userId,
      "paid_by": widget.splitPaidBy["id"],
      "friend_id": friend[0]["id"],
      "split_method": widget.splitMethod,
      "category_id": widget.selectedCategoryId,
      "split": widget.split
    };

    Map<String, dynamic> friendSplitData = await updateObjectInTable(
        TABLENAMES.FRIEND_SPLITS, "id", widget.transactionId, payload);

    List<Map<String, dynamic>> existingTransData = await getFromTableViaFilter(
        TABLENAMES.TRANSACTION, "friend_split_id", friendSplitData["id"]);

    for (var data in existingTransData) {
      print(widget.split);
      print(data['user_id']);
//       for (var key in widget.split) {
//         if
// // TODO: figure out how to get widet.split when friend is changed
//         payload = {
//           "name": transactionName,
//           "note": "",
//           "amount": widget.split[data["user_id"]],
//           "category_id": widget.selectedCategoryId,
//           "is_expense": true,
//           "friend_id": friend[0]["id"],
//           "user_id": data["user_id"],
//         };

//         updateObjectInTable(
//           TABLENAMES.TRANSACTION,
//           "id",
//           data["id"],
//           payload,
//         );
//       }
    }

    widget.onClose();

    Navigator.pop(context);
  }

  // on changing split method and split division, update the state
  void onTransSplitSelect(String splitSelected, Map<String, double> split) {
    setState(() {
      widget.splitMethod = splitSelected.toLowerCase();
      widget.split = split;
    });
  }

  void onDeleteFriendSplitTransaction() async {
    await deleteFromTable(TABLENAMES.FRIEND_SPLITS, "id", widget.transactionId);
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.refresh, color: Colors.white),
                        IconButton(
                          onPressed: () {
                            onDeleteFriendSplitTransaction();
                            widget.onClose();
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.delete, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
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
                            widget.usersListData,
                            widget.selectedFriendsForTransaction,
                            onSelectFromListView,
                            "friend_list",
                            isMultiSelect: false);
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
                          widget.selectedFriendsForTransaction.map((person) {
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
                            backgroundImage: person["profile_picture"] != "" &&
                                    person["profile_picture"].isNotEmpty
                                ? NetworkImage(person["profile_picture"])
                                    as ImageProvider
                                : const AssetImage("lib/assets/netflix.jpg"),
                            minRadius: 10,
                            maxRadius: 26,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                GestureDetector(
                    onTap: () {
                      openSelectableListView(
                          context,
                          widget.selectedFriendsForTransaction +
                              [
                                {
                                  ...widget.liuData,
                                  "FriendUser": widget.liuData
                                }
                              ],
                          [],
                          onSelectFromListView,
                          "split_paid_by",
                          isMultiSelect: false);
                      print("gesture tapped");
                    },
                    child: Card(
                        elevation: 0,
                        margin: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                        color: CustomColors.appColor,
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 4),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                text: widget.splitPaidBy["name"],
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
                              backgroundImage: widget
                                              .splitPaidBy["profile_picture"] !=
                                          "" &&
                                      widget.splitPaidBy["profile_picture"]
                                          .isNotEmpty
                                  ? NetworkImage(
                                          widget.splitPaidBy["profile_picture"])
                                      as ImageProvider
                                  : const AssetImage("lib/assets/netflix.jpg"),
                              minRadius: 10,
                              maxRadius: 26,
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios,
                              size: 24, color: Colors.white),
                        ))),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: AppTextInput(
                        controller: widget.nameController,
                        placeholder: "Name the transaction",
                        keyboardType: TextInputType.text,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: DecimalInputField(
                          controller: widget.amountController),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                IconButtonRow(
                    selectedPeopleDataMap: widget.selectedPeopleDataMap,
                    selectedPeopleIds: (widget.selectedFriendsForTransaction +
                                [widget.liuData])
                            .isNotEmpty
                        ? (widget.selectedFriendsForTransaction +
                                [widget.liuData])
                            .map((people) =>
                                people["id"].toString()) // Cast to String
                            .toList()
                        : [],
                    userId: widget.userId,
                    amountToSplitController: widget.amountController,
                    alreadySplit: widget.split,
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
                      onPressed: _done,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                      ),
                      child: CategoryBox(
                        key: categoryBoxKey, // Assign the key here
                        categoryIdentifier: "EXPENSE",
                        onCategorySelected:
                            (String categoryId, String category) {
                          setState(() {
                            widget.selectedCategoryId = categoryId;
                          });
                        },
                        selectedCategoryId: widget.selectedCategoryId,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
