import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/strength_card.dart';
import '../widgets/badge_card.dart';
import '../services/service_locator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_session_storage.dart';

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
      try {
        final session = await ApiSessionStorage.getSession();
        setState(() {
          userId = session.userId.toString();
        });
        _fetchUser();
        _fetchBadges();
        _fetchStrengths();
        _fetchLinks();
      } catch (e) {
        print('Error getting session: $e');
      }
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
      }
    } catch (e) {
      print('Error fetching user: $e');
    }
  }

  Future<void> _fetchLinks() async {
    if (userId == null) {
      print('ProfilePage: Cannot fetch links - userId is null');
      return;
    }
    
    print('ProfilePage: Starting to fetch links for user $userId');
    try {
      final response = await ServiceLocator().api.getAllLinksForUser(userId!);
      print('ProfilePage: Received links response: $response');
      print('ProfilePage: Response type: ${response.runtimeType}');
      
      if (response != null && response.containsKey('data')) {
        setState(() {
          links = List<Map<String, dynamic>>.from(response['data']);
          print('ProfilePage: Successfully set ${links.length} links');
        });
      } else {
        print('ProfilePage: Response is null or missing data field');
        throw Exception('Invalid links response format');
      }
    } catch (e) {
      print('ProfilePage: Error in _fetchLinks: $e');
      print('ProfilePage: Error type: ${e.runtimeType}');
      setState(() {
        links = [];
      });
    }
  }

  Future<void> _fetchStrengths() async {
    if (userId == null) return;
    
    try {
      final studentResponse = await ServiceLocator().api.getStudentForUserId(userId!);
      if (studentResponse == null || !studentResponse.containsKey('id')) {
        throw Exception('Could not find student for user');
      }
      
      final studentId = studentResponse['id'].toString();
      final response = await ServiceLocator().api.getStrengthsForStudent(studentId);
      
      if (response != null && response.containsKey('data')) {
        setState(() {
          strengths = List<Map<String, dynamic>>.from(response['data']);
        });
      }
    } catch (e) {
      print('Error fetching strengths: $e');
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
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile Header
          Card(
            color: const Color(0xFF1E1E1E),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      user?['fullName']?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
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
            color: const Color(0xFF1E1E1E),
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
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            } catch (e) {
                              print('Error launching URL: $e');
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
            color: const Color(0xFF1E1E1E),
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
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.0,
                            crossAxisSpacing: 4.0,
                            mainAxisSpacing: 4.0,
                          ),
                          itemCount: badges.length,
                          itemBuilder: (context, index) => BadgeCard(badge: badges[index]),
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
            color: const Color(0xFF1E1E1E),
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
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: strengths.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: StrengthCard(strength: strengths[index]),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Logout Button
          ElevatedButton(
            onPressed: _logout,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Logout', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
