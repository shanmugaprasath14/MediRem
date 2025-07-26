import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medirem/utils/alarm_permission_helper.dart'; // Ensure this import is correct
import '/notification_service.dart';
import 'services/medication_api_service.dart'; // Import your API service
import 'package:timezone/timezone.dart' as tz; // Import timezone for accurate scheduling

class AddPlanPage extends StatefulWidget {
  const AddPlanPage({Key? key}) : super(key: key);

  @override
  State<AddPlanPage> createState() => _AddPlanPageState();
}

class _AddPlanPageState extends State<AddPlanPage> {
  String selectedMeal = 'morning_before';
  TimeOfDay? selectedTime;

  final TextEditingController pillNameController = TextEditingController();
  final TextEditingController pillCountController = TextEditingController();
  final TextEditingController daysController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  File? _medicineImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _medicineImage = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    pillNameController.dispose();
    pillCountController.dispose();
    daysController.dispose();
    timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) { // context is available here
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text('Add Plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
                    const SizedBox(height: 24),

                    // Pill Name
                    const Text('Pills name', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.medication, color: Colors.grey),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: pillNameController,
                              decoration: const InputDecoration(
                                hintText: 'Enter pill name',
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          Icon(Icons.qr_code_scanner, color: Colors.green[300]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Amount & Days
                    const Text('Amount & How long?', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F7F7),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.medication_liquid, color: Colors.grey),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: pillCountController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      hintText: 'e.g. 2',
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                const Text('pills', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F7F7),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, color: Colors.grey, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: daysController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      hintText: 'e.g. 30',
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                const Text('days', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Food & Pills + Camera Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Food & Pills', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                        TextButton.icon(
                          onPressed: _pickImageFromCamera,
                          icon: const Icon(Icons.camera_alt, size: 20),
                          label: const Text("Add Photo", style: TextStyle(fontSize: 13)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (_medicineImage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.green),
                          image: DecorationImage(
                            image: FileImage(_medicineImage!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                    // Meal Options
                    Column(
                      children: [
                        Row(
                          children: [
                            _MealOption(label: 'Morning\nBefore Meal', icon: Icons.wb_sunny_outlined, selected: selectedMeal == 'morning_before', onTap: () => setState(() => selectedMeal = 'morning_before')),
                            const SizedBox(width: 10),
                            _MealOption(label: 'Morning\nAfter Meal', icon: Icons.wb_sunny, selected: selectedMeal == 'morning_after', onTap: () => setState(() => selectedMeal = 'morning_after')),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _MealOption(label: 'Afternoon\nBefore Meal', icon: Icons.lunch_dining, selected: selectedMeal == 'afternoon_before', onTap: () => setState(() => selectedMeal = 'afternoon_before')),
                            const SizedBox(width: 10),
                            _MealOption(label: 'Afternoon\nAfter Meal', icon: Icons.lunch_dining, selected: selectedMeal == 'afternoon_after', onTap: () => setState(() => selectedMeal = 'afternoon_after')),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _MealOption(label: 'Night\nBefore Meal', icon: Icons.nightlight_round, selected: selectedMeal == 'night_before', onTap: () => setState(() => selectedMeal = 'night_before')),
                            const SizedBox(width: 10),
                            _MealOption(label: 'Night\nAfter Meal', icon: Icons.nightlight, selected: selectedMeal == 'night_after', onTap: () => setState(() => selectedMeal = 'night_after')),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Notification Time Picker
                    const Text('Notification', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime ?? TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedTime = picked;
                            timeController.text = picked.format(context);
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F7F7),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.notifications_none, color: Colors.grey),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: timeController,
                                  decoration: const InputDecoration(
                                    hintText: 'e.g. 10:00 AM',
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                  style: const TextStyle(fontSize: 16),
                                  readOnly: true,
                                ),
                              ),
                              Icon(Icons.add_circle, color: Colors.green[300]),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Done Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          final pillName = pillNameController.text;
                          final pillCount = int.tryParse(pillCountController.text) ?? 0;
                          final daysDuration = int.tryParse(daysController.text) ?? 0;

                          if (pillName.isEmpty || selectedTime == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please fill all required fields (Pill Name, Time)')),
                            );
                            return;
                          }

                          // Generate a unique ID for the main recurring notification
                          final int recurringNotificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

                          // Prepare data for backend
                          final Map<String, dynamic> planData = {
                            'medicineName': pillName,
                            'time': selectedTime!.format(context), // Send time as formatted string
                            'status': 'Scheduled', // Default status
                            'pillCount': pillCount,
                            'daysDuration': daysDuration,
                            'mealTiming': selectedMeal,
                            'imagePath': _medicineImage?.path, // Path to local image
                          };

                          try {
                            // Call the permission helper and pass the context
                            await checkExactAlarmPermission(context);

                            // 1. Schedule the primary daily recurring notification
                            await NotificationService.scheduleNotification(
                              id: recurringNotificationId, // Pass the generated ID
                              title: 'MediRem Reminder',
                              body: 'Time to take your pill: $pillName',
                              time: selectedTime!,
                              medicineName: pillName, // Pass medicine name for payload
                              imagePath: _medicineImage?.path, // Pass image path for payload
                              customSoundPath: 'assets/sounds/my_alarm_sound.wav', // <-- Added custom sound path
                            );

                            // 2. Schedule a one-time notification to cancel the recurring alarm after daysDuration
                            if (daysDuration > 0) {
                              final now = DateTime.now();
                              // Calculate the exact date and time for cancellation
                              // If current time is past selectedTime, start from tomorrow for calculation
                              DateTime initialScheduledDate = DateTime(
                                now.year,
                                now.month,
                                now.day,
                                selectedTime!.hour,
                                selectedTime!.minute,
                              );

                              if (initialScheduledDate.isBefore(now)) {
                                initialScheduledDate = initialScheduledDate.add(const Duration(days: 1));
                              }

                              // The cancellation date is daysDuration days AFTER the first scheduled alarm.
                              // For example, if duration is 30 days, the alarm runs on day 1, ..., day 30.
                              // It should be cancelled *after* day 30, so on day 31.
                              final DateTime cancellationDateTime = initialScheduledDate.add(Duration(days: daysDuration));

                              // Generate a unique ID for the cancellation notification
                              final int cancellationNotificationId = recurringNotificationId + 1; // Ensure unique ID

                              await NotificationService.flutterLocalNotificationsPlugin.zonedSchedule(
                                cancellationNotificationId,
                                'MediRem: Alarm Ended',
                                'Your "$pillName" medication reminder has ended after $daysDuration days.',
                                tz.TZDateTime.from(cancellationDateTime, tz.local),
                                const NotificationDetails(
                                  android: AndroidNotificationDetails(
                                    'medirem_channel',
                                    'Medication Reminders',
                                    channelDescription: 'Channel for scheduling medication notifications',
                                    importance: Importance.max,
                                    priority: Priority.high,
                                    // No sound for cancellation notification
                                    playSound: false,
                                  ),
                                  iOS: DarwinNotificationDetails(
                                    presentSound: false,
                                  ),
                                ),
                                uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
                                matchDateTimeComponents: DateTimeComponents.dateAndTime, // Specific date and time
                                payload: '{"isCancellation": true, "targetNotificationId": $recurringNotificationId}',
                              );
                              debugPrint('Cancellation notification scheduled for: $cancellationDateTime with target ID: $recurringNotificationId');
                            }

                            // Call the API service to add the medication plan
                            await MedicationApiService().addMedicationPlan(planData);

                            if (!mounted) return; // Check if widget is still active

                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Medication plan added successfully!')),
                            );

                            // Go back to the HomePage (which will refresh data from backend)
                            Navigator.of(context).pop();

                          } catch (e) {
                            if (!mounted) return; // Check if widget is still active
                            // Show error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to add plan: $e')),
                            );
                            print('Error submitting plan: $e'); // For debugging
                          }
                        },
                        child: const Text('Done', style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MealOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _MealOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: selected ? Colors.green : const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(14),
            border: selected ? Border.all(color: Colors.green, width: 2) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: selected ? Colors.white : Colors.grey),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
