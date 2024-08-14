import 'package:fincr/components/text.dart';
import 'package:fincr/utils.dart';
import 'package:flutter/material.dart';

const List<String> list = <String>['month', 'week', 'year'];

class DropdownFilter extends StatelessWidget {
  final String topRightFilter;
  final ValueChanged<String> onFilterChange;

  const DropdownFilter({
    required this.topRightFilter,
    required this.onFilterChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 24,
      width: 90,
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: DropdownButton<String>(
        value: topRightFilter,
        items: const <DropdownMenuItem<String>>[
          DropdownMenuItem(value: "month", child: Text("Month")),
          DropdownMenuItem(value: "week", child: Text("Week")),
          DropdownMenuItem(value: "year", child: Text("Year")),
        ],
        onChanged: (String? newValue) {
          if (newValue != null) {
            onFilterChange(newValue);
          }
        },
      ),
    );
  }
}

// class DropdownFilter extends StatefulWidget {
//   String topRightFilter;

//   DropdownFilter({super.key, required this.topRightFilter});

//   @override
//   State<DropdownFilter> createState() => _DropdownMenuExampleState();
// }

// class _DropdownMenuExampleState extends State<DropdownFilter> {
//   late String dropdownValue = list.first;

//   @override
//   void initState() {
//     super.initState();
//     dropdownValue = widget.topRightFilter;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         decoration: BoxDecoration(
//           color: Colors.white, // Set the background color to white
//           borderRadius:
//               BorderRadius.circular(8), // Optional: Add rounded corners
//           // boxShadow: [
//           //   BoxShadow(
//           //     color: Colors.grey.withOpacity(0.5), // Shadow color
//           //     spreadRadius: 1, // Spread radius
//           //     blurRadius: 5, // Blur radius
//           //     offset: Offset(0, 3), // Offset in x and y direction
//           //   ),
//           // ],
//         ),
//         child: DropdownMenu<String>(
//           width: 120,
//           initialSelection: list.first,
//           textStyle: TextStyle(color: CustomColors.appColor, fontSize: 16),
//           onSelected: (String? value) {
//             // This is called when the user selects an item.
//             setState(() {
//               dropdownValue = value!;
//               widget.topRightFilter = value;
//             });
//           },
//           dropdownMenuEntries:
//               list.map<DropdownMenuEntry<String>>((String value) {
//             return DropdownMenuEntry<String>(value: value, label: value);
//           }).toList(),
//         ));
//   }
// }

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
    print("initializing data");
    if (widget.selectedCategoryId.isNotEmpty) {
      final _categoryData = await getFromTableViaFilter(
          "Category", "id", widget.selectedCategoryId);
      // print(_categoryData);
      setState(() {
        selectedCategory = _categoryData[0]["name"];
        selectedIcon = getIconDataFromString(_categoryData[0]["icon"]);
      });
    }
    print(selectedCategory);
    print(selectedIcon);
  }

  void _showCategorySelection() async {
    List<List<String>> categories = [];
    Map<String, IconData> categoryIcons = {};
    print(widget.categoryIdentifier);
    final categoryData = getFromTableViaFilter(
        "Category", "category_for", widget.categoryIdentifier);
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
