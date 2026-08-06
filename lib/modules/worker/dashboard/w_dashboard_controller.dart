import 'dart:convert';

import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:taskpro/common/models/task_model.dart';
import 'package:taskpro/common/models/worker_model.dart';

import 'package:taskpro/services/secure_storage_service.dart';
import 'package:taskpro/services/storage_keys.dart';

class WorkerDashboardController extends GetxController {
  final storage = SecureStorageService.instance;

  RxString name="".obs;
  RxString role="".obs;
  RxString email="".obs;
  RxString accesstoken="".obs;

  final selectedIndex = 0.obs;
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

    storage.read(StorageKeys.accessToken).then((v){
      accesstoken.value=v!;
    });


  }

}


