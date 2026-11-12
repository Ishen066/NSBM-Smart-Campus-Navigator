
import 'package:flutter/material.dart';

import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../splash/splash_screen.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() =>
      _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final AuthService _authService = AuthService();

  String _studentName = 'Loading...';
  String _studentId = 'Loading...';
  String _degree = 'Loading...';
  String _batch = 'Loading...';
  String _email = 'Loading...';

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // Load student information from Firestore.
  Future<void> _loadProfile() async {
    try {
      final profile = await _authService.getStudentProfile();

      if (!mounted) return;

      if (profile == null) {
        setState(() {
          _studentName = 'NSBM Student';
          _studentId = 'Not available';
          _degree = 'Not available';
          _batch = 'Not available';
          _email = _authService.currentUser?.email ?? 'Not available';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _studentName =
            profile['fullName']?.toString() ?? 'NSBM Student';
        _studentId =
            profile['studentId']?.toString() ?? 'Not available';
        _degree =
            profile['degreeProgramme']?.toString() ?? 'Not available';
        _batch =
            profile['academicBatch']?.toString() ?? 'Not available';
        _email =
            profile['email']?.toString() ??
            _authService.currentUser?.email ??
            'Not available';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage('Unable to load student profile.');
    }
  }

  // Edit student profile.
  Future<void> _editProfile() async {
    final nameController =
        TextEditingController(text: _studentName);
    final idController =
        TextEditingController(text: _studentId);
    final degreeController =
        TextEditingController(text: _degree);
    final batchController =
        TextEditingController(text: _batch);

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Edit Profile',
            style: TextStyle(
              color: AppTheme.navy,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _editField(nameController, 'Student Name'),
                _editField(idController, 'Student ID'),
                _editField(degreeController, 'Degree Programme'),
                _editField(batchController, 'Academic Batch'),
                const SizedBox(height: 5),
                Text(
                  'Email address cannot be changed here.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blueGrey.shade400,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (nameController.text.trim().isEmpty ||
                    idController.text.trim().isEmpty ||
                    degreeController.text.trim().isEmpty ||
                    batchController.text.trim().isEmpty) {
                  return;
                }

                Navigator.pop(dialogContext, {
                  'name': nameController.text.trim(),
                  'id': idController.text.trim(),
                  'degree': degreeController.text.trim(),
                  'batch': batchController.text.trim(),
                });
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    idController.dispose();
    degreeController.dispose();
    batchController.dispose();

    if (result == null || !mounted) return;

    await _saveProfile(result);
  }

  // Save changes to Firestore.
  Future<void> _saveProfile(Map<String, String> data) async {
    setState(() {
      _isSaving = true;
    });

    try {
      await _authService.updateStudentProfile(
        fullName: data['name']!,
        studentId: data['id']!,
        degreeProgramme: data['degree']!,
        academicBatch: data['batch']!,
      );

      if (!mounted) return;

      setState(() {
        _studentName = data['name']!;
        _studentId = data['id']!;
        _degree = data['degree']!;
        _batch = data['batch']!;
        _isSaving = false;
      });

      _showMessage('Profile updated successfully!');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage('Unable to update profile. Please try again.');
    }
  }

  // Logout confirmation and navigation.
  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      // Sign out from Firebase.
      await _authService.logout();

      if (!mounted) return;

      // Clear previous screens and open Splash Screen.
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const SplashScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage('Unable to logout. Please try again.');
    }
  }

  Widget _editField(
    TextEditingController controller,
    String label,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 25),
                    _buildProfileCard(),
                    const SizedBox(height: 28),
                    _buildSectionTitle('Personal Information'),
                    const SizedBox(height: 14),
                    _buildInformationCard(),
                    const SizedBox(height: 26),
                    _buildSectionTitle('Account'),
                    const SizedBox(height: 14),
                    _buildAccountOptions(),
                    const SizedBox(height: 25),
                    _buildFooter(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Profile',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w900,
            color: AppTheme.navy,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Manage your student information',
          style: TextStyle(
            fontSize: 13,
            color: Colors.blueGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppTheme.navy,
            AppTheme.green,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.7),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 52,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            _studentName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _studentId,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isSaving ? null : _editProfile,
              icon: const Icon(
                Icons.edit_outlined,
                size: 17,
              ),
              label: Text(
                _isSaving ? 'Saving...' : 'Edit Profile',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppTheme.navy,
      ),
    );
  }

  Widget _buildInformationCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: Colors.grey.shade100,
        ),
      ),
      child: Column(
        children: [
          _informationRow(
            Icons.badge_outlined,
            'Student ID',
            _studentId,
          ),
          _divider(),
          _informationRow(
            Icons.school_outlined,
            'Degree Programme',
            _degree,
          ),
          _divider(),
          _informationRow(
            Icons.calendar_month_outlined,
            'Academic Batch',
            _batch,
          ),
          _divider(),
          _informationRow(
            Icons.email_outlined,
            'Email Address',
            _email,
          ),
        ],
      ),
    );
  }

  Widget _informationRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.green.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppTheme.green,
              size: 21,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blueGrey.shade400,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.navy,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      color: Colors.grey.shade100,
    );
  }

  Widget _buildAccountOptions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Column(
        children: [
          _accountTile(
            Icons.person_outline_rounded,
            'Edit Personal Details',
            'Update your student information',
            _editProfile,
          ),
          _divider(),
          _accountTile(
            Icons.help_outline_rounded,
            'Help & Support',
            'Get assistance with the application',
            () => _showMessage(
              'Help & Support coming soon!',
            ),
          ),
          _divider(),
          _accountTile(
            Icons.info_outline_rounded,
            'About NSBM Smart Campus',
            'Application information',
            _showAbout,
          ),
          _divider(),
          _accountTile(
            Icons.logout_rounded,
            'Logout',
            'Sign out from your student account',
            _logout,
            iconColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _accountTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    Color? iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 17,
          vertical: 5,
        ),
        leading: Icon(
          icon,
          color: iconColor ?? AppTheme.green,
          size: 25,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.navy,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.blueGrey,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: Colors.blueGrey,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.school_rounded,
            color: AppTheme.green.withValues(alpha: 0.7),
            size: 27,
          ),
          const SizedBox(height: 8),
          const Text(
            'NSBM SMART CAMPUS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              color: AppTheme.navy,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Student Campus Navigation App',
            style: TextStyle(
              fontSize: 11,
              color: Colors.blueGrey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'NSBM Smart Campus',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.school_rounded,
        color: AppTheme.green,
        size: 35,
      ),
      children: const [
        Text(
          'A campus navigation application designed to help '
          'students explore NSBM campus facilities, maps and events.',
        ),
      ],
    );
  }
}
