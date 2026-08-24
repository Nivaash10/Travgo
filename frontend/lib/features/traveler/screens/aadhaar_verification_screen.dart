import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../repository/traveler_trip_repository.dart';

class AadhaarVerificationScreen extends StatefulWidget {
  const AadhaarVerificationScreen({super.key});

  @override
  State<AadhaarVerificationScreen> createState() => _AadhaarVerificationScreenState();
}

enum VerificationStep {
  entry,
  processing,
  success,
  failure,
}

class AadhaarNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length > 12) {
      return oldValue;
    }

    final buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(digitsOnly[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _AadhaarVerificationScreenState extends State<AadhaarVerificationScreen> {
  static const Color backgroundColor = Color(0xFFF6F8FC);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color accentColor = Color(0xFFF59E0B);
  static const Color textColor = Color(0xFF1E293B);
  static const Color subtitleColor = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _aadhaarController = TextEditingController();
  VerificationStep _currentStep = VerificationStep.entry;

  @override
  void dispose() {
    // Clear controller without logging/storing Aadhaar input
    _aadhaarController.clear();
    _aadhaarController.dispose();
    super.dispose();
  }

  void _onContinueFromEntry() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _currentStep = VerificationStep.processing;
      });
    }
  }

  void _simulateSuccess() {
    TravelerTripRepository().isVerified = true;
    setState(() {
      _currentStep = VerificationStep.success;
    });
  }

  void _simulateFailure() {
    setState(() {
      _currentStep = VerificationStep.failure;
    });
  }

  void _retryVerification() {
    _aadhaarController.clear();
    setState(() {
      _currentStep = VerificationStep.entry;
    });
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
          onPressed: () => Navigator.pop(context, false),
        ),
        title: const Text(
          'Verify Aadhaar',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _buildCurrentStepContent(context),
      ),
    );
  }

  Widget _buildCurrentStepContent(BuildContext context) {
    switch (_currentStep) {
      case VerificationStep.entry:
        return _buildEntryStep();
      case VerificationStep.processing:
        return _buildProcessingStep();
      case VerificationStep.success:
        return _buildSuccessStep();
      case VerificationStep.failure:
        return _buildFailureStep();
    }
  }

  // Step 1: Aadhaar Entry Form
  Widget _buildEntryStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.badge_outlined,
                      color: primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verify Identity',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Trusted TRAVGO Traveler',
                          style: TextStyle(
                            fontSize: 12,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Verify your identity to become a Verified TRAVGO Traveler.',
                style: TextStyle(
                  fontSize: 14,
                  color: subtitleColor,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Container(
          width: double.infinity,
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aadhaar Number',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _aadhaarController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    AadhaarNumberFormatter(),
                  ],
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                  ),
                  decoration: InputDecoration(
                    hintText: 'XXXX XXXX XXXX',
                    hintStyle: const TextStyle(
                      color: subtitleColor,
                      fontSize: 15,
                      letterSpacing: 2.0,
                    ),
                    prefixIcon: const Icon(
                      Icons.credit_card_rounded,
                      color: primaryColor,
                      size: 22,
                    ),
                    filled: true,
                    fillColor: backgroundColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: primaryColor,
                        width: 1.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: errorColor),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: errorColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your Aadhaar number';
                    }
                    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
                    if (digitsOnly.length != 12) {
                      return 'Aadhaar number must be exactly 12 digits';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _onContinueFromEntry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Continue',
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
      ],
    );
  }

  // Step 2: Verification Processing State (e-KYC Prototype)
  Widget _buildProcessingStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Prototype / Mock Verification',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const SizedBox(
                height: 48,
                width: 48,
                child: CircularProgressIndicator(
                  color: primaryColor,
                  strokeWidth: 3.5,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Verifying Identity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Please wait while your identity verification is processed.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: subtitleColor,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: const Text(
                  'Real e-KYC verification backend will be connected.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: subtitleColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Simulation Controls
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _simulateSuccess,
                  icon: const Icon(Icons.check_circle_rounded, size: 20),
                  label: const Text(
                    'Continue Verification',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: successColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _simulateFailure,
                  icon: const Icon(Icons.cancel_rounded, size: 20),
                  label: const Text(
                    'Simulate Failure',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: errorColor,
                    side: const BorderSide(color: errorColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Step 3: Verification Success
  Widget _buildSuccessStep() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
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
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: successColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  size: 56,
                  color: successColor,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                '✓ Identity Verified',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: successColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your Aadhaar identity verification was successful.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: subtitleColor,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, color: successColor, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Status: VERIFIED TRAVELER',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: successColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Continue',
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
      ],
    );
  }

  // Step 4: Verification Failure
  Widget _buildFailureStep() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
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
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: errorColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 56,
                  color: errorColor,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Identity Verification Failed',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: errorColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'We could not verify your identity.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: subtitleColor,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _retryVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Back to Profile',
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
