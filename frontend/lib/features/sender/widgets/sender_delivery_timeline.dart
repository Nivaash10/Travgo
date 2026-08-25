import 'package:flutter/material.dart';
import '../models/sender_delivery_status.dart';

/// Reusable vertical timeline widget displaying the delivery lifecycle.
class SenderDeliveryTimeline extends StatelessWidget {
  final SenderDeliveryStatusItem statusItem;

  const SenderDeliveryTimeline({super.key, required this.statusItem});

  @override
  Widget build(BuildContext context) {
    final steps = _buildTimelineSteps(statusItem.status);

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;
        return _TimelineStepTile(step: step, isLast: isLast);
      }),
    );
  }

  List<_TimelineStep> _buildTimelineSteps(SenderDeliveryStatus status) {
    if (status == SenderDeliveryStatus.rejected) {
      return const [
        _TimelineStep(
          title: 'Request Submitted',
          subtitle: 'Sent to traveller',
          state: _StepState.completed,
        ),
        _TimelineStep(
          title: 'Request Rejected',
          subtitle: 'Traveller declined the request',
          state: _StepState.terminalFailed,
        ),
      ];
    }

    if (status == SenderDeliveryStatus.cancelled) {
      return const [
        _TimelineStep(
          title: 'Request Submitted',
          subtitle: 'Sent to traveller',
          state: _StepState.completed,
        ),
        _TimelineStep(
          title: 'Request Cancelled',
          subtitle: 'Delivery request was cancelled',
          state: _StepState.terminalFailed,
        ),
      ];
    }

    int currentStepIndex;
    switch (status) {
      case SenderDeliveryStatus.pending:
        currentStepIndex = 0;
        break;
      case SenderDeliveryStatus.accepted:
        currentStepIndex = 1;
        break;
      case SenderDeliveryStatus.pickupPending:
        currentStepIndex = 2;
        break;
      case SenderDeliveryStatus.pickedUp:
        currentStepIndex = 3;
        break;
      case SenderDeliveryStatus.inTransit:
        currentStepIndex = 4;
        break;
      case SenderDeliveryStatus.delivered:
        currentStepIndex = 5;
        break;
      default:
        currentStepIndex = 0;
    }

    final baseSteps = [
      const _TimelineStep(
        title: 'Request Submitted',
        subtitle: 'Sent to traveller for review',
      ),
      const _TimelineStep(
        title: 'Traveller Accepted',
        subtitle: 'Traveller confirmed parcel delivery',
      ),
      const _TimelineStep(
        title: 'Parcel Pickup Pending',
        subtitle: 'Awaiting sender & traveller meetup',
      ),
      const _TimelineStep(
        title: 'Picked Up',
        subtitle: 'Parcel collected by traveller',
      ),
      const _TimelineStep(
        title: 'In Transit',
        subtitle: 'Parcel travelling on route',
      ),
      const _TimelineStep(
        title: 'Delivered',
        subtitle: 'Parcel safely delivered to destination',
      ),
    ];

    return List.generate(baseSteps.length, (index) {
      final base = baseSteps[index];
      _StepState stepState;
      if (index < currentStepIndex) {
        stepState = _StepState.completed;
      } else if (index == currentStepIndex) {
        stepState = _StepState.current;
      } else {
        stepState = _StepState.upcoming;
      }
      return _TimelineStep(
        title: base.title,
        subtitle: base.subtitle,
        state: stepState,
      );
    });
  }
}

enum _StepState { completed, current, upcoming, terminalFailed }

class _TimelineStep {
  final String title;
  final String subtitle;
  final _StepState state;

  const _TimelineStep({
    required this.title,
    required this.subtitle,
    this.state = _StepState.upcoming,
  });
}

class _TimelineStepTile extends StatelessWidget {
  final _TimelineStep step;
  final bool isLast;

  const _TimelineStepTile({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color indicatorColor;
    IconData iconData;

    switch (step.state) {
      case _StepState.completed:
        indicatorColor = Colors.green[600]!;
        iconData = Icons.check_circle;
        break;
      case _StepState.current:
        indicatorColor = theme.colorScheme.primary;
        iconData = Icons.radio_button_checked;
        break;
      case _StepState.upcoming:
        indicatorColor = Colors.grey[400]!;
        iconData = Icons.radio_button_unchecked;
        break;
      case _StepState.terminalFailed:
        indicatorColor = Colors.red[600]!;
        iconData = Icons.cancel;
        break;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Indicator Column
          Column(
            children: [
              Icon(iconData, size: 20, color: indicatorColor),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: step.state == _StepState.completed
                        ? Colors.green[600]
                        : Colors.grey[300],
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // Content Column
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: step.state == _StepState.current
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: step.state == _StepState.upcoming
                          ? Colors.grey[600]
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
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
