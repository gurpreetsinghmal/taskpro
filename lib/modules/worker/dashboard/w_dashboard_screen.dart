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
            actions: [AppCircleMenu(controller: controller)],
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

class AppCircleMenu extends StatelessWidget {
  const AppCircleMenu({super.key, required this.controller});

  final WorkerDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Builder(
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
                    border: Border.all(color: AppColors.primary, width: 2),
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
                    final hasPhoto =
                        user.photo != null && user.photo!.isNotEmpty;
                    return CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.infoLight,
                      backgroundImage: hasPhoto
                          ? NetworkImage(user.photo!)
                          : null,
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
                      border: Border.all(color: Colors.white, width: 2),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          Obx(() {
            final isSynced = controller.syncStatus.value == true;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isSynced
                    ? Colors.green.withValues(alpha: 0.08)
                    : Colors.orange.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSynced
                      ? Colors.green.withValues(alpha: 0.25)
                      : Colors.orange.withValues(alpha: 0.30),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSynced
                          ? Colors.green.withValues(alpha: 0.15)
                          : Colors.orange.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSynced
                          ? Icons.cloud_done_rounded
                          : Icons.cloud_off_rounded,
                      color: isSynced
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                      size: 22,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSynced ? 'Data synced' : 'Sync pending',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isSynced
                                ? Colors.green.shade800
                                : Colors.orange.shade800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isSynced
                              ? 'Your local device data is up to date'
                              : 'Your local data has not been synced yet',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status indicator
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: isSynced ? Colors.green : Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),

          _buildTodaysOverviewSection(controller),

          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================================================================
                // HEADER
                // ================================================================
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 4, 4, 4),
                  child: Row(
                    children: [
                      // Section Icon
                      Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.78),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.20),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.assignment_turned_in_outlined,
                          size: 22,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Title
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assigned Jobs',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                letterSpacing: -0.2,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Your current work orders',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // View All
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () async {
                            await Get.to(() => const WorkerTasksScreen());

                            controller.fetchSyncStatus();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.primary.withValues(
                                  alpha: 0.08,
                                ),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'View All',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 11,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ================================================================
                // WORK ORDERS
                // ================================================================
                Obx(() {
                  final assignedWorkOrders = controller.workOrderList
                      .where((workOrder) => workOrder.statusId == 13)
                      .toList();

                  // ================================================================
                  // EMPTY STATE
                  // ================================================================
                  if (assignedWorkOrders.isEmpty) {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 28,
                      ),
                      decoration: BoxDecoration(

                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 68,
                            width: 68,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withValues(
                                  alpha: 0.08,
                                ),
                              ),
                            ),
                            child: const Icon(
                              Icons.assignment_late_outlined,
                              size: 31,
                              color: AppColors.primary,
                            ),
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            'No Assigned Jobs',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),

                          const SizedBox(height: 5),

                          const Text(
                            'New work orders assigned to you\nwill appear here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11.5,
                              height: 1.45,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // ================================================================
                  // ASSIGNED WORK ORDERS
                  // ================================================================
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: assignedWorkOrders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),

                    itemBuilder: (context, index) {
                      final workOrder = assignedWorkOrders[index];

                      final statusName = Common.getStatusColorName(
                        workOrder.statusId,
                        controller.workOrderStatusList,
                      );

                      final statusText = Common.getStatusText(
                        workOrder.statusId,
                        controller.workOrderStatusList,
                      );

                      final statusColor = Common.getStatusColor(statusName);

                      final technicianName =
                          [
                                workOrder.technicianFirstName,
                                workOrder.technicianMiddleName,
                                workOrder.technicianLastName,
                              ]
                              .where(
                                (name) =>
                                    name != null && name.trim().isNotEmpty,
                              )
                              .join(' ');

                      // ============================================================
                      // WORK ORDER CARD
                      // ============================================================
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.10),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.055),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Column(
                            children: [
                              // ======================================================
                              // TOP BLUE ACCENT
                              // ======================================================
                              Container(
                                height: 4,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primary.withValues(alpha: 0.55),
                                    ],
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  14,
                                  14,
                                  14,
                                  13,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // =================================================
                                    // WORK ORDER HEADER
                                    // =================================================
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Work order icon
                                        Container(
                                          height: 45,
                                          width: 45,
                                          decoration: BoxDecoration(
                                            color: statusColor.withValues(
                                              alpha: 0.09,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              13,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.handyman_outlined,
                                            color: statusColor,
                                            size: 23,
                                          ),
                                        ),

                                        const SizedBox(width: 11),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [


                                              // Title
                                              Text(
                                                workOrder.workOrderTitle,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  height: 1.25,
                                                  fontWeight: FontWeight.w800,
                                                  color: AppColors.primary,
                                                ),
                                              ),

                                              const SizedBox(height: 5),

                                              // Service + manager
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons
                                                        .miscellaneous_services_outlined,
                                                    size: 13,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      '${workOrder.serviceTypeName}'
                                                      '  •  '
                                                      '${workOrder.managerFirstName}',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 10.5,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: AppColors
                                                            .textSecondary,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 13),

                                    // =================================================
                                    // TECHNICIAN ASSIGNMENT
                                    // =================================================
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 11,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.035,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.06,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 32,
                                            width: 32,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(9),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.04),
                                                  blurRadius: 5,
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.engineering_outlined,
                                              size: 18,
                                              color: statusColor,
                                            ),
                                          ),

                                          const SizedBox(width: 9),

                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'ASSIGNED TECHNICIAN',
                                                  style: TextStyle(
                                                    fontSize: 8.5,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 0.6,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  technicianName.isEmpty
                                                      ? 'Not specified'
                                                      : technicianName,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 11.5,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Assigned indicator
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 7,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: statusColor.withValues(
                                                alpha: 0.09,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  height: 6,
                                                  width: 6,
                                                  decoration: BoxDecoration(
                                                    color: statusColor,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  'Assigned',
                                                  style: TextStyle(
                                                    fontSize: 8.5,
                                                    fontWeight: FontWeight.w700,
                                                    color: statusColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    // =================================================
                                    // BOTTOM INFORMATION
                                    // =================================================
                                    Row(
                                      children: [
                                        // Status
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Container(
                                                height: 27,
                                                width: 27,
                                                decoration: BoxDecoration(
                                                  color: statusColor.withValues(
                                                    alpha: 0.09,
                                                  ),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons
                                                      .radio_button_checked_rounded,
                                                  size: 13,
                                                  color: statusColor,
                                                ),
                                              ),

                                              const SizedBox(width: 7),

                                              Flexible(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'STATUS',
                                                      style: TextStyle(
                                                        fontSize: 8,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        letterSpacing: 0.5,
                                                        color: AppColors
                                                            .textSecondary,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 1),
                                                    Text(
                                                      statusText,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 10.5,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: statusColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Divider
                                        Container(
                                          height: 28,
                                          width: 1,
                                          color: Colors.grey.withValues(
                                            alpha: 0.12,
                                          ),
                                        ),

                                        const SizedBox(width: 12),

                                        // Work Order
                                        Row(
                                          children: [
                                            Container(
                                              height: 27,
                                              width: 27,
                                              decoration: BoxDecoration(
                                                color: AppColors.primary
                                                    .withValues(alpha: 0.07),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons
                                                    .confirmation_number_outlined,
                                                size: 14,
                                                color: AppColors.primary,
                                              ),
                                            ),

                                            const SizedBox(width: 7),

                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'WORK ORDER',
                                                  style: TextStyle(
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 0.5,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                ),
                                                const SizedBox(height: 1),
                                                Text(
                                                  workOrder.workOrderNo,
                                                  style: const TextStyle(
                                                    fontSize: 10.5,
                                                    fontWeight: FontWeight.w800,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  // =======================================================
  // TODAY'S OVERVIEW SECTION (Redesigned)
  // =======================================================

  Widget _buildTodaysOverviewSection(WorkerDashboardController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Dashboard Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Today's Overview",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),

            // Live Pulse Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.6),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    "LIVE UPDATES",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 2. Primary Status Grid (3 Cards: Pending, In Progress, Submitted)
        Obx(
          () => Row(
            children: [
              Expanded(
                child: _buildPrimaryOverviewCard(
                  title: "Pending",
                  value: controller.pendingCount.value,
                  icon: Icons.timer_outlined,
                  accentColor: const Color(0xFFF59E0B), // Warm Gold/Amber
                  trendText: "Queue",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildPrimaryOverviewCard(
                  title: "In Progress",
                  value: controller.inProgressCount.value,
                  icon: Icons.bolt_rounded,
                  accentColor: const Color(0xFF3B82F6), // Vibrant Blue
                  trendText: "Active",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildPrimaryOverviewCard(
                  title: "Submitted",
                  value: controller.completedCount.value,
                  icon: Icons.verified_outlined,
                  accentColor: const Color(0xFF10B981), // Emerald Green
                  trendText: "Done",
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 3. Secondary Performance & Workload Metrics
        Obx(
          () => Row(
            children: [
              Expanded(
                child: _buildSecondaryMetricCard(
                  title: "Assigned",
                  value: controller.assignedCount.value,
                  icon: Icons.assignment_outlined,
                  accentColor: const Color(0xFF6366F1), // Indigo
                  subtitle: "Total Workload",
                  totalForRatio: 1,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSecondaryMetricCard(
                  title: "Completed",
                  value: controller.todayCompletedCount.value,
                  icon: Icons.task_alt_rounded,
                  accentColor: const Color(0xFF06B6D4), // Cyan
                  subtitle: "Finished Today",
                  totalForRatio: controller.assignedCount.value,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =======================================================
  // Helper: Primary Overview Card (Top Row)
  // =======================================================
  Widget _buildPrimaryOverviewCard({
    required String title,
    required int value,
    required IconData icon,
    required Color accentColor,
    required String trendText,
  }) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle Radial Background Glow Accent
          Positioned(
            bottom: -20,
            right: -20,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Badge & Micro Pill Tag
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, size: 16, color: accentColor),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        trendText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Animated Number Display
                _buildAnimatedCounter(
                  value: value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),

                // Label
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryMetricCard({
    required String title,
    required int value,
    required IconData icon,
    required Color accentColor,
    required String subtitle,
    int? totalForRatio,
  }) {
    // Calculate completion percentage if total exists
    double progressPercentage = 0.0;
    if (totalForRatio != null && totalForRatio > 0) {
      progressPercentage = (value / totalForRatio).clamp(0.0, 1.0);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.7),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon Badge
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 18, color: accentColor),
              ),
              const SizedBox(width: 10),

              // Number and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAnimatedCounter(
                      value: value,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Progress Bar (Renders if totalForRatio is provided)
          if (totalForRatio != null) ...[
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textHint,
                      ),
                    ),
                    Text(
                      "${(progressPercentage * 100).toInt()}%",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progressPercentage,
                    minHeight: 4,
                    backgroundColor: accentColor.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnimatedCounter({required int value, required TextStyle style}) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.25),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: Text('$value', key: ValueKey<int>(value), style: style),
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
                      final hasPhoto =
                          user.photo != null && user.photo!.isNotEmpty;
                      return CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.infoLight,
                        backgroundImage: hasPhoto
                            ? NetworkImage(user.photo!)
                            : null,
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
                ),
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
