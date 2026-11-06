import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../../models/nearby_nursery.dart';

enum NearbyLocationState {
  loading,
  ready,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  unavailable,
  error,
}

class NearbyLocationSnapshot {
  const NearbyLocationSnapshot({
    required this.state,
    required this.message,
    this.location,
  });

  final NearbyLocationState state;
  final String message;
  final LocationPoint? location;

  bool get hasLocation => location != null;
}

class NearbyNurseryLocationService {
  const NearbyNurseryLocationService();

  Future<NearbyLocationSnapshot> resolveCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const NearbyLocationSnapshot(
          state: NearbyLocationState.serviceDisabled,
          message: 'Location services are disabled on this device.',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        return const NearbyLocationSnapshot(
          state: NearbyLocationState.permissionDenied,
          message: 'Location permission is needed to sort nurseries nearby.',
        );
      }

      if (permission == LocationPermission.deniedForever) {
        return const NearbyLocationSnapshot(
          state: NearbyLocationState.permissionDeniedForever,
          message: 'Location permission is permanently denied. Open settings to enable it.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          distanceFilter: 50,
          timeLimit: Duration(seconds: 8),
        ),
      );

      return NearbyLocationSnapshot(
        state: NearbyLocationState.ready,
        message:
            'Current location: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
        location: LocationPoint(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );
    } on TimeoutException {
      return const NearbyLocationSnapshot(
        state: NearbyLocationState.unavailable,
        message: 'Unable to get the current location right now.',
      );
    } catch (_) {
      return const NearbyLocationSnapshot(
        state: NearbyLocationState.error,
        message: 'Unable to get the current location right now.',
      );
    }
  }
}
