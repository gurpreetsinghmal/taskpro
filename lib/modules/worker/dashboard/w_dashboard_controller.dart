import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:taskpro/common/models/task_model.dart';
import 'package:taskpro/common/models/worker_model.dart';
import 'package:taskpro/modules/splash/splash_screen.dart';
import 'package:taskpro/services/secure_storage_service.dart';
import 'package:taskpro/services/storage_keys.dart';

class WorkerDashboardController extends GetxController {
  final storage = SecureStorageService.instance;

  RxString name="".obs;
  RxString role="".obs;
  RxString email="".obs;

  final selectedIndex = 0.obs;
  final userRole = 'Manager'.obs; // Toggle between Manager & Worker
  final walletBalance = 320.00.obs;

  // Overview Metrics State
  final pendingCount = 10.obs;
  final inProgressCount = 8.obs;
  final completedCount = 45.obs;
  final assignedCount = 12.obs;
  final todayCompletedCount = 7.obs;

  // Tasks List State
  final tasks = <TaskModel>[
    TaskModel(
      id: '1',
      title: 'HVAC Maintenance Unit B',
      category: 'Maintenance',
      status: 'In Progress',
      priority: 'High',
      worker: 'Alex Morgan',
    ),
    TaskModel(
      id: '2',
      title: 'Electrical Safety Inspection',
      category: 'Inspection',
      status: 'Pending',
      priority: 'Medium',
      worker: 'Alex Morgan',
    ),
    TaskModel(
      id: '3',
      title: 'Plumbing System Leak Repair',
      category: 'Plumbing',
      status: 'Completed',
      priority: 'Urgent',
      worker: 'David Chen',
    ),
    TaskModel(
      id: '4',
      title: 'Solar Panel Array Cleaning',
      category: 'Cleaning',
      status: 'Pending',
      priority: 'Low',
      worker: 'Sarah Jenkins',
    ),
  ].obs;

  // Workers List State
  final workers = <WorkerModel>[
    WorkerModel(name: 'Alex Morgan', role: 'Senior Technician', status: 'On Field', activeTasks: 4),
    WorkerModel(name: 'David Chen', role: 'Electrical Specialist', status: 'Available', activeTasks: 2),
    WorkerModel(name: 'Sarah Jenkins', role: 'Safety Inspector', status: 'On Break', activeTasks: 1),
    WorkerModel(name: 'Robert Fox', role: 'HVAC Specialist', status: 'On Field', activeTasks: 5),
  ].obs;

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  void toggleRole() {
    userRole.value = userRole.value == 'Manager' ? 'Worker' : 'Manager';
  }

  void addTask(String title, String category) {
    if (title.trim().isEmpty) return;
    tasks.insert(
      0,
      TaskModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        category: category,
        status: 'Pending',
        priority: 'Medium',
        worker: 'Alex Morgan',
      ),
    );
    pendingCount.value++;
    assignedCount.value++;
  }

  void withdrawWallet(double amount) {
    if (walletBalance.value >= amount) {
      walletBalance.value -= amount;
    }
  }


  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    getprofile();
  }
  getprofile() async{
    storage.read(StorageKeys.empname).then((value) {
      var x=jsonDecode(value!);
      name.value=x["name"];
      role.value=x["role"];
      email.value=x["email"];
    });
  }

}

class MainLayoutScreen extends StatelessWidget {
  const MainLayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WorkerDashboardController());

    final List<Widget> screens = [
      const DashboardTabScreen(),
      const TasksTabScreen(),
      const WorkersTabScreen(),
      const ReportsTabScreen(),
      const MoreTabScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      // 1. END DRAWER for right-side profile slide out
      endDrawer: const RightProfileDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Obx(
              () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield_outlined, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  "Role: ${controller.userRole.value}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                InkWell(
                  onTap: controller.toggleRole,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Icon(Icons.swap_horiz_rounded, size: 18, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
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
                          border: Border.all(color:  AppColors.primary, width: 2),
                        ),
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(
                            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=200',
                          ),
                        ),
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
          ),
        ],
      ),
      body: Obx(() => AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: screens[controller.selectedIndex.value],
      )),
      bottomNavigationBar: Obx(
            () => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
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
            selectedItemColor:  AppColors.primary,
            unselectedItemColor: const Color(0xFF94A3B8),
            selectedFontSize: 11,
            unselectedFontSize: 11,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
            elevation: 0,
            items: [
              BottomNavigationBarStyleItem(icon: Icons.grid_view_rounded, label: "Dashboard"),
              BottomNavigationBarStyleItem(icon: Icons.check_box_outlined, label: "Tasks"),
              BottomNavigationBarStyleItem(icon: Icons.people_outline_rounded, label: "Workers"),
              BottomNavigationBarStyleItem(icon: Icons.bar_chart_rounded, label: "Reports"),
              BottomNavigationBarStyleItem(icon: Icons.more_horiz_rounded, label: "More"),
            ],
          ),
        ),
      ),
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

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting Header
          Obx(
                () => Row(
              children: [
                Text(
                  "Hello, ${controller.userRole.value}",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 8),
                const Text("👋", style: TextStyle(fontSize: 22)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section Title: Today's Overview
          const Text(
            "Today's Overview",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
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
                    title: "Completed",
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
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
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
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Obx(
                          () => Text(
                        "\$${controller.walletBalance.value.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showWithdrawDialog(context, controller),
                  icon: const Icon(Icons.account_balance_wallet_outlined, size: 16, color: Colors.white),
                  label: const Text(
                    "Withdraw",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:  AppColors.primary,
                    elevation: 2,
                    shadowColor:  AppColors.primary.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 16, color: AppColors.primary),
                        SizedBox(width: 6),
                        Text(
                          "Priority Job",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
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
                      color: const Color(0xFFF8FAFC),
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
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${controller.tasks.first.category} • ${controller.tasks.first.worker}",
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
        color: const Color(0xFFEFF6FF).withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF475569),
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
        color: const Color(0xFFEFF6FF).withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF475569),
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

  void _showWithdrawDialog(BuildContext context, WorkerDashboardController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.account_balance_wallet, color: AppColors.primary),
            SizedBox(width: 8),
            Text("Withdraw Funds", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Available Balance: \$${controller.walletBalance.value.toStringAsFixed(2)}",
              style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500),
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
            style: ElevatedButton.styleFrom(
              backgroundColor:  AppColors.primary,
            ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Assigned Tasks",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddTaskModal(context, controller),
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: const Text("Add Task", style: TextStyle(fontSize: 12, color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor:  AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(
                  () => ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: controller.tasks.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final task = controller.tasks[index];
                  final isCompleted = task.status == 'Completed';
                  final isInProgress = task.status == 'In Progress';

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${task.category} • ${task.worker}",
                              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? Colors.amber.shade50
                                : isInProgress
                                ? Colors.blue.shade50
                                : Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            task.status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isCompleted
                                  ? Colors.amber.shade700
                                  : isInProgress
                                  ? Colors.blue.shade700
                                  : Colors.amber.shade800,
                            ),
                          ),
                        ),
                      ],
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

  void _showAddTaskModal(BuildContext context, WorkerDashboardController controller) {
    final titleController = TextEditingController();
    String category = 'Maintenance';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Create New Task", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Task Title",
                hintText: "e.g. Inspect Boiler Room",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor:  AppColors.primary),
                onPressed: () {
                  controller.addTask(titleController.text, category);
                  Navigator.pop(context);
                },
                child: const Text("Assign Task", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
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
                    border: Border.all(color: const Color(0xFFF1F5F9)),
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
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(worker.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              Text(worker.role, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("${worker.activeTasks} Active Jobs", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          Text(worker.status, style: TextStyle(fontSize: 10, color: Colors.amber.shade600, fontWeight: FontWeight.bold)),
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Completion Rate", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                    Text("88.5%", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const LinearProgressIndicator(
                    value: 0.885,
                    minHeight: 8,
                    backgroundColor: Color(0xFFF1F5F9),
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
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
        const Text("App Settings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
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
  const RightProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WorkerDashboardController>();

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drawer Blue Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, Color(0xFF1D4ED8)],
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text("Active Session", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=200',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Alex Morgan", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Obx(() => Text("Head ${controller.userRole.value}", style: const TextStyle(color: Colors.white70, fontSize: 12))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Icon(Icons.phone_android, size: 14, color: Colors.white70),
                    SizedBox(width: 6),
                    Text("+1 (555) 234-5678", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
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
                  child: Text("WORKER MENU", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                ),
                _buildDrawerItem(
                  icon: Icons.person_outline,
                  title: "My Profile",
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerItem(
                  icon: Icons.edit_note,
                  title: "Edit Details & Skills",
                  onTap: () => Navigator.pop(context),
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
                  child: Text("SUPPORT & HELP", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(context);
                Get.snackbar("Logged Out", "Successfully logged out.", snackPosition: SnackPosition.BOTTOM);
              },
              icon: Icon(Icons.logout, color: Colors.red.shade700, size: 18),
              label: Text("Log Out Account", style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold)),
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
      leading: Icon(icon, color:  AppColors.primary, size: 20),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
      trailing: trailingText != null
          ? Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6)),
        child: Text(trailingText, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11)),
      )
          : const Icon(Icons.chevron_right, size: 18, color: Color(0xFF94A3B8)),
    );
  }
}