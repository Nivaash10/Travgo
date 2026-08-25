import 'package:flutter/material.dart';
import '../../sender/screens/sender_dashboard_screen.dart';
import '../../traveler/screens/traveler_dashboard_screen.dart';
import '../../payment/screens/payment_demo_hub_screen.dart';
import '../../tracking/screens/tracking_screen.dart';
import '../../auth/screens/register_screen.dart';

/// Role Selection Screen — SIH Prototype Common Entry Point
///
/// Allows evaluator/user to seamlessly launch and switch between:
/// 1. Sender Portal (Search -> Match -> Request -> Pay -> Track -> Feedback)
/// 2. Traveler Portal (Create Trip -> Incoming Requests -> Accept -> OTP Verification)
/// 3. Payment Demo Hub & Real OSRM Satellite Map Tracking
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.flight_takeoff, color: Color(0xFF4F46E5)),
            SizedBox(width: 8),
            Text(
              'TRAVGO',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Color(0xFF0F172A),
              ),
            ),
            SizedBox(width: 8),
            Chip(
              label: Text(
                'SIH PROTOTYPE',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
              ),
              backgroundColor: Color(0xFFEEF2FF),
              side: BorderSide.none,
              padding: EdgeInsets.zero,
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const Text(
                'Smart Peer-to-Peer Travel Delivery',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Select a user role to experience the end-to-end delivery prototype flow:',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 24),

              // 1. Sender Role Card
              _RoleCard(
                title: 'Sender Portal',
                subtitle: 'Send parcels with travellers heading your way',
                icon: Icons.inventory_2,
                color: const Color(0xFF4F46E5),
                badgeText: 'SENDER FLOW',
                features: const [
                  'Search travel routes & weight options',
                  'Match verified travellers & view pricing',
                  'Create delivery request & pay via Escrow',
                  'Share Pickup OTP & Track live GPS route',
                  'Confirm delivery completion & rate traveller',
                ],
                buttonText: 'Launch Sender Portal',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SenderDashboardScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // 2. Traveler Role Card
              _RoleCard(
                title: 'Traveler Portal',
                subtitle: 'Earn money delivering parcels along your journey',
                icon: Icons.directions_car,
                color: const Color(0xFF0D9488),
                badgeText: 'TRAVELER FLOW',
                features: const [
                  'Publish travel routes & available capacity',
                  'View & accept incoming sender parcel requests',
                  'Simulated Aadhaar identity verification',
                  'Enter Sender Pickup OTP (4827) & Delivery OTP (7194)',
                  'Track active delivery & request payout',
                ],
                buttonText: 'Launch Traveler Portal',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TravelerDashboardScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Prototype Modules Section
              Text(
                'Interactive Demo Modules',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _ModuleActionTile(
                      icon: Icons.map,
                      title: 'Live OSRM Map',
                      subtitle: 'Satellite tracking',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TrackingScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ModuleActionTile(
                      icon: Icons.payment,
                      title: 'Payment Hub',
                      subtitle: 'Escrow & Payouts',
                      color: const Color(0xFF10B981),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PaymentDemoHubScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ModuleActionTile(
                      icon: Icons.person_add,
                      title: 'Auth Registration',
                      subtitle: 'Supabase Sign-Up',
                      color: Colors.purple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String badgeText;
  final List<String> features;
  final String buttonText;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.badgeText,
    required this.features,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              badgeText,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, size: 16, color: color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        f,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.arrow_forward),
                label: Text(buttonText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ModuleActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
