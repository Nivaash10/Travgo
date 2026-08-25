import 'package:flutter/material.dart';
import '../screens/sender_dashboard_screen.dart';
import '../screens/my_bookings_screen.dart';

/// Bottom navigation bar used across Sender screens.
class SenderBottomNavBar extends StatefulWidget {
  const SenderBottomNavBar({Key? key}) : super(key: key);

  @override
  State<SenderBottomNavBar> createState() => _SenderBottomNavBarState();
}

class _SenderBottomNavBarState extends State<SenderBottomNavBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Navigate to corresponding screen based on index.
    switch (index) {
      case 0:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SenderDashboardScreen()),
          (route) => false,
        );
        break;
      case 1:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MyBookingsScreen(initialBookings: [])),
          (route) => false,
        );
        break;
      case 2:
        // Placeholder for profile screen.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile screen not implemented yet.')),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Bookings'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      onTap: _onItemTapped,
    );
  }
}
