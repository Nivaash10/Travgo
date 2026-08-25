/// Local UI-side model representing Sender search parameters.
///
/// Note: This is a frontend presentation structure.
/// Official API payload contracts will be integrated when defined by Person 1.
class SenderSearchQuery {
  final String source;
  final String destination;
  final DateTime? date;
  final double? parcelWeightKg;

  const SenderSearchQuery({
    this.source = '',
    this.destination = '',
    this.date,
    this.parcelWeightKg,
  });

  SenderSearchQuery copyWith({
    String? source,
    String? destination,
    DateTime? date,
    double? parcelWeightKg,
  }) {
    return SenderSearchQuery(
      source: source ?? this.source,
      destination: destination ?? this.destination,
      date: date ?? this.date,
      parcelWeightKg: parcelWeightKg ?? this.parcelWeightKg,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source,
      'destination': destination,
      'date': date?.toIso8601String(),
      'parcelWeightKg': parcelWeightKg,
    };
  }

  factory SenderSearchQuery.fromJson(Map<String, dynamic> json) {
    return SenderSearchQuery(
      source: json['source'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      date: json['date'] != null ? DateTime.tryParse(json['date'] as String) : null,
      parcelWeightKg: (json['parcelWeightKg'] as num?)?.toDouble(),
    );
  }
}
