// lib/models/user_profile.dart
import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0)
  String? name;

  @HiveField(1)
  double? weight;

  @HiveField(2)
  double? height;

  @HiveField(3)
  String? imagePath;

  @HiveField(4)
  DateTime? dateOfBirth;

  @HiveField(5) // <--- THIS FIELD MUST BE PRESENT
  String? userId; // <--- THIS FIELD MUST BE PRESENT

  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  UserProfile({this.name, this.weight, this.height, this.imagePath, this.dateOfBirth, this.userId});
}