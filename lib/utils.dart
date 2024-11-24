import 'package:fincr/components/modals/modals.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = SupabaseClient("https://aobzyijbbfxncpyqpeae.supabase.co",
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFvYnp5aWpiYmZ4bmNweXFwZWFlIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcyMjE1MjM4MywiZXhwIjoyMDM3NzI4MzgzfQ.bH70qtyYb3FtsyCV0v2_1YoQpVj-GQ_5K1396Z9Fnow");

String convertAmountFormat(double money, bool addMinus,
    {bool removeSign = false}) {
  // Create a NumberFormat instance for the Indian numbering system with two decimal places
  final formatter = NumberFormat('##,##,##,##,##,##,##,##0.00', 'en_IN');

  // Format the amount
  String formattedAmount = formatter.format(money);

  if (removeSign) {
    return "\₹ $formattedAmount";
  }

  // Return the formatted string with the currency symbol
  return addMinus ? "-\₹ $formattedAmount" : "+\₹ $formattedAmount";
}

void showToast(errorMessage, backgroundColor, textColor) {
  Fluttertoast.showToast(
    msg: errorMessage,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.SNACKBAR,
    timeInSecForIosWeb: 2,
    backgroundColor: backgroundColor,
    textColor: textColor,
    fontSize: 16.0,
  );
}

// void getFromTableByName(tableName, filterName) {
//   final data =
//       supabase.from(tableName).select().inFilter('name', ['ONLINE', 'OFFLINE']);
//   ;
// }

Future<List<Map<String, dynamic>>> getFromTable(tableName) async {
  final data = await supabase
      .from(tableName)
      .select("*")
      .order("created_at", ascending: false);
  return data;
}

Future<List<Map<String, dynamic>>> getFromTableWithReference(
    String tableName,
    String foreignTableName,
    String foreignField,
    String fieldFromForeign) async {
  final data = await supabase.from(tableName).select(
      "*,$foreignTableName!${tableName}_${foreignField}_fkey($fieldFromForeign),Transaction(id, name, added_by, amount, transaction_split)");
  return data;
}

Future<List<Map<String, dynamic>>> getFriendsWithReferences(userId) async {
  final data = await supabase
      .from("Friends")
      .select("*, FriendSplits(*)")
      .contains("couple", [userId]);

  List<String> userIds = [];
  for (var friend in data) {
    userIds.addAll(List<String>.from(friend['couple']));
  }
  final userData =
      await supabase.from("Users").select().filter("id", "in", userIds);
  Map<String, Map<String, dynamic>> userDataMap = {};
  for (var usr in userData) {
    userDataMap[usr["id"]] = usr;
  }
  for (var friend in data) {
    friend["linked_amount"] = 0.0;
    for (var c in friend["couple"]) {
      if (c != userId) {
        friend["name"] = userDataMap[c]?["name"] ?? "";
        friend["profile_picture"] = userDataMap[c]?["profile_picture"] ?? "";
        friend["FriendUser"] = userDataMap[c] ?? {};
        for (var trans in friend["FriendSplits"]) {
          if (trans["paid_by"] == userId) {
            friend["linked_amount"] += trans["split"][c] ?? 0.0;
          } else {
            friend["linked_amount"] -= trans["split"][userId] ?? 0.0;
          }
        }
      }
    }
  }

  data.sort((a, b) =>
      (a['linked_amount'] as double).compareTo(b['linked_amount'] as double));

  return data;
}

Future<List<Map<String, dynamic>>> getGroupsWithReferences(userId) async {
  final data = await supabase
      .from("Groups")
      .select("*, GroupSplits(*)")
      .contains("couple", [userId]);

  List<String> userIds = [];
  for (var group in data) {
    userIds.addAll(List<String>.from(group['couple']));
  }
  final userData =
      await supabase.from("Users").select().filter("id", "in", userIds);
  Map<String, Map<String, dynamic>> userDataMap = {};
  for (var usr in userData) {
    userDataMap[usr["id"]] = usr;
  }
  for (var group in data) {
    group["linked_amount"] = 0.0;
    group["GroupUsers"] = [];

    for (var trans in group["GroupSplits"]) {
      double totalExceptLIU = 0;
      for (var c in group["couple"]) {
        if (c != userId) {
          group["GroupUsers"].add(userDataMap[c] ?? {});
          totalExceptLIU += trans["split"][c] ?? 0.0;
        }
      }

      if (trans["paid_by"] == userId) {
        group["linked_amount"] += totalExceptLIU;
      } else {
        group["linked_amount"] -= trans["split"][userId] ?? 0.0;
      }
    }
  }

  data.sort((a, b) =>
      (a['linked_amount'] as double).compareTo(b['linked_amount'] as double));

  return data;
}

Future<List<Map<String, dynamic>>> getFromTableViaFilter(
    tableName, filterColumn, filterValue,
    {filterType = "eq"}) async {
  final data;
  if (filterType == "eq") {
    data = await supabase
        .from(tableName)
        .select()
        .eq(filterColumn, filterValue)
        .order("created_at", ascending: false);
  } else if (filterType == "contains") {
    data = await supabase
        .from(tableName)
        .select()
        .contains(filterColumn, filterValue)
        .order("created_at", ascending: false);
  } else {
    data = await supabase
        .from(tableName)
        .select()
        .inFilter(filterColumn, filterValue)
        .order("created_at", ascending: false);
  }

  return data;
}

Future<bool> deleteFromTable(tableName, filterColumn, filterValue) async {
  await supabase.from(tableName).delete().eq(filterColumn, filterValue);
  return true;
}

Future<Map<String, dynamic>> insertInTable(tableName, payload) async {
  return await supabase.from(tableName).insert([payload]).select().single();
}

Future<Map<String, dynamic>> updateObjectInTable(
    tableName, filterColumn, filterValue, payload,
    {filterColumn1 = "", filterValue1 = ""}) async {
  if (filterColumn1.isNotEmpty) {
    return await supabase
        .from(tableName)
        .update(payload)
        .eq(filterColumn, filterValue)
        .eq(filterColumn1, filterValue1)
        .select()
        .single();
  }

  return await supabase
      .from(tableName)
      .update(payload)
      .eq(filterColumn, filterValue)
      .select()
      .single();
}

IconData getIconDataFromString(String stringUnicode) {
  return IconData(int.parse(stringUnicode.replaceFirst('U+', ''), radix: 16),
      fontFamily: 'MaterialIcons');
}

String getUnicodeFromIconData(IconData iconData) {
  // Extract the code point from the IconData
  final int codePoint = iconData.codePoint;

  // Convert the code point to a hexadecimal string
  final String hexString = codePoint.toRadixString(16).toUpperCase();

  // Format it as a Unicode string (e.g., 'U+1F600')
  return 'U+${hexString.padLeft(4, '0')}';
}

double parseAmountFromString(String transactionAmount) {
  if (transactionAmount.isEmpty) {
    return 0.00;
  }

  // Parse the string to a double
  double amount = double.parse(transactionAmount);

  // Format the double to two decimal places and then parse it back to double
  amount = double.parse(amount.toStringAsFixed(2));

  return amount;
}

int convertHexcodeToDartColorFormat(String hexcode) {
  // Remove the '#' character
  String cleanedHexCode = hexcode.replaceFirst('#', '');

  // Convert to the Dart color format by adding '0xFF'
  String dartColorFormat = '0xFF$cleanedHexCode';

  return int.parse(dartColorFormat);
}

String convertDartColorToHexcode(Color color) {
  String hexColor =
      '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  return hexColor;
}

List<dynamic> convertListToDateSeparatedList(
    List<dynamic> transactions, String topRightFilter,
    {String userId = ""}) {
  Map<String, List<List<dynamic>>> dateSeparatedTransactions = {};

  final now = DateTime.now();
  DateFormat dateFormat = DateFormat('EEE, MMM dd');

  double totalIncomeBasedOnFilters = 0.0;
  double totalExpensesBasedOnFilters = 0.0;

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

    if (topRightFilter == "overall") {
      shouldInclude = true;
    } else if (topRightFilter == "you owe") {
      if (transaction["paid_by"] != userId) {
        shouldInclude = true;
      }
    } else if (topRightFilter == "owes you") {
      if (transaction["paid_by"] == userId) {
        shouldInclude = true;
      }
    }

    if (shouldInclude) {
      String dateKey = dateFormat.format(createdAt);
      if (!dateSeparatedTransactions.containsKey(dateKey)) {
        dateSeparatedTransactions[dateKey] = [];
      }

      if (transaction?["is_expense"] != null && !transaction["is_expense"]) {
        totalIncomeBasedOnFilters += transaction["amount"];
      } else {
        totalExpensesBasedOnFilters += transaction["amount"];
      }

      dateSeparatedTransactions[dateKey]?.add([
        transaction["id"],
        transaction["name"],
        DateFormat('HH:mm').format(createdAt),
        double.parse(transaction["amount"].toStringAsFixed(2)),
        transaction?["is_expense"] ?? false,
        transaction?["category_id"] ?? "",
        transaction?["from_account"] ?? transaction?["accountId"] ?? "",
        transaction?["to_account"] ?? "",
        transaction?["friend_id"] ?? "",
        transaction?["group_id"] ?? "",
        transaction?["added_by"] ?? "",
        transaction?["paid_by"] ?? "",
        transaction?["split"] ?? <String, double>{},
        transaction?["split_method"] ?? ""
      ]);
    }
  }
  return [
    dateSeparatedTransactions,
    totalIncomeBasedOnFilters,
    totalExpensesBasedOnFilters
  ];
}

bool listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) {
    return b == null;
  }
  if (b == null || a.length != b.length) {
    return false;
  }
  if (identical(a, b)) {
    return true;
  }
  for (int index = 0; index < a.length; index += 1) {
    if (a[index] != b[index]) {
      return false;
    }
  }
  return true;
}
