import 'package:flutter/material.dart';
import '../models/sender_delivery_request.dart';
import '../models/sender_search_query.dart';
import '../models/sender_traveller_match.dart';
import 'review_delivery_request_screen.dart';

/// Screen for entering parcel details for a selected traveller delivery request.
class ParcelDetailsScreen extends StatefulWidget {
  final SenderSearchQuery searchQuery;
  final SenderTravellerMatch traveller;
  final SenderDeliveryRequest? initialRequest;

  const ParcelDetailsScreen({
    super.key,
    required this.searchQuery,
    required this.traveller,
    this.initialRequest,
  });

  @override
  State<ParcelDetailsScreen> createState() => _ParcelDetailsScreenState();
}

class _ParcelDetailsScreenState extends State<ParcelDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _weightController;
  late TextEditingController _instructionsController;
  String? _selectedCategory;

  static const List<String> _categories = [
    'Documents',
    'Clothes',
    'Electronics',
    'Food',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.initialRequest?.parcelDescription ?? '',
    );

    final initialWeight = widget.initialRequest?.parcelWeightKg ??
        widget.searchQuery.parcelWeightKg;
    _weightController = TextEditingController(
      text: initialWeight != null ? initialWeight.toString() : '',
    );

    _instructionsController = TextEditingController(
      text: widget.initialRequest?.specialInstructions ?? '',
    );

    _selectedCategory = widget.initialRequest?.parcelCategory ?? _categories.first;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _weightController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _onReviewSubmitted() {
    if (_formKey.currentState?.validate() ?? false) {
      final description = _descriptionController.text.trim();
      final weight = double.parse(_weightController.text.trim());
      final instructions = _instructionsController.text.trim();

      final deliveryRequest = SenderDeliveryRequest(
        searchQuery: widget.searchQuery,
        traveller: widget.traveller,
        parcelDescription: description,
        parcelWeightKg: weight,
        parcelCategory: _selectedCategory!,
        specialInstructions: instructions.isNotEmpty ? instructions : null,
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ReviewDeliveryRequestScreen(
            request: deliveryRequest,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final traveller = widget.traveller;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parcel Details'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Selected Traveller Summary Card
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
                          Expanded(
                            child: Text(
                              traveller.travellerName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (traveller.isVerified)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green[600]!),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified,
                                      size: 14, color: Colors.green[700]),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Verified',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        traveller.route,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Travel: ${traveller.travelDateTime}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Capacity: ${traveller.availableCapacityKg} kg',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Price: ₹${traveller.priceRupees.toStringAsFixed(0)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Enter Parcel Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Parcel Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Parcel Description',
                        hintText: 'e.g., Books and clothes',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a parcel description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Parcel Weight
                    TextFormField(
                      controller: _weightController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Parcel Weight (kg)',
                        hintText: 'e.g., 2.5',
                        prefixIcon: const Icon(Icons.scale),
                        border: const OutlineInputBorder(),
                        helperText:
                            'Max available: ${traveller.availableCapacityKg} kg',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a valid parcel weight';
                        }
                        final parsed = double.tryParse(value.trim());
                        if (parsed == null || parsed <= 0) {
                          return 'Please enter a valid parcel weight';
                        }
                        if (parsed > traveller.availableCapacityKg) {
                          return 'Weight exceeds available capacity (${traveller.availableCapacityKg} kg)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Parcel Category
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Parcel Category',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a parcel category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Special Instructions
                    TextFormField(
                      controller: _instructionsController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Special Instructions (Optional)',
                        hintText: 'e.g., Handle with care',
                        prefixIcon: Icon(Icons.note_alt_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Review Action Button
                    ElevatedButton(
                      onPressed: _onReviewSubmitted,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Review Delivery Request',
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
