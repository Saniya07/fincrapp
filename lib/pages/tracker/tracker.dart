import 'package:fincr/components/card.dart';
import 'package:fincr/components/dropdown.dart';
import 'package:fincr/components/listview.dart';
import 'package:fincr/components/text.dart';
import 'package:fincr/constants/constants.dart';
import 'package:fincr/utils.dart';
import 'package:flutter/material.dart';
import 'package:fincr/assets/colors.dart';
import 'package:intl/intl.dart';

class Tracker extends StatefulWidget {
  const Tracker({super.key});

  @override
  _TrackerState createState() => _TrackerState();
}

class _TrackerState extends State<Tracker> {
  String topRightFilter = "month";
  String transactionTypeFilter = "all";
  double totalIncomeBasedOnFilters = 0.0;
  double totalExpensesBasedOnFilters = 0.0;
  Map<String, List<List<dynamic>>> dateSeparatedTransactions = {};
  Map<String, List<List<dynamic>>> filteredDateSeparatedTransactions = {};
  Map<String, dynamic> categoryMappings = {};

  bool isLoading = true;

  // to initialize on loading the screen
  @override
  void initState() {
    super.initState();
    _getAndSetTransactions();
    _getAndSetCateogryMappings();
  }

  void _getAndSetCateogryMappings() async {
    var data = await getFromTable(TABLENAMES.CATEGORY);
    Map<String, Map<String, dynamic>> categMappings = {};

    for (var d in data) {
      categMappings[d["id"]] = d;
    }

    setState(() {
      categoryMappings.clear();
      categoryMappings = categMappings;
      isLoading = false;
    });
  }

  void _getAndSetTransactions() async {
    dateSeparatedTransactions.clear();

    totalIncomeBasedOnFilters = 0.0;
    totalExpensesBasedOnFilters = 0.0;

    final transactions = await getFromTableViaFilter(TABLENAMES.TRANSACTION,
        "user_id", "1e114504-5f6b-4eb7-9403-fd11776a5bb3");

    var result = convertListToDateSeparatedList(transactions, topRightFilter);
    dateSeparatedTransactions = result[0];
    totalIncomeBasedOnFilters = result[1];
    totalExpensesBasedOnFilters = result[2];

    setState(() {});
  }

  void _deleteTransaction(String id) async {
    await deleteFromTable(TABLENAMES.TRANSACTION, "id", id);
    _getAndSetTransactions();
    _getAndSetCateogryMappings();
    _updateTransactionsWithTransactionFilter();
    setState(() {});
  }

  void _updateTransactionsWithTransactionFilter() {
    filteredDateSeparatedTransactions = <String, List<List<dynamic>>>{};

    for (var entry in dateSeparatedTransactions.entries) {
      String date = entry.key;
      List<List<dynamic>> transactions = entry.value;

      for (var transaction in transactions) {
        bool shouldInclude = false;
        if (transaction[4] && transactionTypeFilter == "expenses") {
          shouldInclude = true;
        } else if (!transaction[4] && transactionTypeFilter == "income") {
          shouldInclude = true;
        }

        if (shouldInclude) {
          if (!filteredDateSeparatedTransactions.containsKey(date)) {
            filteredDateSeparatedTransactions[date] = [];
          }
          filteredDateSeparatedTransactions[date]?.add(transaction);
        }
      }
    }
  }

  void _updateFilter(String newFilter) {
    setState(() {
      // only change when newFilter is different from
      // existng filter
      if (topRightFilter != newFilter) {
        topRightFilter = newFilter;
        transactionTypeFilter = "all";
        _getAndSetTransactions();
        _getAndSetCateogryMappings();
      }
    });
  }

  void _updateTransactionTypeFilter(String newFilter) {
    setState(() {
      if (transactionTypeFilter != newFilter) {
        transactionTypeFilter = newFilter;
        _updateTransactionsWithTransactionFilter();
      }
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
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DropdownFilter(
                    currenFilter: topRightFilter,
                    onFilterChange: _updateFilter,
                    dropdownMenuEntries: const {
                      "Month": "month",
                      "Week": "week",
                      "Year": "year"
                    },
                  )
                ],
              ),
              const SizedBox(height: 20),
              const Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                              text: "JUL 2024",
                              fontSize: 16,
                              textColor: CustomColors.appLightGrey),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              AppBoldText(
                                  text: "+₹ ",
                                  fontSize: 20,
                                  textColor: Colors.white),
                              AppBoldText(
                                  text: "1,43,426.00",
                                  fontSize: 24,
                                  textColor: Colors.white)
                            ],
                          )
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AppText(
                              text: "income/day",
                              fontSize: 16,
                              textColor: CustomColors.appLightGrey),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              AppBoldText(
                                  text: "₹ ",
                                  fontSize: 20,
                                  textColor: Colors.white),
                              AppBoldText(
                                  text: "1,426.00",
                                  fontSize: 24,
                                  textColor: Colors.white)
                            ],
                          )
                        ],
                      ),
                    ],
                  )),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      _updateTransactionTypeFilter("all");
                    },
                    child: Container(
                        padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2)),
                        child: const AppText(
                            text: "All",
                            fontSize: 20,
                            textColor: Colors.white)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TrackerTopCard(
                        heading: "Income",
                        icon: const Icon(Icons.north_east,
                            color: Color.fromARGB(255, 158, 236, 167),
                            size: 36),
                        amount: totalIncomeBasedOnFilters,
                        mainColor: const Color.fromARGB(255, 49, 161, 133),
                        onFilterChange: _updateTransactionTypeFilter),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TrackerTopCard(
                        heading: "Expenses",
                        icon: const Icon(Icons.south_east,
                            color: Color.fromARGB(255, 236, 166, 158),
                            size: 36),
                        amount: totalExpensesBasedOnFilters,
                        mainColor: CustomColors.appRed,
                        onFilterChange: _updateTransactionTypeFilter),
                  )
                ],
              ),
              const SizedBox(height: 16),
              if (!isLoading)
                Expanded(
                  child: DateSeparatedListView(
                      dateSeparatedTransactions: transactionTypeFilter == "all"
                          ? dateSeparatedTransactions
                          : filteredDateSeparatedTransactions,
                      slideableActionPressed: _deleteTransaction,
                      categoryMappings: categoryMappings,
                      onClose: () {}),
                )
            ]),
          ),
        ),
      ),
    );
  }
}
