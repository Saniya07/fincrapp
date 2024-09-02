import 'package:fincr/assets/colors.dart';
import 'package:fincr/components/buttons.dart';
import 'package:fincr/components/filters.dart';
import 'package:fincr/components/listview.dart';
import 'package:fincr/components/text.dart';
import 'package:fincr/constants/constants.dart';
import 'package:fincr/utils.dart';
import 'package:flutter/material.dart';

class FriendTransactionsDetails extends StatefulWidget {
  final String friendId;
  Map<String, dynamic> friendData;
  final void Function() parentOnClose;

  FriendTransactionsDetails(
      {super.key,
      required this.friendId,
      required this.friendData,
      required this.parentOnClose});

  @override
  State<FriendTransactionsDetails> createState() =>
      _FriendTransactionsDetailsState();
}

class _FriendTransactionsDetailsState extends State<FriendTransactionsDetails> {
  Map<String, List<List<dynamic>>> dateSeparatedTransactions = {};
  Map<String, dynamic> categoryMappings = {};

  Map<String, Map<String, dynamic>> selectedPeopleDataMap = {};

  List<Map<String, dynamic>> friendsListData = [];
  List<Map<String, dynamic>> groupsListData = [];
  List<Map<String, dynamic>> usersListData = [];

  String filterSwitchTabSelect = "overall";

  String userId = "1e114504-5f6b-4eb7-9403-fd11776a5bb3";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getAndSetTransactions();
    getAndSetFriendsAndGroupsData();
    getAndSetCateogryMappings();
  }

  void getAndSetFriendsAndGroupsData({listFor = "all"}) async {
    List<Map<String, dynamic>> friendsData = [];
    List<Map<String, dynamic>> groupsData = [];
    List<Map<String, dynamic>> usersData = [];
    double fOverall = 0.0;
    double gOverall = 0.0;

    var _splitPaidBy = await getFromTableViaFilter(
        "Users", "id", "1e114504-5f6b-4eb7-9403-fd11776a5bb3");

    if (listFor == "friends" || listFor == "all") {
      friendsData = await getFriendsWithReferences(
          "1e114504-5f6b-4eb7-9403-fd11776a5bb3");

      for (var data in friendsData) {
        fOverall += data["linked_amount"];
        usersData.add(data["FriendUser"]);
      }
    }
    if (listFor == "groups" || listFor == "all") {
      groupsData = await getFromTable(TABLENAMES.GROUPS);
    }

    setState(() {
      if (listFor == "friends" || listFor == "all") {
        friendsListData = friendsData;
      }
      if (listFor == "groups" || listFor == "all") {
        groupsListData = groupsData;
      }
      usersListData = usersData;

      for (var data in usersListData) {
        selectedPeopleDataMap[data["id"]] = data;
      }
    });

    // isLoading = false;
  }

  getAndSetTransactions() async {
    final allFriendTrans = await getFromTableViaFilter(
        TABLENAMES.FRIEND_SPLITS, "friend_id", widget.friendId);

    var result = convertListToDateSeparatedList(
        allFriendTrans, filterSwitchTabSelect,
        userId: userId);

    setState(() {
      dateSeparatedTransactions = result[0];
    });
  }

  void getAndSetCateogryMappings() async {
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

  void onClose() {
    setState(() {
      isLoading = false;
    });
    getAndSetTransactions();
    getAndSetFriendsAndGroupsData();
    getAndSetCateogryMappings();
  }

  void onSlideActionDelete(String cardId) async {
    await deleteFromTable(TABLENAMES.FRIEND_SPLITS, "id", cardId);

    onClose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: CustomColors.appColor,
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                    child: isLoading == true
                        ? CircularProgressIndicator()
                        : Column(children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    widget.parentOnClose();
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(Icons.close,
                                      color: Colors.white),
                                ),
                                AppText(
                                    text: widget.friendData["FriendUser"]
                                        ["name"],
                                    fontSize: 20,
                                    textColor: Colors.white),
                                const Row(
                                  children: [
                                    Icon(Icons.search, color: Colors.white),
                                    SizedBox(width: 8),
                                    Icon(Icons.refresh, color: Colors.white),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width:
                                          2.0, // Set the color and width of the border
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    backgroundImage: widget.friendData[
                                                        "FriendUser"]
                                                    ["profile_picture"] !=
                                                "" &&
                                            widget
                                                .friendData["FriendUser"]
                                                    ["profile_picture"]
                                                .isNotEmpty
                                        ? NetworkImage(widget
                                                    .friendData["FriendUser"]
                                                ["profile_picture"])
                                            as ImageProvider
                                        : const AssetImage(
                                            "lib/assets/netflix.jpg"),
                                    minRadius: 36,
                                    maxRadius: 40,
                                  ),
                                ),
                                const Spacer(),
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      if (widget.friendData["linked_amount"] !=
                                          0) ...[
                                        AppText(
                                            text: widget.friendData[
                                                        "linked_amount"] >
                                                    0
                                                ? "owes you"
                                                : "you owe",
                                            fontSize: 16,
                                            textColor: CustomColors.appGrey),
                                        AppText(
                                            text: widget
                                                .friendData["linked_amount"]
                                                .abs()
                                                .toString(),
                                            fontSize: 20,
                                            textColor: widget.friendData[
                                                        "linked_amount"] >
                                                    0
                                                ? CustomColors.appGreen
                                                : CustomColors.appRed)
                                      ] else ...[
                                        const AppText(
                                            text: "Settled",
                                            fontSize: 16,
                                            textColor: CustomColors.appGrey)
                                      ]
                                    ]),
                              ],
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Row(children: [
                              PrimaryButton(
                                  buttonText: "Settle",
                                  buttonTextColor: Colors.white,
                                  buttonColor: CustomColors.appGreen,
                                  buttonOutlineColor: CustomColors.appGreen,
                                  height: 44,
                                  width: 120),
                              const SizedBox(width: 8),
                              PrimaryButton(
                                  buttonText: "Remind",
                                  buttonTextColor: Colors.black,
                                  buttonColor: Colors.white,
                                  buttonOutlineColor: Colors.white,
                                  height: 44,
                                  width: 120),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.rectangle,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                ),
                                child: const Icon(
                                  Icons.pie_chart,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 8),
                              PopupMenuButton<String>(
                                elevation: 2,
                                shadowColor: CustomColors.appGrey,
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12))),
                                color: Colors.white,
                                onSelected: (value) {
                                  // Handle the selected option here
                                  if (value == 'export') {
                                    // Export action
                                  } else if (value == 'balances') {
                                    // Balances action
                                  }
                                },
                                itemBuilder: (BuildContext context) {
                                  return [
                                    const PopupMenuItem(
                                      value: 'export',
                                      child: Row(
                                        children: [
                                          Icon(Icons.download),
                                          SizedBox(width: 4),
                                          AppText(
                                              text: "Export",
                                              fontSize: 16,
                                              textColor: Colors.black)
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'balances',
                                      child: Row(
                                        children: [
                                          Icon(Icons.wallet),
                                          SizedBox(width: 4),
                                          AppText(
                                              text: "Balances",
                                              fontSize: 16,
                                              textColor: Colors.black)
                                        ],
                                      ),
                                    ),
                                  ];
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.rectangle,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                  ),
                                  child: const Icon(
                                    Icons.more_horiz,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ]),
                            const SizedBox(
                              height: 16,
                            ),
                            // Row(
                            //   children: [
                            //     Column(
                            //       children: [
                            //         Container(
                            //           decoration: BoxDecoration(
                            //             shape: BoxShape.circle,
                            //             border: Border.all(
                            //               color: Colors.white,
                            //               width:
                            //                   2.0, // Set the color and width of the border
                            //             ),
                            //           ),
                            //           child: const CircleAvatar(
                            //             backgroundImage:
                            //                 AssetImage("lib/assets/netflix.jpg"),
                            //             minRadius: 28,
                            //             maxRadius: 32,
                            //           ),
                            //         ),
                            //         const SizedBox(
                            //           height: 8,
                            //         ),
                            //         const AppText(
                            //             text: "Joint Account",
                            //             fontSize: 12,
                            //             textColor: Colors.white)
                            //       ],
                            //     ),
                            //   ],
                            // ),
                            const SizedBox(
                              height: 16,
                            ),
                            FilterSwitchTab(
                                tabTitles: const [
                                  "Overall",
                                  "You owe",
                                  "Owes you"
                                ],
                                onFilterChange: (String text) {
                                  setState(() {
                                    filterSwitchTabSelect = text.toLowerCase();
                                  });
                                  getAndSetTransactions();
                                }),
                            const SizedBox(
                              height: 12,
                            ),
                            if (!isLoading)
                              Expanded(
                                  child: DateSeparatedListView(
                                      dateSeparatedTransactions:
                                          dateSeparatedTransactions,
                                      slideableActionPressed:
                                          onSlideActionDelete,
                                      categoryMappings: categoryMappings,
                                      listViewType: "friends_split",
                                      friendData: widget.friendData,
                                      friendsListData: friendsListData,
                                      usersListData: usersListData,
                                      onClose: onClose))
                          ])))));
  }
}
