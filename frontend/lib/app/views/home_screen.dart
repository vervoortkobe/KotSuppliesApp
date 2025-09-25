import 'package:flutter/material.dart';
import 'package:kotsupplies/app/views/lists/create_list_screen.dart';
import 'package:kotsupplies/app/views/lists/join_list_screen.dart';
import 'package:kotsupplies/app/views/lists/list_detail_screen.dart';
import 'package:kotsupplies/app/views/login_screen.dart';
import 'package:kotsupplies/app/views/profile/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:kotsupplies/app/constants/app_constants.dart';
import 'package:kotsupplies/app/models/list.dart';
import 'package:kotsupplies/app/view_models/auth_view_model.dart';
import 'package:kotsupplies/app/view_models/list_view_model.dart';
import 'package:kotsupplies/app/view_models/notification_view_model.dart';
import 'package:kotsupplies/app/widgets/app_loading_indicator.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    if (authViewModel.currentUser != null) {
      final listViewModel = Provider.of<ListViewModel>(context, listen: false);
      final notificationViewModel = Provider.of<NotificationViewModel>(
        context,
        listen: false,
      );

      await listViewModel.fetchUserLists(authViewModel.currentUser!.guid);
      await notificationViewModel.fetchNotifications(
        authViewModel.currentUser!.guid,
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final listViewModel = Provider.of<ListViewModel>(context);
    final notificationViewModel = Provider.of<NotificationViewModel>(context);

    if (authViewModel.currentUser == null) {
      return LoginScreen();
    }

    List<Widget> pages = <Widget>[
      _buildListsTab(listViewModel, authViewModel.currentUser!.guid),
      _buildNotificationsTab(notificationViewModel),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'KotSupplies',
          style: kHeadingStyle.copyWith(color: Colors.white),
        ),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => ProfileScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authViewModel.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadInitialData(),
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'My Lists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: kPrimaryColor,
        onTap: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => CreateListScreen()));
                if (result == true) {
                  // If a list was created, refresh
                  _loadInitialData();
                }
              },
              label: const Text('New List'),
              icon: const Icon(Icons.add),
              backgroundColor: kAccentColor,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Widget _buildListsTab(ListViewModel listViewModel, String userGuid) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('My Accessible Lists', style: kSubtitleStyle),
              TextButton.icon(
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => JoinListScreen(userGuid: userGuid),
                    ),
                  );
                  if (result == true) {
                    // If a list was joined, refresh
                    _loadInitialData();
                  }
                },
                icon: const Icon(Icons.group_add, color: kPrimaryColor),
                label: const Text(
                  'Join List',
                  style: TextStyle(color: kPrimaryColor),
                ),
              ),
            ],
          ),
        ),
        listViewModel.isLoading
            ? const Expanded(child: AppLoadingIndicator())
            : listViewModel.errorMessage != null
            ? Text(listViewModel.errorMessage!, style: kErrorTextStyle)
            : Expanded(
                child: listViewModel.userLists.isEmpty
                    ? LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: Center(
                                child: Text(
                                  'No lists yet.\nCreate one or join an existing one!',
                                  style: kBodyTextStyle.copyWith(
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : ListView.builder(
                        itemCount: listViewModel.userLists.length,
                        itemBuilder: (context, index) {
                          final list = listViewModel.userLists[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: kDefaultPadding,
                              vertical: kSmallPadding,
                            ),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: kDefaultBorderRadius,
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(
                                kDefaultPadding,
                              ),
                              leading: Icon(
                                list.type == ListType.imageCount
                                    ? Icons.image_outlined
                                    : Icons.check_box,
                                color: kPrimaryColor,
                                size: 30,
                              ),
                              title: Text(
                                list.title,
                                style: kBodyTextStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    list.description ?? 'No description',
                                    style: kSmallTextStyle,
                                  ),
                                  Text(
                                    'Share Code: ${list.shareCode}',
                                    style: kSmallTextStyle,
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 18,
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ListDetailScreen(listGuid: list.guid),
                                    ),
                                  );
                                },
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ListDetailScreen(listGuid: list.guid),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
      ],
    );
  }

  Widget _buildNotificationsTab(NotificationViewModel notificationViewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Text('Recent Notifications', style: kSubtitleStyle),
        ),
        notificationViewModel.isLoading
            ? const Expanded(child: AppLoadingIndicator())
            : notificationViewModel.errorMessage != null
            ? Text(notificationViewModel.errorMessage!, style: kErrorTextStyle)
            : Expanded(
                child: notificationViewModel.notifications.isEmpty
                    ? LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: Center(
                                child: Text(
                                  'No new notifications.',
                                  style: kBodyTextStyle.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : ListView.builder(
                        itemCount: notificationViewModel.notifications.length,
                        itemBuilder: (context, index) {
                          final notification =
                              notificationViewModel.notifications[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: kDefaultPadding,
                              vertical: kSmallPadding,
                            ),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: kDefaultBorderRadius,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(kDefaultPadding),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notification.message,
                                    style: kBodyTextStyle.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: kSmallPadding / 2),
                                  Text(
                                    '${notification.list?.title != null ? 'List: ${notification.list!.title} - ' : ''}'
                                    '${DateFormat('MMM dd, yyyy - hh:mm a').format(notification.createdAt)}',
                                    style: kSmallTextStyle,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
      ],
    );
  }
}
