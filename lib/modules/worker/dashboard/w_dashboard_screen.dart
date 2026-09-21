import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:taskpro/common/helpers/helper_methods.dart';
import 'package:taskpro/modules/changepassword/change_password_screen.dart';
import 'package:taskpro/modules/worker/dashboard/w_dashboard_controller.dart';
import 'package:taskpro/modules/worker/tasks/w_tasks_screen.dart';
import 'package:get/get.dart';
import 'package:taskpro/modules/worker/profile/profile_screen.dart';
import 'package:taskpro/services/secure_storage_service.dart';
import 'package:taskpro/theme/app_colors.dart';

class WorkerDashboardScreen extends StatelessWidget {
  const WorkerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WorkerDashboardController());

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.background,
          endDrawer: RightProfileDrawer(),
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            title: Obx(() {
              final user = controller.user.value;
              final name = user?.name;
              return Row(
                children: [
                  const Text(
                    "Hello, ",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (name == null || name.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: LoadingAnimationWidget.progressiveDots(
                        color: AppColors.primary,
                        size: 28,
                      ),
                    )
                  else
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  const SizedBox(width: 8),
                  const Text("👋", style: TextStyle(fontSize: 22)),
                ],
              );
            }),
            actions: [
              Builder(
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: GestureDetector(
                      onTap: () => Scaffold.of(context).openEndDrawer(),
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            child: Obx(() {
                              final user = controller.user.value;
                              if (user == null) {
                                return const CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.infoLight,
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                );
                              }
                              final initial = user.firstName.isNotEmpty
                                  ? user.firstName[0].toUpperCase()
                                  : '?';
                              final hasPhoto = user.photo != null && user.photo!.isNotEmpty;
                              return CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.infoLight,
                                backgroundImage: hasPhoto ? NetworkImage(user.photo!) : null,
                                child: !hasPhoto
                                    ? Text(
                                        initial,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      )
                                    : null,
                              );
                            }),
                          ),
                          Positioned(
                            right: 2,
                            bottom: 2,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: const DashboardTabScreen(),
        ),
        Obx(
          () => controller.isApiLoading.value
              ? Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class DashboardTabScreen extends StatelessWidget {
  const DashboardTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WorkerDashboardController>();

    return RefreshIndicator(
      onRefresh: controller.getdata,
      color: Colors.white,
      backgroundColor: Colors.blue,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8,
        ),
        children: [
          const SizedBox(height: 20),
          const Text(
            "Today's Overview",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: _buildOverviewCard(
                    title: "Pending",
                    value: controller.pendingCount.value,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildOverviewCard(
                    title: "In Progress",
                    value: controller.inProgressCount.value,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildOverviewCard(
                    title: "Submitted",
                    value: controller.completedCount.value,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: _buildSecondaryCard(
                    title: "Tasks Assigned",
                    value: controller.assignedCount.value,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSecondaryCard(
                    title: "Tasks Completed",
                    value: controller.todayCompletedCount.value,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.textWhite),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Wallet Balance",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Obx(
                      () => Text(
                        "\$${controller.walletBalance.value.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showWithdrawDialog(context, controller),
                  icon: const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Withdraw",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 2,
                    shadowColor: AppColors.primary.withValues(alpha: 0.3),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.textWhite),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "Priority Job",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Get.to(() => const WorkerTasksScreen()),
                      child: const Text(
                        "View All >",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Obx(
                  () => controller.workOrders.isNotEmpty
                      ? Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.textWhite,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    controller.workOrders.first.workOrderTitle,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${controller.workOrders.first.serviceTypeName} • ${controller.workOrders.first.managerFirstName}",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  Common.getStatusText(controller.workOrders.first.statusId, controller.workOrderStatusList),

                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color:Common.getStatusColor(Common.getStatusColorName(controller.workOrders.first.statusId, controller.workOrderStatusList)),
                                     ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildOverviewCard({required String title, required int value}) {
    final formattedValue = value < 10 ? '0$value' : '$value';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.textWhite.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.textWhite),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formattedValue,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryCard({required String title, required int value}) {
    final formattedValue = value < 10 ? '0$value' : '$value';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.textWhite.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.textWhite),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formattedValue,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog(
    BuildContext context,
    WorkerDashboardController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.account_balance_wallet, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              "Withdraw Funds",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Available Balance: \$${controller.walletBalance.value.toStringAsFixed(2)}",
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Amount (\$)",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              controller.withdrawWallet(50.0);
              Navigator.pop(context);
              Get.snackbar(
                "Payout Initiated",
                "Successfully transferred \$50.00 to your bank.",
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text("Confirm", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class RightProfileDrawer extends StatelessWidget {
  RightProfileDrawer({super.key});

  final controller = Get.find<WorkerDashboardController>();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Active Session",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Obx(() {
                      final user = controller.user.value;
                      if (user == null) {
                        return const CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.infoLight,
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      }
                      final initial = user.firstName.isNotEmpty
                          ? user.firstName[0].toUpperCase()
                          : '?';
                      final hasPhoto = user.photo != null && user.photo!.isNotEmpty;
                      return CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.infoLight,
                        backgroundImage: hasPhoto ? NetworkImage(user.photo!) : null,
                        child: !hasPhoto
                            ? Text(
                                initial,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              )
                            : null,
                      );
                    }),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() {
                        final user = controller.user.value;
                        if (user == null) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (user.currentRole.isNotEmpty)
                              Text(
                                user.currentRole,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            Text(
                              user.email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              user.phoneNumber,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 12, top: 8, bottom: 6),
                  child: Text(
                    "WORKER MENU",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                _buildDrawerItem(
                  icon: Icons.person_outline,
                  title: "My Profile",
                  onTap: () => Get.to(() => WorkerProfileScreen()),
                ),
                _buildDrawerItem(
                  icon: Icons.check_box_outlined,
                  title: "All Tasks",
                  onTap: () => Get.to(() => const WorkerTasksScreen()),
                ),
                _buildDrawerItem(
                  icon: Icons.edit_note,
                  title: "Change Password",
                  onTap: () => Get.to(() => ChangePasswordScreen()),
                ),
                _buildDrawerItem(
                  icon: Icons.account_balance_wallet_outlined,
                  title: "Wallet & Earnings",
                  trailingText: "\$${controller.walletBalance.value.toStringAsFixed(0)}",
                  onTap: () => Navigator.pop(context),
                ),
                const Divider(height: 24),
                const Padding(
                  padding: EdgeInsets.only(left: 12, bottom: 6),
                  child: Text(
                    "SUPPORT & HELP",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                _buildDrawerItem(
                  icon: Icons.help_outline,
                  title: "Help & Contact Support",
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerItem(
                  icon: Icons.security,
                  title: "Privacy & Guidelines",
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                elevation: 0,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                final storage = SecureStorageService.instance;
                storage.loggedOut();
              },
              icon: Icon(Icons.logout, color: Colors.red.shade700, size: 18),
              label: Text(
                "Log Out Account",
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      dense: true,
      leading: Icon(icon, color: AppColors.primary, size: 20),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: AppColors.primary,
        ),
      ),
      trailing: trailingText != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                trailingText,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            )
          : const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textSecondary,
            ),
    );
  }
}
