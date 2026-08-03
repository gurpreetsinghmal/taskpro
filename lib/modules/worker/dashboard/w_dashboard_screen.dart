import 'package:flutter/material.dart';
import 'package:taskpro/modules/login/login_screen.dart';
import 'package:taskpro/modules/splash/splash_screen.dart';
import 'package:taskpro/modules/worker/dashboard/w_dashboard_controller.dart';
import 'package:taskpro/services/secure_storage_service.dart';
import 'package:get/get.dart';

class WorkerDashboardScreen extends StatelessWidget {
   WorkerDashboardScreen({super.key});



  @override
  Widget build(BuildContext context) {



    return Scaffold(
      drawer: WorkerDrawer(),
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false, // Hides the default back icon / hamburger button
        actions: [
          // Builder provides the context needed to open the drawer
          Builder(
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: () {
                    // Opens the drawer from the right side tap
                    Scaffold.of(context).openDrawer();
                  },
                  child: const CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(
                      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=300',
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text("Dashboard Screen Content"),
      ),
    );
  }
}


class WorkerDrawer extends StatelessWidget {
   WorkerDrawer({super.key});
  final controller = Get.put(WorkerDashboardController());
  @override
  Widget build(BuildContext context) {


    final primaryColor = AppColors.primary;

    return Drawer(
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(25)),
      ),
      child: Column(
        children: [
          // 1. HEADER SECTION
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor,
                  primaryColor.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(24),
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture & Edit Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const CircleAvatar(
                            radius: 36,
                            backgroundImage: NetworkImage(
                              'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=300',
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              // TODO: Navigate to Edit Profile / Change Photo
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.amber,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Status Tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: const Row(
                        children: [
                          CircleAvatar(
                            radius: 4,
                            backgroundColor: Colors.greenAccent,
                          ),
                          SizedBox(width: 6),
                          Text(
                            "Active",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Worker Name
                Text(
                  controller.name.value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                // Mobile Number
                 Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 14,
                      color: Colors.white70,
                    ),
                    SizedBox(width: 6),
                    Text(
                      controller.role.value,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                 Row(
                  children: [
                    Icon(
                      Icons.email,
                      size: 14,
                      color: Colors.white70,
                    ),
                    SizedBox(width: 6),
                    Text(
                      controller.email.value,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. DRAWER MENU ITEMS
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              children: [
                _buildSectionHeader("Account Management"),
                _buildDrawerItem(
                  icon: Icons.person_outline_rounded,
                  title: "My Profile",
                  subtitle: "View and update basic info",
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to Profile
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.edit_note_rounded,
                  title: "Edit Worker Details",
                  subtitle: "Skills, address & contact",
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to Edit Details
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.assignment_outlined,
                  title: "My Tasks & History",
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1, thickness: 0.8),
                ),

                _buildSectionHeader("Support & App"),
                _buildDrawerItem(
                  icon: Icons.help_outline_rounded,
                  title: "Help & Support",
                  subtitle: "FAQs & customer service",
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to Help
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.privacy_tip_outlined,
                  title: "Privacy & Terms",
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),

          // 3. LOGOUT & FOOTER SECTION
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Column(
              children: [
                // Logout Button
                InkWell(
                  onTap: () => _showLogoutDialog(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          color: Colors.red.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Log Out",
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Version Info
                Text(
                  "TaskPro Worker v1.0.0",
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget: Section Header
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 8, bottom: 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // Helper Widget: Drawer Item Tile
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      dense: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: Colors.blue.shade700,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 11,
        ),
      )
          : null,
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: 18,
        color: Colors.grey,
      ),
    );
  }

  // Helper Function: Show Logout Confirmation Dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out of your worker account?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context); // Close Dialog
              Navigator.pop(context); // Close Drawer
              await SecureStorageService.instance.deleteAll();

              Get.offAll(() => const LoginScreen());
            },
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}