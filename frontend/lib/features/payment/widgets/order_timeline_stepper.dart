import 'package:flutter/material.dart';
import '../models/payment_models.dart';

class OrderTimelineStepper extends StatelessWidget {
  final OrderLifecycleStep currentStep;
  final Function(OrderLifecycleStep)? onStepTapped;

  const OrderTimelineStepper({
    super.key,
    required this.currentStep,
    this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final steps = OrderLifecycleStep.values;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.timeline_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order & Escrow Lifecycle',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Stage ${currentStep.stageIndex + 1} of ${steps.length} • ${currentStep.title}',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Steps list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            separatorBuilder: (context, index) {
              final isCompleted = index < currentStep.stageIndex;
              final isConnectingToActive = index == currentStep.stageIndex - 1;

              return Padding(
                padding: const EdgeInsets.only(left: 17),
                child: Container(
                  width: 2.5,
                  height: 24,
                  color: isCompleted
                      ? const Color(0xFF10B981)
                      : (isConnectingToActive
                          ? theme.colorScheme.primary.withValues(alpha: 0.5)
                          : (isDark ? Colors.grey.shade800 : Colors.grey.shade300)),
                ),
              );
            },
            itemBuilder: (context, index) {
              final step = steps[index];
              final isCompleted = index < currentStep.stageIndex;
              final isCurrent = index == currentStep.stageIndex;
              final isPending = index > currentStep.stageIndex;

              return InkWell(
                onTap: onStepTapped != null ? () => onStepTapped!(step) : null,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Node Indicator
                      _buildStepIndicator(isCompleted, isCurrent, isPending, theme, step),
                      const SizedBox(width: 14),

                      // Step Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  step.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isCurrent
                                        ? FontWeight.w700
                                        : (isCompleted ? FontWeight.w600 : FontWeight.w500),
                                    color: isCurrent
                                        ? (isDark ? Colors.white : const Color(0xFF0F172A))
                                        : (isCompleted
                                            ? (isDark ? Colors.grey.shade200 : const Color(0xFF1E293B))
                                            : Colors.grey.shade500),
                                  ),
                                ),
                                const Spacer(),
                                if (isCurrent)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'CURRENT',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: theme.colorScheme.primary,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  )
                                else if (isCompleted)
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    size: 16,
                                    color: Color(0xFF10B981),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              step.subtitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: isCurrent
                                    ? (isDark ? Colors.grey.shade300 : Colors.grey.shade700)
                                    : (isCompleted
                                        ? Colors.grey.shade500
                                        : Colors.grey.shade400),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(
    bool isCompleted,
    bool isCurrent,
    bool isPending,
    ThemeData theme,
    OrderLifecycleStep step,
  ) {
    if (isCompleted) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF10B981), width: 2),
        ),
        child: const Icon(
          Icons.check,
          color: Color(0xFF10B981),
          size: 18,
        ),
      );
    } else if (isCurrent) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.4),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          step.icon,
          color: Colors.white,
          size: 18,
        ),
      );
    } else {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade400, width: 1.5),
        ),
        child: Icon(
          step.icon,
          color: Colors.grey.shade400,
          size: 17,
        ),
      );
    }
  }
}
