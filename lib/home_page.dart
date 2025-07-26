// lib/pages/home_page.dart (Modify this file)
import 'package:flutter/material.dart';
import 'package:medirem/add_plan_page.dart';
import 'package:medirem/calendar_page.dart'; // Import CalendarPage
import 'package:medirem/chat_page.dart';     // Import ChatPage
import 'package:medirem/profile_page.dart';  // Import ProfilePage
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Keep if used for notifications
import 'package:http/http.dart' as http; // Keep if used directly
import 'dart:convert'; // For json decoding
import 'package:hive_flutter/hive_flutter.dart'; // Import Hive
import 'package:medirem/models/user_profile.dart'; // Import UserProfile model

// Import the API service you created
import 'package:medirem/services/medication_api_service.dart';
// Import the new detail page
import 'package:medirem/medication_detail_page.dart'; // Corrected import path

// --- Start: Define DailyReviewItemData ---
class DailyReviewItemData {
  final String id;
  final String medicine;
  final String time;
  final String status;
  final int? pillCount;
  final int? daysDuration;
  final String? mealTiming;
  final String? imagePath;

  DailyReviewItemData({
    required this.id,
    required this.medicine,
    required this.time,
    required this.status,
    this.pillCount,
    this.daysDuration,
    this.mealTiming,
    this.imagePath,
  });

  factory DailyReviewItemData.fromJson(Map<String, dynamic> json) {
    return DailyReviewItemData(
      id: json['_id'] as String,
      medicine: json['medicineName'] as String,
      time: json['time'] as String,
      status: json['status'] as String,
      pillCount: json['pillCount'] as int?,
      daysDuration: json['daysDuration'] as int?,
      mealTiming: json['mealTiming'] as String?,
      imagePath: json['imagePath'] as String?,
    );
  }
}
// --- End: Define DailyReviewItemData ---


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late PageController _pageController;
  late Future<List<DailyReviewItemData>> _medicationPlansFuture;
  Box<UserProfile>? _userProfileBox; // Declare UserProfile box
  String _userName = 'Guest'; // Default user name

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _fetchMedicationPlans();
    _loadUserName(); // Load user name when the page initializes
  }

  // New method to load user name from Hive
  Future<void> _loadUserName() async {
    _userProfileBox = await Hive.openBox<UserProfile>('userProfileBox');
    final userProfile = _userProfileBox?.get('currentUser');
    if (userProfile != null && userProfile.name != null && userProfile.name!.isNotEmpty) {
      setState(() {
        _userName = userProfile.name!;
      });
    } else {
      setState(() {
        _userName = 'Guest'; // Fallback if no name is set
      });
    }
  }

  void _fetchMedicationPlans() {
    setState(() {
      _medicationPlansFuture = MedicationApiService().getMedicationPlans();
    });
  }

  void _onItemTapped(int index) async {
    if (index == 2) { // Add button
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const AddPlanPage()),
      );
      // Always refresh after returning from AddPlanPage
      _fetchMedicationPlans();
    } else if (index == 4) { // Profile button
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
      // Refresh user name after returning from ProfilePage
      _loadUserName();
      setState(() {
        _selectedIndex = index;
        _pageController.jumpToPage(index);
      });
    }
    else {
      setState(() {
        _selectedIndex = index;
        _pageController.jumpToPage(index); // Navigate to the selected page
      });
    }
  }

  // The actual home page content (formerly the entire HomePage body)
  Widget _buildHomePageContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Search',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Hello,',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
            Text( // Changed from const Text to Text
              _userName, // Display the fetched user name
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 24),
            // Plan Card
            Center(
              child: Image.asset(
                'assets/images/medicine.png',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Daily Review',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            // Daily Review List fetched from backend
            FutureBuilder<List<DailyReviewItemData>>(
              future: _medicationPlansFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'No medication plans added yet.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  );
                } else {
                  final plans = snapshot.data!;
                  return Column(
                    children: plans.map((item) => _DailyReviewItem(
                      id: item.id,
                      medicine: item.medicine,
                      time: item.time,
                      status: item.status,
                      pillCount: item.pillCount,
                      daysDuration: item.daysDuration,
                      mealTiming: item.mealTiming,
                      imagePath: item.imagePath,
                      onDeleteSuccess: _fetchMedicationPlans,
                    )).toList(),
                  );
                }
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          SafeArea(child: _buildHomePageContent()), // Content for Home
          const CalendarPage(), // Content for Calendar
          const SizedBox(), // Placeholder for the 'Add' button (handled by navigation)
          const ChatPage(), // Content for Chat
          const ProfilePage(), // Content for Profile
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 40),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// --- UPDATED _DailyReviewItem (no changes needed from previous provided code) ---
class _DailyReviewItem extends StatelessWidget {
  final String id;
  final String medicine;
  final String time;
  final String status;
  final int? pillCount;
  final int? daysDuration;
  final String? mealTiming;
  final String? imagePath;
  final VoidCallback? onDeleteSuccess;

  const _DailyReviewItem({
    required this.id,
    required this.medicine,
    required this.time,
    required this.status,
    this.pillCount,
    this.daysDuration,
    this.mealTiming,
    this.imagePath,
    this.onDeleteSuccess,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final bool? deleted = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MedicationDetailPage(medicationId: id),
          ),
        );
        if (deleted == true) {
          onDeleteSuccess?.call();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            const Icon(Icons.medication, color: Colors.grey, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$time   ·   $status',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
