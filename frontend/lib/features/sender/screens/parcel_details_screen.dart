import 'package:flutter/material.dart';
import '../../../models/receiver_model.dart';
import '../models/sender_delivery_request.dart';
import '../models/sender_search_query.dart';
import '../models/sender_traveller_match.dart';
import 'matching_travellers_screen.dart';

/// Step 3 of Sender Delivery Workflow: Parcel Details.
class ParcelDetailsScreen extends StatefulWidget {
  final SenderSearchQuery searchQuery;
  final ReceiverModel? receiver;
  final SenderTravellerMatch? traveller;
  final SenderDeliveryRequest? initialRequest;

  const ParcelDetailsScreen({
    super.key,
    required this.searchQuery,
    this.receiver,
    this.traveller,
    this.initialRequest,
  });

  @override
  State<ParcelDetailsScreen> createState() => _ParcelDetailsScreenState();
}

class _ParcelDetailsScreenState extends State<ParcelDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _weightController;
  late TextEditingController _quantityController;
  late TextEditingController _instructionsController;
  String? _selectedCategory;

  static const List<String> _categories = [
    'Documents',
    'Books',
    'Clothes',
    'Electronics',
    'Gifts',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.initialRequest?.parcelDescription ?? '',
    );

    final initialWeight = widget.initialRequest?.parcelWeightKg ??
        widget.searchQuery.parcelWeightKg ??
        2.5;
    _weightController = TextEditingController(
      text: initialWeight.toString(),
    );

    _quantityController = TextEditingController(
      text: (widget.initialRequest?.parcelQuantity ?? 1).toString(),
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
    _quantityController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _onReviewSubmitted() {
    if (_formKey.currentState?.validate() ?? false) {
      final description = _descriptionController.text.trim();
      final weight = double.parse(_weightController.text.trim());
      final quantity = int.tryParse(_quantityController.text.trim()) ?? 1;
      final instructions = _instructionsController.text.trim();

      final updatedQuery = widget.searchQuery.copyWith(
        parcelWeightKg: weight,
      );

      final receiver = widget.receiver ??
          ReceiverModel(
            id: 'REC-101',
            fullName: 'Priya Sharma',
            phoneNumber: '+91 98765 01234',
            deliveryAddress: 'Flat 402, Sunshine Apartments, Anna Nagar, ${widget.searchQuery.destination}',
          );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MatchingTravellersScreen(
            query: updatedQuery,
            receiver: receiver,
            parcelDescription: description,
            parcelCategory: _selectedCategory,
            parcelQuantity: quantity,
            specialInstructions: instructions.isNotEmpty ? instructions : null,
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Step 3: Parcel Details'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Step Progress Indicator
              Row(
                children: [
                  _buildStepDot(number: '1', title: 'Route', isComplete: true),
                  _buildStepLine(isComplete: true),
                  _buildStepDot(number: '2', title: 'Receiver', isComplete: true),
                  _buildStepLine(isComplete: true),
                  _buildStepDot(number: '3', title: 'Parcel', isActive: true),
                  _buildStepLine(isComplete: false),
                  _buildStepDot(number: '4', title: 'Travellers', isComplete: false),
                ],
              ),
              const SizedBox(height: 24),

              // Selected Traveller Card if available
              if (traveller != null) ...[
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
                            Text(
                              traveller.travellerName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            if (traveller.isVerified)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Verified',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          traveller.route,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Travel: ${traveller.travelDateTime}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              Text(
                'Parcel Attributes',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Provide clear details about the package to be transported.',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 20),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Parcel Category Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Parcel Category *',
                        prefixIcon: Icon(Icons.category_outlined),
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

                    // Parcel Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Parcel Description *',
                        hintText: 'e.g., Textbooks and study material',
                        prefixIcon: Icon(Icons.description_outlined),
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

                    // Weight & Quantity Row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _weightController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Weight (kg) *',
                              hintText: 'Enter weight',
                              prefixIcon: Icon(Icons.scale_outlined),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a valid parcel weight';
                              }
                              final parsed = double.tryParse(value.trim());
                              if (parsed == null || parsed <= 0) {
                                return 'Please enter a valid parcel weight';
                              }
                              if (traveller != null && parsed > traveller.availableCapacityKg) {
                                return 'Weight exceeds available capacity (${traveller.availableCapacityKg} kg)';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Quantity *',
                              hintText: '1',
                              prefixIcon: Icon(Icons.inventory_2_outlined),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter quantity';
                              }
                              final parsed = int.tryParse(value.trim());
                              if (parsed == null || parsed <= 0) {
                                return 'Invalid qty';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Special Instructions
                    TextFormField(
                      controller: _instructionsController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Special Instructions (Optional)',
                        hintText: 'e.g., Keep away from moisture / fragile',
                        prefixIcon: Icon(Icons.note_alt_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Prohibited Items Notice Box
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Prohibited Items Notice',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF991B1B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Hazardous materials, explosives, illegal drugs, firearms, live animals, and contraband are strictly prohibited on TRAVGO.',
                                  style: TextStyle(fontSize: 11, color: Colors.red[800], height: 1.3),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Review Action Button
                    ElevatedButton(
                      onPressed: _onReviewSubmitted,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Find Available Travellers',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildStepDot({required String number, required String title, bool isActive = false, bool isComplete = false}) {
    final color = isComplete || isActive ? const Color(0xFF2563EB) : Colors.grey[400]!;
    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: isComplete ? const Color(0xFF10B981) : (isActive ? const Color(0xFF2563EB) : Colors.grey[200]),
          child: isComplete
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : Text(
                  number,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.white : Colors.grey[600],
                  ),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: color),
        ),
      ],
    );
  }

  Widget _buildStepLine({required bool isComplete}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        color: isComplete ? const Color(0xFF10B981) : Colors.grey[300],
      ),
    );
  }
}
