import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:hackathon/screens/dahboard_screen.dart';
import 'package:hackathon/screens/profile_screen.dart';
import 'package:hackathon/utils/colors.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import 'chatting_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // userProvider 내에 있는 user 초기화.
  @override
  void initState() {
    super.initState();
    addData();
  }

  addData() async {
    UserProvider _userProvider =
        Provider.of<UserProvider>(context, listen: false);
    await _userProvider.refreshUser();
  }

  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    List<Widget> pages = <Widget>[
      DashboardScreen(),
      ChattingScreen(uid: userProvider.getUser.uid),
      ProfileScreen(uid: userProvider.getUser.uid)
    ];

    return Scaffold(
      body: pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
        const BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'chats'),
        const BottomNavigationBarItem(
            icon: Icon(Icons.account_circle), label: 'profile')
      ], currentIndex: _selectedIndex, onTap: _onItemTapped),

    );
  }
}
