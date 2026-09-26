import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';


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
        //           color: Colors.black.withValues(alpha: .05),
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
                      await _showTaskDetails(context, tasks[index]);
                      controller.getTasksData();
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
                          color: AppColors.primary.withValues(alpha:.22),
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

  // Future<void> _showTaskDetails(
  //   BuildContext context,
  //   WorkOrderModel task,
  // ) async
  // {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     useSafeArea: true,
  //     backgroundColor: Colors.transparent,
  //     barrierColor: Colors.black.withValues(alpha: .45),
  //     builder: (context) {
  //       return DraggableScrollableSheet(
  //         expand: false,
  //         initialChildSize: .90,
  //         minChildSize: .60,
  //         maxChildSize: .96,
  //         snap: true,
  //         snapSizes: const [.90, .96],
  //         builder: (_, scrollController) {
  //           return Container(
  //             decoration: BoxDecoration(
  //               color: const Color(0xFFF8F9FC),
  //               borderRadius: const BorderRadius.vertical(
  //                 top: Radius.circular(32),
  //               ),
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: Colors.black.withValues(alpha: .12),
  //                   blurRadius: 30,
  //                   offset: const Offset(0, -8),
  //                 ),
  //               ],
  //             ),
  //             child: Column(
  //               children: [
  //                 // ─────────────────────────────────────────────
  //                 // Top Handle
  //                 // ─────────────────────────────────────────────
  //                 Padding(
  //                   padding: const EdgeInsets.only(top: 12),
  //                   child: Container(
  //                     width: 44,
  //                     height: 5,
  //                     decoration: BoxDecoration(
  //                       color: Colors.grey.shade300,
  //                       borderRadius: BorderRadius.circular(20),
  //                     ),
  //                   ),
  //                 ),
  //
  //                 // ─────────────────────────────────────────────
  //                 // Scrollable Content
  //                 // ─────────────────────────────────────────────
  //                 Expanded(
  //                   child: ListView(
  //                     controller: scrollController,
  //                     physics: const BouncingScrollPhysics(),
  //                     padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
  //                     children: [
  //                       // Header
  //                       _buildDetailHeader(task),
  //
  //                       const SizedBox(height: 20),
  //
  //                       // Status & Priority
  //                       _buildStatusPriority(task),
  //
  //                       const SizedBox(height: 28),
  //
  //                       // ───────────────────────────────────────
  //                       // Work Information
  //                       // ───────────────────────────────────────
  //                       _sectionTitle(
  //                         icon: Icons.assignment_outlined,
  //                         title: "Work Information",
  //                       ),
  //
  //                       const SizedBox(height: 10),
  //
  //                       _InfoTile(
  //                         icon: Icons.category_outlined,
  //                         title: "Service Type",
  //                         value: task.serviceTypeName,
  //                       ),
  //
  //                       const SizedBox(height: 10),
  //
  //                       _InfoTile(
  //                         icon: Icons.engineering_outlined,
  //                         title: "Assigned Worker",
  //                         value:
  //                             "${task.technicianFirstName} ${task.technicianLastName}",
  //                       ),
  //
  //                       const SizedBox(height: 10),
  //
  //                       _InfoTile(
  //                         icon: Icons.manage_accounts_outlined,
  //                         title: "Manager",
  //                         value:
  //                             "${task.managerFirstName} ${task.managerLastName}",
  //                       ),
  //
  //                       const SizedBox(height: 10),
  //
  //                       _InfoTile(
  //                         icon: Icons.description_outlined,
  //                         title: "Scope of Work",
  //                         value: task.scopeOfWork?.trim().isNotEmpty == true
  //                             ? task.scopeOfWork!
  //                             : "-",
  //                       ),
  //
  //                       const SizedBox(height: 28),
  //
  //                       // ───────────────────────────────────────
  //                       // Work Estimation
  //                       // ───────────────────────────────────────
  //                       _sectionTitle(
  //                         icon: Icons.analytics_outlined,
  //                         title: "Work Estimation",
  //                       ),
  //
  //                       const SizedBox(height: 14),
  //
  //                       _buildScheduleGrid(task),
  //
  //                       const SizedBox(height: 28),
  //
  //                       // ───────────────────────────────────────
  //                       // Actions
  //                       // ───────────────────────────────────────
  //                       _buildActions(task),
  //
  //                       const SizedBox(height: 10),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  Future<void> _showTaskDetails(
    BuildContext context,
    WorkOrderModel task,
  ) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha:.50),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: .92,
          minChildSize: .60,
          maxChildSize: .97,
          snap: true,
          snapSizes: const [.92, .97],
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF6F7FB),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  // ─────────────────────────────────────────
                  // Drag Handle
                  // ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD5D8E0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
                      children: [
                        // ─────────────────────────────────────
                        // Header
                        // ─────────────────────────────────────
                        _buildDetailHeader(task),

                        const SizedBox(height: 18),

                        // Status / Priority
                        _buildStatusPriority(task),

                        const SizedBox(height: 26),

                        // ═════════════════════════════════════
                        // WORK INFORMATION
                        // ═════════════════════════════════════
                        _modernSection(
                          icon: Icons.work_outline_rounded,
                          title: "Work Order Information",
                          color: const Color(0xFF5B5FEF),
                          children: [
                            _modernInfoTile(
                              icon: Icons.category_outlined,
                              title: "Service Type",
                              value: task.serviceTypeName,
                            ),

                            _modernInfoTile(
                              icon: Icons.engineering_outlined,
                              title: "Assigned Technician",
                              value:
                                  "${task.technicianFirstName} ${task.technicianLastName}",
                            ),

                            _psnManagerDetails(task),

                            _modernInfoTile(
                              icon: Icons.description_outlined,
                              title: "Scope of Work",
                              value: task.scopeOfWork?.trim().isNotEmpty == true
                                  ? task.scopeOfWork!
                                  : "-",
                              multiline: true,
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // ═════════════════════════════════════
                        // LOCATION INFORMATION
                        // ═════════════════════════════════════
                        _modernSection(
                          icon: Icons.location_on_outlined,
                          title: "Location Information",
                          color: const Color(0xFF10A37F),
                          children: [
                            _modernInfoTile(
                              icon: Icons.location_city_outlined,
                              title: "Service Location",
                              value:
                                  "742 Evergreen Terrace, Springfield, OR 97477",
                            ),

                            _modernLocationButton(onTap: ()=>controller.loadMap(null)),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // ═════════════════════════════════════
                        // SCHEDULE INFORMATION
                        // ═════════════════════════════════════
                        _modernSection(
                          icon: Icons.calendar_month_outlined,
                          title: "Schedule Information",
                          color: const Color(0xFFF59E0B),
                          children: [_buildScheduleGrid(task)],
                        ),

                        const SizedBox(height: 18),

                        // ═════════════════════════════════════
                        // TRAVEL RATES
                        // ═════════════════════════════════════
                        _modernSection(
                          icon: Icons.directions_car_outlined,
                          title: "Travel Rates",
                          color: AppColors.chartCyan,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _modernInfoTile(
                                    icon: Icons.route_outlined,
                                    title: "Rate Type",
                                    value: _rateType(task.rateType),
                                  ),
                                ),
                                SizedBox(width: 7),
                                Expanded(
                                  child: _modernInfoTile(
                                    icon: Icons.attach_money_rounded,
                                    title: "Rate Value",
                                    value: task.rateValue,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: _InfoTile(
                                    icon: Icons.timer_outlined,
                                    title: "Approx. Hours",
                                    value: task.approximateHoursToComplete,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _InfoTile(
                                    icon: Icons.hourglass_bottom,
                                    title: "Max Hours",
                                    value: task.maxHours,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 7),
                            _InfoTile(
                              icon: Icons.attach_money_rounded,
                              title: "Maximum Payout",
                              value:
                                  "\$ ${((double.tryParse(task.maxHours) ?? 0.0) * (double.tryParse(task.rateValue) ?? 0.0)).toStringAsFixed(2)}",
                              custColor: AppColors.income,
                            ),
                          ],
                        ),

                        const SizedBox(height: 26),

                        // ─────────────────────────────────────
                        // Actions
                        // ─────────────────────────────────────
                        _buildActions(task),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
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
            color: statusColor.withValues(alpha: .10),
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


              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: .08),
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

  Widget _buildScheduleGrid(WorkOrderModel task) {
    return Column(
      children: [
        _InfoTile(
          icon: Icons.schedule_rounded,
          title: "Scheduled ETA From",
          value: Common.getformatDate(task.scheduledEtaFrom),
        ),

        const SizedBox(height: 10),

        _InfoTile(
          icon: Icons.event_available_rounded,
          title: "Scheduled ETA To",
          value: Common.getformatDate(task.scheduledEtaTo),
        ),

        const SizedBox(height: 10),

        _InfoTile(
          icon: Icons.play_circle_outline_rounded,
          title: "Hard Start Time",
          value: Common.getformatDate(task.hardStartTime),
          custColor: AppColors.error,
        ),
        const SizedBox(height: 10),
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


                    bool? confirmed = await showConfirmationDialog(
                      context: context,
                      title: "Accept Work Order?",
                      message: "You are about to accept this work order. It will be added to your Active Work Orders.",
                      confirmText: "Accept",
                      isDestructive: false, // Triggers Green styling & checkmark icon
                      icon: Icons.task_alt_rounded,
                    );

                    if (confirmed == true) {
                      Get.back();
                      await controller.acceptWorkOrderApi(
                        task.id,
                        task.workOrderNo,
                      );

                      Get.offAll(() => const WorkerDashboardScreen());
                    }


                  },
                  backgroundColor: AppColors.success,
                  icon: const Icon(
                    Icons.thumb_up,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: findButton(
                  title: "Reject",
                  onPressed: () async{

                    bool? confirmed = await showConfirmationDialog(
                      context: context,
                      title: "Reject Work Order?",
                      message: "Are you sure you want to reject this Work Order? This action cannot be undone.",
                      confirmText: "Reject",
                      isDestructive: true, // Triggers Red styling & cross icon isDestructive: true, // Triggers Green styling & checkmark icon
                      icon: Icons.block_rounded,
                    );

                    if (confirmed == true) {
                      Get.back();
                      await controller.rejectWorkOrderApi(
                        task.id,
                        task.workOrderNo,
                      );

                      Get.offAll(() => const WorkerDashboardScreen());
                    }
                  },
                  backgroundColor: AppColors.error,
                  icon: const Icon(Icons.thumb_down, color: Colors.white),
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

        Get.to(() => TaskCompletionScreen(task: task));
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
            color: AppColors.primary.withValues(alpha: .10),
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

  Widget _modernInfoTile({
    required IconData icon,
    required String title,
    required String value,
    bool multiline = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 19, color: const Color(0xFF646A7A)),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF858A99),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  maxLines: multiline ? 5 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF242733),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _modernLocationButton({required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF10A37F).withValues(alpha: .08),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Row(
          children: [
            Icon(Icons.map_outlined, color: Color(0xFF10A37F), size: 19),

            SizedBox(width: 9),

            Expanded(
              child: Text(
                "View location on map",
                style: TextStyle(
                  color: Color(0xFF10A37F),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFF10A37F),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _scheduleGrid({required List<_ScheduleItem> items}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.65,
      ),
      itemBuilder: (_, index) {
        final item = items[index];

        return Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FC),
            borderRadius: BorderRadius.circular(17),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(item.icon, size: 19, color: const Color(0xFFF59E0B)),

                  const SizedBox(height: 7, width: 7),

                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 15,
                      // color: Color(0xFF858A99),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 2),

              Text(
                item.value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF242733),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _rateGrid({required List<_RateItem> items}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.65,
      ),
      itemBuilder: (_, index) {
        final item = items[index];

        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8F7),
            borderRadius: BorderRadius.circular(17),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(item.icon, size: 19, color: AppColors.chartCyan),

                  const SizedBox(height: 7, width: 7),

                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF858A99),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 2),

              Text(
                item.value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF242733),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _modernSection({
    required IconData icon,
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8EAF0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: color, size: 21),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF181A22),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Section Content
          ...children,
        ],
      ),
    );
  }

  Widget _psnManagerDetails(WorkOrderModel task) {
    final managerName = "${task.managerFirstName} ${task.managerLastName}"
        .trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF5B5FEF).withValues(alpha: .10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.manage_accounts_outlined,
              size: 20,
              color: Color(0xFF5B5FEF),
            ),
          ),

          const SizedBox(width: 12),

          // Details
          Expanded(
            child: InkWell(
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
                    backgroundColor: AppColors.chartPurple,
                    colorText: Colors.white,
                    borderRadius: 10,
                    duration: const Duration(seconds: 2),
                  );
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "PSN Manager Details",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF858A99),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    managerName.isNotEmpty ? managerName : "-",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF242733),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Email
                  Row(
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        size: 15,
                        color: Color(0xFF858A99),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          task.managerEmail ?? "-",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF646A7A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Phone
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 15,
                        color: Color(0xFF858A99),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          task.managerPhoneNumber ?? "-",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF646A7A),
                            fontWeight: FontWeight.w500,
                          ),
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
            color: Colors.black.withValues(alpha: .045),
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
                color: Colors.black.withValues(alpha: .055),
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
                                color: statusColor.withValues(alpha: .10),
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
        color: color.withValues(alpha: .09),
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
        color: color.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: .10)),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
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
              color: AppColors.primary.withValues(alpha: .09),
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: custColor?.withValues(alpha: 0.2) ?? const Color(0xffF7F9FC),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xffE9EEF5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 39,
            width: 39,
            decoration: BoxDecoration(
              color: AppColors.textWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: custColor ?? AppColors.textSecondary,
              size: 19,
            ),
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
                    color: custColor??Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value.isEmpty ? "-" : value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: custColor ?? AppColors.textPrimary,
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
                color: AppColors.primary.withValues(alpha: .08),
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

class _ScheduleItem {
  final IconData icon;
  final String title;
  final String value;

  _ScheduleItem({required this.icon, required this.title, required this.value});
}

class _RateItem {
  final String title;
  final String value;
  final IconData icon;

  _RateItem({required this.title, required this.value, required this.icon});
}
