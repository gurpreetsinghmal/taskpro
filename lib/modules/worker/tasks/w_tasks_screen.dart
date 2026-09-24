import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:taskpro/common/helpers/app_helper.dart';
import 'package:taskpro/common/models/work_order_model.dart';
import 'package:taskpro/modules/worker/dashboard/w_dashboard_screen.dart';
import 'package:taskpro/modules/worker/photoupload/task_completion_screen.dart';
import 'package:taskpro/modules/worker/tasks/w_tasks_controller.dart';
import 'package:taskpro/theme/app_colors.dart';

import '../../../common/helpers/helper_methods.dart';

class WorkerTasksScreen extends StatelessWidget {
  const WorkerTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WorkerTasksController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          "All Tasks",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isApiLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.workOrderList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "No Work Orders Found",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: controller.workOrderList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),

                  itemBuilder: (context, index) {
                    final task = controller.workOrderList[index];

                    final statusName = Common.getStatusColorName(
                      task.statusId,
                      controller.workOrderStatusList,
                    );

                    final statusText = Common.getStatusText(
                      task.statusId,
                      controller.workOrderStatusList,
                    );

                    final statusColor = Common.getStatusColor(statusName);

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),

                        onTap: () async {
                          _showTaskDetails(context, task, controller);
                        },

                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),

                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                // Status Accent
                                Container(
                                  width: 5,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(18),
                                      bottomLeft: Radius.circular(18),
                                    ),
                                  ),
                                ),

                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),

                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                      children: [
                                        // Header Row
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,

                                          children: [
                                            // Work Order Icon
                                            Container(
                                              height: 44,
                                              width: 44,

                                              decoration: BoxDecoration(
                                                color: statusColor.withOpacity(
                                                  0.10,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(13),
                                              ),

                                              child: Icon(
                                                Icons.assignment_rounded,
                                                color: statusColor,
                                                size: 23,
                                              ),
                                            ),

                                            const SizedBox(width: 12),

                                            // Title + Details
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,

                                                children: [
                                                  Text(
                                                    task.workOrderTitle,

                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,

                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),

                                                  const SizedBox(height: 5),

                                                  Text(
                                                    "${task.serviceTypeName} • "
                                                    "${task.managerFirstName}",

                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,

                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            const SizedBox(width: 8),

                                            // Arrow
                                            Icon(
                                              Icons.chevron_right_rounded,
                                              color: Colors.grey.shade400,
                                              size: 24,
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 14),

                                        // Bottom Row
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,

                                          children: [
                                            // Status Badge
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),

                                              decoration: BoxDecoration(
                                                color: statusColor.withOpacity(
                                                  0.10,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),

                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,

                                                children: [
                                                  Container(
                                                    height: 7,
                                                    width: 7,

                                                    decoration: BoxDecoration(
                                                      color: statusColor,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),

                                                  const SizedBox(width: 6),

                                                  Text(
                                                    statusText,

                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: statusColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),

                                              decoration: BoxDecoration(
                                                color: statusColor.withOpacity(
                                                  0.10,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),

                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,

                                                children: [
                                                  Container(
                                                    height: 7,
                                                    width: 7,

                                                    decoration: BoxDecoration(
                                                      color: statusColor,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),

                                                  const SizedBox(width: 6),

                                                  Text(
                                                    "WO No : ${task.workOrderNo}",

                                                    style: TextStyle(
                                                      fontSize: 10,
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
                                      ],
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
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskDetails(
    BuildContext context,
    WorkOrderModel task,
    WorkerTasksController controller,
  ) {
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
                              "Work Order No : ${task.workOrderNo}",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Chip(
                        avatar: Icon(
                          Common.getStatusIcon(
                            Common.getStatusText(
                              task.statusId,
                              controller.workOrderStatusList,
                            ),
                          ),
                          color: Colors.white,
                          size: 18,
                        ),
                        label: Text(
                          Common.getStatusText(
                            task.statusId,
                            controller.workOrderStatusList,
                          ),
                        ),
                        backgroundColor: Common.getStatusColor(
                          Common.getStatusColorName(
                            task.statusId,
                            controller.workOrderStatusList,
                          ),
                        ),
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
                        backgroundColor: Common.getPriorityColor(task.priority),
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
                    value: task.technicianFirstName+" "+task.technicianLastName,
                  ),
                  const SizedBox(height: 14),
                  _InfoTile(
                    icon: Icons.person_outline,
                    title: "Lead Title",
                    value: task.leadTitle,
                  ),
                  const SizedBox(height: 14),
                   _InfoTile(
                    icon: Icons.person_outline,
                    title: "Manager",
                    value: '${task.managerFirstName} ${task.managerLastName}',
                  ),
                  const SizedBox(height: 14),
                  _InfoTile(
                    icon: Icons.person_outline,
                    title: "Manager Contact",
                    value: '${task.managerEmail} ${task.managerPhoneNumber}',
                  ),
                  const SizedBox(height: 14),
                  _InfoTile(
                    icon: Icons.person_outline,
                    title: "Scope of Work",
                    value: task.scopeOfWork??"-",
                  ),

                  const SizedBox(height: 25),

                  Text(
                    "Work Estimation Details",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InfoTile(
                    icon: Icons.person_outline,
                    title: "Rate Type",
                    value: task.rateType == null ? '-' : task.rateType.toString() == '1' ? 'Hourly rate' : task.rateType.toString() == '2' ? 'Flat rate' : 'NA',
                  ),
                  const SizedBox(height: 12),
                  _InfoTile(
                    icon: Icons.person_outline,
                    title: "Rate Value (in \$)",
                    value:task.rateValue),
                  const SizedBox(height: 12),
                  _InfoTile(
                      icon: Icons.person_outline,
                      title: "Max Hours",
                      value:task.maxHours),
                  const SizedBox(height: 12),
                  _InfoTile(
                      icon: Icons.person_outline,
                      title: "Approximate Hours To Complete",
                      value:task.approximateHoursToComplete),
                  const SizedBox(height: 12),
                  _InfoTile(
                      icon: Icons.person_outline,
                      title: "Scheduled ETA From",
                      value:Common.formatToLocalUS(task.scheduledEtaFrom)),
                  const SizedBox(height: 12),
                  _InfoTile(
                      icon: Icons.person_outline,
                      title: "Scheduled ETA To",
                      value:Common.formatToLocalUS(task.scheduledEtaTo)),
                  const SizedBox(height: 12),
                  _InfoTile(
                      icon: Icons.person_outline,
                      title: "Hard Start Time",
                      value:Common.formatToLocalUS(task.hardStartTime)),
                  const SizedBox(height: 25),


                  const SizedBox(height: 25),
                  task.statusId == 13
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Actions",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                Expanded(
                                  child: findButton(
                                    title: "Accept",
                                    onPressed: () async {
                                      Get.back();
                                      await controller.acceptWorkOrderApi(
                                        task.id,
                                        task.workOrderNo,
                                      );
                                      Get.offAll(
                                        () => const WorkerDashboardScreen(),
                                      );
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
                                    onPressed: () => Get.back(),
                                    backgroundColor: AppColors.error,
                                    icon: const Icon(
                                      Icons.close,
                                      color: AppColors.textWhite,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : findButton(
                          title: "Proceed",
                          backgroundColor: AppColors.primary,
                          onPressed: () {
                            Get.back();
                            Get.to(() => const TaskCompletionScreen());
                          },
                        ),

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
                    fontSize: 14,
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
