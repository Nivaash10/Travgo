import 'package:flutter/material.dart';
import '../models/sender_search_query.dart';
import 'matching_travellers_screen.dart';

/// Search Route Screen for Senders.
///
/// Allows Senders to input and validate route details (Source, Destination, Date, Parcel Weight)
/// and construct a presentation-level [SenderSearchQuery].
class SearchRouteScreen extends StatefulWidget {
  final String? initialSource;
  final String? initialDestination;

  const SearchRouteScreen({
    super.key,
    this.initialSource,
    this.initialDestination,
  });

  @override
  State<SearchRouteScreen> createState() => _SearchRouteScreenState();
}

class _SearchRouteScreenState extends State<SearchRouteScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _sourceController;
  late TextEditingController _destinationController;
  late TextEditingController _weightController;
  DateTime? _selectedDate;
  SenderSearchQuery? lastSearchQuery;

  @override
  void initState() {
    super.initState();
    _sourceController = TextEditingController(text: widget.initialSource ?? '');
    _destinationController = TextEditingController(text: widget.initialDestination ?? '');
    _weightController = TextEditingController();
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _destinationController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime initial = _selectedDate ?? today;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(today) ? today : initial,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _onSearchSubmitted() {
    if (_formKey.currentState?.validate() ?? false) {
      final trimmedSource = _sourceController.text.trim();
      final trimmedDestination = _destinationController.text.trim();
      final double weight = double.parse(_weightController.text.trim());

      final query = SenderSearchQuery(
        source: trimmedSource,
        destination: trimmedDestination,
        date: _selectedDate,
        parcelWeightKg: weight,
      );

      setState(() {
        lastSearchQuery = query;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Search criteria ready: ${query.source} to ${query.destination} on ${_formatDate(query.date!)} (${query.parcelWeightKg} kg)',
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MatchingTravellersScreen(query: query),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Route'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Search Travellers',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter parcel travel details to find available travellers.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
                const SizedBox(height: 24),

                // Source Input
                TextFormField(
                  controller: _sourceController,
                  decoration: const InputDecoration(
                    labelText: 'From (Source)',
                    hintText: 'e.g., Coimbatore',
                    prefixIcon: Icon(Icons.trip_origin),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a source location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Destination Input
                TextFormField(
                  controller: _destinationController,
                  decoration: const InputDecoration(
                    labelText: 'To (Destination)',
                    hintText: 'e.g., Chennai',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a destination location';
                    }
                    final sourceTrimmed = _sourceController.text.trim();
                    final destTrimmed = value.trim();
                    if (sourceTrimmed.isNotEmpty &&
                        sourceTrimmed.toLowerCase() == destTrimmed.toLowerCase()) {
                      return 'Source and destination must be different';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Travel Date Selection FormField
                FormField<DateTime>(
                  initialValue: _selectedDate,
                  validator: (_) {
                    if (_selectedDate == null) {
                      return 'Please select a travel date';
                    }
                    return null;
                  },
                  builder: (FormFieldState<DateTime> state) {
                    return InkWell(
                      onTap: () async {
                        await _selectDate(context);
                        state.didChange(_selectedDate);
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Travel Date',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: const OutlineInputBorder(),
                          errorText: state.errorText,
                        ),
                        child: Text(
                          _selectedDate == null
                              ? 'Select date'
                              : _formatDate(_selectedDate!),
                          style: TextStyle(
                            color: _selectedDate == null ? Colors.grey[600] : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Parcel Weight Input
                TextFormField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Parcel Weight (kg)',
                    hintText: 'e.g., 2.5',
                    prefixIcon: Icon(Icons.scale),
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
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                // Submit Button
                ElevatedButton(
                  onPressed: _onSearchSubmitted,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Find Travellers',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
