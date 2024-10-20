import 'package:contacts_service/contacts_service.dart';
import 'package:fincr/assets/colors.dart';
import 'package:fincr/components/filters.dart';
import 'package:fincr/components/listview.dart';
import 'package:fincr/components/modals/modals.dart';
import 'package:fincr/components/text.dart';
import 'package:fincr/constants/constants.dart';
import 'package:fincr/utils.dart';
import 'package:flutter/material.dart';

class SplitItUp extends StatefulWidget {
  const SplitItUp({super.key});

  @override
  State<SplitItUp> createState() => _SplitItUpState();
}

class _SplitItUpState extends State<SplitItUp> {
  // will contain friends and groups list data connected to user
  List<Map<String, dynamic>> friendsListData = [];
  List<Map<String, dynamic>> groupsListData = [];

  double friendsOverall = 0.0;
  double groupsOverall = 0.0;

  // to figure out what tab is selected by user
  String topFilter = "groups";

  void onFilterPageChange(String newFilter) {
    setState(() {
      topFilter = newFilter.toLowerCase();
    });
  }

  @override
  void initState() {
    super.initState();
    getAndSetListData();
  }

  void onClose() {
    getAndSetListData();
  }

  void getAndSetListData({listFor = "all"}) async {
    List<Map<String, dynamic>> friendsData = [];
    List<Map<String, dynamic>> groupsData = [];
    double fOverall = 0.0;
    double gOverall = 0.0;

    if (listFor == "friends" || listFor == "all") {
      friendsData = await getFriendsWithReferences(
          "1e114504-5f6b-4eb7-9403-fd11776a5bb3");

      for (var data in friendsData) {
        // print(data);
        fOverall += data["linked_amount"];
      }
    }
    if (listFor == "groups" || listFor == "all") {
      groupsData =
          await getGroupsWithReferences("1e114504-5f6b-4eb7-9403-fd11776a5bb3");

      for (var data in groupsData) {
        gOverall += data["linked_amount"];
      }
    }
    setState(() {
      if (listFor == "friends" || listFor == "all") {
        friendsListData = friendsData;
        friendsOverall = fOverall;
      }
      if (listFor == "groups" || listFor == "all") {
        groupsListData = groupsData;
        groupsOverall = gOverall;
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.search,
                              color: Colors.white, size: 32)),
                      FilterSwitchTab(
                          tabTitles: const ["Groups", "Friends"],
                          onFilterChange: onFilterPageChange),
                      Row(
                        children: [
                          IconButton(
                              onPressed: () async {
                                Contact? selectedContact =
                                    await openContactList(context);
                                if (selectedContact != null) {
                                  // Handle the selected contact
                                  print(
                                      "Selected Contact: ${selectedContact.displayName}");
                                }
                              },
                              icon: const Icon(Icons.add,
                                  color: Colors.white, size: 32)),
                          IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.filter_list,
                                  color: Colors.white, size: 32))
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                            text: topFilter == "friends"
                                ? (friendsOverall > 0
                                    ? "Your friends owe you"
                                    : "You owe your friends")
                                : (groupsOverall > 0
                                    ? "All groups owe you"
                                    : "You owe all groups"),
                            fontSize: 16,
                            textColor: Colors.white),
                        AppBoldText(
                            text: topFilter == "friends"
                                ? convertAmountFormat(
                                    friendsOverall.abs(), friendsOverall <= 0,
                                    removeSign: true)
                                : convertAmountFormat(
                                    groupsOverall.abs(), groupsOverall <= 0,
                                    removeSign: true),
                            fontSize: 36,
                            textColor: (topFilter == "friends"
                                    ? friendsOverall > 0
                                    : groupsOverall > 0)
                                ? CustomColors.appGreen
                                : CustomColors.appRed)
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                      child: SplitListView(
                          topFilter: topFilter,
                          data: topFilter == "friends"
                              ? friendsListData
                              : groupsListData,
                          onClose: onClose))
                ])))));
  }
}
