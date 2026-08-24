import 'package:flutter/material.dart';
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

  String _formatLastUpdated(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hrs ago';
    return '${time.day}/${time.month}/${time.year}';
  }

  String _formatEventTime(DateTime time) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
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
      _tracking = _tracking.copyWith(
        lastUpdated: DateTime.now(),
      );
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
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
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
      body: SafeArea(
        child: _buildBody(context, theme),
      ),
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
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
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
              Icon(Icons.error_outline, size: 56, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Unable to load tracking information',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                widget.errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
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
            // Delivery Summary Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_tracking.source} → ${_tracking.destination}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SenderTrackingStatusBadge(status: _tracking.currentStatus),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          'Traveller: ${_tracking.travellerName}',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        if (_tracking.travellerVerified) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.verified, size: 14, color: theme.colorScheme.primary),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          _tracking.travelDateTime,
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Route Progress Visualization
            SenderTrackingRoute(
              source: _tracking.source,
              destination: _tracking.destination,
              currentLocation: _tracking.currentLocation,
              progressPercentage: _tracking.progressPercentage,
            ),
            const SizedBox(height: 16),

            // Current Status & Location Card
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURRENT STATUS',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const Divider(height: 18),
                    Text(
                      _tracking.statusMessage,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_tracking.currentLocation != null)
                      _InfoRow(
                        icon: Icons.my_location,
                        label: 'Current Location',
                        value: _tracking.currentLocation!,
                      ),
                    if (_tracking.estimatedArrival != null)
                      _InfoRow(
                        icon: Icons.access_time,
                        label: 'Estimated Arrival',
                        value: _tracking.estimatedArrival!,
                        valueColor: theme.colorScheme.primary,
                      ),
                    _InfoRow(
                      icon: Icons.update,
                      label: 'Last Updated',
                      value: '${_formatLastUpdated(_tracking.lastUpdated)} (Demo tracking data)',
                    ),
                    if (_tracking.currentStatus == SenderTrackingStatus.delivered) ...[
                      const SizedBox(height: 12),
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
                          icon: const Icon(Icons.verified),
                          label: const Text(
                            'View Delivery Confirmation',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tracking Timeline Card
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TRACKING TIMELINE',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const Divider(height: 20),
                    if (_tracking.events.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          'No tracking events recorded yet.',
                          style: TextStyle(color: Colors.grey[600]),
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
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
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
                          fontWeight:
                              event.isCurrent ? FontWeight.bold : FontWeight.w600,
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
