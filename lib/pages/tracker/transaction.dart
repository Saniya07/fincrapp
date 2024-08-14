import 'package:fincr/assets/colors.dart';
import 'package:fincr/components/buttons.dart';
import 'package:fincr/components/dropdown.dart';
import 'package:fincr/components/filters.dart';
import 'package:fincr/components/text.dart';
import 'package:fincr/pages/tracker/tracker.dart';
import 'package:fincr/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Transaction extends StatefulWidget {
  final String transactionId;
  final TextEditingController nameController;
  final TextEditingController amountController;
  String selectedCategoryId;
  String addState;

  Transaction({
    super.key,
    required this.transactionId,
    required this.nameController,
    required this.amountController,
    required this.selectedCategoryId,
    required this.addState,
  });

  @override
  _TransactionState createState() => _TransactionState();
}

class _TransactionState extends State<Transaction> {
  String trackerTopRightFilter = "month";
  String trackerTransactionTypeFilter = "all";
  late bool isExpense;
  Key categoryBoxKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    isExpense = widget.addState.toLowerCase() == "expense";
  }

  void _done() {
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
      errorMessage += "category";
    }

    if (transactionName.isEmpty ||
        transactionAmount.isEmpty ||
        widget.selectedCategoryId.isEmpty) {
      showToast(errorMessage, Colors.red, Colors.white);
    } else {
      print('Transaction Name: $transactionName');
      print('Transaction Amount: $transactionAmount');
      print('Selected Category ID: ${widget.selectedCategoryId}');
      print(isExpense);

      updateObjectInTable("Transaction", "id", widget.transactionId, {
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
