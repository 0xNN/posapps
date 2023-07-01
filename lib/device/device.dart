import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class DeviceDataInfo {
  Future<String> _getId() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    String id;
    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidDeviceInfo =
          await deviceInfoPlugin.androidInfo;
      id = androidDeviceInfo.androidId;
    } else if (Platform.isIOS) {
      final IosDeviceInfo iosDeviceInfo = await deviceInfoPlugin.iosInfo;
      id = iosDeviceInfo.identifierForVendor;
    }
    return id;
  }
}
