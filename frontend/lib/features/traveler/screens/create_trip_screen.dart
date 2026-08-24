import 'package:flutter/material.dart';
import '../models/tamil_nadu_cities.dart';
import '../models/traveler_trip.dart';
import '../repository/traveler_trip_repository.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  static const Color backgroundColor = Color(0xFFF6F8FC);
  static const Color cardColor = Color(0xFFFFFFFF);
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a travel date'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      if (_selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a travel time'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final newTrip = TravelerTrip(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        source: _sourceController.text.trim(),
        destination: _destinationController.text.trim(),
        travelDate: _selectedDate!,
        travelTime: _selectedTime!.format(context),
        availableWeight: double.parse(_capacityController.text.trim()),
        price: double.parse(_priceController.text.trim()),
        isNegotiable: _isNegotiable,
        status: 'ACTIVE',
      );

      TravelerTripRepository().addTrip(newTrip);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text('Trip created successfully!'),
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

  Widget _buildCityAutocomplete({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData prefixIcon,
    required Color iconColor,
    required String? Function(String?) validator,
  }) {
    return RawAutocomplete<String>(
      textEditingController: controller,
      focusNode: focusNode,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.trim().isEmpty) {
          return const Iterable<String>.empty();
        }
        final query = textEditingValue.text.trim().toLowerCase();
        return TamilNaduCities.cities.where((city) => city.toLowerCase().contains(query));
      },
      onSelected: (String selection) {
        controller.text = selection;
        controller.selection = TextSelection.collapsed(offset: selection.length);
      },
      fieldViewBuilder: (context, fieldController, fieldFocusNode, onFieldSubmitted) {
        return TextFormField(
          controller: fieldController,
          focusNode: fieldFocusNode,
          style: const TextStyle(color: textColor),
          decoration: _buildInputDecoration(
            label: label,
            hint: hint,
            prefixIcon: prefixIcon,
          ),
          validator: validator,
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 6,
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: MediaQuery.of(context).size.width - 80,
              constraints: const BoxConstraints(maxHeight: 220),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 4),
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                itemBuilder: (BuildContext context, int index) {
                  final String option = options.elementAt(index);
                  return InkWell(
                    onTap: () => onSelected(option),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_city_rounded,
                            size: 18,
                            color: iconColor,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            option,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          'Create Trip',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Trip Route',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Source Autocomplete
                    _buildCityAutocomplete(
                      controller: _sourceController,
                      focusNode: _sourceFocusNode,
                      label: 'Source',
                      hint: 'e.g., Coimbatore',
                      prefixIcon: Icons.trip_origin_rounded,
                      iconColor: primaryColor,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a source location';
                        }
                        if (_destinationController.text.trim().isNotEmpty &&
                            value.trim().toLowerCase() ==
                                _destinationController.text.trim().toLowerCase()) {
                          return 'Source and destination cannot be the same.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Destination Autocomplete
                    _buildCityAutocomplete(
                      controller: _destinationController,
                      focusNode: _destinationFocusNode,
                      label: 'Destination',
                      hint: 'e.g., Chennai',
                      prefixIcon: Icons.place_rounded,
                      iconColor: secondaryColor,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a destination location';
                        }
                        if (_sourceController.text.trim().isNotEmpty &&
                            value.trim().toLowerCase() ==
                                _sourceController.text.trim().toLowerCase()) {
                          return 'Source and destination cannot be the same.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Date & Time',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        // Travel Date
                        Expanded(
                          child: InkWell(
                            onTap: _pickDate,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    color: primaryColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Travel Date',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: subtitleColor,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _selectedDate != null
                                              ? _formatDate(_selectedDate!)
                                              : 'Select date',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: _selectedDate != null
                                                ? textColor
                                                : subtitleColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Travel Time
                        Expanded(
                          child: InkWell(
                            onTap: _pickTime,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    color: secondaryColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Travel Time',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: subtitleColor,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _selectedTime != null
                                              ? _selectedTime!.format(context)
                                              : 'Select time',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: _selectedTime != null
                                                ? textColor
                                                : subtitleColor,
                                          ),
                                        ),
                                      ],
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

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Capacity & Pricing',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Available Capacity
                    TextFormField(
                      controller: _capacityController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(color: textColor),
                      decoration: _buildInputDecoration(
                        label: 'Available Capacity (kg)',
                        hint: 'e.g., 5',
                        prefixIcon: Icons.scale_rounded,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter available capacity';
                        }
                        final capacity = double.tryParse(value.trim());
                        if (capacity == null || capacity <= 0) {
                          return 'Capacity must be greater than 0 kg';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Price
                    TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(color: textColor),
                      decoration: _buildInputDecoration(
                        label: 'Price (₹)',
                        hint: 'e.g., 100',
                        prefixIcon: Icons.currency_rupee_rounded,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter price';
                        }
                        final price = double.tryParse(value.trim());
                        if (price == null || price < 0) {
                          return 'Price must be greater than or equal to 0';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Negotiable Switch
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Price Negotiable',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Allow senders to negotiate price',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: subtitleColor,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: _isNegotiable,
                            activeThumbColor: primaryColor,
                            onChanged: (val) {
                              setState(() {
                                _isNegotiable = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Create Trip Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Publish Trip',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required String hint,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: subtitleColor, fontSize: 14),
      hintStyle: const TextStyle(color: subtitleColor, fontSize: 13),
      prefixIcon: Icon(prefixIcon, color: primaryColor, size: 20),
      filled: true,
      fillColor: backgroundColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
    );
  }
}
