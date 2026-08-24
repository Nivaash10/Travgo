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
  static const Color borderColor = Color(0xFFE2E8F0);

  String _selectedStatusFilter = 'ALL';

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

    // Confirmation dialog before acceptance
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: cardColor,
        title: const Text(
          'Accept Parcel Request?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${request.source} → ${request.destination}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 4),
            Text(
              'Sender: ${request.senderName} • ${request.parcelWeight} kg',
              style: const TextStyle(fontSize: 13, color: subtitleColor),
            ),
            const SizedBox(height: 4),
            Text(
              'Price: ₹${request.price.toInt()}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: subtitleColor)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ParcelRequestRepository().updateRequestStatus(request.id, 'ACCEPTED');
              if (mounted) {
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
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text('Accept Request'),
          ),
        ],
      ),
    );
  }

  void _rejectRequest(ParcelRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: cardColor,
        title: const Text(
          'Reject Parcel Request?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        content: Text(
          'Are you sure you want to reject the parcel request from ${request.senderName}?',
          style: const TextStyle(
            fontSize: 13,
            color: subtitleColor,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Request', style: TextStyle(color: subtitleColor)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ParcelRequestRepository().updateRequestStatus(request.id, 'REJECTED');
              if (mounted) {
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
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _onActiveDeliveryTap(ParcelRequest request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActiveDeliveryScreen(request: request),
      ),
    );
  }

  List<ParcelRequest> _getFilteredRequests(List<ParcelRequest> allRequests) {
    if (_selectedStatusFilter == 'ALL') {
      return allRequests;
    }
    return allRequests
        .where((r) => r.status.toUpperCase() == _selectedStatusFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final allRequests = ParcelRequestRepository().getRequestsForTrip(widget.tripId);
    final filteredRequests = _getFilteredRequests(allRequests);
    final pendingCount = allRequests.where((r) => r.status == 'PENDING').length;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // 1. Clean Screen Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: textColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Parcel Requests',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$pendingCount pending',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD97706),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 1),
                        const Text(
                          'Requests matching your journeys',
                          style: TextStyle(
                            fontSize: 11,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Status Filter Bar (if requests exist)
          if (allRequests.isNotEmpty)
            Container(
              height: 48,
              color: Colors.white,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _buildFilterChip('ALL', 'All (${allRequests.length})'),
                  _buildFilterChip(
                    'PENDING',
                    'Pending ($pendingCount)',
                  ),
                  _buildFilterChip(
                    'ACCEPTED',
                    'Accepted (${allRequests.where((r) => r.status == 'ACCEPTED').length})',
                  ),
                  _buildFilterChip(
                    'REJECTED',
                    'Rejected (${allRequests.where((r) => r.status == 'REJECTED').length})',
                  ),
                ],
              ),
            ),

          // Main Content List or Empty State
          Expanded(
            child: filteredRequests.isEmpty
                ? _buildEmptyState(context, isFiltered: allRequests.isNotEmpty)
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    itemCount: filteredRequests.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final request = filteredRequests[index];
                      return RequestCard(
                        request: request,
                        onAccept: () => _acceptRequest(request),
                        onReject: () => _rejectRequest(request),
                        onActiveDeliveryTap: () => _onActiveDeliveryTap(request),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label) {
    final isSelected = _selectedStatusFilter == filterKey;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : textColor,
          ),
        ),
        selected: isSelected,
        selectedColor: primaryColor,
        backgroundColor: const Color(0xFFF1F5F9),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isSelected ? primaryColor : Colors.transparent,
          ),
        ),
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedStatusFilter = filterKey;
            });
          }
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, {required bool isFiltered}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.markunread_mailbox_outlined,
                size: 50,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              isFiltered ? 'No requests match this filter' : 'No parcel requests yet',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isFiltered
                  ? 'Try selecting a different status filter above.'
                  : 'Parcel delivery requests matching your published journeys will appear here.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
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
