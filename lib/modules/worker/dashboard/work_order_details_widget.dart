import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:taskpro/common/models/work_order_model.dart';
import 'package:taskpro/theme/app_colors.dart';

class WorkOrderDetailsWidget extends StatelessWidget {
  const WorkOrderDetailsWidget({required this.workOrders, super.key});
  final List<WorkOrderModel> workOrders;

  @override
  Widget build(BuildContext context) {
    if (workOrders.isEmpty) return const SizedBox.shrink();
    final totalSizeKb = workOrders.fold<double>(
      0,
      (total, order) => total + _sizeInKb(order.toJson()),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'WORK ORDER JSON',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Total size: ${totalSizeKb.toStringAsFixed(2)} KB',
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        ...workOrders.map(
          (order) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            elevation: 0,
            child: ExpansionTile(
              title: Text(
                'Work order ${order.workOrderNo}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                'Size: ${_sizeInKb(order.toJson()).toStringAsFixed(2)} KB',
              ),
              childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: SelectableText(
                    const JsonEncoder.withIndent('  ').convert(order.toJson()),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      height: 1.4,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  double _sizeInKb(Map<String, dynamic> data) =>
      utf8.encode(jsonEncode(data)).length / 1024;
}
