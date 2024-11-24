import 'package:fincr/assets/colors.dart';
import 'package:fincr/components/buttons.dart';
import 'package:fincr/components/dropdown.dart';
import 'package:fincr/components/filters.dart';
import 'package:fincr/components/text.dart';
import 'package:fincr/constants/constants.dart';
import 'package:fincr/pages/tracker/tracker.dart';
import 'package:fincr/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// EDIT TRANSACTION PAGE
class Transaction extends StatefulWidget {
  final String transactionId;
  final TextEditingController nameController;
  final TextEditingController amountController;
  String selectedCategoryId;
  String addState;
  bool currentIsExpense;
  String currentAccountId;
  double currentAmount;

  Transaction(
      {super.key,
      required this.transactionId,
      required this.nameController,
      required this.amountController,
      required this.selectedCategoryId,
      required this.addState,
      required this.currentIsExpense,
      required this.currentAccountId,
      required this.currentAmount});

  @override
  _TransactionState createState() => _TransactionState();
}

class _TransactionState extends State<Transaction> {
  String trackerTopRightFilter = "month";
  String trackerTransactionTypeFilter = "all";
  late bool isExpense;
  Key categoryBoxKey = UniqueKey();
  String newAccountId = "";
  Map<String, String> accountsNameToIdMap = {};
  Map<String, String> accountsIdToNameMap = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    isExpense = widget.addState.toLowerCase() == "expense";
    newAccountId = widget.currentAccountId;

    _getAndSetAccounts();
  }

  _getAndSetAccounts() async {
    var data = await getFromTable(TABLENAMES.ACCOUNTS);
    Map<String, String> nameToId = {};
    Map<String, String> IdToName = {};

    for (var d in data) {
      nameToId[d["name"]] = d["id"];
      IdToName[d["id"]] = d["name"];
    }
    setState(() {
      accountsNameToIdMap.clear();
      accountsIdToNameMap.clear();

      accountsNameToIdMap = nameToId;
      accountsIdToNameMap = IdToName;

      isLoading = false;
    });
  }

  void onChangingAccount(String newAccId) {
    if (newAccId != null && newAccId != "") {
      newAccountId = newAccId;
    }
  }

  void _done() async {
    String transactionName = widget.nameController.text;
    String transactionAmount = widget.amountController.text;

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
    if (widget.selectedCategoryId.isEmpty) {
      if (count != 0) {
        errorMessage += " and ";
      }
      errorMessage += TABLENAMES.CATEGORY;
    }

    if (transactionName.isEmpty ||
        transactionAmount.isEmpty ||
        widget.selectedCategoryId.isEmpty) {
      showToast(errorMessage, Colors.red, Colors.white);
    } else {
      Map<String, dynamic> payload = {
        "name": transactionName,
        "amount": parseAmountFromString(transactionAmount),
        "is_expense": isExpense,
        "category_id": widget.selectedCategoryId,
        "updated_at": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())
      };

      // if isExpense changes or accountId changes or totalAmount changes, then update the same in account ids
      if (widget.currentIsExpense != isExpense ||
          widget.currentAccountId != newAccountId ||
          widget.currentAmount != parseAmountFromString(transactionAmount)) {
        // update in old account
        List<Map<String, dynamic>> oldAccount = await getFromTableViaFilter(
            TABLENAMES.ACCOUNTS, "id", widget.currentAccountId);
        double updatedAmount = oldAccount[0]["amount"];
        if (widget.currentIsExpense) {
          updatedAmount += widget.currentAmount;
        } else {
          updatedAmount -= widget.currentAmount;
        }
        updateObjectInTable(TABLENAMES.ACCOUNTS, "id", widget.currentAccountId,
            {"amount": updatedAmount});

        // update in new account
        List<Map<String, dynamic>> newAccount = await getFromTableViaFilter(
            TABLENAMES.ACCOUNTS, "id", newAccountId);
        updatedAmount = newAccount[0]["amount"];
        if (isExpense) {
          updatedAmount -= parseAmountFromString(transactionAmount);
        } else {
          updatedAmount += parseAmountFromString(transactionAmount);
        }
        updateObjectInTable(
            TABLENAMES.ACCOUNTS, "id", newAccountId, {"amount": updatedAmount});
      }

      updateObjectInTable(TABLENAMES.TRANSACTION, "id", widget.transactionId, {
        "name": transactionName,
        "amount": parseAmountFromString(transactionAmount),
        "is_expense": isExpense,
        "category_id": widget.selectedCategoryId,
        "updated_at": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())
      });

      Navigator.pop(
        context,
        MaterialPageRoute(
          builder: (context) => const Tracker(),
          settings: RouteSettings(
            arguments: {
              'topRightFilter': trackerTopRightFilter,
              'transactionTypeFilter': trackerTransactionTypeFilter,
            },
          ),
        ),
      );

      // Navigator.pop(context, {
      //   'topRightFilter': trackerTopRightFilter,
      //   'transactionTypeFilter': trackerTransactionTypeFilter,
      //   'refresh': true
      // });
    }
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
                        setState(() {});
                        Navigator.pop(context, {
                          'topRightFilter': trackerTopRightFilter,
                          'transactionTypeFilter': trackerTransactionTypeFilter,
                        });
                      },
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                    FilterSwitchTab(
                      tabTitles: const ["Expense", "Income"],
                      onFilterChange: (String state) {
                        setState(() {
                          widget.addState = state.toLowerCase();
                          isExpense = (widget.addState == "expense");
                          widget.selectedCategoryId = "";
                          categoryBoxKey =
                              UniqueKey(); // Update the key to force rebuild
                        });
                      },
                    ),
                    const Icon(Icons.refresh, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 32),
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
                const SizedBox(height: 20),
                Column(
                  children: [
                    Row(
                      children: [
                        AppText(
                            text: widget.addState == "expense" ? "From" : "To",
                            fontSize: 14,
                            textColor: Colors.white),
                        const SizedBox(width: 10),
                        if (!isLoading)
                          DropdownFilter(
                            currenFilter: widget.currentAccountId,
                            onFilterChange: onChangingAccount,
                            dropdownMenuEntries: accountsNameToIdMap,
                          ),
                      ],
                    ),
                  ],
                ),
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
                        categoryIdentifier: widget.addState.toUpperCase(),
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
