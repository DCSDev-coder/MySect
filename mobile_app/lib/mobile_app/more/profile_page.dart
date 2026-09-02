import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../notifications/notifications_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController(text: 'Elly Melissa');
  final TextEditingController _emailController = TextEditingController(text: 'melissa@datacenterspecialists.com');
  final TextEditingController _phoneController = TextEditingController(text: '+6012 -299 3330');
  final TextEditingController _dobController = TextEditingController(text: 'Jan 1, 2000');
  final TextEditingController _addressController = TextEditingController(text: 'Eco Forest, Malaysia');

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _dobFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _dobFocus.dispose();
    _addressFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 8.0,
                        top: 16.0,
                        right: 16.0,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.black87),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Image.asset(
                            'assets/YourSectComp.png',
                            width: 150,
                            fit: BoxFit.contain,
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_none,
                              color: Colors.black,
                              size: 28,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const NotificationsPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: _buildProfileHeader(),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            _buildSectionHeader('PERSONAL INFORMATION'),
            _buildSectionContainer(
              children: [
                _buildInfoItem(
                  title: 'Full Name',
                  controller: _nameController,
                  focusNode: _nameFocus,
                  icon: Icons.person_outline,
                  onChanged: (value) => setState(() {}),
                ),
                _buildDivider(),
                _buildInfoItem(
                  title: 'Email Address',
                  controller: _emailController,
                  focusNode: _emailFocus,
                  icon: Icons.email_outlined,
                ),
                _buildDivider(),
                _buildInfoItem(
                  title: 'Phone Number',
                  controller: _phoneController,
                  focusNode: _phoneFocus,
                  icon: Icons.phone_outlined,
                ),
                _buildDivider(),
                _buildInfoItem(
                  title: 'Date of Birth',
                  controller: _dobController,
                  focusNode: _dobFocus,
                  icon: Icons.cake_outlined,
                ),
                _buildDivider(),
                _buildInfoItem(
                  title: 'Address',
                  controller: _addressController,
                  focusNode: _addressFocus,
                  icon: Icons.home_outlined,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('ACCOUNT SECURITY'),
            _buildSectionContainer(
              children: [
                _buildActionItem(
                  title: 'Change Password',
                  icon: Icons.lock_outline,
                  onTap: () {},
                ),
                _buildDivider(),
                _buildActionItem(
                  title: 'Two-Factor Authentication',
                  icon: Icons.security_outlined,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.indigo.shade50,
            child: Text(
              _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : '?',
              style: GoogleFonts.poppins(
                color: Colors.indigo.shade700,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nameController.text.isEmpty ? 'Your Name' : _nameController.text,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Personal Account • Active',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionContainer({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 64.0, right: 16.0),
      child: Divider(color: Colors.grey.shade100, height: 1, thickness: 1),
    );
  }

  Widget _buildInfoItem({
    required String title,
    required TextEditingController controller,
    required FocusNode focusNode,
    required IconData icon,
    Function(String)? onChanged,
  }) {
    return InkWell(
      onTap: () => focusNode.requestFocus(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(icon, color: Colors.grey.shade600, size: 18),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 2),
                TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: onChanged,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.edit, color: Colors.grey.shade300, size: 16),
        ],
      ),
      ),
    );
  }

  Widget _buildActionItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(icon, color: Colors.indigo.shade500, size: 18),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}

