import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keep_note_new/screens/archive_screen.dart';
import 'package:keep_note_new/screens/deleted_screen.dart';
import 'package:keep_note_new/screens/main_screen.dart';
import 'package:keep_note_new/screens/reminder_screen.dart';

class KeepDrawer extends StatelessWidget {
  final int selectedIndex;

  const KeepDrawer({super.key, this.selectedIndex = 0});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color(0xFFF6FAF2),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12),
            SizedBox(height: 20),
            _drawerItem(
              icon: Icons.lightbulb_outlined,
              title: 'Notes',
              selected: selectedIndex == 0,
              onTap: () {
                Get.to(() => MainScreen());
              },
            ),
            _drawerItem(
              icon: Icons.notifications_none_outlined,
              title: 'Reminders',
              selected: selectedIndex == 1,
              onTap: () {
                Get.to(() => ReminderScreen());
              },
            ),
            // _drawerItem(
            //   icon: Icons.add,
            //   title: 'Create new label',
            //   onTap: () {},
            // ),
            _drawerItem(
              icon: Icons.archive_outlined,
              title: 'Archive',
              onTap: () {
                Get.to(() => ArchiveScreen());
              },
            ),
            _drawerItem(
              icon: CupertinoIcons.delete,
              title: 'Deleted',
              onTap: () {
                Get.to(() => DeletedScreen());
              },
            ),
            // _drawerItem(
            //   icon: Icons.settings,
            //   title: 'Settings',
            //   onTap: () {},
            // ),
            // _drawerItem(
            //   icon: Icons.help_outline,
            //   title: 'Help & feedback',
            //   onTap: () {},
            // ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    bool selected = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          decoration: BoxDecoration(
            color: selected ? Color(0xFFB5C99A) : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: Colors.black54),
              SizedBox(width: 20),
              Text(title, style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
