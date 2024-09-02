import 'package:fincr/assets/colors.dart';
import 'package:fincr/components/buttons.dart';
import 'package:fincr/components/filters.dart';
import 'package:fincr/components/listview.dart';
import 'package:fincr/components/modals/modals.dart';
import 'package:fincr/components/text.dart';
import 'package:fincr/constants/constants.dart';
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
    // Fetch categories based on the current categoryType
    var _categories = await getFromTableViaFilter(
        TABLENAMES.CATEGORY, "category_for", categoryType.toUpperCase());
    setState(() {
      categories.clear();
      categories = _categories;
    });
  }

  void _deleteCategory(String categId) async {
    var transactionsForCategory = await getFromTableViaFilter(
        TABLENAMES.TRANSACTION, "category_id", categId);

    if (transactionsForCategory.isNotEmpty) {
      showToast("This Category already has Transactions. Can not delete.",
          Colors.red, Colors.white);
      return;
    }

    await deleteFromTable(TABLENAMES.CATEGORY, "id", categId);
    _getAndSetCategories();
  }

  void _updateCategory(BuildContext _context, String id, String heading,
      String icon, String color, String categType) {
    if (heading == '' || icon == '' || color == '') {
      showToast("Please fill all the fields", Colors.red, Colors.white);
      return;
    }
    Map payload = {
      "name": heading,
      "icon": icon,
      "color": color,
    };
    updateObjectInTable(TABLENAMES.CATEGORY, "id", id, payload);
    Navigator.pop(_context);
    _getAndSetCategories();
  }

  void _createCategory(BuildContext _context, String id, String heading,
      String icon, String color, String categType) {
    if (heading == '' || icon == '' || color == '' || categType == '') {
      showToast("Please fill all fields", Colors.red, Colors.white);
      return;
    }

    insertInTable(TABLENAMES.CATEGORY, {
      "name": heading,
      "icon": icon,
      "color": color,
      "category_for": categType.toUpperCase()
    });
    Navigator.pop(_context);
    _getAndSetCategories();
  }

  void _onFilterChange(String categType) {
    // Only update if the categoryType has actually changed
    if (categoryType != categType) {
      setState(() {
        categories.clear();
        categoryType = categType;
      });
      _getAndSetCategories();
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
                    const SizedBox(height: 8),
                    FilterSwitchTab(
                        tabTitles: const ["Expense", "Income"],
                        onFilterChange: _onFilterChange),
                    Expanded(
                        child: CategoryListView(
                            data: categories,
                            onDeleteCategory: _deleteCategory,
                            onUpdateCategory: _updateCategory)),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: PrimaryButton(
                          buttonText: "Add new $categoryType Category",
                          buttonTextColor: CustomColors.appColor,
                          buttonColor: Colors.white,
                          buttonOutlineColor: Colors.white,
                          onPressed: () {
                            displayBottomSheetModalForCategory(
                                context,
                                '',
                                categoryType,
                                null,
                                null,
                                null,
                                null,
                                _createCategory,
                                null);
                          }),
                    )
                  ],
                )))));
  }
}
