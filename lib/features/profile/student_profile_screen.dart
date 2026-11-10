
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() =>
      _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  String _studentName = 'NSBM Student';
  String _studentId = 'Add your student ID';
  String _degree = 'Add your degree programme';
  String _batch = 'Add your academic batch';
  String _email = 'Add your email address';

  Future<void> _editProfile() async {
    final nameController =
        TextEditingController(text: _studentName);
    final idController =
        TextEditingController(text: _studentId);
    final degreeController =
        TextEditingController(text: _degree);
    final batchController =
        TextEditingController(text: _batch);
    final emailController =
        TextEditingController(text: _email);

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
                _editField(emailController, 'Email Address'),
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
                Navigator.pop(dialogContext, {
                  'name': nameController.text.trim(),
                  'id': idController.text.trim(),
                  'degree': degreeController.text.trim(),
                  'batch': batchController.text.trim(),
                  'email': emailController.text.trim(),
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
    emailController.dispose();

    if (result != null && mounted) {
      setState(() {
        _studentName =
            result['name']!.isEmpty ? 'NSBM Student' : result['name']!;
        _studentId =
            result['id']!.isEmpty ? 'Add your student ID' : result['id']!;
        _degree = result['degree']!.isEmpty
            ? 'Add your degree programme'
            : result['degree']!;
        _batch = result['batch']!.isEmpty
            ? 'Add your academic batch'
            : result['batch']!;
        _email = result['email']!.isEmpty
            ? 'Add your email address'
            : result['email']!;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
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
              onPressed: _editProfile,
              icon: const Icon(Icons.edit_outlined, size: 17),
              label: const Text('Edit Profile'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
                padding: const EdgeInsets.symmetric(vertical: 13),
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
        border: Border.all(color: Colors.grey.shade100),
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
            () => _showMessage('Help & Support coming soon!'),
          ),
          _divider(),
          _accountTile(
            Icons.info_outline_rounded,
            'About NSBM Smart Campus',
            'Application information',
            _showAbout,
          ),
        ],
      ),
    );
  }

  Widget _accountTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 17,
        vertical: 5,
      ),
      leading: Icon(
        icon,
        color: AppTheme.green,
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
