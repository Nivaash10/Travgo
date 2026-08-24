/// Map Tile Layer Configuration for Hybrid Satellite Map
///
/// Decouples tile URLs, overlay layers, and attributions from the map widget.
/// Combines Esri World Imagery (Satellite Base), Esri World Transportation (Roads),
/// and Esri World Boundaries and Places (City, Town, Highway, and Place Labels).
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';

enum MapStyleMode {
  hybridSatellite,
  streets,
}

class MapTileConfig {
  const MapTileConfig._();

  /// Esri World Imagery — Satellite Base Layer
  static const String esriSatelliteUrl =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';

  /// Esri World Transportation — Roads & Highways Overlay Layer (Transparent)
  static const String esriRoadsOverlayUrl =
      'https://server.arcgisonline.com/ArcGIS/rest/services/Reference/World_Transportation/MapServer/tile/{z}/{y}/{x}';

  /// Esri World Boundaries and Places — City, Town, & Place Labels Overlay (Transparent)
  static const String esriLabelsOverlayUrl =
      'https://server.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places/MapServer/tile/{z}/{y}/{x}';

  /// Standard OpenStreetMap Streets Fallback
  static const String openStreetMapUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// Package User-Agent
  static const String userAgentPackageName = 'com.travgo.app';

  /// Attribution Text
  static const String satelliteAttribution =
      'Tiles © Esri — Source: Esri, Maxar, Earthstar, USGS, USDA';
  static const String streetsAttribution = 'OpenStreetMap contributors';

  /// Builds TileLayer widgets for the specified MapStyleMode
  static List<TileLayer> buildTileLayers(MapStyleMode mode) {
    void handleTileError(TileImage tile, Object error, StackTrace? stackTrace) {
      if (kDebugMode) {
        debugPrint('Tile load error (${tile.coordinates}): $error');
      }
    }

    if (mode == MapStyleMode.hybridSatellite) {
      return [
        // 1. Satellite Base Layer
        TileLayer(
          urlTemplate: esriSatelliteUrl,
          userAgentPackageName: userAgentPackageName,
          maxZoom: 19,
          errorTileCallback: handleTileError,
        ),
        // 2. Roads & Highways Reference Overlay (Transparent)
        TileLayer(
          urlTemplate: esriRoadsOverlayUrl,
          userAgentPackageName: userAgentPackageName,
          maxZoom: 19,
          errorTileCallback: handleTileError,
        ),
        // 3. City, Town, & Place Labels Overlay (Transparent)
        TileLayer(
          urlTemplate: esriLabelsOverlayUrl,
          userAgentPackageName: userAgentPackageName,
          maxZoom: 19,
          errorTileCallback: handleTileError,
        ),
      ];
    }

    // Fallback Standard Streets
    return [
      TileLayer(
        urlTemplate: openStreetMapUrl,
        userAgentPackageName: userAgentPackageName,
        maxZoom: 19,
        errorTileCallback: handleTileError,
      ),
    ];
  }
}
