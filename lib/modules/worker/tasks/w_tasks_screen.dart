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
              child: Obx(
                () => controller.isApiLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: controller.workOrderList.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final task = controller.workOrderList[index];
                          controller.fetchWorkOrderHoursList(task.id);
                          return GestureDetector(
                            onTap: () => _showTaskDetails(context, task, controller),
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
                                      color: Common.getStatusColor(Common.getStatusColorName(task.statusId, controller.workOrderStatusList)),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      Common.getStatusText(task.statusId, controller.workOrderStatusList),
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
      ),
    );
  }

  void _showTaskDetails(BuildContext context, WorkOrderModel task, WorkerTasksController controller) {
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
                        backgroundColor: AppColors.primary.withValues(alpha: .12),
                        child: const Icon(Icons.assignment_outlined, color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(task.workOrderTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text("Work Order No : ${task.workOrderNo}", style: TextStyle(color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Chip(
                        avatar: Icon(Common.getStatusIcon(Common.getStatusText(task.statusId, controller.workOrderStatusList)), color: Colors.white, size: 18),
                        label: Text(Common.getStatusText(task.statusId, controller.workOrderStatusList)),
                        backgroundColor: Common.getStatusColor(Common.getStatusColorName(task.statusId, controller.workOrderStatusList)),
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Chip(
                        avatar: const Icon(Icons.flag, color: Colors.white, size: 18),
                        label: Text(task.priority),
                        backgroundColor: Common.getPriorityColor(task.priority),
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  _InfoTile(icon: Icons.category_outlined, title: "Category", value: task.serviceTypeName),
                  const SizedBox(height: 14),
                  _InfoTile(icon: Icons.person_outline, title: "Assigned Worker", value: task.technicianFirstName),
                  const SizedBox(height: 14),
                  _InfoTile(icon: Icons.info_outline, title: "Current Status", value: Common.getStatusText(task.statusId, controller.workOrderStatusList)),
                  const SizedBox(height: 25),
                  
                  Text(
                    "Timing Details",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    final timing = controller.workorder_hour_timing.value;
                    if (timing == null) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final dateFormat = DateFormat('MMM dd, yyyy - hh:mm a');
                    
                    return Column(
                      children: [
                        _InfoTile(
                          icon: Icons.calendar_today_outlined,
                          title: "Scheduled Range",
                          value: "${timing.scheduledStart != null ? dateFormat.format(timing.scheduledStart!) : 'N/A'} \nto ${timing.scheduledEnd != null ? dateFormat.format(timing.scheduledEnd!) : 'N/A'}",
                        ),
                        const SizedBox(height: 14),
                        _InfoTile(
                          icon: Icons.timer_outlined,
                          title: "Actual Execution",
                          value: "Start: ${timing.actualStartAt != null ? dateFormat.format(timing.actualStartAt!) : 'Not Started'}\nEnd: ${timing.actualCompletedAt != null ? dateFormat.format(timing.actualCompletedAt!) : 'Pending'}",
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _InfoTile(
                                icon: Icons.more_time,
                                title: "Est. Hours",
                                value: timing.estimatedHours ?? "0",
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _InfoTile(
                                icon: Icons.history_toggle_off,
                                title: "Actual Hours",
                                value: timing.actualHours ?? "0",
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 25),
                  task.statusId == 13?
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text("Actions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: findButton(
                            title: "Accept",
                            onPressed: () async{
                              Get.back();
                              await controller.acceptWorkOrderApi(task.id,task.workOrderNo);
                              Get.offAll(() => const WorkerDashboardScreen());
                            },
                            backgroundColor: AppColors.primaryDark,
                            icon: const Icon(Icons.thumb_up, color: AppColors.textWhite),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: findButton(
                            title: "Close",
                            onPressed: () => Get.back(),
                            backgroundColor: AppColors.error,
                            icon: const Icon(Icons.close, color: AppColors.textWhite),
                          ),
                        ),
                      ],
                    ),
                  ],):findButton(title: "Proceed",backgroundColor: AppColors.primary,
                      onPressed: (){
                        Get.back();
                        Get.to(() => const TaskCompletionScreen());
                      }),

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
  const _InfoTile({required this.icon, required this.title, required this.value});

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
                Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                const SizedBox(height: 3),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
