import 'package:flutter/material.dart';
import 'payment_colors.dart';
import 'payment_status_screen.dart';

/// Person 5 — Payment Confirmation Screen, mobile layout

class PaymentConfirmationScreen extends StatefulWidget {
  final double amount;
  final String route;
  final String method;
  final String parcelId;

  const PaymentConfirmationScreen({
    super.key,
    required this.amount,
    required this.route,
    required this.method,
    this.parcelId = 'PCL-2026-0417',
  });

  @override
  State<PaymentConfirmationScreen> createState() => _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _circleScale;
  late final Animation<double> _checkProgress;
  late final Animation<double> _textFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Circle pops in with a slight overshoot (0 -> 0.5)
    _circleScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    );

    // Tick draws in right after the circle lands (0.35 -> 0.75)
    _checkProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
    );

    // Text fades/slides in last (0.6 -> 1.0)
    _textFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        foregroundColor: kText,
        title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return ScaleTransition(
                    scale: _circleScale,
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFECFDF5),
                        border: Border.all(color: kAccent, width: 2),
                      ),
                      child: CustomPaint(
                        painter: _CheckmarkPainter(
                          progress: _checkProgress.value,
                          color: kAccent,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              FadeTransition(
                opacity: _textFade,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.15),
                    end: Offset.zero,
                  ).animate(_textFade),
                  child: Column(
                    children: [
                      const Text('Payment successful',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: kText)),
                      const SizedBox(height: 4),
                      Text('₹${widget.amount.toStringAsFixed(0)} paid via ${widget.method}',
                          style: const TextStyle(fontSize: 14, color: kMuted)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: _textFade,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: kBorder),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _row('Parcel ID', widget.parcelId),
                      const SizedBox(height: 10),
                      _row('Route', widget.route),
                      const SizedBox(height: 10),
                      _row('Status', 'Payment confirmed'),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kAccent),
                    foregroundColor: kAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentStatusScreen(parcelId: widget.parcelId, route: widget.route),
                      ),
                    );
                  },
                  child: const Text('Track parcel', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: kMuted)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kText)),
      ],
    );
  }
}

/// Draws a checkmark stroke-by-stroke based on [progress] (0.0 -> 1.0).
/// Mimics the GPay/Paytm "tick drawing in" effect.
class _CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CheckmarkPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Checkmark points, scaled to the widget size (88x88 circle)
    final p1 = Offset(size.width * 0.28, size.height * 0.52);
    final p2 = Offset(size.width * 0.44, size.height * 0.68);
    final p3 = Offset(size.width * 0.74, size.height * 0.34);

    final firstLegLength = (p2 - p1).distance;
    final secondLegLength = (p3 - p2).distance;
    final totalLength = firstLegLength + secondLegLength;
    final drawLength = totalLength * progress;

    final path = Path()..moveTo(p1.dx, p1.dy);

    if (drawLength <= firstLegLength) {
      final t = drawLength / firstLegLength;
      path.lineTo(
        p1.dx + (p2.dx - p1.dx) * t,
        p1.dy + (p2.dy - p1.dy) * t,
      );
    } else {
      path.lineTo(p2.dx, p2.dy);
      final remaining = drawLength - firstLegLength;
      final t = (remaining / secondLegLength).clamp(0.0, 1.0);
      path.lineTo(
        p2.dx + (p3.dx - p2.dx) * t,
        p2.dy + (p3.dy - p2.dy) * t,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}