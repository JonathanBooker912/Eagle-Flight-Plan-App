import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/strength_card.dart';
import '../widgets/badge_card.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Mock data - replace with actual API calls
  final String fullName = "John Doe";
  final String major = "Computer Science";
  final String profileDescription = "I am a passionate student interested in software development and aviation.";
  final String email = "john.doe@example.com";
  
  final List<Map<String, String>> links = [
    {"websiteName": "LinkedIn", "link": "https://linkedin.com/in/johndoe"},
    {"websiteName": "GitHub", "link": "https://github.com/johndoe"},
    {"websiteName": "Portfolio", "link": "https://johndoe.com"},
  ];

  final List<Map<String, dynamic>> strengths = [
    {"name": "Achiever", "description": "You work hard and possess a great deal of stamina."},
    {"name": "Strategic", "description": "You create alternative ways to proceed."},
    {"name": "Learner", "description": "You have a great desire to learn and want to continuously improve."},
  ];

  List<Map<String, dynamic>> badges = [];
  bool isLoading = true;
  bool hasError = false;
  int currentPage = 1;
  int pageSize = 6;
  int totalPages = 1;

  @override
  void initState() {
    super.initState();
    print('ProfilePage: initState called');
    _fetchBadges();
  }

  Future<void> _fetchBadges() async {
    print('ProfilePage: Starting to fetch badges');
    print('ProfilePage: Current page: $currentPage, Page size: $pageSize');
    
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });

      // Get the auth token from storage
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      print('ProfilePage: Auth token found: ${token != null}');

      if (token == null) {
        print('ProfilePage: No auth token found');
        throw Exception('Authentication required');
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final url = 'https://flightplan.eaglesoftwareteam.com/flight-plan-t1/badge/student/1?page=$currentPage&pageSize=$pageSize';
      print('ProfilePage: Making request to URL: $url with auth headers');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      print('ProfilePage: Response status code: ${response.statusCode}');
      print('ProfilePage: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('ProfilePage: Decoded data: $data');
        
        if (data['badges'] != null) {
          setState(() {
            badges = List<Map<String, dynamic>>.from(data['badges']);
            totalPages = (data['total'] / pageSize).ceil();
            isLoading = false;
          });
          print('ProfilePage: Successfully loaded ${badges.length} badges');
          print('ProfilePage: Total pages: $totalPages');
        } else {
          print('ProfilePage: Error - badges field is null in response');
          throw Exception('Badges field is null in response');
        }
      } else {
        print('ProfilePage: Error - HTTP status code ${response.statusCode}');
        throw Exception('Failed to load badges: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('ProfilePage: Error caught: $e');
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
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/Birb.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Profile Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          major,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "About Me:",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          profileDescription,
                          style: const TextStyle(
                            fontSize: 18,
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
          const SizedBox(height: 16),
          
          // Contact Information
          Card(
            color: const Color(0xFF1E1E1E), // backgroundDarken
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Contact Information",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Email: $email",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...links.map((link) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      children: [
                        Text(
                          "${link['websiteName']}: ",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Handle link tap
                          },
                          child: Text(
                            link['link']!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
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
          const SizedBox(height: 16),

          // Badges Section
          Card(
            color: const Color(0xFF1E1E1E), // backgroundDarken
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Badges",
                    style: TextStyle(
                      fontSize: 18,
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
                          Text(
                            "Complete some flight plan items to be rewarded!",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "The LORD repay you for what you have done, and a full reward be given you by the LORD, the God of Israel, under whose wings you have come to take refuge!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
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
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                          ),
                          itemCount: badges.length,
                          itemBuilder: (context, index) {
                            print('ProfilePage: Building badge card for index $index: ${badges[index]}');
                            return BadgeCard(badge: badges[index]);
                          },
                        ),
                        if (totalPages > 1)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
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
          const SizedBox(height: 16),

          // Strengths Section
          Card(
            color: const Color(0xFF1E1E1E), // backgroundDarken
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Clifton Strengths",
                    style: TextStyle(
                      fontSize: 18,
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
                          Text(
                            "Contact Charlotte Hamil to change this!",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Before I formed you in the womb I knew you, and before you were born I consecrated you; I appointed you a prophet to the nations.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
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
                        return StrengthCard(strength: strengths[index]);
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