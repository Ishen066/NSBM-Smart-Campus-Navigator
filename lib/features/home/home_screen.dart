
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../map/campus_map_screen.dart';
import '../events/campus_events_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: _selectedIndex == 0
            ? _buildHome()
            : _selectedIndex == 1
                ? const CampusMapScreen()
                : _selectedIndex == 2
                    ? const CampusEventsScreen()
                    : _buildOtherPage(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.green.withValues(alpha: 0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event_rounded),
            label: 'Events',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),

          const SizedBox(height: 28),

          _buildWelcome(),

          const SizedBox(height: 22),

          _buildSearchBar(),

          const SizedBox(height: 28),

          _buildSectionTitle(
            'Explore Campus',
            'View all',
            () => setState(() => _selectedIndex = 1),
          ),

          const SizedBox(height: 14),

          _buildMapPreview(),

          const SizedBox(height: 28),

          _buildSectionTitle(
            'Quick Access',
            'See all',
            () => setState(() => _selectedIndex = 1),
          ),

          const SizedBox(height: 14),

          _buildQuickActions(),

          const SizedBox(height: 28),

          _buildSectionTitle(
            'Campus Updates',
            'All events',
            () => setState(() => _selectedIndex = 2),
          ),

          const SizedBox(height: 14),

          _buildEventCard(),

          const SizedBox(height: 18),

          _buildNoticeCard(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.navy,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.school_rounded,
            color: Colors.white,
            size: 27,
          ),
        ),

        const SizedBox(width: 12),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NSBM',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.navy,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'SMART CAMPUS',
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.green,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        IconButton(
          onPressed: () => _showMessage(
            'Notifications coming soon!',
          ),
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: AppTheme.navy,
            size: 27,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hello, Student 👋',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w800,
            color: AppTheme.navy,
          ),
        ),

        const SizedBox(height: 7),

        Text(
          'Explore your campus with ease.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.blueGrey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            color: AppTheme.green,
            size: 24,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: TextField(
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  _showMessage('Searching for $value...');
                }
              },
              decoration: InputDecoration(
                hintText: 'Search buildings, rooms...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: Colors.blueGrey.shade300,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),

          const Icon(
            Icons.tune_rounded,
            color: AppTheme.navy,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
    String action,
    VoidCallback onTap,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.navy,
          ),
        ),

        TextButton(
          onPressed: onTap,
          child: Text(
            action,
            style: const TextStyle(
              color: AppTheme.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapPreview() {
    return Container(
      height: 190,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE3F0E9),
        borderRadius: BorderRadius.circular(22),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            left: -35,
            top: 65,
            child: Transform.rotate(
              angle: -0.35,
              child: Container(
                width: 420,
                height: 15,
                color: Colors.white,
              ),
            ),
          ),

          Positioned(
            left: 80,
            top: -50,
            child: Transform.rotate(
              angle: 0.65,
              child: Container(
                width: 15,
                height: 300,
                color: Colors.white,
              ),
            ),
          ),

          Positioned(
            right: 35,
            bottom: 20,
            child: Container(
              width: 110,
              height: 65,
              decoration: BoxDecoration(
                color: const Color(0xFFB7D8C4),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          Positioned(
            left: 35,
            top: 22,
            child: _mapMarker(
              Icons.school_rounded,
              'Campus',
            ),
          ),

          Positioned(
            right: 35,
            top: 65,
            child: _mapMarker(
              Icons.location_on_rounded,
              'You are here',
            ),
          ),

          Positioned(
            left: 16,
            bottom: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.map_rounded,
                    color: AppTheme.green,
                    size: 18,
                  ),
                  SizedBox(width: 7),
                  Text(
                    'Explore Campus Map',
                    style: TextStyle(
                      color: AppTheme.navy,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            right: 14,
            bottom: 15,
            child: Icon(
              Icons.explore_rounded,
              color: AppTheme.green.withValues(alpha: 0.8),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapMarker(IconData icon, String label) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.green,
          size: 29,
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppTheme.navy,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'title': 'Lecture Halls',
        'icon': Icons.meeting_room_rounded,
        'color': const Color(0xFFE8F1FF),
        'iconColor': const Color(0xFF3478DB),
      },
      {
        'title': 'Library',
        'icon': Icons.local_library_rounded,
        'color': const Color(0xFFE4F5EE),
        'iconColor': AppTheme.green,
      },
      {
        'title': 'Cafeteria',
        'icon': Icons.restaurant_rounded,
        'color': const Color(0xFFFFF0E5),
        'iconColor': const Color(0xFFE88A35),
      },
      {
        'title': 'Laboratories',
        'icon': Icons.science_rounded,
        'color': const Color(0xFFF1EAFE),
        'iconColor': const Color(0xFF8758D8),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 13,
        mainAxisSpacing: 13,
        childAspectRatio: 1.7,
      ),
      itemBuilder: (context, index) {
        final item = actions[index];

        return InkWell(
          borderRadius: BorderRadius.circular(17),
          onTap: () => _showMessage(
            '${item['title']} - Coming soon!',
          ),
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: Colors.grey.shade100,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: item['color'] as Color,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: item['iconColor'] as Color,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 9),

                Expanded(
                  child: Text(
                    item['title'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.navy,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventCard() {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => setState(() => _selectedIndex = 2),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              width: 65,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFE4F5EE),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.event_available_rounded,
                color: AppTheme.green,
                size: 32,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Campus Events',
                    style: TextStyle(
                      color: AppTheme.navy,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Discover campus events, workshops and announcements.',
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.4,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,
              color: AppTheme.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoticeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.navy,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppTheme.skyBlue,
            size: 25,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Find your destination and explore the campus with ease.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherPage() {
    final pages = [
      '',
      'Campus Map',
      'Campus Events',
      'Student Profile',
    ];

    final icons = [
      Icons.home_rounded,
      Icons.map_rounded,
      Icons.event_rounded,
      Icons.person_rounded,
    ];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icons[_selectedIndex],
            size: 65,
            color: AppTheme.green,
          ),
          const SizedBox(height: 18),
          Text(
            pages[_selectedIndex],
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: AppTheme.navy,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This section is coming soon.',
            style: TextStyle(color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }
}
