import 'package:flutter/material.dart';
import '../models/parcel_request.dart';

class ReceiverDetailsCard extends StatelessWidget {
  final ParcelRequest request;

  const ReceiverDetailsCard({
    super.key,
    required this.request,
  });

  static const Color primaryColor = Color(0xFF2563EB);
  static const Color secondaryColor = Color(0xFF14B8A6);
  static const Color textColor = Color(0xFF1E293B);
  static const Color subtitleColor = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color containerBgColor = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    final receiverName = (request.receiverName != null && request.receiverName!.trim().isNotEmpty)
        ? request.receiverName!
        : 'Not provided';
    final receiverPhone = (request.receiverPhone != null && request.receiverPhone!.trim().isNotEmpty)
        ? request.receiverPhone!
        : 'Not provided';
    final deliveryLocation = (request.deliveryLocation != null && request.deliveryLocation!.trim().isNotEmpty)
        ? request.deliveryLocation!
        : 'Not provided';
    final deliveryCity = (request.deliveryCity != null && request.deliveryCity!.trim().isNotEmpty)
        ? request.deliveryCity!
        : 'Not provided';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: containerBgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_pin_circle_rounded,
                  color: primaryColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'RECEIVER DETAILS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Receiver Info Grid / Rows
          _buildInfoRow(
            icon: Icons.person_outline_rounded,
            label: 'Receiver Name',
            value: receiverName,
            isNotProvided: receiverName == 'Not provided',
          ),
          const SizedBox(height: 8),

          _buildInfoRow(
            icon: Icons.phone_outlined,
            label: 'Receiver Contact',
            value: receiverPhone,
            isNotProvided: receiverPhone == 'Not provided',
          ),
          const SizedBox(height: 8),

          _buildInfoRow(
            icon: Icons.location_on_outlined,
            label: 'Delivery Location',
            value: deliveryLocation,
            isNotProvided: deliveryLocation == 'Not provided',
          ),
          const SizedBox(height: 8),

          _buildInfoRow(
            icon: Icons.location_city_rounded,
            label: 'Delivery City',
            value: deliveryCity,
            isNotProvided: deliveryCity == 'Not provided',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isNotProvided,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            icon,
            size: 15,
            color: isNotProvided ? subtitleColor.withValues(alpha: 0.7) : secondaryColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: subtitleColor,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                softWrap: true,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isNotProvided ? FontWeight.normal : FontWeight.w600,
                  color: isNotProvided ? subtitleColor : textColor,
                  fontStyle: isNotProvided ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
