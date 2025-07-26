// lib/models/daily_review_item_data.dart
class DailyReviewItemData {
  final String id;
  final String medicine;
  final String time;
  final String status;
  final int? pillCount;
  final int? daysDuration;
  final String? mealTiming;
  final String? imagePath;
  final String? customSoundPath;

  DailyReviewItemData({
    required this.id,
    required this.medicine,
    required this.time,
    required this.status,
    this.pillCount,
    this.daysDuration,
    this.mealTiming,
    this.imagePath,
    this.customSoundPath,
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
      customSoundPath: json['customSoundPath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'medicineName': medicine,
      'time': time,
      'status': status,
      'pillCount': pillCount,
      'daysDuration': daysDuration,
      'mealTiming': mealTiming,
      'imagePath': imagePath,
      'customSoundPath': customSoundPath,
    };
  }
}