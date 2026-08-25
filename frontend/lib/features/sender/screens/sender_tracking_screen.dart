import 'package:flutter/material.dart';
import '../../tracking/screens/tracking_screen.dart';
import '../data/sender_mock_tracking_data.dart';
import '../models/sender_tracking.dart';
import '../widgets/sender_tracking_route.dart';
import '../widgets/sender_tracking_status_badge.dart';
import 'sender_delivery_completion_screen.dart';

/// Live Delivery Tracking screen for Senders in TRAVGO.
class SenderTrackingScreen extends StatefulWidget {
  final SenderTracking? tracking;
  final String? bookingId;
  final String? requestId;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const SenderTrackingScreen({
    super.key,
    this.tracking,
    this.bookingId,
    this.requestId,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
  });

  @override
  State<SenderTrackingScreen> createState() => _SenderTrackingScreenState();
}

class _SenderTrackingScreenState extends State<SenderTrackingScreen> {
  late SenderTracking _tracking;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    if (widget.tracking != null) {
      _tracking = widget.tracking!;
    } else {
      final id = widget.bookingId ?? widget.requestId ?? 'BKG-103';
      _tracking = SenderMockTrackingData.getTracking(id);
    }
  }

  String _formatEventTime(DateTime time) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final minuteStr = time.minute.toString().padLeft(2, '0');
    return '${time.day} ${months[time.month - 1]} • ${time.hour}:$minuteStr';
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    setState(() {
      _isRefreshing = false;
      _tracking = _tracking.copyWith(lastUpdated: DateTime.now());
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demo tracking data refreshed.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Live Tracking'),
            Text(
              'ID: ${_tracking.bookingId}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            onPressed: _handleRefresh,
            tooltip: 'Refresh tracking',
          ),
        ],
      ),
      body: SafeArea(child: _buildBody(context, theme)),
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme) {
    // 1. Loading State
    if (widget.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading tracking information...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      );
    }

    // 2. Error State
    if (widget.errorMessage != null && widget.errorMessage!.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 56,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Unable to load tracking information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: widget.onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Main Populated Content
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Map Visualizer Canvas
            SenderTrackingRoute(
              bookingId: _tracking.bookingId,
              source: _tracking.source,
              destination: _tracking.destination,
              currentLocation: _tracking.currentLocation,
              estimatedArrival: _tracking.estimatedArrival,
              progressPercentage: _tracking.progressPercentage,
            ),
            const SizedBox(height: 12),

            // Live OSRM Map Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TrackingScreen(
                      parcelId: _tracking.bookingId,
                      sourceName: _tracking.source,
                      destinationName: _tracking.destination,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.map_rounded),
              label: const Text(
                'Open Live Satellite Map & OSRM Route',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Carrier Information Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'CARRIER INFORMATION',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF475569),
                            letterSpacing: 0.8,
                          ),
                        ),
                        SenderTrackingStatusBadge(
                          status: _tracking.currentStatus,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: const Color(0xFFE2E8F0),
                                child: Text(
                                  _tracking.travellerName.isNotEmpty
                                      ? _tracking.travellerName[0].toUpperCase()
                                      : 'T',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        _tracking.travellerName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      if (_tracking.travellerVerified) ...[
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.verified,
                                          size: 14,
                                          color: Color(0xFF2563EB),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _tracking.travelDateTime,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Calling ${_tracking.travellerName}...',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2563EB),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.call,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Delivery Confirmation OTP Notice
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFDBEAFE)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Delivery Confirmation OTP',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Share with receiver to verify handoff.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF1D4ED8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFBFDBFE),
                              ),
                            ),
                            child: const Text(
                              '6842',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF1D4ED8),
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Tracking Timeline Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DELIVERY LIFECYCLE TIMELINE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const Divider(height: 24, color: Color(0xFFF1F5F9)),
                    if (_tracking.events.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          'No tracking events recorded yet.',
                          style: TextStyle(color: Color(0xFF64748B)),
                        ),
                      )
                    else
                      ..._tracking.events.map((evt) {
                        final isLast = evt == _tracking.events.last;
                        return _TimelineTile(
                          event: evt,
                          isLast: isLast,
                          formatTime: _formatEventTime,
                        );
                      }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 4. Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SenderDeliveryCompletionScreen(
                        bookingId: _tracking.bookingId,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.task_alt),
                label: Text(
                  _tracking.currentStatus == SenderTrackingStatus.delivered
                      ? 'View Delivery Confirmation'
                      : 'Confirm Package Delivery (Receiver OTP)',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  final SenderTrackingEvent event;
  final bool isLast;
  final String Function(DateTime) formatTime;

  const _TimelineTile({
    required this.event,
    required this.isLast,
    required this.formatTime,
  });

  Color _getCircleColor(BuildContext context) {
    final theme = Theme.of(context);
    if (event.status == SenderTrackingStatus.cancelled) return Colors.red;
    if (event.isCurrent) return theme.colorScheme.primary;
    if (event.isCompleted) return Colors.green[700]!;
    return Colors.grey[400]!;
  }

  IconData _getIcon() {
    if (event.status == SenderTrackingStatus.cancelled) return Icons.cancel;
    if (event.isCompleted) return Icons.check;
    if (event.isCurrent) return Icons.navigation;
    return Icons.circle;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final circleColor = _getCircleColor(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column: Dot & Connecting Line
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: circleColor.withAlpha(40),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: circleColor,
                    width: event.isCurrent ? 2 : 1.5,
                  ),
                ),
                child: Icon(_getIcon(), size: 12, color: circleColor),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: event.isCompleted
                        ? Colors.green[300]
                        : Colors.grey[300],
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // Right Column: Title, Message, Time
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        event.title,
                        style: TextStyle(
                          fontWeight: event.isCurrent
                              ? FontWeight.bold
                              : FontWeight.w600,
                          fontSize: 14,
                          color: event.isCurrent
                              ? theme.colorScheme.primary
                              : Colors.black87,
                        ),
                      ),
                      Text(
                        formatTime(event.timestamp),
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.message,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
