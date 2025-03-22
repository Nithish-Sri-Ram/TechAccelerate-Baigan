// // lib/controller/emergency_controller.dart
// import 'package:get/get.dart';
// import 'package:baigan/services/accident_detection_service.dart';
// import 'package:baigan/services/emergency_alert_service.dart';
// import 'package:baigan/controller/auth_controller.dart';

// class EmergencyController extends GetxController {
//   final AccidentDetectionService _detectionService = Get.find<AccidentDetectionService>();
//   final EmergencyAlertService _alertService = Get.find<EmergencyAlertService>();
//   final AuthController _authController = Get.find<AuthController>();
  
//   RxBool get isMonitoring => _detectionService.isMonitoring;
//   RxList<EmergencyContact> contacts = <EmergencyContact>[].obs;
  
//   @override
//   void onInit() {
//     super.onInit();
//     _initServices();
//     _loadContacts();
//   }
  
//   Future<void> _initServices() async {
//     // Listen for accident events
//     _detectionService.accidentStream.listen((accidentData) {
//       _handleAccidentDetected(accidentData);
//     });
//   }
  
//   Future<void> _loadContacts() async {
//     if (_authController.user != null) {
//       final userContacts = await _alertService.getUserEmergencyContacts(
//         _authController.user!.uid
//       );
//       contacts.assignAll(userContacts);
//     }
//   }
  
//   void _handleAccidentDetected(AccidentData accidentData) {
//     // Log the detected event
//     print('Accident detected: ${accidentData.detectionSource} with magnitude ${accidentData.magnitude}');
    
//     // Trigger the alert system
//     _alertService.triggerEmergencyAlert(
//       accidentData: accidentData,
//     );
//   }
  
//   Future<void> toggleMonitoring() async {
//     if (isMonitoring.value) {
//       await _detectionService.stopMonitoring();
//     } else {
//       await _detectionService.startMonitoring();
//     }
//   }
  
//   Future<void> addContact(EmergencyContact contact) async {
//     if (_authController.user != null) {
//       await _alertService.saveEmergencyContact(
//         _authController.user!.uid,
//         contact,
//       );
//       await _loadContacts();
//     }
//   }
  
//   Future<void> deleteContact(String contactId) async {
//     if (_authController.user != null) {
//       await _alertService.deleteEmergencyContact(
//         _authController.user!.uid,
//         contactId,
//       );
//       await _loadContacts();
//     }
//   }
  
//   void testEmergencyAlert() {
//     _detectionService.simulateAccident();
//   }
  
//   @override
//   void onClose() {
//     _detectionService.dispose();
//     super.onClose();
//   }
// }