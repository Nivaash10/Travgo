import 'package:flutter/material.dart';
import '../../../models/receiver_model.dart';
import '../repository/saved_receiver_repository.dart';

/// Screen allowing Senders to manage and select saved parcel receivers.
class SavedReceiversScreen extends StatefulWidget {
  final ValueChanged<ReceiverModel>? onReceiverSelected;
  final bool isSelectionMode;

  const SavedReceiversScreen({
    super.key,
    this.onReceiverSelected,
    this.isSelectionMode = false,
  });

  @override
  State<SavedReceiversScreen> createState() => _SavedReceiversScreenState();
}

class _SavedReceiversScreenState extends State<SavedReceiversScreen> {
  final SavedReceiverRepository _repo = SavedReceiverRepository();

  void _showAddReceiverDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final landmarkCtrl = TextEditingController();
    final pincodeCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.person_add_outlined, color: Color(0xFF2563EB)),
            SizedBox(width: 8),
            Text('Add Saved Receiver', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Please enter name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number *',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Please enter phone number' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Delivery Address *',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Please enter address' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: landmarkCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Landmark (Optional)',
                    prefixIcon: Icon(Icons.map),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: pincodeCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'PIN Code (Optional)',
                    prefixIcon: Icon(Icons.pin),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final newRec = ReceiverModel(
                  id: 'REC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                  fullName: nameCtrl.text.trim(),
                  phoneNumber: phoneCtrl.text.trim(),
                  deliveryAddress: addressCtrl.text.trim(),
                  landmark: landmarkCtrl.text.trim().isNotEmpty ? landmarkCtrl.text.trim() : null,
                  pincode: pincodeCtrl.text.trim().isNotEmpty ? pincodeCtrl.text.trim() : null,
                  isSaved: true,
                );
                _repo.addReceiver(newRec);
                Navigator.pop(ctx);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${newRec.fullName} added to Saved Receivers.'),
                    backgroundColor: const Color(0xFF10B981),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save Receiver'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final receivers = _repo.receivers;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Saved Receivers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Receiver',
            onPressed: _showAddReceiverDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: receivers.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.contacts_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No saved receivers yet',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Save receiver details for quick single-tap parcel dispatch.',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _showAddReceiverDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Add First Receiver'),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: receivers.length,
                itemBuilder: (context, index) {
                  final rec = receivers[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: const Color(0xFFEFF6FF),
                                    child: Text(
                                      rec.fullName.isNotEmpty ? rec.fullName[0].toUpperCase() : 'R',
                                      style: const TextStyle(
                                        color: Color(0xFF2563EB),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        rec.fullName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      Text(
                                        rec.phoneNumber,
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                                onPressed: () {
                                  setState(() {
                                    _repo.removeReceiver(rec.id);
                                  });
                                },
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF64748B)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  rec.deliveryAddress,
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
                                ),
                              ),
                            ],
                          ),
                          if (rec.landmark != null && rec.landmark!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Landmark: ${rec.landmark}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                          if (rec.pincode != null && rec.pincode!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'PIN: ${rec.pincode}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (widget.onReceiverSelected != null) {
                                  widget.onReceiverSelected!(rec);
                                }
                                Navigator.pop(context, rec);
                              },
                              icon: const Icon(Icons.check_circle_outline, size: 18),
                              label: Text(
                                widget.isSelectionMode ? 'Use This Receiver' : 'Select for Delivery',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
