// lib/pages/home_tab_content.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider for ThemeProvider
import 'package:medirem/theme/theme_provider.dart'; // Import your ThemeProvider
import 'package:medirem/models/daily_review_item_data.dart'; // Add this line
// ... other imports
import 'package:medirem/services/medication_api_service.dart';
import 'package:medirem/medication_detail_page.dart'; // Ensure this path is correct

// --- Define DailyReviewItemData ---
// Moved here to be self-contained for the HomeTabContent
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


class HomeTabContent extends StatefulWidget {
  // Add a Key parameter to the constructor to allow managing state from parent
  const HomeTabContent({Key? key}) : super(key: key);

  @override
  State<HomeTabContent> createState() => _HomeTabContentState();
}

class _HomeTabContentState extends State<HomeTabContent> {
  late Future<List<DailyReviewItemData>> _medicationPlansFuture;

  @override
  void initState() {
    super.initState();
    _fetchMedicationPlans();
  }

  // Make _fetchMedicationPlans accessible from outside this widget
  // (e.g., from HomePage after adding a new plan)
  void _fetchMedicationPlans() {
    setState(() {
      _medicationPlansFuture = MedicationApiService().getMedicationPlans() as Future<List<DailyReviewItemData>>;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access the ThemeProvider  for theme-aware colors
    final themeProvider = Provider.of<ThemeProvider>(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Search',
              style: TextStyle(
                color: themeProvider.themeMode == ThemeMode.dark
                    ? Colors.grey[400]
                    : Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Hello,',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: themeProvider.themeMode == ThemeMode.dark
                    ? ThemeProvider.darkTheme.textTheme.titleLarge?.color
                    : ThemeProvider.lightTheme.textTheme.titleLarge?.color,
              ),
            ),
            Text(
              'Nirmala C', // Consider fetching user name from UserProfile
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 26,
                color: themeProvider.themeMode == ThemeMode.dark
                    ? ThemeProvider.darkTheme.textTheme.titleMedium?.color
                    : ThemeProvider.lightTheme.textTheme.titleMedium?.color,
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
            Text(
              'Daily Review',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: themeProvider.themeMode == ThemeMode.dark
                    ? ThemeProvider.darkTheme.textTheme.titleLarge?.color
                    : ThemeProvider.lightTheme.textTheme.titleLarge?.color,
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
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'No medication plans added yet.',
                        style: TextStyle(fontSize: 16, color: themeProvider.themeMode == ThemeMode.dark
                            ? ThemeProvider.darkTheme.textTheme.bodyMedium?.color
                            : ThemeProvider.lightTheme.textTheme.bodyMedium?.color),
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
                      onDeleteSuccess: _fetchMedicationPlans, // Pass the refresh callback
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
}

// --- _DailyReviewItem (Moved to home_tab_content.dart) ---
class _DailyReviewItem extends StatelessWidget {
  final String id;
  final String medicine;
  final String time;
  final String status;
  final int? pillCount;
  final int? daysDuration;
  final String? mealTiming;
  final String? imagePath;
  final VoidCallback? onDeleteSuccess; // Callback for successful deletion

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
    // Access the ThemeProvider for theme-aware colors
    final themeProvider = Provider.of<ThemeProvider>(context);

    return GestureDetector(
      onTap: () async {
        final bool? deleted = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MedicationDetailPage(medicationId: id),
          ),
        );
        if (deleted == true) {
          onDeleteSuccess?.call(); // Call refresh if item was deleted
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          // Use theme card color or a specific color that adapts
          color: themeProvider.themeMode == ThemeMode.dark
              ? ThemeProvider.darkTheme.cardColor // Or a slightly lighter dark color
              : const Color(0xFFF7F7F7), // Original light mode color
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(Icons.medication, color: themeProvider.themeMode == ThemeMode.dark ? Colors.grey[400] : Colors.grey, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: themeProvider.themeMode == ThemeMode.dark
                          ? ThemeProvider.darkTheme.textTheme.titleMedium?.color
                          : ThemeProvider.lightTheme.textTheme.titleMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$time   ·   $status',
                    style: TextStyle(
                      color: themeProvider.themeMode == ThemeMode.dark
                          ? ThemeProvider.darkTheme.textTheme.bodySmall?.color
                          : ThemeProvider.lightTheme.textTheme.bodySmall?.color,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: themeProvider.themeMode == ThemeMode.dark
                ? ThemeProvider.darkTheme.iconTheme.color
                : ThemeProvider.lightTheme.iconTheme.color),
          ],
        ),
      ),
    );
  }
}