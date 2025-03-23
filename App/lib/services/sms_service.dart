import 'package:telephony/telephony.dart';

class SMSService {
  static final Telephony telephony = Telephony.instance;

  static Future<void> sendEmergencySMS(String message, List<String> recipients) async {
    bool? permissionGranted = await telephony.requestSmsPermissions;

    if (permissionGranted ?? false) {
      for (String number in recipients) {
        telephony.sendSms(
          to: number,
          message: message,
        );
      }
      print("🚀 Emergency SMS Sent Successfully!");
    } else {
      print("⚠️ SMS Permission Denied!");
    }
  }
}
