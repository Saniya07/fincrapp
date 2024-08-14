import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = SupabaseClient("https://aobzyijbbfxncpyqpeae.supabase.co",
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFvYnp5aWpiYmZ4bmNweXFwZWFlIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcyMjE1MjM4MywiZXhwIjoyMDM3NzI4MzgzfQ.bH70qtyYb3FtsyCV0v2_1YoQpVj-GQ_5K1396Z9Fnow");

String convertAmountFormat(double money, bool addMinus) {
  // Create a NumberFormat instance for the Indian numbering system with two decimal places
  final formatter = NumberFormat('##,##,##,##,##,##,##,##0.00', 'en_IN');

  // Format the amount
  String formattedAmount = formatter.format(money);

  // Return the formatted string with the currency symbol
  return addMinus ? "-\₹ $formattedAmount" : "+\₹ $formattedAmount";
}

void showToast(errorMessage, backgroundColor, textColor) {
  Fluttertoast.showToast(
    msg: errorMessage,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.SNACKBAR,
    timeInSecForIosWeb: 2,
    backgroundColor: Colors.red,
    textColor: Colors.white,
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

Future<List<Map<String, dynamic>>> getFromTableViaFilter(
    tableName, filterColumn, filterValue) async {
  final data = await supabase
      .from(tableName)
      .select()
      .eq(filterColumn, filterValue)
      .order("created_at", ascending: false);
  return data;
}

Future<bool> deleteFromTable(tableName, filterColumn, filterValue) async {
  await supabase.from(tableName).delete().eq(filterColumn, filterValue);
  return true;
}

void insertInTable(tableName, payload) async {
  await supabase.from(tableName).insert([payload]).select();
}

void updateObjectInTable(tableName, filterColumn, filterValue, payload) async {
  await supabase
      .from(tableName)
      .update(payload)
      .eq(filterColumn, filterValue)
      .select();
}

IconData getIconDataFromString(String stringUnicode) {
  return IconData(int.parse(stringUnicode.replaceFirst('U+', ''), radix: 16),
      fontFamily: 'MaterialIcons');
}

double parseAmountFromString(String transactionAmount) {
  // Parse the string to a double
  double amount = double.parse(transactionAmount);

  // Format the double to two decimal places and then parse it back to double
  amount = double.parse(amount.toStringAsFixed(2));

  return amount;
}
