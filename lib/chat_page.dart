// lib/pages/chat_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medirem/theme/theme_provider.dart'; // Import your ThemeProvider

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: themeProvider.themeMode == ThemeMode.dark
              ? ThemeProvider.darkTheme.iconTheme.color
              : ThemeProvider.lightTheme.iconTheme.color),
          const SizedBox(height: 20),
          Text(
            'Chat Feature Coming Soon!',
            style: TextStyle(fontSize: 22, color: themeProvider.themeMode == ThemeMode.dark
                ? ThemeProvider.darkTheme.textTheme.bodyLarge?.color
                : ThemeProvider.lightTheme.textTheme.bodyLarge?.color),
          ),
          Text(
            'Connect with healthcare professionals or support.',
            style: TextStyle(fontSize: 16, color: themeProvider.themeMode == ThemeMode.dark
                ? ThemeProvider.darkTheme.textTheme.bodyMedium?.color
                : ThemeProvider.lightTheme.textTheme.bodyMedium?.color),
          ),
        ],
      ),
    );
  }
}