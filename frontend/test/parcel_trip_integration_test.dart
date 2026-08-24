import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:frontend/features/tracking/models/tracking_model.dart';
import 'package:frontend/features/tracking/screens/tracking_screen.dart';
import 'package:flutter/material.dart';

void main() {
  group('ParcelTrip Data Integration Tests', () {
    test('ParcelTrip JSON serialization and deserialization', () {
      final tripJson = {
        'parcelId': 'TRV9988',
        'tripId': 'TRIP5544',
        'sourceName': 'Madurai',
        'sourceLatitude': 9.9252,
        'sourceLongitude': 78.1198,
        'destinationName': 'Trichy',
        'destinationLatitude': 10.7905,
        'destinationLongitude': 78.7047,
        'travellerName': 'Karthik S',
        'status': 'inTransit',
      };

      final trip = ParcelTrip.fromJson(tripJson);

      expect(trip.parcelId, equals('TRV9988'));
      expect(trip.tripId, equals('TRIP5544'));
      expect(trip.sourceName, equals('Madurai'));
      expect(trip.sourceLocation.latitude, equals(9.9252));
      expect(trip.destinationName, equals('Trichy'));
      expect(trip.destinationLocation.latitude, equals(10.7905));
      expect(trip.travellerName, equals('Karthik S'));
      expect(trip.status, equals(ParcelStatus.inTransit));

      final serialized = trip.toJson();
      expect(serialized['parcelId'], equals('TRV9988'));
      expect(serialized['sourceName'], equals('Madurai'));
    });

    testWidgets('TrackingScreen accepts dynamic ParcelTrip instance', (tester) async {
      final customTrip = ParcelTrip(
        parcelId: 'TRV7070',
        tripId: 'TRIP3030',
        sourceName: 'Salem',
        sourceLocation: const LatLng(11.6643, 78.1460),
        destinationName: 'Coimbatore',
        destinationLocation: const LatLng(11.0168, 76.9558),
        travellerName: 'Priya M',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: TrackingScreen(trip: customTrip),
        ),
      );

      expect(find.text('Live Tracking'), findsOneWidget);
      expect(find.text('Parcel #TRV7070'), findsOneWidget);
      expect(find.text('Salem → Coimbatore'), findsOneWidget);
    });
  });
}
