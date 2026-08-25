import 'package:flutter/material.dart';
import '../data/sender_mock_booking_data.dart';
import '../data/sender_mock_notification_data.dart';
import '../widgets/sender_booking_card.dart';
import 'my_bookings_screen.dart';
import 'search_route_screen.dart';
import 'sender_booking_detail_screen.dart';
import 'sender_notifications_screen.dart';

/// Sender Dashboard Screen.
///
/// Primary mobile dashboard view for Senders in TRAVGO.
class SenderDashboardScreen extends StatefulWidget {
  final String userName;

  const SenderDashboardScreen({super.key, this.userName = 'Sender'});

  @override
  State<SenderDashboardScreen> createState() => _SenderDashboardScreenState();
}

class _SenderDashboardScreenState extends State<SenderDashboardScreen> {
  final TextEditingController _quickSourceController = TextEditingController(
    text: 'Coimbatore',
  );
  final TextEditingController _quickDestinationController =
      TextEditingController(text: 'Chennai');

  @override
  void dispose() {
    _quickSourceController.dispose();
    _quickDestinationController.dispose();
    super.dispose();
  }

  void _navigateToSearchRoute({String? source, String? destination}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SearchRouteScreen(
          initialSource: source ?? _quickSourceController.text.trim(),
          initialDestination:
              destination ?? _quickDestinationController.text.trim(),
        ),
      ),
    );
  }

  void _navigateToMyBookings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MyBookingsScreen(
          initialBookings: SenderMockBookingData.getMockBookings(),
          onCreateRequest: _navigateToSearchRoute,
        ),
      ),
    );
  }

  void _navigateToNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SenderNotificationsScreen(
          initialNotifications:
              SenderMockNotificationData.getMockNotifications(),
        ),
      ),
    );
  }

  void _showFeatureNotice(String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$featureName integration will be enabled in a future phase.',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    final mockNotifs = SenderMockNotificationData.getMockNotifications();
    final unreadCount = mockNotifs.where((n) => !n.isRead).length;

    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: _navigateToNotifications,
        ),
        if (unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRecentBookingsPreview(BuildContext context) {
    final mockBookings = SenderMockBookingData.getMockBookings();

    if (mockBookings.isEmpty) {
      return Center(
        child: Text(
          'No recent bookings.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
      );
    }

    final recentPreview = mockBookings.take(2).toList();
    return Column(
      children: recentPreview.map((item) {
        return SenderBookingCard(
          booking: item,
          onViewDetails: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SenderBookingDetailScreen(booking: item),
              ),
            );
          },
          onCancel: null,
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          color: Theme.of(context).colorScheme.background,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => _showFeatureNotice('Profile'),
              ),
              const Text(
                'TRAVGO',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  _buildNotificationIcon(),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showFeatureNotice('Profile'),
                    child: const CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0xFFE2E8F0),
                      child: Text(
                        'S',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section
              Text(
                'Hello, ${widget.userName}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Where do you want to send a parcel?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 20),

              // Primary Search Entry Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Where do you want to send a parcel?',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // From Input
                      TextFormField(
                        controller: _quickSourceController,
                        decoration: const InputDecoration(
                          labelText: 'From',
                          prefixIcon: Icon(Icons.trip_origin),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // To Input with Swap Button
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _quickDestinationController,
                              decoration: const InputDecoration(
                                labelText: 'To',
                                prefixIcon: Icon(Icons.location_on),
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              final temp = _quickSourceController.text;
                              _quickSourceController.text =
                                  _quickDestinationController.text;
                              _quickDestinationController.text = temp;
                            },
                            child: const Text('Swap'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Date & Weight Row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: '25 Aug 2026',
                              decoration: const InputDecoration(
                                labelText: 'Date',
                                prefixIcon: Icon(Icons.calendar_today),
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              initialValue: '2',
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Weight (kg)',
                                prefixIcon: Icon(Icons.fitness_center),
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Search Travellers Button
                      ElevatedButton.icon(
                        onPressed: _navigateToSearchRoute,
                        icon: const Icon(Icons.search),
                        label: const Text(
                          'Search Travellers',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions Section
              Text(
                'Quick Actions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.search,
                      label: 'Search Travellers',
                      onTap: _navigateToSearchRoute,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.inventory_2_outlined,
                      label: 'My Bookings',
                      onTap: _navigateToMyBookings,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.alt_route,
                      label: 'Track Parcel',
                      onTap: () => _showFeatureNotice('Track Parcel'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Bookings Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Bookings',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: _navigateToMyBookings,
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _buildRecentBookingsPreview(context),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          child: Column(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
