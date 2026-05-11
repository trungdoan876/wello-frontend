import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  static Future<LatLng> getCurrentLatLng() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Vui lòng bật GPS trên thiết bị');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw Exception('Bạn đã từ chối quyền vị trí');
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Bạn đã chặn quyền vị trí vĩnh viễn trong cài đặt');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      return LatLng(position.latitude, position.longitude);
    } on MissingPluginException {
      throw Exception(
        'Plugin định vị chưa được nạp. Hãy tắt app hoàn toàn rồi chạy lại bằng flutter run (không hot reload).',
      );
    }
  }
}
