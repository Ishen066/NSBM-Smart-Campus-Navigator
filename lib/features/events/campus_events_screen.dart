import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class CampusEventsScreen extends StatefulWidget {
  const CampusEventsScreen({super.key});

  @override
  State<CampusEventsScreen> createState() => _CampusEventsScreenState();
}

class _CampusEventsScreenState extends State<CampusEventsScreen> {
  String _selectedCategory = 'All';

  // These are demonstration entries, not confirmed NSBM event listings.
  // Replace them with verified university event data when available.
  final List<Map<String, String>> _events = [
    {
      'title': 'Technology Workshop',
      'category': 'Workshop',
      'date': 'Date to be announced',
      'time': 'Time to be announced',
      'location': 'Venue to be announced',
      'description':
          'A sample workshop listing for technology-related learning '
              'and practical activities. Official event details should '
              'be added after confirmation.',
    },
    {
      'title': 'Career Guidance Session',
      'category': 'Seminar',
      'date': 'Date to be announced',
      'time': 'Time to be announced',
      'location': 'Venue to be announced',
      'description':
          'A sample career guidance session listing. Add the confirmed '
              'organiser, registration information and venue when available.',
    },
    {
      'title': 'Sports and Recreation',
      'category': 'Sports',
      'date': 'Date to be announced',
      'time': 'Time to be announced',
      'location': 'Sports Centre',
      'description':
          'A sample sports and recreation listing for campus activities. '
              'The date and participation details need official confirmation.',
    },
    {
      'title': 'Student Club Meetup',
      'category': 'Student Life',
      'date': 'Date to be announced',
      'time': 'Time to be announced',
      'location': 'Student Center',
      'description':
          'A sample student club meetup listing. Confirm the participating '
              'clubs and meeting details before publishing.',
    },
  ];

  final List<String> _categories = [
    'All',
    'Workshop',
    'Seminar',
    'Sports',
    'Student Life',
  ];

  List<Map<String, String>> get _filteredEvents {
    if (_selectedCategory == 'All') return _events;

    return _events
        .where((event) => event['category'] == _selectedCategory)
        .toList();
  }

  void _showEventDetails(Map<String, String> event) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  _categoryBadge(event['category'] ?? 'Event'),
                  const SizedBox(height: 14),
                  Text(
                    event['title'] ?? 'Campus Event',
                    style: const TextStyle(
                      color: AppTheme.navy,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    event['description'] ?? '',
                    style: TextStyle(
                      color: Colors.blueGrey.shade700,
                      height: 1.5,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _detailRow(
                    Icons.calendar_today_outlined,
                    event['date'] ?? 'To be announced',
                  ),
                  _detailRow(
                    Icons.access_time_rounded,
                    event['time'] ?? 'To be announced',
                  ),
                  _detailRow(
                    Icons.location_on_outlined,
                    event['location'] ?? 'To be announced',
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7E8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Demo listing: confirm event information through '
                      'official NSBM channels before attending.',
                      style: TextStyle(
                        color: Color(0xFF8A5A12),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          Icon(icon, size: 19, color: AppTheme.green),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.navy,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryBadge(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE4F5EE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category,
        style: const TextStyle(
          color: AppTheme.green,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Campus Events',
                style: TextStyle(
                  color: AppTheme.navy,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Discover activities and campus updates.',
                style: TextStyle(
                  color: Colors.blueGrey.shade600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppTheme.navy,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.campaign_outlined,
                      color: AppTheme.skyBlue,
                      size: 25,
                    ),
                    SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stay connected',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Check this page for campus activities and '
                            'important announcements.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'Upcoming Events',
                style: TextStyle(
                  color: AppTheme.navy,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Select a category to explore event listings.',
                style: TextStyle(
                  color: Colors.blueGrey.shade600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 39,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final selected = _selectedCategory == category;

                    return ChoiceChip(
                      label: Text(category),
                      selected: selected,
                      onSelected: (_) {
                        setState(() => _selectedCategory = category);
                      },
                      selectedColor: AppTheme.green,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : AppTheme.navy,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      side: BorderSide(
                        color: selected
                            ? AppTheme.green
                            : Colors.grey.shade200,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 15),
              if (_filteredEvents.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Center(child: Text('No events in this category.')),
                )
              else
                ..._filteredEvents.map(
                  (event) => _eventCard(event),
                ),
              const SizedBox(height: 14),
              const Text(
                'Announcements',
                style: TextStyle(
                  color: AppTheme.navy,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              _announcementCard(
                icon: Icons.info_outline_rounded,
                title: 'Official campus updates',
                message:
                    'Check official NSBM communication channels for '
                    'confirmed notices, dates and timetable changes.',
                color: const Color(0xFFEAF3FF),
                iconColor: const Color(0xFF3478DB),
              ),
              const SizedBox(height: 10),
              _announcementCard(
                icon: Icons.event_note_rounded,
                title: 'Event information',
                message:
                    'Event entries on this screen are sample data for '
                    'the app interface and are not confirmed university events.',
                color: const Color(0xFFFFF2E5),
                iconColor: const Color(0xFFE88A35),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _eventCard(Map<String, String> event) {
    return InkWell(
      onTap: () => _showEventDetails(event),
      borderRadius: BorderRadius.circular(17),
      child: Container(
        margin: const EdgeInsets.only(bottom: 11),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFE4F5EE),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.event_available_rounded,
                color: AppTheme.green,
                size: 26,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title'] ?? '',
                    style: const TextStyle(
                      color: AppTheme.navy,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${event['category']}  •  ${event['date']}',
                    style: TextStyle(
                      color: Colors.blueGrey.shade600,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 7),
                  _categoryBadge(event['category'] ?? 'Event'),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.green,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _announcementCard({
    required IconData icon,
    required String title,
    required String message,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.navy,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.blueGrey.shade600,
                    fontSize: 11,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
