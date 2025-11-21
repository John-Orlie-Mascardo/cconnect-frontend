import 'package:flutter/material.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section: Contains the navigation back button and the screen title 'Chats'
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Back Button: Navigates to the previous screen
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(40),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF333333),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Screen Title
                  const Text(
                    'Chats',
                    style: TextStyle(
                      fontFamily: 'kobe11',
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Chat List Item: Displays a preview of a conversation with a user
            Container(
              width: double.infinity,
              color: const Color(0xFF404040),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  // Profile Picture: Placeholder for the user's avatar
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFB0B0B0),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'profile',
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'kobe11',
                        fontSize: 18,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Message Details: Shows the user's name and the last message content
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BIG HEEL JANE',
                          style: TextStyle(
                            fontFamily: 'kobe11',
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'This shoe is unavailable, would you like another one?',
                          style: TextStyle(
                            fontFamily: 'kobe11',
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Remaining Space: Fills the rest of the screen below the chat list
            Expanded(child: Container(color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
