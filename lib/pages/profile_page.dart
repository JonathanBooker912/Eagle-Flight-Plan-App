import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../theme/app_theme.dart';
import '../models/strength.dart';
import '../models/link.dart';
import '../services/strength_service.dart';
import '../services/link_service.dart';
import '../services/user_service.dart';
import '../services/badge_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/service_locator.dart';
import '../services/api_session_storage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentPage = 1;
  final int _pageSize = 6;
  int _totalPages = 1;
  List<StrengthModel> _strengths = [];
  List<LinkModel> _links = [];
  List<BadgeModel> _badges = [];
  bool _isLoading = true;
  UserProfile? _userProfile;
  int? _expandedStrengthIndex; // Track which strength is expanded
  late final ServiceLocator _serviceLocator = ServiceLocator();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userProfileFuture = _serviceLocator.user.getUserProfile();
      final strengthsFuture = _serviceLocator.strength.getStrengthsForUser();
      final linksFuture = _serviceLocator.link.getLinksForUser();
      final badgesFuture = _serviceLocator.badge
          .getBadgesForStudent(page: _currentPage, pageSize: _pageSize);

      final results = await Future.wait(
          [userProfileFuture, strengthsFuture, linksFuture, badgesFuture]);

      final userProfile = results[0] as UserProfile;
      final strengthResponse = results[1] as StrengthResponse;
      final links = results[2] as List<LinkModel>;
      final badgeResponse = results[3] as BadgeResponse;

      setState(() {
        _userProfile = userProfile;
        _strengths = strengthResponse.strengths;
        _links = links;
        _badges = badgeResponse.badges;
        _totalPages = (badgeResponse.total / _pageSize).ceil();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadBadges() async {
    try {
      final badgeResponse = await _serviceLocator.badge.getBadgesForStudent(
        page: _currentPage,
        pageSize: _pageSize,
      );

      setState(() {
        _badges = badgeResponse.badges;
        _totalPages = (badgeResponse.total / _pageSize).ceil();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading badges: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not launch URL'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _logout() {
    GoogleSignIn().signOut();
    ApiSessionStorage.clearSession();
    Navigator.of(context).pushReplacementNamed("/login");
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isTablet = constraints.maxWidth < 960;

        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () => _logout(),
            child: const Icon(Icons.logout),
          ),
          backgroundColor: colorScheme.background,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  // Profile and About Me Section
                  Card(
                    color: colorScheme.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: isMobile
                          ? Column(
                              children: [
                                _buildProfilePicture(),
                                const SizedBox(height: 16),
                                _buildAboutMeSection(),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  child: _buildProfilePicture(),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildAboutMeSection(),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Links Section
                  Card(
                    color: colorScheme.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildLinksSection(),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Bottom Section
                  isMobile
                      ? Column(
                          children: [
                            _buildBadgesSection(),
                            const SizedBox(height: 8),
                            _buildStrengthsSection(),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildBadgesSection(),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildStrengthsSection(),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfilePicture() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: AppTheme.primaryColor,
              child: Text(
                _userProfile?.fullName.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _userProfile?.fullName ?? 'User Name',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          _userProfile?.email ?? 'No email',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildAboutMeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'About Me:',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          // padding: const EdgeInsets.all(12),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              _userProfile?.profileDescription ?? 'No description',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLinksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Links',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_links.isEmpty)
          const Center(
            child: Text(
              'No links found',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Email: ${_userProfile?.email ?? 'No email'}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              ..._links
                  .map((link) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              link.websiteName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _launchUrl(link.link),
                              child: Text(
                                link.link,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ],
          ),
      ],
    );
  }

  Widget _buildBadgesSection() {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Badges',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_badges.isEmpty)
              const Center(
                child: Text(
                  'No badges! Complete some flight plan items to be rewarded!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                ),
              )
            else
              Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _badges.length,
                    itemBuilder: (context, index) {
                      final badge = _badges[index];
                      return Card(
                        color: const Color(0xFF42444C),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // if (badge.imageUrl != null)
                            //   Image.network(
                            //     badge.imageUrl!,
                            //     height: 60,
                            //     width: 60,
                            //   )

                            const Icon(Icons.workspace_premium,
                                size: 60, color: Colors.white),
                            const SizedBox(height: 8),
                            Text(
                              badge.name,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  if (_totalPages > 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left,
                                color: Colors.white),
                            onPressed: _currentPage > 1
                                ? () {
                                    setState(() {
                                      _currentPage--;
                                    });
                                    _loadBadges();
                                  }
                                : null,
                          ),
                          Text(
                            'Page $_currentPage of $_totalPages',
                            style: const TextStyle(color: Colors.white),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right,
                                color: Colors.white),
                            onPressed: _currentPage < _totalPages
                                ? () {
                                    setState(() {
                                      _currentPage++;
                                    });
                                    _loadBadges();
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
    );
  }

  Widget _buildStrengthsSection() {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Clifton Strengths',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_strengths.isEmpty)
              const Center(
                child: Text(
                  'No strengths found. Contact Charlotte Hamil to change this!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _strengths.length,
                itemBuilder: (context, index) {
                  final strength = _strengths[index];
                  return _buildStrengthCard(strength, index);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrengthCard(StrengthModel strength, int index) {
    return StatefulBuilder(
      builder: (context, setState) {
        final isExpanded = _expandedStrengthIndex == index;

        Color getDomainColor(String domain) {
          switch (domain) {
            case 'Executing':
              return const Color(0xFF8B5CF6); // Blue
            case 'Influencing':
              return const Color(0xFFD97706); // Orange
            case 'Relationship Building':
              return const Color(0xFF0070CA); // Green
            case 'Strategic Planning':
              return const Color(0xFF10B981); // Purple
            default:
              return const Color(0xFF0070CA); // Default blue
          }
        }

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expandedStrengthIndex = null;
              } else {
                _expandedStrengthIndex = index;
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isExpanded ? 175 : 50,
            child: Card(
              color: const Color(0xFF42444C),
              child: Padding(
                padding: const EdgeInsets.symmetric(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: getDomainColor(strength.domain),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.zero,
                              bottomRight: Radius.zero,
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${strength.number ?? index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            strength.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Text(
                            strength.domain,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (isExpanded)
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                          child: Text(
                            strength.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
