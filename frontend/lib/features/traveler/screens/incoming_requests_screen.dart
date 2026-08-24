import 'package:flutter/material.dart';
import '../models/parcel_request.dart';
import '../repository/parcel_request_repository.dart';
import '../repository/traveler_trip_repository.dart';
import '../widgets/request_card.dart';
import 'aadhaar_verification_screen.dart';
import 'active_delivery_screen.dart';

class IncomingRequestsScreen extends StatefulWidget {
  final String? tripId;

  const IncomingRequestsScreen({
    super.key,
    this.tripId,
  });

  @override
  State<IncomingRequestsScreen> createState() => _IncomingRequestsScreenState();
}

class _IncomingRequestsScreenState extends State<IncomingRequestsScreen> {
  static const Color backgroundColor = Color(0xFFF6F8FC);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color textColor = Color(0xFF1E293B);
  static const Color subtitleColor = Color(0xFF64748B);

  void _acceptRequest(ParcelRequest request) {
    if (!TravelerTripRepository().isVerified) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: cardColor,
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 24),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Verification Required',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'Complete Aadhaar verification before accepting parcel requests.',
            style: TextStyle(
              fontSize: 14,
              color: subtitleColor,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: subtitleColor)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AadhaarVerificationScreen(),
                  ),
                );
                if (mounted) {
                  setState(() {});
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text('Verify Aadhaar'),
            ),
          ],
        ),
      );
      return;
    }

    ParcelRequestRepository().updateRequestStatus(request.id, 'ACCEPTED');
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Request from ${request.senderName} accepted!'),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
    setState(() {});
  }

  void _rejectRequest(ParcelRequest request) {
    ParcelRequestRepository().updateRequestStatus(request.id, 'REJECTED');
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.cancel_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Request from ${request.senderName} rejected.'),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
    setState(() {});
  }

  void _onActiveDeliveryTap(ParcelRequest request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActiveDeliveryScreen(request: request),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final requests = ParcelRequestRepository().getRequestsForTrip(widget.tripId);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Incoming Requests (${requests.length})',
          style: const TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: requests.isEmpty
          ? _buildEmptyState(context)
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: requests.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final request = requests[index];
                return RequestCard(
                  request: request,
                  onAccept: () => _acceptRequest(request),
                  onReject: () => _rejectRequest(request),
                  onActiveDeliveryTap: () => _onActiveDeliveryTap(request),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inbox_outlined,
                size: 54,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No incoming requests',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You don\'t have any parcel delivery requests for this trip yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: subtitleColor,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
