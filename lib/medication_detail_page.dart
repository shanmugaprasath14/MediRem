// lib/medication_detail_page.dart
import 'package:flutter/material.dart';
import 'services/medication_api_service.dart';
import 'home_page.dart'; // To use DailyReviewItemData (already there, just noting)
import 'dart:io'; // For FileImage

class MedicationDetailPage extends StatefulWidget {
  final String medicationId;

  const MedicationDetailPage({Key? key, required this.medicationId}) : super(key: key);

  @override
  State<MedicationDetailPage> createState() => _MedicationDetailPageState();
}

class _MedicationDetailPageState extends State<MedicationDetailPage> {
  late Future<DailyReviewItemData> _medicationDetailFuture;

  @override
  void initState() {
    super.initState();
    // Fetch medication details when the page initializes
    _fetchMedicationDetail();
  }

  void _fetchMedicationDetail() {
    setState(() {
      _medicationDetailFuture = MedicationApiService().getMedicationPlan(widget.medicationId);
    });
  }

  // --- NEW: Function to handle deletion with confirmation ---
  Future<void> _confirmAndDeleteMedication() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this medication plan? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false), // User cancelled
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true), // User confirmed deletion
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    // If the user confirmed deletion
    if (confirm == true) {
      try {
        // Call the API service to delete the medication plan
        await MedicationApiService().deleteMedicationPlan(widget.medicationId);

        // Check if the widget is still mounted before showing UI feedback
        if (!mounted) return;

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medication plan deleted successfully!')),
        );

        // Pop the current detail page, and crucially, pass 'true' back to the HomePage
        // This 'true' will signal HomePage to refresh its list.
        Navigator.of(context).pop(true);
      } catch (e) {
        // If an error occurs during deletion
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete plan: ${e.toString()}')),
        );
        debugPrint('Error deleting medication plan: $e'); // Use debugPrint for detailed console logs
      }
    }
  }
  // --- END NEW FUNCTION ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Details'),
        backgroundColor: Colors.green,
        // --- NEW: Add the delete button to the AppBar actions ---
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.white), // Changed to white for visibility on green AppBar
            tooltip: 'Delete Medication',
            onPressed: _confirmAndDeleteMedication, // Call the delete function
          ),
        ],
        // --- END NEW ---
      ),
      body: FutureBuilder<DailyReviewItemData>(
        future: _medicationDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No details found.'));
          } else {
            final medication = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medication.medicine,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (medication.imagePath != null && File(medication.imagePath!).existsSync())
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(medication.imagePath!),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey[200],
                            child: const Center(
                              child: Text('Image not found', style: TextStyle(color: Colors.grey)),
                            ),
                          );
                        },
                      ),
                    )
                  else
                    Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.image, size: 50, color: Colors.grey),
                      ),
                    ),
                  const SizedBox(height: 24),
                  _buildDetailRow('Time', medication.time, Icons.access_time),
                  _buildDetailRow('Status', medication.status, Icons.check_circle_outline),
                  if (medication.pillCount != null)
                    _buildDetailRow('Pill Count', '${medication.pillCount} pills', Icons.medical_services_outlined),
                  if (medication.daysDuration != null)
                    _buildDetailRow('Days Duration', '${medication.daysDuration} days', Icons.calendar_today),
                  if (medication.mealTiming != null)
                    _buildDetailRow('Meal Timing', _formatMealTiming(medication.mealTiming!), Icons.fastfood),
                  // Add more details as needed
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatMealTiming(String rawMealTiming) {
    switch (rawMealTiming) {
      case 'morning_before': return 'Morning Before Meal';
      case 'morning_after': return 'Morning After Meal';
      case 'afternoon_before': return 'Afternoon Before Meal';
      case 'afternoon_after': return 'Afternoon After Meal';
      case 'night_before': return 'Night Before Meal';
      case 'night_after': return 'Night After Meal';
      default: return rawMealTiming;
    }
  }
}