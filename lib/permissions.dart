import 'package:permission_handler/permission_handler.dart';

Future<bool> requestContactPermission() async {
  var status = await Permission.contacts.status;
  if (status.isDenied) {
    status = await Permission.contacts.request();
  }
  return status.isGranted;
}
