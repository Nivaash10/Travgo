import 'package:flutter/material.dart';
import '../../../models/receiver_model.dart';
import '../models/sender_search_query.dart';
import '../repository/saved_receiver_repository.dart';
import 'parcel_details_screen.dart';
import 'saved_receivers_screen.dart';

/// Step 2 of Sender Delivery Workflow: Receiver Details.
class ReceiverDetailsScreen extends StatefulWidget {
  final SenderSearchQuery searchQuery;

  const ReceiverDetailsScreen({
    super.key,
    required this.searchQuery,
  });

  @override
  State<ReceiverDetailsScreen> createState() => _ReceiverDetailsScreenState();
}

class _ReceiverDetailsScreenState extends State<ReceiverDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _landmarkCtrl;
  late TextEditingController _pincodeCtrl;
  bool _saveForFuture = true;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: 'Priya Sharma');
    _phoneCtrl = TextEditingController(text: '+91 98765 01234');
    _addressCtrl = TextEditingController(text: 'Flat 402, Sunshine Apartments, Anna Nagar, ${widget.searchQuery.destination}');
    _landmarkCtrl = TextEditingController(text: 'Near Tower Park');
    _pincodeCtrl = TextEditingController(text: '600040');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _landmarkCtrl.dispose();
    _pincodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFromSavedReceivers() async {
    final selected = await Navigator.push<ReceiverModel>(
      context,
      MaterialPageRoute(
        builder: (context) => const SavedReceiversScreen(isSelectionMode: true),
      ),
    );
    if (selected != null) {
      setState(() {
        _nameCtrl.text = selected.fullName;
        _phoneCtrl.text = selected.phoneNumber;
        _addressCtrl.text = selected.deliveryAddress;
        _landmarkCtrl.text = selected.landmark ?? '';
        _pincodeCtrl.text = selected.pincode ?? '';
      });
    }
  }

  void _onProceedToParcelDetails() {
    if (_formKey.currentState?.validate() ?? false) {
      final receiver = ReceiverModel(
        id: 'REC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        fullName: _nameCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim(),
        deliveryAddress: _addressCtrl.text.trim(),
        landmark: _landmarkCtrl.text.trim().isNotEmpty ? _landmarkCtrl.text.trim() : null,
        pincode: _pincodeCtrl.text.trim().isNotEmpty ? _pincodeCtrl.text.trim() : null,
        isSaved: _saveForFuture,
      );

      if (_saveForFuture) {
        SavedReceiverRepository().addReceiver(receiver);
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ParcelDetailsScreen(
            searchQuery: widget.searchQuery,
            receiver: receiver,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Step 2: Receiver Details'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Step Progress Indicator
                Row(
                  children: [
                    _buildStepDot(number: '1', title: 'Route', isComplete: true),
                    _buildStepLine(isComplete: true),
                    _buildStepDot(number: '2', title: 'Receiver', isActive: true),
                    _buildStepLine(isComplete: false),
                    _buildStepDot(number: '3', title: 'Parcel', isComplete: false),
                    _buildStepLine(isComplete: false),
                    _buildStepDot(number: '4', title: 'Review', isComplete: false),
                  ],
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Receiver Information',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _pickFromSavedReceivers,
                      icon: const Icon(Icons.contacts, size: 16),
                      label: const Text('Saved Receivers', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2563EB),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Specify the person who will receive the parcel at ${widget.searchQuery.destination}.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 20),

                // Receiver Full Name
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Receiver Full Name *',
                    hintText: 'e.g., Priya Sharma',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Please enter receiver name' : null,
                ),
                const SizedBox(height: 16),

                // Receiver Phone Number
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Receiver Phone Number *',
                    hintText: 'e.g., +91 98765 01234',
                    prefixIcon: Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Please enter receiver phone number' : null,
                ),
                const SizedBox(height: 16),

                // Receiver Delivery Address
                TextFormField(
                  controller: _addressCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Delivery Address *',
                    hintText: 'House/Flat No, Building, Street, Area',
                    prefixIcon: Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Please enter delivery address' : null,
                ),
                const SizedBox(height: 16),

                // Landmark & Pincode Row
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _landmarkCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Landmark (Optional)',
                          hintText: 'Near Tower Park',
                          prefixIcon: Icon(Icons.map_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _pincodeCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'PIN Code',
                          hintText: '600040',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Save Receiver Checkbox
                CheckboxListTile(
                  value: _saveForFuture,
                  onChanged: (val) {
                    setState(() {
                      _saveForFuture = val ?? true;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text(
                    'Save this receiver for future deliveries',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  activeColor: const Color(0xFF2563EB),
                ),
                const SizedBox(height: 24),

                // CTA Button
                ElevatedButton.icon(
                  onPressed: _onProceedToParcelDetails,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text(
                    'Next: Parcel Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
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
