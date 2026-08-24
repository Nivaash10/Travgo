import 'package:flutter/material.dart';

class TripCapacityPriceCard extends StatelessWidget {
  final TextEditingController capacityController;
  final TextEditingController priceController;
  final bool isNegotiable;
  final ValueChanged<bool> onNegotiableChanged;
  final String? Function(String?) capacityValidator;
  final String? Function(String?) priceValidator;
  final VoidCallback onChanged;

  const TripCapacityPriceCard({
    super.key,
    required this.capacityController,
    required this.priceController,
    required this.isNegotiable,
    required this.onNegotiableChanged,
    required this.capacityValidator,
    required this.priceValidator,
    required this.onChanged,
  });

  static const Color primaryColor = Color(0xFF2563EB);
  static const Color secondaryColor = Color(0xFF14B8A6);
  static const Color textColor = Color(0xFF1E293B);
  static const Color subtitleColor = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color backgroundColor = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    final parsedCapacity = double.tryParse(capacityController.text.trim()) ?? 0.0;
    // Scale visual meter up to 20kg benchmark
    final meterRatio = (parsedCapacity / 20.0).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Capacity Section Header
          const Row(
            children: [
              Icon(Icons.scale_rounded, color: primaryColor, size: 20),
              SizedBox(width: 8),
              Text(
                'HOW MUCH CAN YOU CARRY?',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Capacity TextFormField
          TextFormField(
            controller: capacityController,
            onChanged: (_) => onChanged(),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
            decoration: InputDecoration(
              labelText: 'Available capacity (kg)',
              hintText: 'e.g., 5',
              labelStyle: const TextStyle(color: subtitleColor, fontSize: 13),
              hintStyle: const TextStyle(color: subtitleColor, fontSize: 13),
              prefixIcon: const Icon(Icons.fitness_center_rounded, color: primaryColor, size: 18),
              suffixText: 'kg',
              suffixStyle: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
              filled: true,
              fillColor: backgroundColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: primaryColor, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
              ),
            ),
            validator: capacityValidator,
          ),

          const SizedBox(height: 12),

          // Capacity Visual Indicator Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Available space indicator',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF15803D),
                      ),
                    ),
                    Text(
                      parsedCapacity > 0 ? '${parsedCapacity.toStringAsFixed(parsedCapacity.truncateToDouble() == parsedCapacity ? 0 : 1)} kg available' : '0 kg',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: meterRatio > 0 ? meterRatio : 0.05,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFDCFCE7),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF16A34A)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 20),

          // 2. Pricing Section Header
          const Row(
            children: [
              Icon(Icons.payments_rounded, color: secondaryColor, size: 20),
              SizedBox(width: 8),
              Text(
                'SET YOUR PRICE',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Price TextFormField
          TextFormField(
            controller: priceController,
            onChanged: (_) => onChanged(),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
            decoration: InputDecoration(
              labelText: 'Price per parcel / agreed amount (₹)',
              hintText: 'e.g., 100',
              labelStyle: const TextStyle(color: subtitleColor, fontSize: 13),
              hintStyle: const TextStyle(color: subtitleColor, fontSize: 13),
              prefixIcon: const Icon(Icons.currency_rupee_rounded, color: secondaryColor, size: 20),
              filled: true,
              fillColor: backgroundColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: secondaryColor, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
              ),
            ),
            validator: priceValidator,
          ),

          const SizedBox(height: 16),

          // Negotiable Switch Container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price flexibility',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Allow parcel senders to negotiate price',
                        style: TextStyle(
                          fontSize: 12,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isNegotiable,
                  activeThumbColor: primaryColor,
                  activeTrackColor: primaryColor.withValues(alpha: 0.2),
                  onChanged: (val) {
                    onNegotiableChanged(val);
                    onChanged();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
