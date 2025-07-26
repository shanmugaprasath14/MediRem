// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:provider/provider.dart';
// import 'package:medirem/theme/theme_provider.dart';
// import 'package:medirem/models/user_profile.dart';
//
// // New imports for API calls
// import 'package:http/http.dart' as http;
// import 'dart:convert'; // For json.decode and json.encode
// // REMOVED: import 'package:firebase_auth/firebase_auth.dart'; // <-- REMOVED
//
// class ProfilePage extends StatefulWidget {
//   const ProfilePage({Key? key}) : super(key: key);
//
//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }
//
// class _ProfilePageState extends State<ProfilePage> {
//   late Box<UserProfile> _userProfileBox;
//   UserProfile? _userProfile;
//
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _weightController = TextEditingController();
//   final TextEditingController _heightController = TextEditingController();
//   final TextEditingController _caretakerNumberController = TextEditingController();
//
//   File? _image;
//   final ImagePicker _picker = ImagePicker();
//
//   final String _backendBaseUrl = 'http://10.0.2.2:3000/api'; // Adjust for your setup
//
//   // NEW: Using a hardcoded/dummy userId since Firebase Auth is removed
//   // IMPORTANT: For a real application, this `userId` must come from
//   // your actual authentication system (e.g., a custom login API, another auth provider).
//   // DO NOT USE A HARDCODED ID IN PRODUCTION.
//   final String _currentUserId = 'dummy_app_user_123'; // <-- Replace with a unique ID from your auth system
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeProfileData();
//   }
//
//   Future<void> _initializeProfileData() async {
//     // We no longer get userId from Firebase here, it's hardcoded for demonstration.
//     // In a real app, ensure _currentUserId is populated by your auth system before this.
//
//     // 1. Open Hive Box
//     _userProfileBox = await Hive.openBox<UserProfile>('userProfileBox');
//
//     // 2. Load local profile (from Hive)
//     _loadUserProfileFromHive();
//
//     // 3. Load caretaker number from backend
//     _loadCaretakerNumberFromBackend();
//   }
//
//   void _loadUserProfileFromHive() {
//     setState(() {
//       _userProfile = _userProfileBox.get('currentUser');
//       if (_userProfile != null) {
//         _nameController.text = _userProfile!.name ?? '';
//         _weightController.text = _userProfile!.weight?.toString() ?? '';
//         _heightController.text = _userProfile!.height?.toString() ?? '';
//         if (_userProfile!.imagePath != null) {
//           _image = File(_userProfile!.imagePath!);
//         }
//       }
//     });
//   }
//
//   // Function to load caretaker number from backend
//   Future<void> _loadCaretakerNumberFromBackend() async {
//     // _currentUserId is always available now (hardcoded)
//     // If it were dynamic, you'd add a null check here.
//
//     try {
//       final response = await http.get(
//         Uri.parse('$_backendBaseUrl/caretaker/$_currentUserId'),
//       );
//
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         setState(() {
//           _caretakerNumberController.text = data['phoneNumber'] ?? '';
//         });
//       } else if (response.statusCode == 404) {
//         // No caretaker number found, which is fine for a new user
//         _caretakerNumberController.text = '';
//         debugPrint('Caretaker number not found for user $_currentUserId');
//       } else {
//         debugPrint('Failed to load caretaker number: ${response.statusCode} ${response.body}');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load caretaker number. Status: ${response.statusCode}')),
//         );
//       }
//     } catch (e) {
//       debugPrint('Error loading caretaker number: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Network error loading caretaker number: $e')),
//       );
//     }
//   }
//
//   Future<void> _saveUserProfile() async {
//     // Ensure user profile object exists
//     _userProfile ??= UserProfile();
//
//     // Update local profile data
//     _userProfile!.name = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null;
//     _userProfile!.weight = double.tryParse(_weightController.text);
//     _userProfile!.height = double.tryParse(_heightController.text);
//     _userProfile!.imagePath = _image?.path;
//     _userProfile!.userId = _currentUserId; // Save current user ID to local profile
//
//     await _userProfileBox.put('currentUser', _userProfile!); // Save or update local Hive profile
//
//     // Save caretaker number to backend
//     await _saveCaretakerNumberToBackend();
//
//     // Show success message only after all saves are attempted
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Profile saved successfully!')),
//     );
//   }
//
//   // Function to save caretaker number to backend
//   Future<void> _saveCaretakerNumberToBackend() async {
//     // _currentUserId is always available now (hardcoded)
//     // In a real app, you'd ensure this isn't null.
//
//     final String phoneNumber = _caretakerNumberController.text.trim();
//
//     if (phoneNumber.isEmpty) {
//       debugPrint('Caretaker phone number is empty, not sending to backend.');
//       return;
//     }
//
//     try {
//       final response = await http.post(
//         Uri.parse('$_backendBaseUrl/caretaker'), // POST for upsert
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: jsonEncode(<String, String>{
//           'userId': _currentUserId, // Using the hardcoded userId
//           'phoneNumber': phoneNumber,
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         debugPrint('Caretaker number saved/updated successfully on backend.');
//       } else {
//         debugPrint('Failed to save caretaker number to backend: ${response.statusCode} ${response.body}');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to save caretaker number. Status: ${response.statusCode}')),
//         );
//       }
//     } catch (e) {
//       debugPrint('Error saving caretaker number to backend: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Network error saving caretaker number: $e')),
//       );
//     }
//   }
//
//   Future<void> _pickImage() async {
//     final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//       });
//     }
//   }
//
//   Future<void> _selectDateOfBirth(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _userProfile?.dateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 20)),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null && picked != _userProfile?.dateOfBirth) {
//       setState(() {
//         _userProfile ??= UserProfile();
//         _userProfile!.dateOfBirth = picked;
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _weightController.dispose();
//     _heightController.dispose();
//     _caretakerNumberController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);
//     final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile'),
//         backgroundColor: isDarkMode ? ThemeProvider.darkTheme.appBarTheme.backgroundColor : ThemeProvider.lightTheme.appBarTheme.backgroundColor,
//         foregroundColor: isDarkMode ? ThemeProvider.darkTheme.appBarTheme.foregroundColor : ThemeProvider.lightTheme.appBarTheme.foregroundColor,
//         actions: [
//           IconButton(
//             icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
//             onPressed: () {
//               themeProvider.toggleTheme(!isDarkMode);
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.save),
//             onPressed: _saveUserProfile,
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: GestureDetector(
//                 onTap: _pickImage,
//                 child: CircleAvatar(
//                   radius: 60,
//                   backgroundColor: Colors.grey[200],
//                   backgroundImage: _image != null ? FileImage(_image!) : null,
//                   child: _image == null
//                       ? Icon(
//                     Icons.camera_alt,
//                     size: 40,
//                     color: isDarkMode ? Colors.white70 : Colors.grey[600],
//                   )
//                       : null,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: _nameController,
//               decoration: InputDecoration(
//                 labelText: 'Name',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 filled: true,
//                 fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
//               ),
//               style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
//             ),
//             const SizedBox(height: 16),
//             GestureDetector(
//               onTap: () => _selectDateOfBirth(context),
//               child: AbsorbPointer(
//                 child: TextField(
//                   controller: TextEditingController(
//                     text: _userProfile?.dateOfBirth != null
//                         ? '${_userProfile!.dateOfBirth!.day}/${_userProfile!.dateOfBirth!.month}/${_userProfile!.dateOfBirth!.year}'
//                         : '',
//                   ),
//                   decoration: InputDecoration(
//                     labelText: 'Date of Birth',
//                     hintText: 'Select Date of Birth',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     suffixIcon: const Icon(Icons.calendar_today),
//                     filled: true,
//                     fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
//                   ),
//                   style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _weightController,
//               decoration: InputDecoration(
//                 labelText: 'Weight (kg)',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 filled: true,
//                 fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
//               ),
//               keyboardType: TextInputType.number,
//               style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _heightController,
//               decoration: InputDecoration(
//                 labelText: 'Height (cm)',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 filled: true,
//                 fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
//               ),
//               keyboardType: TextInputType.number,
//               style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _caretakerNumberController,
//               decoration: InputDecoration(
//                 labelText: 'Caretaker Phone Number',
//                 hintText: '+1234567890',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 filled: true,
//                 fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
//               ),
//               keyboardType: TextInputType.phone,
//               style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
//             ),
//             const SizedBox(height: 20),
//             if (_userProfile?.age != null)
//               Text(
//                 'Age: ${_userProfile!.age} years',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: isDarkMode ? Colors.white70 : Colors.black87,
//                 ),
//               ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:medirem/theme/theme_provider.dart';
import 'package:medirem/models/user_profile.dart';

// New imports for API calls
import 'package:http/http.dart' as http;
import 'dart:convert'; // For json.decode and json.encode

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Box<UserProfile> _userProfileBox;
  UserProfile? _userProfile;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _caretakerNumberController = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();

  final String _backendBaseUrl = 'http://10.0.2.2:3000/api'; // Adjust for your setup

  final String _currentUserId = 'dummy_app_user_123'; // IMPORTANT: Replace in production!

  @override
  void initState() {
    super.initState();
    _initializeProfileData();
  }

  Future<void> _initializeProfileData() async {
    _userProfileBox = await Hive.openBox<UserProfile>('userProfileBox');
    _loadUserProfileFromHive();
    _loadCaretakerNumberFromBackend();
  }

  void _loadUserProfileFromHive() {
    setState(() {
      _userProfile = _userProfileBox.get('currentUser');
      if (_userProfile != null) {
        _nameController.text = _userProfile!.name ?? '';
        _weightController.text = _userProfile!.weight?.toString() ?? '';
        _heightController.text = _userProfile!.height?.toString() ?? '';
        if (_userProfile!.imagePath != null) {
          _image = File(_userProfile!.imagePath!);
        }
      }
    });
  }

  Future<void> _loadCaretakerNumberFromBackend() async {
    try {
      final response = await http.get(
        Uri.parse('$_backendBaseUrl/caretaker/$_currentUserId'),
      );

      // --- ADDED THIS CHECK ---
      if (!mounted) {
        debugPrint('ProfilePage unmounted during _loadCaretakerNumberFromBackend.');
        return;
      }
      // -------------------------

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _caretakerNumberController.text = data['phoneNumber'] ?? '';
        });
      } else if (response.statusCode == 404) {
        _caretakerNumberController.text = '';
        debugPrint('Caretaker number not found for user $_currentUserId');
      } else {
        debugPrint('Failed to load caretaker number: ${response.statusCode} ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load caretaker number. Status: ${response.statusCode}')),
        );
      }
    } catch (e) {
      debugPrint('Error loading caretaker number: $e');
      // --- ADDED THIS CHECK ---
      if (!mounted) {
        debugPrint('ProfilePage unmounted during _loadCaretakerNumberFromBackend error handling.');
        return;
      }
      // -------------------------
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error loading caretaker number: $e')),
      );
    }
  }

  Future<void> _saveUserProfile() async {
    _userProfile ??= UserProfile();

    _userProfile!.name = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null;
    _userProfile!.weight = double.tryParse(_weightController.text);
    _userProfile!.height = double.tryParse(_heightController.text);
    _userProfile!.imagePath = _image?.path;
    _userProfile!.userId = _currentUserId;

    await _userProfileBox.put('currentUser', _userProfile!);

    await _saveCaretakerNumberToBackend();

    // --- ADDED THIS CHECK ---
    if (!mounted) {
      debugPrint('ProfilePage unmounted after saving user profile.');
      return;
    }
    // -------------------------
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved successfully!')),
    );
  }

  Future<void> _saveCaretakerNumberToBackend() async {
    final String phoneNumber = _caretakerNumberController.text.trim();

    if (phoneNumber.isEmpty) {
      debugPrint('Caretaker phone number is empty, not sending to backend.');
      // --- ADDED THIS CHECK (if you want to show a snackbar for empty number) ---
      // if (!mounted) return;
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Caretaker number cannot be empty.')),
      // );
      // ----------------------------------------------------------------------
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$_backendBaseUrl/caretaker'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'userId': _currentUserId,
          'phoneNumber': phoneNumber,
        }),
      );

      // --- ADDED THIS CHECK ---
      if (!mounted) {
        debugPrint('ProfilePage unmounted during _saveCaretakerNumberToBackend.');
        return;
      }
      // -------------------------

      if (response.statusCode == 200) {
        debugPrint('Caretaker number saved/updated successfully on backend.');
      } else {
        debugPrint('Failed to save caretaker number to backend: ${response.statusCode} ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save caretaker number. Status: ${response.statusCode}')),
        );
      }
    } catch (e) {
      debugPrint('Error saving caretaker number to backend: $e');
      // --- ADDED THIS CHECK ---
      if (!mounted) {
        debugPrint('ProfilePage unmounted during _saveCaretakerNumberToBackend error handling.');
        return;
      }
      // -------------------------
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error saving caretaker number: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _userProfile?.dateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _userProfile?.dateOfBirth) {
      setState(() {
        _userProfile ??= UserProfile();
        _userProfile!.dateOfBirth = picked;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _caretakerNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: isDarkMode ? ThemeProvider.darkTheme.appBarTheme.backgroundColor : ThemeProvider.lightTheme.appBarTheme.backgroundColor,
        foregroundColor: isDarkMode ? ThemeProvider.darkTheme.appBarTheme.foregroundColor : ThemeProvider.lightTheme.appBarTheme.foregroundColor,
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: () {
              themeProvider.toggleTheme(!isDarkMode);
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveUserProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? Icon(
                    Icons.camera_alt,
                    size: 40,
                    color: isDarkMode ? Colors.white70 : Colors.grey[600],
                  )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
              ),
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _selectDateOfBirth(context),
              child: AbsorbPointer(
                child: TextField(
                  controller: TextEditingController(
                    text: _userProfile?.dateOfBirth != null
                        ? '${_userProfile!.dateOfBirth!.day}/${_userProfile!.dateOfBirth!.month}/${_userProfile!.dateOfBirth!.year}'
                        : '',
                  ),
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    hintText: 'Select Date of Birth',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: const Icon(Icons.calendar_today),
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                  ),
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _weightController,
              decoration: InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
              ),
              keyboardType: TextInputType.number,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _heightController,
              decoration: InputDecoration(
                labelText: 'Height (cm)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
              ),
              keyboardType: TextInputType.number,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _caretakerNumberController,
              decoration: InputDecoration(
                labelText: 'Caretaker Phone Number',
                hintText: '+1234567890',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
              ),
              keyboardType: TextInputType.phone,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 20),
            if (_userProfile?.age != null)
              Text(
                'Age: ${_userProfile!.age} years',
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}