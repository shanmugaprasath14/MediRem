// lib/services/medication_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../home_page.dart'; // To use DailyReviewItemData


class MedicationApiService {
  static const String _baseUrl = 'http://10.0.2.2:5000/api/medications'; // Adjust as needed

  Future<List<DailyReviewItemData>> getMedicationPlans() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => DailyReviewItemData.fromJson(json)).toList(); // Use fromJson
      } else {
        throw Exception('Failed to load medication plans: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching medication plans: $e');
      throw Exception('Failed to connect to backend or parse data.');
    }
  }

  Future<DailyReviewItemData> getMedicationPlan(String id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$id'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return DailyReviewItemData.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Medication plan not found: ID $id');
      } else {
        throw Exception('Failed to load medication plan: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching single medication plan: $e');
      rethrow; // Re-throw the error to be caught by the FutureBuilder
    }
  }

  Future<DailyReviewItemData> addMedicationPlan(Map<String, dynamic> planData) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(planData),
      );

      if (response.statusCode == 201) { // 201 Created
        final Map<String, dynamic> data = json.decode(response.body);
        return DailyReviewItemData.fromJson(data); // Use fromJson
      } else {
        throw Exception('Failed to add medication plan: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error adding medication plan: $e');
      throw Exception('Failed to connect to backend or send data.');
    }
  }

  // --- NEW METHOD: Delete a medication plan by ID ---
  Future<void> deleteMedicationPlan(String id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/$id'));

      if (response.statusCode == 200 || response.statusCode == 204) { // 200 OK or 204 No Content
        print('Medication plan $id deleted successfully.');
        // No content expected for 204, so no json.decode needed
      } else if (response.statusCode == 404) {
        throw Exception('Medication plan not found for deletion: ID $id');
      } else {
        throw Exception('Failed to delete medication plan: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error deleting medication plan: $e');
      rethrow; // Re-throw the error
    }
  }
// --- END NEW METHOD ---
}