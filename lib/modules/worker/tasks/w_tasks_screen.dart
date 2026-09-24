import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:taskpro/common/helpers/app_helper.dart';
import 'package:taskpro/common/helpers/helper_methods.dart';
import 'package:taskpro/common/models/work_order_model.dart';
import 'package:taskpro/modules/worker/dashboard/w_dashboard_screen.dart';
import 'package:taskpro/modules/worker/photoupload/task_completion_screen.dart';
import 'package:taskpro/modules/worker/tasks/w_tasks_controller.dart';
import 'package:taskpro/theme/app_colors.dart';

class WorkerTasksScreen extends StatefulWidget {
  const WorkerTasksScreen({super.key});

  @override
  State<WorkerTasksScreen> createState() => _WorkerTasksScreenState();
}

class _WorkerTasksScreenState extends State<WorkerTasksScreen> {
  final WorkerTasksController controller = Get.put(WorkerTasksController());

  final TextEditingController searchController = TextEditingController();

  String selectedFilter = "All";

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<WorkOrderModel> get filteredTasks {
    final query = searchController.text.trim().toLowerCase();

    return controller.workOrderList.where((task) {
      final matchesSearch =
          query.isEmpty ||
          task.workOrderTitle.toLowerCase().contains(query) ||
          task.workOrderNo.toString().toLowerCase().contains(query) ||
          task.serviceTypeName.toLowerCase().contains(query) ||
          "${task.managerFirstName} ${task.managerLastName}"
              .toLowerCase()
              .contains(query);

      if (!matchesSearch) {
        return false;
      }

      if (selectedFilter == "All") {
        return true;
      }
      if (selectedFilter == task.statusName?.toString()) {
        return true;
      }

      final statusText = Common.getStatusText(
        task.statusId,
        controller.workOrderStatusList,
      );

      return statusText.toLowerCase() == selectedFilter.toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,

        titleSpacing: 20,

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "All Work Orders",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 3),
            Text(
              "Stay on top of your work orders",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),

        // actions: [
        //   Container(
        //     margin: const EdgeInsets.only(right: 18),
        //     height: 44,
        //     width: 44,
        //     decoration: BoxDecoration(
        //       color: Colors.white,
        //       borderRadius: BorderRadius.circular(14),
        //       boxShadow: [
        //         BoxShadow(
        //           color: Colors.black.withOpacity(.05),
        //           blurRadius: 12,
        //           offset: const Offset(0, 4),
        //         ),
        //       ],
        //     ),
        //     child: Stack(
        //       alignment: Alignment.center,
        //       children: [
        //         const Icon(
        //           Icons.notifications_none_rounded,
        //           color: AppColors.primary,
        //           size: 25,
        //         ),
        //         Positioned(
        //           right: 9,
        //           top: 8,
        //           child: Container(
        //             height: 8,
        //             width: 8,
        //             decoration: BoxDecoration(
        //               color: Colors.redAccent,
        //               shape: BoxShape.circle,
        //               border: Border.all(color: Colors.white, width: 1.5),
        //             ),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ],
      ),

      body: Column(
        children: [
          const SizedBox(height: 15),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _SearchBox(
              controller: searchController,
              onChanged: (_) {
                setState(() {});
              },
            ),
          ),

          const SizedBox(height: 15),

          // Filters
          Obx(() => _buildFilters()),
          const SizedBox(height: 18),

          Expanded(
            child: Obx(() {
              if (controller.isApiLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final tasks = filteredTasks;

              if (tasks.isEmpty) {
                return _EmptyTasks();
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                physics: const BouncingScrollPhysics(),
                itemCount: tasks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 13),
                itemBuilder: (context, index) {
                  return _TaskCard(
                    task: tasks[index],
                    controller: controller,
                    onTap: () async {
                      if (!context.mounted) return;

                      _showTaskDetails(context, tasks[index]);
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final filters = [
      "All",
      ...controller.workOrderStatusList
          .map((e) => e.name ?? "")
          .where((name) => name.isNotEmpty),
    ];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) {
          final filter = filters[index];
          final selected = selectedFilter == filter;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedFilter = filter;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(.22),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                filter,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.primary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }



  void _showTaskDetails(BuildContext context, WorkOrderModel task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(.35),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: .90,
          minChildSize: .60,
          maxChildSize: .96,
          snap: true,
          snapSizes: const [.90, .96],
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: ListView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 35),
                children: [
                  // Handle
                  Center(
                    child: Container(
                      height: 5,
                      width: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  _buildDetailHeader(task),

                  const SizedBox(height: 22),

                  _buildStatusPriority(task),

                  const SizedBox(height: 22),

                  _sectionTitle(
                    icon: Icons.assignment_outlined,
                    title: "Work Information",
                  ),

                  const SizedBox(height: 12),

                  _InfoTile(
                    icon: Icons.category_outlined,
                    title: "Service Type",
                    value: task.serviceTypeName,
                  ),

                  const SizedBox(height: 10),

                  _InfoTile(
                    icon: Icons.engineering_outlined,
                    title: "Assigned Worker",
                    value:
                        "${task.technicianFirstName} ${task.technicianLastName}",
                  ),

                  const SizedBox(height: 10),



                  const SizedBox(height: 10),

                  _InfoTile(
                    icon: Icons.manage_accounts_outlined,
                    title: "Manager Name",
                    value: "${task.managerFirstName} ${task.managerLastName}",
                  ),

                  const SizedBox(height: 10),



                  _contactManager(task: task),

                  const SizedBox(height: 10),

                  _InfoTile(
                    icon: Icons.description_outlined,
                    title: "Scope of Work",
                    value: task.scopeOfWork ?? "-",
                  ),

                  const SizedBox(height: 25),

                  _sectionTitle(
                    icon: Icons.analytics_outlined,
                    title: "Work Estimation",
                  ),

                  const SizedBox(height: 12),

                  _buildEstimationGrid(task),

                  const SizedBox(height: 25),

                  _buildActions(task),

                  const SizedBox(height: 15),
                ],
              ),
            );
          },
        );
      },
    );
  }



  Widget _buildDetailHeader(WorkOrderModel task) {
    final statusName = Common.getStatusColorName(
      task.statusId,
      controller.workOrderStatusList,
    );

    final statusColor = Common.getStatusColor(statusName);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 62,
          width: 62,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(.10),
            borderRadius: BorderRadius.circular(19),
          ),
          child: Icon(Icons.assignment_rounded, color: statusColor, size: 32),
        ),

        const SizedBox(width: 15),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.workOrderTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.15,
                  letterSpacing: -.4,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                task.serviceTypeName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "WO No • ${task.workOrderNo}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusPriority(WorkOrderModel task) {
    final statusName = Common.getStatusColorName(
      task.statusId,
      controller.workOrderStatusList,
    );
    print(statusName);

    final statusText = Common.getStatusText(
      task.statusId,
      controller.workOrderStatusList,
    );

    final statusColor = Common.getStatusColor(statusName);

    return Row(
      children: [
        Expanded(
          child: _LargeBadge(
            icon: Common.getStatusIcon(statusText),
            title: "STATUS",
            value: statusText,
            color: statusColor,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _LargeBadge(
            icon: Icons.flag_rounded,
            title: "PRIORITY",
            value: task.priority,
            color: Common.getPriorityColor(task.priority),
          ),
        ),
      ],
    );
  }


  Widget _buildEstimationGrid(WorkOrderModel task) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _InfoTile(
                icon: Icons.payments_outlined,
                title: "Rate Type",
                value: _rateType(task.rateType),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _InfoTile(
                icon: Icons.attach_money_rounded,
                title: "Rate Value",
                value: task.rateValue,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        _InfoTile(
          icon: Icons.schedule_rounded,
          title: "Scheduled ETA From",
          value: Common.formatToLocalUS(task.scheduledEtaFrom),
        ),

        const SizedBox(height: 10),

        _InfoTile(
          icon: Icons.event_available_rounded,
          title: "Scheduled ETA To",
          value: Common.formatToLocalUS(task.scheduledEtaTo),
        ),


        const SizedBox(height: 10),

        _InfoTile(
          icon: Icons.play_circle_outline_rounded,
          title: "Hard Start Time",
          value: Common.formatToLocalUS(task.hardStartTime),
          custColor: AppColors.error
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _InfoTile(
                icon: Icons.hourglass_bottom,
                title: "Max Hours",
                value: task.maxHours,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _InfoTile(
                icon: Icons.timer_outlined,
                title: "Approx. Hours",
                value: task.approximateHoursToComplete,
              ),
            ),
          ],
        ),

      ],
    );
  }

  String _rateType(dynamic rateType) {
    if (rateType == null) {
      return "-";
    }

    switch (rateType.toString()) {
      case "1":
        return "Hourly Rate";

      case "2":
        return "Flat Rate";

      default:
        return "N/A";
    }
  }

  Widget _buildActions(WorkOrderModel task) {
    if (task.statusId == 13) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(icon: Icons.flash_on_rounded, title: "Actions"),

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

                    Get.offAll(() => const WorkerDashboardScreen());
                  },
                  backgroundColor: AppColors.primaryDark,
                  icon: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
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
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return findButton(
      title: "Proceed",
      backgroundColor: AppColors.primary,
      onPressed: () {
        Get.back();

        Get.to(() => TaskCompletionScreen(task:task));
      },
      icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
    );
  }

  Widget _sectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          height: 34,
          width: 34,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 19, color: AppColors.primary),
        ),

        const SizedBox(width: 10),

        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _contactManager extends StatelessWidget {
  final WorkOrderModel task;
  const _contactManager({
    super.key, required this.task,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final contact = [
          if (task.managerEmail?.isNotEmpty == true) task.managerEmail!,
          if (task.managerPhoneNumber?.isNotEmpty == true)
            task.managerPhoneNumber!,
        ].join("\n");

        if (contact.isNotEmpty) {
          Clipboard.setData(ClipboardData(text: contact));

          Get.snackbar(
            "Copied",
            "Manager contact copied to clipboard",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.chartPurple ,
            colorText: Colors.white,
            borderRadius: 10,
            duration: const Duration(seconds: 2),
          );
        }
      },
      borderRadius: BorderRadius.circular(17),
      child: _InfoTile(
        icon: Icons.phone_outlined,
        title: "Manager Contact",
        value: "${task.managerEmail} \n\n${task.managerPhoneNumber}",
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBox({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.045),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: "Search work orders...",
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primary,
            size: 25,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    controller.clear();
                    onChanged("");
                  },
                  icon: const Icon(Icons.close_rounded, size: 20),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final WorkOrderModel task;
  final WorkerTasksController controller;
  final VoidCallback onTap;

  const _TaskCard({
    required this.task,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
        onTap: onTap,
        borderRadius: BorderRadius.circular(21),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(21),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.055),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Status line
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(21),
                      bottomLeft: Radius.circular(21),
                    ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 52,
                              width: 52,
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(.10),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.assignment_rounded,
                                color: statusColor,
                                size: 27,
                              ),
                            ),

                            const SizedBox(width: 13),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.workOrderTitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                      height: 1.15,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    "${task.serviceTypeName} • "
                                    "${task.managerFirstName}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.grey.shade400,
                              size: 25,
                            ),
                          ],
                        ),

                        const SizedBox(height: 17),

                        Row(
                          children: [
                            _SmallBadge(
                              icon: Icons.circle,
                              text: statusText,
                              color: statusColor,
                            ),

                            const Spacer(),

                            _SmallBadge(
                              icon: Icons.circle,
                              text: 'Wo No: ${task.workOrderNo}',
                              color: AppColors.primary,
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
  }
}

class _SmallBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _SmallBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(.09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _LargeBadge extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _LargeBadge({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(.10)),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 19),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade600,
                    letterSpacing: .5,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: color,
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xffF5F8FC),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xffE9EEF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.09),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 17, color: AppColors.primary),
          ),

          const SizedBox(height: 10),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? custColor;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
    this.custColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: custColor?.withValues(alpha: 0.2) ?? const Color(0xffF7F9FC),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xffE9EEF5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 39,
            width: 39,
            decoration: BoxDecoration(
              color: custColor?.withValues(alpha: 0.09)??AppColors.primary.withOpacity(.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: custColor??AppColors.primary, size: 19),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value.isEmpty ? "-" : value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: custColor??AppColors.primary,
                    height: 1.3,
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


class _TimingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _TimingRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 19, color: AppColors.primary),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HourBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _HourBox({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xffE5EAF1)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 19, color: AppColors.primary),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
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

class _EmptyTasks extends StatelessWidget {
  const _EmptyTasks();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_turned_in_outlined,
                size: 48,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "No Work Order Found",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              "You're all caught up!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
