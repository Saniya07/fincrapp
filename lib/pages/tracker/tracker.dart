import 'package:fincr/components/card.dart';
import 'package:fincr/components/dropdown.dart';
import 'package:fincr/components/listview.dart';
import 'package:fincr/components/text.dart';
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

  // to initialize on loading the screen
  @override
  void initState() {
    super.initState();
    _getAndSetTransactions();
  }

  void _getAndSetTransactions() async {
    final now = DateTime.now();
    DateFormat dateFormat = DateFormat('EEE, MMM dd');

    dateSeparatedTransactions.clear();

    totalIncomeBasedOnFilters = 0.0;
    totalExpensesBasedOnFilters = 0.0;

    final transactions = await supabase
        .from('Transaction')
        .select("*")
        .order("created_at", ascending: false);

    for (var transaction in transactions) {
      DateTime createdAt = DateTime.parse(transaction['created_at']);
      bool shouldInclude = false;

      if (topRightFilter == 'month' &&
          createdAt.month == now.month &&
          createdAt.year == now.year) {
        shouldInclude = true;
      } else if (topRightFilter == 'week') {
        final startOfWeek = now.subtract(Duration(days: now.weekday));
        final endOfWeek = startOfWeek.add(const Duration(days: 8));

        if (createdAt.isAfter(startOfWeek) && createdAt.isBefore(endOfWeek)) {
          shouldInclude = true;
        }
      } else if (topRightFilter == 'year' && createdAt.year == now.year) {
        shouldInclude = true;
      }

      if (shouldInclude) {
        String dateKey = dateFormat.format(createdAt);
        if (!dateSeparatedTransactions.containsKey(dateKey)) {
          dateSeparatedTransactions[dateKey] = [];
        }

        if (!transaction["is_expense"]) {
          totalIncomeBasedOnFilters += transaction["amount"];
        } else {
          totalExpensesBasedOnFilters += transaction["amount"];
        }

        dateSeparatedTransactions[dateKey]?.add([
          transaction["id"],
          transaction["name"],
          DateFormat('HH:mm').format(createdAt),
          double.parse(transaction["amount"].toStringAsFixed(2)),
          transaction["is_expense"],
          transaction["category_id"],
        ]);
      }
    }
    setState(() {});
  }

  void _deleteTransaction(String id) async {
    await deleteFromTable("Transaction", "id", id);
    _getAndSetTransactions();
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
                    topRightFilter: topRightFilter,
                    onFilterChange: _updateFilter,
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
              Expanded(
                child: DateSeparatedListView(
                    dateSeparatedTransactions: transactionTypeFilter == "all"
                        ? dateSeparatedTransactions
                        : filteredDateSeparatedTransactions,
                    slideableActionPressed: _deleteTransaction),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
