import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

class PhoneNumberHelper {
  // Function to fetch the phone number from contacts
  Future<String?> getPhoneNumber() async {
    // Request permission to access contacts
    PermissionStatus permissionStatus = await Permission.contacts.request();
    
    // Check if permission is granted
    if (permissionStatus != PermissionStatus.granted) {
      return "Permission not granted!";
    }
    
    // Fetch contacts
    try {
      Iterable<Contact> contacts = await ContactsService.getContacts();
      // Find the first contact with a phone number
      for (var contact in contacts) {
        if (contact.phones?.isNotEmpty ?? false) {
          return contact.phones?.first.value; // Return the first phone number
        }
      }
      return "No phone number found in contacts";
    } catch (e) {
      return "Error fetching contacts: $e";
    }
  }
}
