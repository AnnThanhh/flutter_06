import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';

Future<dynamic> getDeviceInfo() async {
  if (kIsWeb) {
    throw UnsupportedError("chỉ hỗ trợ trên thiết bị di động (Android và iOS)");
  }

  final deviceInfoPlugin = DeviceInfoPlugin();

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      final androidInfo = await deviceInfoPlugin.androidInfo;
      return {
        "platform": "android",
        "deviceName": androidInfo.model,
        "brand": androidInfo.brand,
        "manufacturer": androidInfo.manufacturer, // Device manufacturer
        "version": androidInfo.version.release, // Android version release
        "sdkInt": androidInfo.version.sdkInt, // Android SDK version
        "isPhysicalDevice": androidInfo
            .isPhysicalDevice, // Whether the device is physical or emulator || true là thiết bị vật lý, false là giả lập
      };
    case TargetPlatform.iOS:
      final iosInfo = await deviceInfoPlugin.iosInfo;
      return {
        "platform": "ios",
        "deviceName": iosInfo.name,
        "brand": "Apple",
        "manufacturer": "Apple",
        "systemName": iosInfo.systemName, // iOS system name
        "systemVersion": iosInfo.systemVersion, // iOS system version
        "model": iosInfo.model,
        "isPhysicalDevice": iosInfo
            .isPhysicalDevice, // Whether the device is physical or emulator || true là thiết bị vật lý, false là giả lập
      };
    default:
      throw UnsupportedError(
        "chỉ hỗ trợ trên thiết bị di động (Android và iOS)",
      );
  }
}
