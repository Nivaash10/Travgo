import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:frontend/features/tracking/services/routing_service.dart';

void main() {
  group('Dynamic Routing Service Tests', () {
    final routingService = RoutingService();

    test('Route A: Coimbatore -> Chennai', () async {
      final start = const LatLng(11.0168, 76.9558);
      final dest = const LatLng(13.0827, 80.2707);

      final result = await routingService.getRoute(start: start, destination: dest);
      expect(result, isNotNull);
      expect(result!.points.isNotEmpty, isTrue);
      expect(result.distanceMeters, greaterThan(300000));
    });

    test('Route B: Chennai -> Madurai', () async {
      final start = const LatLng(13.0827, 80.2707);
      final dest = const LatLng(9.9252, 78.1198);

      final result = await routingService.getRoute(start: start, destination: dest);
      expect(result, isNotNull);
      expect(result!.points.isNotEmpty, isTrue);
      expect(result.distanceMeters, greaterThan(300000));
    });

    test('Route C: Salem -> Coimbatore', () async {
      final start = const LatLng(11.6643, 78.1460);
      final dest = const LatLng(11.0168, 76.9558);

      final result = await routingService.getRoute(start: start, destination: dest);
      expect(result, isNotNull);
      expect(result!.points.isNotEmpty, isTrue);
      expect(result.distanceMeters, greaterThan(100000));
    });

    test('Route D: Madurai -> Trichy', () async {
      final start = const LatLng(9.9252, 78.1198);
      final dest = const LatLng(10.7905, 78.7047);

      final result = await routingService.getRoute(start: start, destination: dest);
      expect(result, isNotNull);
      expect(result!.points.isNotEmpty, isTrue);
      expect(result.distanceMeters, greaterThan(100000));
    });

    test('Coordinate Snapping Utility', () {
      final route = [
        const LatLng(11.0000, 76.9000),
        const LatLng(11.0100, 76.9100),
        const LatLng(11.0200, 76.9200),
      ];

      final rawPoint = const LatLng(11.0050, 76.9051); // 10m off route
      final snapped = RoutingService.snapPointToRoute(rawPoint, route);

      expect(snapped.latitude, closeTo(11.0050, 0.001));
      expect(snapped.longitude, closeTo(76.9050, 0.001));
    });
  });
}
