import 'package:flutter/material.dart';
import 'package:baigan/theme/app_colors.dart';
import 'package:baigan/widgets/custom_appbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String name = "";
  String phone = "";
  String email = "";
  String business = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // Set email from auth
        email = currentUser.email ?? "";

        // Get additional user data from Firestore
        final userData =
            await _firestore.collection('users').doc(currentUser.uid).get();

        if (userData.exists) {
          setState(() {
            name = userData.get('name') ?? "User";
            phone = userData.get('phone') ?? "";
            business = userData.get('business') ?? "";
            isLoading = false;
          });
        } else {
          // Create user document if it doesn't exist
          await _firestore.collection('users').doc(currentUser.uid).set({
            'name': currentUser.displayName ?? "User",
            'email': currentUser.email ?? "",
            'phone': "",
            'business': "",
          });

          // Set default values
          setState(() {
            name = currentUser.displayName ?? "User";
            isLoading = false;
          });
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load user data. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> editField(String field, String hint) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade200.withOpacity(0.85),
        title: Text(
          "Edit $hint",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          style: TextStyle(fontSize: 18),
          decoration: InputDecoration(
            hintText: field,
            hintStyle: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          onChanged: (value) => newValue = value,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 16),
              )),
          TextButton(
            onPressed: () => Navigator.of(context).pop(newValue),
            child: const Text(
              'Save',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );

    if (newValue.isNotEmpty) {
      try {
        final User? currentUser = _auth.currentUser;
        if (currentUser != null) {
          // Update value in state
          setState(() {
            if (hint == 'Name') {
              name = newValue;
            } else if (hint == 'Phone') {
              phone = newValue;
            } else if (hint == 'Email') {
              email = newValue;
            } else if (hint == 'Business') {
              business = newValue;
            }
          });

          // Update in Firestore
          Map<String, dynamic> updateData = {};
          if (hint == 'Name') {
            updateData['name'] = newValue;
          } else if (hint == 'Phone') {
            updateData['phone'] = newValue;
          } else if (hint == 'Business') {
            updateData['business'] = newValue;
          }

          // Only update email in Auth if email is changed
          if (hint == 'Email') {
            await currentUser.updateEmail(newValue);
            updateData['email'] = newValue;
          }

          // Update Firestore document
          await _firestore
              .collection('users')
              .doc(currentUser.uid)
              .update(updateData);

          Get.snackbar(
            'Success',
            '$hint updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            margin: const EdgeInsets.all(10),
          );
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to update $hint. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Profile',
          showCartIcon: true,
        ),
        backgroundColor: Colors.grey.shade300,
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 180,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            16, 40, 16, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(width: 2),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(45),
                                  child: _auth.currentUser?.photoURL != null
                                      ? Image.network(
                                          _auth.currentUser!.photoURL!,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Image.asset(
                                              'assets/images/linkedin.png',
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        )
                                      : Image.asset(
                                          'assets/images/linkedin.png',
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  16, 0, 0, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0, 4, 0, 0),
                                    child: Text(
                                      email,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 16.0),
                              child: Text(
                                'Account',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey),
                                color: Colors.white,
                              ),
                              child: Column(
                                children: [
                                  ProfileRow(
                                    icon: Icons.person,
                                    text: name,
                                    onPressed: () => editField(name, 'Name'),
                                  ),
                                  ProfileRow(
                                    icon: Icons.phone_in_talk,
                                    text: phone.isEmpty ? "Add Phone" : phone,
                                    onPressed: () => editField(phone, 'Phone'),
                                  ),
                                  ProfileRow(
                                    icon: Icons.mail,
                                    text: email,
                                    onPressed: () => editField(email, 'Email'),
                                  ),
                                  ProfileRow(
                                    icon: Icons.business,
                                    text: business.isEmpty
                                        ? "Add Business"
                                        : business,
                                    onPressed: () =>
                                        editField(business, 'Business'),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 30),
                            Center(
                              child: ElevatedButton(
                                onPressed: () async {
                                  await _auth.signOut();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'Sign Out',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class ProfileRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const ProfileRow({
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(text),
      trailing: InkWell(
        onTap: onPressed,
        child: Icon(Icons.arrow_forward_ios, color: Colors.black, size: 20),
      ),
      onTap: onPressed,
    );
  }
}
