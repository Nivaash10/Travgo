import 'package:flutter/material.dart';
import '../models/traveler_trip.dart';
import '../repository/traveler_trip_repository.dart';
import '../widgets/trip_capacity_price_card.dart';
import '../widgets/trip_route_selector.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  static const Color backgroundColor = Color(0xFFF6F8FC);
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color secondaryColor = Color(0xFF14B8A6);
  static const Color textColor = Color(0xFF1E293B);
  static const Color subtitleColor = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  final FocusNode _sourceFocusNode = FocusNode();
  final FocusNode _destinationFocusNode = FocusNode();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isNegotiable = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _sourceFocusNode.dispose();
    _destinationFocusNode.dispose();
    _sourceController.dispose();
    _destinationController.dispose();
    _capacityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return '${date.day} ${months[date.month - 1]} ${date.year} (${days[date.weekday % 7]})';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.calendar_today_rounded, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Text('Please select your travel date'),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }

      if (_selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.access_time_rounded, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Text('Please select your departure time'),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }

      final formattedTime = _selectedTime!.format(context);

      setState(() {
        _isSubmitting = true;
      });

      // Subtle loading delay for smooth feedback
      await Future.delayed(const Duration(milliseconds: 300));

      final newTrip = TravelerTrip(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        source: _sourceController.text.trim(),
        destination: _destinationController.text.trim(),
        travelDate: _selectedDate!,
        travelTime: formattedTime,
        availableWeight: double.parse(_capacityController.text.trim()),
        price: double.parse(_priceController.text.trim()),
        isNegotiable: _isNegotiable,
        status: 'ACTIVE',
      );

      TravelerTripRepository().addTrip(newTrip);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Trip Published! Your journey is now visible to parcel senders.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
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

        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasRoute = _sourceController.text.trim().isNotEmpty &&
        _destinationController.text.trim().isNotEmpty &&
        _sourceController.text.trim().toLowerCase() !=
            _destinationController.text.trim().toLowerCase();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Column(
          children: [
            // 1. Clean Custom Screen Header
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
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create a Trip',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            'Share your journey • Carry parcels • Earn',
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

            // Main Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2. Journey Route Selector Card (Centerpiece)
                      TripRouteSelector(
                        sourceController: _sourceController,
                        destinationController: _destinationController,
                        sourceFocusNode: _sourceFocusNode,
                        destinationFocusNode: _destinationFocusNode,
                        sourceValidator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a source city';
                          }
                          if (_destinationController.text.trim().isNotEmpty &&
                              value.trim().toLowerCase() ==
                                  _destinationController.text.trim().toLowerCase()) {
                            return 'Source and destination cannot be the same.';
                          }
                          return null;
                        },
                        destinationValidator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a destination city';
                          }
                          if (_sourceController.text.trim().isNotEmpty &&
                              value.trim().toLowerCase() ==
                                  _sourceController.text.trim().toLowerCase()) {
                            return 'Source and destination cannot be the same.';
                          }
                          return null;
                        },
                        onChanged: () => setState(() {}),
                      ),

                      const SizedBox(height: 20),

                      // 3. Date & Time Selection Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderColor),
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
                            const Row(
                              children: [
                                Icon(Icons.event_available_rounded, color: primaryColor, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'WHEN ARE YOU TRAVELING?',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: textColor,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                // Date Picker Card
                                Expanded(
                                  child: InkWell(
                                    onTap: _pickDate,
                                    borderRadius: BorderRadius.circular(14),
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: _selectedDate != null
                                              ? primaryColor.withValues(alpha: 0.4)
                                              : borderColor,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_month_rounded,
                                                color: primaryColor,
                                                size: 18,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                'TRAVEL DATE',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: subtitleColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _selectedDate != null
                                                ? _formatDate(_selectedDate!)
                                                : 'Select date',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: _selectedDate != null
                                                  ? textColor
                                                  : subtitleColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // Time Picker Card
                                Expanded(
                                  child: InkWell(
                                    onTap: _pickTime,
                                    borderRadius: BorderRadius.circular(14),
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: _selectedTime != null
                                              ? secondaryColor.withValues(alpha: 0.4)
                                              : borderColor,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Row(
                                            children: [
                                              Icon(
                                                Icons.access_time_filled_rounded,
                                                color: secondaryColor,
                                                size: 18,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                'DEPARTURE',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: subtitleColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _selectedTime != null
                                                ? _selectedTime!.format(context)
                                                : 'Select time',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: _selectedTime != null
                                                  ? textColor
                                                  : subtitleColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 4. Capacity & Price Card
                      TripCapacityPriceCard(
                        capacityController: _capacityController,
                        priceController: _priceController,
                        isNegotiable: _isNegotiable,
                        onNegotiableChanged: (val) {
                          setState(() {
                            _isNegotiable = val;
                          });
                        },
                        capacityValidator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter available capacity';
                          }
                          final cap = double.tryParse(value.trim());
                          if (cap == null || cap <= 0) {
                            return 'Capacity must be greater than 0 kg';
                          }
                          return null;
                        },
                        priceValidator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter price';
                          }
                          final p = double.tryParse(value.trim());
                          if (p == null || p < 0) {
                            return 'Price must be 0 or higher';
                          }
                          return null;
                        },
                        onChanged: () => setState(() {}),
                      ),

                      const SizedBox(height: 20),

                      // 5. Pre-Publish Trip Summary Card
                      if (hasRoute) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFEFF6FF), Color(0xFFF8FAFC)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: primaryColor.withValues(alpha: 0.25)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.fact_check_rounded, color: primaryColor, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'TRIP SUMMARY PREVIEW',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: primaryColor,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${_sourceController.text.trim()} → ${_destinationController.text.trim()}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_selectedDate != null ? _formatDate(_selectedDate!) : "Date pending"} • ${_selectedTime != null ? _selectedTime!.format(context) : "Time pending"}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: subtitleColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_capacityController.text.trim().isEmpty ? "0" : _capacityController.text.trim()} kg capacity • ₹${_priceController.text.trim().isEmpty ? "0" : _priceController.text.trim()} • ${_isNegotiable ? "Negotiable" : "Fixed price"}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: secondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // 6. Publish Trip Hero Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            shadowColor: primaryColor.withValues(alpha: 0.35),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Publish Trip',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded, size: 20),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
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
