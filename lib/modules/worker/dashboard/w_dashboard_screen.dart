import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:taskpro/common/helpers/app_helper.dart';

import 'package:taskpro/modules/changepassword/change_password_screen.dart';

import 'package:taskpro/modules/worker/dashboard/w_dashboard_controller.dart';
import 'package:taskpro/modules/worker/photoupload/task_completion_screen.dart';

import 'package:get/get.dart';
import 'package:taskpro/modules/worker/profile/profile_screen.dart';
import 'package:taskpro/services/secure_storage_service.dart';
import 'package:taskpro/theme/app_colors.dart';

import '../../../common/models/work_order_model.dart';

class WorkerDashboardScreen extends StatelessWidget {
   WorkerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WorkerDashboardController());

    final List<Widget> screens = [
      const DashboardTabScreen(),
      const TasksTabScreen(),
      TaskCompletionScreen(),
      const WorkersTabScreen(),
      const ReportsTabScreen(),
      const MoreTabScreen(),
    ];

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.background,
          // 1. END DRAWER for right-side profile slide out
          endDrawer: RightProfileDrawer(),
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            title: // Greeting Header
            Obx(() {
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
              // 2. AVATAR BUTTON IN APPBAR RIGHT SIDE TO OPEN DRAWER
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
                            child:
                            // 1. Avatar with Reactive Null Check
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
          body: Obx(
            () => AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: screens[controller.selectedIndex.value],
            ),
          ),
          bottomNavigationBar: Obx(
            () => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: controller.selectedIndex.value,
                onTap: controller.changeTab,
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                selectedItemColor: AppColors.primary,
                unselectedItemColor: AppColors.textSecondary,
                selectedFontSize: 11,
                unselectedFontSize: 11,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
                elevation: 0,
                items: [
                  BottomNavigationBarStyleItem(
                    icon: Icons.grid_view_rounded,
                    label: "Dashboard",
                  ),
                  BottomNavigationBarStyleItem(
                    icon: Icons.check_box_outlined,
                    label: "All Tasks",
                  ),
                  BottomNavigationBarStyleItem(
                    icon: Icons.people_outline_rounded,
                    label: "Task Completion",
                  ),
                  // BottomNavigationBarStyleItem(
                  //   icon: Icons.bar_chart_rounded,
                  //   label: "Reports",
                  // ),
                  // BottomNavigationBarStyleItem(
                  //   icon: Icons.more_horiz_rounded,
                  //   label: "More",
                  // ),
                ],
              ),
            ),
          ),
        ),
        // Overlay Progress Indicator
        Obx(
          () => controller.isApiLoading.value
              ? Container(
                  color: Colors.black.withValues(alpha: 0.3), // Semi-transparent backdrop
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

// Helper class for BottomNavigationBar items
class BottomNavigationBarStyleItem extends BottomNavigationBarItem {
  BottomNavigationBarStyleItem({required IconData icon, required String label})
    : super(
        icon: Icon(icon, size: 22),
        activeIcon: Icon(icon, size: 24),
        label: label,
      );
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
      
            // Section Title: Today's Overview
            const Text(
              "Today's Overview",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
      
            // 3 Column Grid: Pending, In Progress, Completed
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
      
            // 2 Column Grid: Tasks Assigned & Tasks Completed
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
      
            // Wallet Balance Card
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
      
            // Urgent Job Card Preview
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
                        onTap: () => controller.changeTab(1),
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
                    () => controller.tasks.isNotEmpty
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
                                      controller.tasks.first.title,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "${controller.tasks.first.category} • ${controller.tasks.first.worker}",
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
                                    controller.tasks.first.status,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber.shade900,
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

  // Card Widget: Top 3 Overview Metrics
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

  // Card Widget: Bottom 2 Metric Breakdown
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

class TasksTabScreen extends StatelessWidget {
  const TasksTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WorkerDashboardController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: controller.workOrderList.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final task = controller.workOrderList[index];
                  final isCompleted=false;
                  final isInProgress=false;

                  return GestureDetector(
                    onTap: () => showTaskDetails(context, task),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.textWhite),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.workOrderTitle,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${task.serviceTypeName} • ${task.managerFirstName}",
                                style: const TextStyle(
                                  fontSize: 12,
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
                              color: isCompleted
                                  ? AppColors.completed
                                  : isInProgress
                                  ? AppColors.inProgress
                                  : AppColors.pending,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              task.statusName??"Pending",
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textWhite,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showTaskDetails(BuildContext context, WorkOrderModel task) {
    Color getStatusColor() {
      switch (task.statusName) {
        case "Completed":
          return Colors.green;
        case "In Progress":
          return Colors.orange;
        default:
          return Colors.redAccent;
      }
    }

    Color getPriorityColor() {
      switch (task.priority.toLowerCase()) {
        case "high":
          return Colors.red;
        case "medium":
          return Colors.orange;
        default:
          return Colors.green;
      }
    }

    IconData getStatusIcon() {
      switch (task.statusName) {
        case "Completed":
          return Icons.check_circle;
        case "In Progress":
          return Icons.timelapse;
        default:
          return Icons.schedule;
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: .85,
          maxChildSize: .95,
          minChildSize: .55,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.textWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  /// Drag Handle
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: .12,
                        ),
                        child: const Icon(
                          Icons.assignment_outlined,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.workOrderTitle,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              "Task ID : ${task.workOrderNo}",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  /// Status + Priority
                  Row(
                    children: [
                      Chip(
                        avatar: Icon(
                          getStatusIcon(),
                          color: Colors.white,
                          size: 18,
                        ),
                        label: Text(task.statusName??"Pending"),
                        backgroundColor: getStatusColor(),
                        labelStyle: const TextStyle(color: Colors.white),
                      ),

                      const SizedBox(width: 10),

                      Chip(
                        avatar: const Icon(
                          Icons.flag,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: Text(task.priority),
                        backgroundColor: getPriorityColor(),
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  _InfoTile(
                    icon: Icons.category_outlined,
                    title: "Category",
                    value: task.serviceTypeName,
                  ),

                  const SizedBox(height: 14),

                  _InfoTile(
                    icon: Icons.person_outline,
                    title: "Assigned Worker",
                    value: task.technicianFirstName,
                  ),

                  const SizedBox(height: 14),

                  _InfoTile(
                    icon: Icons.info_outline,
                    title: "Current Status",
                    value: task.statusName??"Pending",
                  ),

                  const SizedBox(height: 30),

                  Text(
                    "Actions",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 15),

                  task.statusId==null?Row(
                    children: [
                      Expanded(
                        child: findButton(
                          title: "Accept",
                          onPressed: () {
                            Get.back();
                            final controller =
                                Get.find<WorkerDashboardController>();
                            controller.changeTab(2);
                          },
                          backgroundColor: AppColors.primaryDark,
                          icon: const Icon(
                            Icons.thumb_up,
                            color: AppColors.textWhite,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: findButton(
                          title: "Close",
                          onPressed: () {
                            Get.back();
                          },
                          backgroundColor: AppColors.error,
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.textWhite,
                          ),
                        ),
                      ),
                    ],
                  ):Text(task.statusName??"-"),

                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: .12),
            child: Icon(icon, color: AppColors.primary),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
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

class WorkersTabScreen extends StatelessWidget {
  const WorkersTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WorkerDashboardController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Active Field Team",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: controller.workers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final worker = controller.workers[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.textWhite),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              worker.name.substring(0, 1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                worker.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                worker.role,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                "0987654321",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${worker.activeTasks} Active Jobs",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            worker.status,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.amber.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ReportsTabScreen extends StatelessWidget {
  const ReportsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Performance Summary",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.textWhite),
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Completion Rate",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      "88.5%",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const LinearProgressIndicator(
                    value: 0.885,
                    minHeight: 8,
                    backgroundColor: AppColors.textWhite,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
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

class MoreTabScreen extends StatelessWidget {
  const MoreTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        const Text(
          "App Settings",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.person, color: AppColors.primary),
          title: const Text("View Full Profile"),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Scaffold.of(context).openEndDrawer(),
        ),

        ListTile(
          leading: const Icon(Icons.notifications, color: AppColors.primary),
          title: const Text("Notification Preferences"),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.help, color: AppColors.primary),
          title: const Text("Help & Support Center"),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
      ],
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
          // Drawer Blue Header
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
                    // 1. Avatar with Reactive Null Check
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

                    // 2. User Info Column Wrapped in Obx & Expanded
                    Expanded(
                      child: Obx(() {
                        final user = controller.user.value;

                        if (user == null) {
                          return const SizedBox.shrink();
                        }

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

          // Drawer Navigation Items
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
                  icon: Icons.edit_note,
                  title: "Change Password",
                  onTap: () => Get.to(() => ChangePasswordScreen()),
                ),
                _buildDrawerItem(
                  icon: Icons.account_balance_wallet_outlined,
                  title: "Wallet & Earnings",
                  trailingText:
                      "\$${controller.walletBalance.value.toStringAsFixed(0)}",
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

          // Logout Button
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
