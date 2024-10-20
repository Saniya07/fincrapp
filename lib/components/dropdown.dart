import 'package:fincr/components/text.dart';
import 'package:fincr/constants/constants.dart';
import 'package:fincr/utils.dart';
import 'package:flutter/material.dart';

class DropdownFilter extends StatelessWidget {
  final String currenFilter;
  final ValueChanged<String> onFilterChange;
  final Map<String, String> dropdownMenuEntries;

  const DropdownFilter({
    required this.currenFilter,
    required this.onFilterChange,
    required this.dropdownMenuEntries,
  });

  @override
  Widget build(BuildContext context) {
    double maxWidth = dropdownMenuEntries.keys.fold<double>(0, (width, key) {
      final textWidth =
          (key.length * 14.0); // Approximate width for each character
      return textWidth > width ? textWidth : width;
    });

    return Container(
      color: Colors.white,
      height: 24,
      width: maxWidth < 90 ? 90 : maxWidth,
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: DropdownButton<String>(
        value: dropdownMenuEntries.values.contains(currenFilter)
            ? currenFilter
            : dropdownMenuEntries.values.first,
        items: dropdownMenuEntries.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.value,
            child: Text(entry.key),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            onFilterChange(newValue);
          }
        },
      ),
    );
  }
}

class CategoryBox extends StatefulWidget {
  final String categoryIdentifier;
  String selectedCategoryId;
  final void Function(String, String) onCategorySelected;

  CategoryBox(
      {super.key,
      required this.categoryIdentifier,
      required this.onCategorySelected,
      this.selectedCategoryId = ""});

  @override
  _CategoryBoxState createState() => _CategoryBoxState();
}

class _CategoryBoxState extends State<CategoryBox> {
  String selectedCategory = 'Category';
  IconData selectedIcon = Icons.category;

  final Map<String, IconData> expenseIcons = {
    'Food': Icons.fastfood,
    'Transport': Icons.directions_car,
    'Entertainment': Icons.movie,
  };

  final Map<String, IconData> incomeIcons = {
    'Salary': Icons.attach_money,
    'Freelance': Icons.work,
    'Investment': Icons.trending_up,
  };

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    if (widget.selectedCategoryId.isNotEmpty) {
      final _categoryData = await getFromTableViaFilter(
          TABLENAMES.CATEGORY, "id", widget.selectedCategoryId);

      setState(() {
        selectedCategory = _categoryData[0]["name"];
        selectedIcon = getIconDataFromString(_categoryData[0]["icon"]);
      });
    }
  }

  void _showCategorySelection() async {
    List<List<String>> categories = [];
    Map<String, IconData> categoryIcons = {};

    final categoryData = getFromTableViaFilter(
        TABLENAMES.CATEGORY, "category_for", widget.categoryIdentifier);
    for (var data in await categoryData) {
      categories.add([data["id"], data["name"]]);
      categoryIcons[data["name"]] = getIconDataFromString(data["icon"]);
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: Colors.black,
          child: ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              String categoryId = categories[index][0];
              String category = categories[index][1];
              return ListTile(
                leading: Icon(categoryIcons[category], color: Colors.white),
                title: Text(
                  category,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  setState(() {
                    selectedCategory = category;
                    selectedIcon = categoryIcons[category]!;
                  });
                  widget.onCategorySelected(categoryId, category);
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showCategorySelection,
      child: Row(children: [
        Icon(selectedIcon, color: Colors.white),
        const SizedBox(width: 4),
        AppText(text: selectedCategory, fontSize: 18, textColor: Colors.white),
      ]),
    );
  }
}
