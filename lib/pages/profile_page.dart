import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/strength_card.dart';
import '../widgets/badge_card.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/service_locator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? user;
  List<Map<String, dynamic>> strengths = [];
  List<Map<String, dynamic>> badges = [];
  List<Map<String, dynamic>> links = [];
  bool isLoading = true;
  bool hasError = false;
  int currentPage = 1;
  int pageSize = 6;
  int totalPages = 1;
  String? userId;

  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  Future<void> _getUserId() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        userId = currentUser.uid;
      });
      _fetchUser();
      _fetchBadges();
      _fetchStrengths();
      _fetchLinks();
    } else {
      // Handle no user case
    }
  }

  Future<void> _fetchUser() async {
    if (userId == null) return;
    
    
    try {
      final response = await ServiceLocator().api.getUser(userId!);

      if (response != null) {
        setState(() {
          user = response;
        });
      } else {
     
        throw Exception('Invalid user response format');
      }
    } catch (e) {
    }
  }

  Future<void> _fetchLinks() async {
    if (userId == null) return;
    
    
    try {
      final response = await ServiceLocator().api.getAllLinksForUser(userId!);

      if (response != null) {
        setState(() {
          links = List<Map<String, dynamic>>.from(response);
        });
      } else {
        throw Exception('Invalid links response format');
      }
    } catch (e) {
    }
  }

  Future<void> _fetchStrengths() async {
    if (userId == null) return;
    
    try {
      // First get the student ID for this user
      final studentResponse = await ServiceLocator().api.getStudentForUserId(userId!);
      if (studentResponse == null || !studentResponse.containsKey('id')) {
        throw Exception('Could not find student for user');
      }
      
      final studentId = studentResponse['id'].toString(); // Convert to string
      
      // Now get the strengths for this student
      final response = await ServiceLocator().api.getStrengthsForStudent(studentId);
      
      if (response != null) {
        setState(() {
          // The response is directly the array of strengths
          strengths = List<Map<String, dynamic>>.from(response);
        });
      } else {
        throw Exception('Invalid strengths response format');
      }
    } catch (e) {
      print('ProfilePage: Error fetching strengths: $e');
      // Set strengths to empty list to show the "No Clifton Strengths" message
      setState(() {
        strengths = [];
      });
    }
  }

  Future<void> _fetchBadges() async {
    if (userId == null) return;
    
  
    
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });

      final response = await ServiceLocator().api.getBadgesForStudent(userId!, currentPage, pageSize);

      if (response != null && response['badges'] != null) {
        setState(() {
          badges = List<Map<String, dynamic>>.from(response['badges']);
          totalPages = (response['total'] / pageSize).ceil();
          isLoading = false;
        });
      
      } else {
       
        throw Exception('Invalid response format');
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('ProfilePage: Building widget, isLoading: $isLoading, hasError: $hasError, badges count: ${badges.length}');
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Card(
            color: const Color(0xFF1E1E1E), // backgroundDarken
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/Birb.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Profile Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?['fullName'] ?? 'Loading...',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?['major'] ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "About Me:",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?['profileDescription'] ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // Contact Information
          Card(
            color: const Color(0xFF1E1E1E), // backgroundDarken
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Contact Information",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Email: ${user?['email'] ?? 'Loading...'}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...links.map((link) => Padding(
                    padding: const EdgeInsets.only(bottom: 2.0),
                    child: Row(
                      children: [
                        Text(
                          "${link['websiteName']}: ",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final url = Uri.parse(link['link']);
                            try {
                              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                              }
                            } catch (e) {
                            }
                          },
                          child: Text(
                            link['link'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Badges Section
          Card(
            color: const Color(0xFF1E1E1E), // backgroundDarken
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Badges",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isLoading)
                    const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                  else if (hasError)
                    const Center(
                      child: Text(
                        "Failed to load badges",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    )
                  else if (badges.isEmpty)
                    const Center(
                      child: Column(
                        children: [
                          Text(
                            "No badges yet!",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Complete some flight plan items to be rewarded!",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "The LORD repay you for what you have done, and a full reward be given you by the LORD, the God of Israel, under whose wings you have come to take refuge!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "- Ruth 2:12",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: [
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.0,
                            crossAxisSpacing: 4.0,
                            mainAxisSpacing: 4.0,
                          ),
                          itemCount: badges.length,
                          itemBuilder: (context, index) {
                            print('ProfilePage: Building badge card for index $index: ${badges[index]}');
                            return BadgeCard(badge: badges[index]);
                          },
                        ),
                        if (totalPages > 1)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.chevron_left,
                                    color: Colors.white,
                                  ),
                                  onPressed: currentPage > 1
                                      ? () {
                                          print('ProfilePage: Previous page button pressed');
                                          setState(() {
                                            currentPage--;
                                          });
                                          _fetchBadges();
                                        }
                                      : null,
                                ),
                                Text(
                                  'Page $currentPage of $totalPages',
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.chevron_right,
                                    color: Colors.white,
                                  ),
                                  onPressed: currentPage < totalPages
                                      ? () {
                                          print('ProfilePage: Next page button pressed');
                                          setState(() {
                                            currentPage++;
                                          });
                                          _fetchBadges();
                                        }
                                      : null,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Strengths Section
          Card(
            color: const Color(0xFF1E1E1E), // backgroundDarken
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Clifton Strengths",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (strengths.isEmpty)
                    const Center(
                      child: Column(
                        children: [
                          Text(
                            "No Clifton Strengths listed",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Contact Charlotte Hamil to change this!",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Before I formed you in the womb I knew you, and before you were born I consecrated you; I appointed you a prophet to the nations.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "- Jeremiah 1:5",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: strengths.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: StrengthCard(strength: strengths[index]),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 