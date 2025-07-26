import 'package:flutter/material.dart';
import 'dart:io'; // For FileImage
import 'package:medirem/notification_service.dart'; // To cancel the notification
import 'package:audioplayers/audioplayers.dart'; // Import audioplayers

class AlarmPage extends StatefulWidget {
  final String medicineName;
  final String? imagePath;
  final int notificationId;
  final String? customSoundPath; // Keep this as it comes from notification payload
  final int? pillCount; // Added pillCount parameter

  const AlarmPage({
    super.key,
    required this.medicineName,
    this.imagePath,
    required this.notificationId,
    this.customSoundPath, // Keep in constructor
    this.pillCount, // Added to constructor
  });

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  // Define a default alarm sound asset path
  static const String _defaultAlarmSoundAsset = 'assets/sounds/iphone_alarm.wav'; // <--- NEW: Define default sound

  @override
  void initState() {
    super.initState();
    _playAlarmSound();
  }

  Future<void> _playAlarmSound() async {
    String? soundToPlayPath = widget.customSoundPath;

    // If no custom sound is provided or it's invalid, use the default asset sound
    // Check if it's an asset path OR if it's a file path that exists
    if (soundToPlayPath == null ||
        (!soundToPlayPath.startsWith('assets/') && !File(soundToPlayPath).existsSync())) {
      soundToPlayPath = _defaultAlarmSoundAsset;
      debugPrint('No valid custom sound path provided or file not found. Attempting to play default asset sound: $_defaultAlarmSoundAsset');
    }

    debugPrint('No sound path resolved. Not playing any sound from AlarmPage.');
    }

  Future<void> _stopAlarmSound() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
      });
      debugPrint('Alarm sound stopped.');
    }
  }

  @override
  void dispose() {
    _stopAlarmSound(); // Ensure sound is stopped when page is disposed
    _audioPlayer.dispose(); // Release audio player resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine text for pill count
    String pillCountText = widget.pillCount != null && widget.pillCount! > 0
        ? '${widget.pillCount} pill${widget.pillCount! > 1 ? 's' : ''}'
        : 'your medicine'; // Fallback if pillCount is null or 0

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarm!'),
        automaticallyImplyLeading: false, // Prevent back button
        backgroundColor: Colors.redAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Photo Box
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.width * 0.7, // Responsive height
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: widget.imagePath != null && File(widget.imagePath!).existsSync()
                    ? Image.file(
                  File(widget.imagePath!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, size: 50, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Image not found', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  },
                )
                    : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.medication_outlined, size: 80, color: Colors.grey),
                      SizedBox(height: 10),
                      Text(
                        'No medicine image',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Message Text with Pill Count
            Text(
              "It's time to take $pillCountText: \n${widget.medicineName}", // Updated message
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "You are old enough.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 60),

            // Stop Alarm Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () {
                  _stopAlarmSound(); // Stop the audio playback
                  NotificationService.cancelNotification(widget.notificationId); // Cancel notification
                  Navigator.of(context).pop(); // Dismiss the alarm page
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 5,
                  shadowColor: Colors.green.withOpacity(0.4),
                ),
                icon: const Icon(Icons.alarm_off, color: Colors.white, size: 28),
                label: const Text(
                  'STOP ALARM',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}