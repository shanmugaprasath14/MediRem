// // lib/pages/caregiver_settings_page.dart
// import 'package:flutter/material.dart';
// import 'package:medirem/services/medication_api_service.dart'; // Import your ApiService
//
// class CaregiverSettingsPage extends StatefulWidget {
//   const CaregiverSettingsPage({super.key});
//
//   @override
//   State<CaregiverSettingsPage> createState() => _CaregiverSettingsPageState();
// }
//
// class _CaregiverSettingsPageState extends State<CaregiverSettingsPage> {
//   final TextEditingController _phoneNumberController = TextEditingController();
//   bool _isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadPhoneNumber();
//   }
//
//   Future<void> _loadPhoneNumber() async {
//     setState(() {
//       _isLoading = true;
//     });
//     // In a real app, _currentUserId would be available from an AuthProvider
//     // For this example, let's assume a static user ID is set somewhere after login
//     // This is a placeholder. You NEED to replace 'exampleUserId' with the actual authenticated user's ID.
//     ApiService.setUserId('exampleUserId'); // <--- IMPORTANT: Replace with actual user ID
//
//     final String? phoneNumber = await ApiService.getCaregiverPhoneNumber();
//     if (phoneNumber != null) {
//       _phoneNumberController.text = phoneNumber;
//     }
//     setState(() {
//       _isLoading = false;
//     });
//   }
//
//   Future<void> _savePhoneNumber() async {
//     final phoneNumber = _phoneNumberController.text.trim();
//     setState(() {
//       _isLoading = true;
//     });
//
//     bool success = await ApiService.updateCaregiverPhoneNumber(phoneNumber);
//
//     setState(() {
//       _isLoading = false;
//     });
//
//     if (success) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Caregiver number saved successfully!')),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to save caregiver number.')),
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     _phoneNumberController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Caregiver Reminders'),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Enter the phone number of someone you want to remind to take medicine (e.g., a family member or friend).',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: _phoneNumberController,
//               keyboardType: TextInputType.phone,
//               decoration: const InputDecoration(
//                 labelText: 'Caregiver Phone Number (e.g., +919876543210)',
//                 hintText: 'Include country code',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _savePhoneNumber,
//               child: const Text('Save Number'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }