import 'package:fincr/assets/colors.dart';
import 'package:fincr/components/filters.dart';
import 'package:fincr/components/text.dart';
import 'package:fincr/utils.dart';
import 'package:flutter/material.dart';

class CategoriesSettings extends StatefulWidget {
  const CategoriesSettings({super.key});

  @override
  _CategoriesSettingsState createState() => _CategoriesSettingsState();
}

class _CategoriesSettingsState extends State<CategoriesSettings> {
  String categoryType = "Expense";
  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    _getAndSetCategories();
  }

  void _getAndSetCategories() async {
    var _categories =
        await getFromTableViaFilter("Category", "category_for", categoryType);
    setState(() {
      categories = _categories;
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
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          color: Colors.white,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        const AppText(
                            text: "Categories",
                            fontSize: 20,
                            textColor: Colors.white)
                      ],
                    ),
                    FilterSwitchTab(
                        tabTitles: ["Expense", "Income"],
                        onFilterChange: (String categType) {
                          categoryType = categType;
                          print(categoryType);
                        }),
                    ListView()
                  ],
                )))));
  }
}
