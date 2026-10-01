
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:taskpro/common/helpers/app_helper.dart';
import 'package:taskpro/common/helpers/helper_methods.dart';
import 'package:taskpro/common/models/work_order_model.dart';
import 'package:taskpro/modules/worker/checkin/checkin_screen.dart';
import 'package:taskpro/modules/worker/dashboard/w_dashboard_screen.dart';
import 'package:taskpro/modules/worker/tasks/w_tasks_controller.dart';
import 'package:taskpro/theme/app_colors.dart';

class WorkerTasksScreen extends StatefulWidget {
  const WorkerTasksScreen({super.key});

  @override
  State<WorkerTasksScreen> createState() => _WorkerTasksScreenState();
}

class _WorkerTasksScreenState extends State<WorkerTasksScreen>
    with SingleTickerProviderStateMixin {
  final WorkerTasksController controller = Get.put(WorkerTasksController());

  final TextEditingController searchController = TextEditingController();

  String selectedFilter = "All";

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    searchController.dispose();
    super.dispose();
  }

  // ================================================================
  // FILTERED TASKS
  // ================================================================

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

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      body: SafeArea(
        child: Column(
          children: [
            _buildAnimatedHeader(),

            _buildSearch(),

            const SizedBox(height: 14),

            Obx(() => _buildFilters()),

            const SizedBox(height: 14),

            Expanded(
              child: Obx(() {
                if (controller.isApiLoading.value) {
                  return const _AnimatedLoading();
                }

                final tasks = filteredTasks;

                if (tasks.isEmpty) {
                  return const _EmptyTasks();
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    await controller.getTasksData();
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 35),
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _AnimatedTaskCard(
                        index: index,
                        animationController: _animationController,
                        child: _TaskCard(
                          task: tasks[index],
                          controller: controller,
                          onTap: () async {
                            await _showTaskDetails(context, tasks[index]);

                            if (mounted) {
                              await controller.getTasksData();
                            }
                          },
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // HEADER
  // ================================================================

  Widget _buildAnimatedHeader() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final value = Curves.easeOutCubic.transform(_animationController.value);

        return Transform.translate(
          offset: Offset(0, -25 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -35,
              top: -55,
              child: Container(
                height: 145,
                width: 145,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: .055),
                ),
              ),
            ),

            Positioned(
              right: 45,
              bottom: -75,
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: .035),
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .14),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: .12),
                        ),
                      ),
                      child: const Icon(
                        Icons.handyman_rounded,
                        color: Colors.white,
                        size: 23,
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "PSN TASK PRO",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "All Work Orders",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    _HeaderCount(),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // SEARCH
  // ================================================================

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primary.withValues(alpha: .07)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: .055),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: TextField(
          controller: searchController,
          onChanged: (_) {
            setState(() {});
          },
          textInputAction: TextInputAction.search,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: "Search work orders, services...",
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.search_rounded,
                color: AppColors.primary,
                size: 21,
              ),
            ),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      searchController.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.close_rounded, size: 19),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // FILTERS
  // ================================================================

  Widget _buildFilters() {
    final filters = [
      "All",
      ...controller.workOrderStatusList
          .map((e) => e.name ?? "")
          .where((name) => name.isNotEmpty),
    ];

    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final filter = filters[index];
          final selected = selectedFilter == filter;
          final color = _getFilterColor(filter);

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();

              setState(() {
                selectedFilter = filter;
              });
            },
            child: AnimatedPhysicalModel(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              elevation: selected ? 4 : 0,
              color: selected ? color : Colors.white,
              shadowColor: selected
                  ? color.withValues(alpha: .25)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              shape: BoxShape.rectangle,
              clipBehavior: Clip.none,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: selected ? color : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? color
                        : Colors.grey.withValues(alpha: .12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Icon(
                        _getFilterIcon(filter),
                        key: ValueKey("$filter-$selected"),
                        size: 15,
                        color: selected ? Colors.white : color,
                      ),
                    ),

                    const SizedBox(width: 6),

                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: selected ? Colors.white : color,
                      ),
                      child: Text(filter),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getFilterColor(String filter) {
    if (filter == "All") {
      return AppColors.primary;
    }

    final lower = filter.toLowerCase();

    if (lower.contains("new") || lower.contains("assign")) {
      return const Color(0xFF4F7CFF);
    }

    if (lower.contains("progress")) {
      return const Color(0xFFF59E0B);
    }

    if (lower.contains("hold")) {
      return const Color(0xFFEAB308);
    }

    if (lower.contains("complete")) {
      return const Color(0xFF10B981);
    }

    if (lower.contains("cancel")) {
      return const Color(0xFFEF4444);
    }

    if (lower.contains("submit")) {
      return const Color(0xFF8B5CF6);
    }

    return AppColors.primary;
  }

  IconData _getFilterIcon(String filter) {
    if (filter == "All") {
      return Icons.grid_view_rounded;
    }

    final lower = filter.toLowerCase();

    if (lower.contains("new") || lower.contains("assign")) {
      return Icons.assignment_outlined;
    }

    if (lower.contains("progress")) {
      return Icons.play_circle_outline_rounded;
    }

    if (lower.contains("hold")) {
      return Icons.pause_circle_outline_rounded;
    }

    if (lower.contains("complete")) {
      return Icons.check_circle_outline_rounded;
    }

    if (lower.contains("cancel")) {
      return Icons.cancel_outlined;
    }

    if (lower.contains("submit")) {
      return Icons.send_outlined;
    }

    return Icons.circle_outlined;
  }

  // ================================================================
  // DETAILS
  // ================================================================

  Future<void> _showTaskDetails(
    BuildContext context,
    WorkOrderModel task,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .55),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: .91,
          minChildSize: .55,
          maxChildSize: .97,
          snap: true,
          snapSizes: const [.91, .97],
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5F7FC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Color(0xFFD2D6DF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 17, 16, 30),
                      children: [
                        _buildDetailHeader(task),

                        const SizedBox(height: 15),

                        _buildStatusPriority(task),

                        const SizedBox(height: 22),

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

                        const SizedBox(height: 14),

                        _modernSection(
                          icon: Icons.location_on_outlined,
                          title: "Location Information",
                          color: const Color(0xFF10A37F),
                          children: [
                            _modernInfoTile(
                              icon: Icons.location_city_outlined,
                              title: "Service Location",
                              value: task.address?.fullAddress ?? "-",
                              multiline: true,
                            ),

                            _modernLocationButton(
                              onTap: () {
                                if (task.address?.googleMapLink != null) {
                                  controller.loadMap(
                                    task.address!.googleMapLink,
                                  );
                                }
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        _modernSection(
                          icon: Icons.calendar_month_outlined,
                          title: "Schedule Information",
                          color: const Color(0xFFF59E0B),
                          children: [_buildScheduleGrid(task)],
                        ),

                        const SizedBox(height: 14),

                        _modernSection(
                          icon: Icons.directions_car_outlined,
                          title: "Pricing Information",
                          color: AppColors.chartCyan,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _InfoTile(
                                    icon: Icons.route_outlined,
                                    title: "Rate Type",
                                    value: _rateType(task.rateType),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _InfoTile(
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
                                    title: "Estimated Hours",
                                    value: task.approximateHoursToComplete,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _InfoTile(
                                    icon: Icons.hourglass_bottom_rounded,
                                    title: "Maximum Hours",
                                    value: task.maxHours,
                                  ),
                                ),
                              ],
                            ),

                            _InfoTile(
                              icon: Icons.directions_car_outlined,
                              title: "Travel Rates",
                              value: task.travelRate??"-",
                            ),

                            _InfoTile(
                              icon: Icons.payments_rounded,
                              title: "Maximum Payout",
                              value: task.rateType == 2
                                  ? task.rateValue
                                  : "\$ ${((double.tryParse(task.maxHours) ?? 0) * (double.tryParse(task.rateValue) ?? 0)).toStringAsFixed(2)}",
                              customColor: AppColors.income,
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),
                        Obx(() {

                          if (controller.hardStartChangeStatus[task.id]==0) {
                            return  _buildActions(task);
                          }
                          if (controller.hardStartChangeStatus[task.id]!>1) {
                            return  _buildActions(task);
                          }
                          return const SizedBox.shrink();
                        })
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

  // ================================================================
  // DETAIL HEADER
  // ================================================================

  Widget _buildDetailHeader(WorkOrderModel task) {
    final statusName = Common.getStatusColorName(
      task.statusId,
      controller.workOrderStatusList,
    );

    final statusColor = Common.getStatusColor(statusName);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [statusColor, statusColor.withValues(alpha: .82)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .20),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(Icons.assignment_rounded, color: statusColor, size: 30),
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
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),

                const SizedBox(height: 7),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "WO • ${task.workOrderNo}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .3,
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

  // ================================================================
  // STATUS + PRIORITY
  // ================================================================

  Widget _buildStatusPriority(WorkOrderModel task) {
    final statusName = Common.getStatusColorName(
      task.statusId,
      controller.workOrderStatusList,
    );

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
        const SizedBox(width: 10),
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

  // ================================================================
  // SCHEDULE
  // ================================================================

  Widget _buildScheduleGrid(WorkOrderModel task) {
    return Column(
      children: [
        _InfoTile(
          icon: Icons.schedule_rounded,
          title: "Scheduled ETA From",
          value: Common.getformatDate(task.scheduledEtaFrom),
        ),

        const SizedBox(height: 8),

        _InfoTile(
          icon: Icons.event_available_rounded,
          title: "Scheduled ETA To",
          value: Common.getformatDate(task.scheduledEtaTo),
        ),

        const SizedBox(height: 8),

        _InfoTile(
          icon: Icons.play_circle_outline_rounded,
          title: "Hard Start Time",
          value: Common.getformatDate(task.hardStartTime),
          customColor: AppColors.error,
        ),
        const SizedBox(height: 8),
        Obx(() {
          if (controller.hardStartChangeStatus[task.id]==0) {
            return  _buildHardStartChangeRequest(task);
          }
          return _buildConstant(task);
        })





      ],
    );
  }

  // ================================================================
  // RATE TYPE
  // ================================================================

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

  // ================================================================
  // ACTIONS
  // ================================================================

  Widget _buildActions(WorkOrderModel task) {
    if (task.statusId == 13 && controller.hardStartChangeStatus[task.id]!=1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon: Icons.flash_on_rounded,
            title: "What would you like to do?",
          ),

          const SizedBox(height: 13),

          Row(
            children: [
              Expanded(
                child: _AnimatedActionButton(
                  title: "Accept",
                  icon: Icons.check_rounded,
                  color: AppColors.success,
                  onPressed: () async {
                    HapticFeedback.mediumImpact();

                    final result = await showConfirmationDialog(
                      context: context,
                      title: "Accept Work Order?",
                      message:
                          "You are about to accept this work order. It will be added to your Active Work Orders.",
                      confirmText: "Accept",
                      isDestructive: false,
                      icon: Icons.task_alt_rounded,
                      requireRemarks: false,
                    );

                    if (result?.confirmed == true){
                      Get.back();

                      await controller.acceptWorkOrderApi(
                        task.id,
                        task.workOrderNo,
                      );

                      Get.offAll(() => const WorkerDashboardScreen());
                    }
                  },
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _AnimatedActionButton(
                  title: "Reject",
                  icon: Icons.close_rounded,
                  color: AppColors.error,
                  onPressed: () async {
                    HapticFeedback.mediumImpact();

                    final result  = await showConfirmationDialog(
                      context: context,
                      title: "Reject Work Order?",
                      message:
                          "Are you sure you want to reject this Work Order? This action cannot be undone.",
                      confirmText: "Reject",
                      isDestructive: true,
                      icon: Icons.block_rounded,
                      requireRemarks: true
                    );

                    if (result?.confirmed == true){
                      Get.back();

                      await controller.rejectWorkOrderApi(
                        task.id,
                        task.workOrderNo,
                        result?.remarks ?? ""
                      );

                      Get.offAll(() => const WorkerDashboardScreen());
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (task.statusId == 59) {
      return _AnimatedActionButton(
        title: "Proceed to Check In",
        icon: Icons.arrow_forward_rounded,
        color: AppColors.primary,
        onPressed: () {
          HapticFeedback.mediumImpact();

          Get.back();

          Get.to(() => CheckInScreen(task: task));
        },
      );
    }

    return const SizedBox.shrink();
  }

  // ================================================================
  // SECTION TITLE
  // ================================================================

  Widget _sectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: .09),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // ================================================================
  // MODERN SECTION
  // ================================================================

  Widget _modernSection({
    required IconData icon,
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: .045)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .035),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          ...children,
        ],
      ),
    );
  }

  // ================================================================
  // MODERN INFO
  // ================================================================

  Widget _modernInfoTile({
    required IconData icon,
    required String title,
    required String value,
    bool multiline = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF687083)),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8B91A0),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  maxLines: multiline ? 5 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
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

  // ================================================================
  // LOCATION
  // ================================================================

  Widget _modernLocationButton({required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
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
                  "Open location on map",
                  style: TextStyle(
                    color: Color(0xFF10A37F),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFF10A37F),
                size: 13,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // MANAGER
  // ================================================================

  Widget _psnManagerDetails(WorkOrderModel task) {
    final managerName = "${task.managerFirstName} ${task.managerLastName}"
        .trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF5B5FEF).withValues(alpha: .10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.manage_accounts_outlined,
              size: 20,
              color: Color(0xFF5B5FEF),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
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
                    "Manager contact copied",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.chartPurple,
                    colorText: Colors.white,
                    borderRadius: 12,
                    margin: const EdgeInsets.all(12),
                    duration: const Duration(seconds: 2),
                  );
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "PSN MANAGER",
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .7,
                      color: Color(0xFF858A99),
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    managerName.isNotEmpty ? managerName : "-",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF242733),
                    ),
                  ),

                  const SizedBox(height: 7),

                  Row(
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        size: 14,
                        color: Color(0xFF858A99),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          task.managerEmail ?? "-",
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF646A7A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 14,
                        color: Color(0xFF858A99),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          task.managerPhoneNumber ?? "-",
                          style: const TextStyle(
                            fontSize: 11.5,
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

  Widget _buildHardStartChangeRequest(WorkOrderModel task) {
    // Replace these with your actual model fields.



    // ─────────────────────────────────────────────
    // Request already exists
    // ─────────────────────────────────────────────
    var  hasRequest = task.proposed_datetime_accepted_by_manager??0;

    final bool pending = hasRequest == 1;
    final bool approved =  hasRequest == 2;
    final bool rejected =  hasRequest == 3;

    final Color statusColor = approved
        ? const Color(0xFF16A34A)
        : rejected
        ? const Color(0xFFDC2626)
        : const Color(0xFFD97706);

    final Color backgroundColor = approved
        ? const Color(0xFFF0FDF4)
        : rejected
        ? const Color(0xFFFEF2F2)
        : const Color(0xFFFFFBEB);

    final Color borderColor = approved
        ? const Color(0xFFBBF7D0)
        : rejected
        ? const Color(0xFFFECACA)
        : const Color(0xFFFDE68A);



    if (hasRequest==0 && task.statusId==13) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color(0xFFFED7AA),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEDD5),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.edit_calendar_rounded,
                color: Color(0xFFEA580C),
                size: 20,
              ),
            ),

            const SizedBox(width: 11),

            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need to change Hard Start Time?',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF7C2D12),
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'You can propose a different time for manager approval.',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF9A3412),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Material(
              color: const Color(0xFFEA580C),
              borderRadius: BorderRadius.circular(9),
              child: InkWell(
                borderRadius: BorderRadius.circular(9),
                onTap: () {
                  _showHardStartChangeDialog(task);
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Text(
                    'Request',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    else if (hasRequest!=0){
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                approved
                    ? Icons.check_circle_rounded
                    : rejected
                    ? Icons.cancel_rounded
                    : Icons.hourglass_top_rounded,
                size: 19,
                color: statusColor,
              ),

              const SizedBox(width: 7),

              const Expanded(
                child: Text(
                  'Hard Start Time Change',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF172033),
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  approved
                      ? 'APPROVED'
                      : rejected
                      ? 'REJECTED'
                      : 'PENDING',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _ChangeTimeBox(
                  title: 'Current',
                  value: Common.getformatDate(
                    task.hardStartTime,
                  ),
                  color: const Color(0xFF64748B),
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 17,
                  color: Color(0xFF94A3B8),
                ),
              ),

              Expanded(
                child:
                    Obx(()=> _ChangeTimeBox(
                      title: 'Proposed',
                      value: controller.proposedTime.value==""
                          ? Common.getformatDate(task.proposed_datetime.toString())
                          : Common.getformatDate(controller.proposedTime.value.toString()),
                      color: statusColor,
                    ))
               ,
              ),
            ],
          ),

          if (rejected && task.proposed_reason != null) ...[
            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 15,
                    color: statusColor,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      task.proposed_reason!,
                      style: const TextStyle(
                        fontSize: 10.5,
                        height: 1.35,
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
    }
    else
      {
        return SizedBox.shrink();
      }
  }

  Future<void> _showHardStartChangeDialog(
      WorkOrderModel task,
      ) async {
    DateTime selectedDateTime = DateTime.tryParse(task.hardStartTime ?? '') ?? DateTime.now();

    final result = await showDialog<DateTime>(
      context: Get.context!,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              titlePadding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                5,
              ),
              contentPadding: const EdgeInsets.fromLTRB(
                20,
                8,
                20,
                10,
              ),
              actionsPadding: const EdgeInsets.fromLTRB(
                15,
                0,
                15,
                15,
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.edit_calendar_rounded,
                    color: Color(0xFFEA580C),
                  ),
                  SizedBox(width: 9),
                  Text(
                    'Request Time Change',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Hard Start Time',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    Common.getformatDate(task.hardStartTime),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF172033),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Proposed Hard Start Time',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 7),

                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      final now = DateTime.now();

                      final today = DateTime(
                        now.year,
                        now.month,
                        now.day,
                      );

                      final lastDate = today.add(
                        const Duration(days: 30),
                      );

// Existing hard start may already be in the past.
// In that case, open the picker on today instead.
                      final initialDate = selectedDateTime.isBefore(today)
                          ? today
                          : selectedDateTime;

                      final date = await showDatePicker(
                        context: context,
                        initialDate: initialDate,
                        firstDate: today,
                        lastDate: lastDate,
                      );

                      if (date == null) return;

// ─────────────────────────────────────────────
// Select Time
// ─────────────────────────────────────────────

                      final isToday =
                          date.year == now.year &&
                              date.month == now.month &&
                              date.day == now.day;

                      final currentTime = TimeOfDay.fromDateTime(now);

                      TimeOfDay initialTime;

                      if (isToday) {
                        // If the previously selected time is already in the past,
                        // open the picker around the current time.
                        final selectedMinutes =
                            selectedDateTime.hour * 60 +
                                selectedDateTime.minute;

                        final currentMinutes =
                            now.hour * 60 +
                                now.minute;

                        initialTime = selectedMinutes > currentMinutes
                            ? TimeOfDay.fromDateTime(selectedDateTime)
                            : currentTime;
                      } else {
                        initialTime = TimeOfDay.fromDateTime(selectedDateTime);
                      }

                      final time = await showTimePicker(
                        context: context,
                        initialTime: initialTime,
                      );

                      if (time == null) return;

// ─────────────────────────────────────────────
// Final validation
// ─────────────────────────────────────────────

                      final proposedDateTime = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );

                      if (!proposedDateTime.isAfter(now)) {
                        Get.snackbar(
                          'Invalid Time',
                          'Proposed Hard Start Time must be in the future.',
                          backgroundColor: AppColors.error,
                          colorText: Colors.white,
                        );
                        return;
                      }

                      setState(() {
                        selectedDateTime = proposedDateTime;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFED7AA),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 20,
                            color: Color(0xFFEA580C),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              Common.getformatDate(
                                selectedDateTime.toIso8601String(),
                              ),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF9A3412),
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.edit_rounded,
                            size: 16,
                            color: Color(0xFFEA580C),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'The requested time will be sent to your manager for approval.',
                    style: TextStyle(
                      fontSize: 10.5,
                      height: 1.4,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      selectedDateTime,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEA580C),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(
                    Icons.send_rounded,
                    size: 16,
                  ),
                  label: const Text(
                    'Send Request',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) return;

    await controller.proposeChangeScheduleTimeApi(result,task);

  }

  Widget _buildConstant(WorkOrderModel task) {
    var  hasRequest = task.proposed_datetime_accepted_by_manager??0;
    final bool pending = hasRequest == 1;
    final bool approved =  hasRequest == 2;
    final bool rejected =  hasRequest == 3;
    final Color statusColor = approved
        ? const Color(0xFF16A34A)
        : rejected
        ? const Color(0xFFDC2626)
        : const Color(0xFFD97706);

    final Color backgroundColor = approved
        ? const Color(0xFFF0FDF4)
        : rejected
        ? const Color(0xFFFEF2F2)
        : const Color(0xFFFFFBEB);

    final Color borderColor = approved
        ? const Color(0xFFBBF7D0)
        : rejected
        ? const Color(0xFFFECACA)
        : const Color(0xFFFDE68A);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                approved
                    ? Icons.check_circle_rounded
                    : rejected
                    ? Icons.cancel_rounded
                    : Icons.hourglass_top_rounded,
                size: 19,
                color: statusColor,
              ),

              const SizedBox(width: 7),

              const Expanded(
                child: Text(
                  'Hard Start Time Change',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF172033),
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  approved
                      ? 'APPROVED'
                      : rejected
                      ? 'REJECTED'
                      : 'PENDING',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _ChangeTimeBox(
                  title: 'Current',
                  value: Common.getformatDate(
                    task.hardStartTime,
                  ),
                  color: const Color(0xFF64748B),
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 17,
                  color: Color(0xFF94A3B8),
                ),
              ),

              Expanded(
                child:
                Obx(()=> _ChangeTimeBox(
                  title: 'Proposed',
                  value: controller.proposedTime.value ==""
                      ? Common.getformatDate(task.proposed_datetime.toString())
                      : Common.getformatDate(controller.proposedTime.value.toString()),
                  color: statusColor,
                ))
                ,
              ),
            ],
          ),

          if (rejected && task.proposed_reason != null) ...[
            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 15,
                    color: statusColor,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      task.proposed_reason!,
                      style: const TextStyle(
                        fontSize: 10.5,
                        height: 1.35,
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );


  }
}

class _ChangeTimeBox extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _ChangeTimeBox({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// ANIMATED TASK CARD
// ====================================================================

class _AnimatedTaskCard extends StatelessWidget {
  final int index;
  final AnimationController animationController;
  final Widget child;

  const _AnimatedTaskCard({
    required this.index,
    required this.animationController,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final start = (index * .08).clamp(0.0, .65);

    final animation = CurvedAnimation(
      parent: animationController,
      curve: Interval(
        start,
        math.min(start + .4, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (_, child) {
        return Transform.translate(
          offset: Offset(0, 25 * (1 - animation.value)),
          child: Opacity(opacity: animation.value, child: child),
        );
      },
      child: child,
    );
  }
}

// ====================================================================
// TASK CARD
// ====================================================================

class _TaskCard extends StatefulWidget {
  final WorkOrderModel task;
  final WorkerTasksController controller;
  final VoidCallback onTap;

  const _TaskCard({
    required this.task,
    required this.controller,
    required this.onTap,
  });

  @override
  State<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<_TaskCard> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final statusName = Common.getStatusColorName(
      widget.task.statusId,
      widget.controller.workOrderStatusList,
    );

    final statusText = Common.getStatusText(
      widget.task.statusId,
      widget.controller.workOrderStatusList,
    );

    final statusColor = Common.getStatusColor(statusName);

    return GestureDetector(
      onTapDown: (_) {
        setState(() => pressed = true);
      },
      onTapCancel: () {
        setState(() => pressed = false);
      },
      onTapUp: (_) {
        setState(() => pressed = false);
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: pressed ? .975 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: statusColor.withValues(alpha: .08)),
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: .07),
                blurRadius: 20,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Column(
              children: [
                // Top status strip
                Container(
                  height: 4,
                  width: double.infinity,
                  color: statusColor,
                ),

                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon
                          Container(
                            height: 52,
                            width: 52,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  statusColor.withValues(alpha: .16),
                                  statusColor.withValues(alpha: .07),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.handyman_rounded,
                              color: statusColor,
                              size: 26,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5),

                                Text(
                                  widget.task.workOrderTitle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    height: 1.2,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Row(
                                  children: [
                                    const Icon(
                                      Icons.miscellaneous_services_outlined,
                                      size: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        "${widget.task.serviceTypeName} • "
                                        "${widget.task.managerFirstName}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 5),

                          Container(
                            height: 32,
                            width: 32,
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: .07),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 13),

                      // Technician row
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8FC),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Icon(
                                Icons.engineering_outlined,
                                size: 17,
                                color: statusColor,
                              ),
                            ),

                            const SizedBox(width: 8),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "TECHNICIAN",
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: .6,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    [
                                          widget.task.technicianFirstName,
                                          widget.task.technicianMiddleName,
                                          widget.task.technicianLastName,
                                        ]
                                        .where(
                                          (name) =>
                                              name != null &&
                                              name.trim().isNotEmpty,
                                        )
                                        .join(" "),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            _SmallBadge(
                              icon: Icons.circle,
                              text: statusText,
                              color: statusColor,
                            ),
                            SizedBox(width: 5),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: .07),
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: Text(
                                    "WO ${widget.task.workOrderNo}",
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: statusColor,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ====================================================================
// SMALL BADGE
// ====================================================================

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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 7, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// LARGE BADGE
// ====================================================================

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
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: color.withValues(alpha: .10)),
      ),
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .11),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .6,
                    color: Color(0xFF858A99),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
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

// ====================================================================
// INFO TILE
// ====================================================================

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? customColor;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = customColor ?? AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: customColor?.withValues(alpha: .08) ?? const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: customColor?.withValues(alpha: .10) ?? const Color(0xFFE9EDF4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 37,
            width: 37,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 18),
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
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value.isEmpty ? "-" : value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: customColor ?? AppColors.textPrimary,
                    height: 1.25,
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

// ====================================================================
// ACTION BUTTON
// ====================================================================

class _AnimatedActionButton extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _AnimatedActionButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  State<_AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<_AnimatedActionButton> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => pressed = true);
      },
      onTapCancel: () {
        setState(() => pressed = false);
      },
      onTapUp: (_) {
        setState(() => pressed = false);
        widget.onPressed();
      },
      child: AnimatedScale(
        scale: pressed ? .96 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: 53,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.color, widget.color.withValues(alpha: .82)],
            ),
            borderRadius: BorderRadius.circular(17),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: .22),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 19),
              const SizedBox(width: 8),
              Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ====================================================================
// HEADER COUNT
// ====================================================================

class _HeaderCount extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<WorkerTasksController>(
      builder: (controller) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: Colors.white.withValues(alpha: .10)),
          ),
          child: Column(
            children: [
              Obx(
                () => Text(
                  controller.workOrderList.length.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Text(
                "JOBS",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 7,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .7,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ====================================================================
// EMPTY STATE
// ====================================================================

class _EmptyTasks extends StatefulWidget {
  const _EmptyTasks();

  @override
  State<_EmptyTasks> createState() => _EmptyTasksState();
}

class _EmptyTasksState extends State<_EmptyTasks>
    with SingleTickerProviderStateMixin {
  late AnimationController animation;

  @override
  void initState() {
    super.initState();

    animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: animation,
        builder: (_, child) {
          return Transform.translate(
            offset: Offset(0, math.sin(animation.value * math.pi) * 5),
            child: child,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 105,
                width: 105,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: .13),
                      AppColors.primary.withValues(alpha: .04),
                    ],
                  ),
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
                "You're all caught up!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                "No work orders match your current filter.\n"
                "New jobs will appear here when assigned.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.45,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ====================================================================
// LOADING
// ====================================================================

class _AnimatedLoading extends StatefulWidget {
  const _AnimatedLoading();

  @override
  State<_AnimatedLoading> createState() => _AnimatedLoadingState();
}

class _AnimatedLoadingState extends State<_AnimatedLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController animation;

  @override
  void initState() {
    super.initState();

    animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: animation,
        builder: (_, __) {
          return Transform.rotate(
            angle: animation.value * math.pi * 2,
            child: Container(
              height: 52,
              width: 52,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: .10),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: const CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.primary,
              ),
            ),
          );
        },
      ),
    );
  }
}
