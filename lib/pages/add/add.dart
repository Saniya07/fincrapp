import 'package:fincr/assets/colors.dart';
import 'package:fincr/components/buttons.dart';
import 'package:fincr/components/dropdown.dart';
import 'package:fincr/components/filters.dart';
import 'package:fincr/components/text.dart';
import 'package:fincr/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DynamicAdd extends StatefulWidget {
  final String trackerTopRightFilter = "month";
  final String trackerTransactionTypeFilter = "income";

  const DynamicAdd({super.key});

  @override
  _DynamicAddState createState() => _DynamicAddState();
}

class _DynamicAddState extends State<DynamicAdd> {
  bool isExpense = true;
  String addState = "expense";

  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  String selectedCategory = "Category";
  String selectedCategoryId = "";

  void _setAddState(String state) {
    setState(() {
      if (addState != state) {
        addState = state.toLowerCase();
        isExpense = (addState == "expense");
      }
    });
  }

  void _done() {
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
    if (selectedCategory == "Category") {
      if (count != 0) {
        errorMessage += " and ";
      }
      errorMessage += "category";
    }

    if (transactionName.isEmpty ||
        transactionAmount.isEmpty ||
        selectedCategory == "Category") {
      showToast(errorMessage, Colors.red, Colors.white);
    } else {
      print('Transaction Name: $transactionName');
      print('Transaction Amount: $transactionAmount');
      print('Selected Category: $selectedCategory');
      print('Selected Cateogry ID: $selectedCategoryId');
      print(isExpense);
      insertInTable("Transaction", {
        "name": transactionName,
        "amount": parseAmountFromString(transactionAmount),
        "is_expense": isExpense,
        "category_id": selectedCategoryId
      });
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
                        const Icon(Icons.close, color: Colors.white),
                        FilterSwitchTab(
                          tabTitles: const ["Expense", "Income"],
                          onFilterChange: _setAddState,
                        ),
                        const Icon(Icons.refresh, color: Colors.white)
                      ],
                    ),
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
                              onPressed: _done),
                          Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.white, width: 2),
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
