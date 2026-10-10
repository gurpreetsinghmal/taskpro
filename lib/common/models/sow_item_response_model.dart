import 'dart:convert';
import 'work_order_model.dart';

enum SowItemResponseStatus { completed, notApplicable }

class SowItemResponseModel {
  static const evidenceDirectoryName = 'taskpro_sow_item_evidence';

  const SowItemResponseModel({
    required this.sowItemId,
    required this.status,
    required this.comments,
    this.images = const [],
  });

  final int sowItemId;
  final SowItemResponseStatus status;
  final String comments;
  final List<SowAttachmentModel> images;

  factory SowItemResponseModel.fromJson(Map<String, dynamic> json) {
    return SowItemResponseModel(
      sowItemId: int.tryParse(json['sow_item_id']?.toString() ?? '') ?? 0,
      status: SowItemResponseStatus.values.firstWhere(
        (status) => status.name == json['status'],
      ),
      comments: json['comments']?.toString() ?? '',
      images: (json['images'] as List<dynamic>? ?? [])
          .map(
            (image) =>
                SowAttachmentModel.fromJson(image as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'sow_item_id': sowItemId,
    'status': status.name,
    'comments': comments,
    'images': images.map((image) => image.toJson()).toList(),
  };

  static String storageKey(int workOrderId) =>
      'sow_item_responses_$workOrderId';

  static Map<int, SowItemResponseModel> decodeStorage(String? value) {
    if (value == null || value.isEmpty) return {};
    final responses = (jsonDecode(value) as List<dynamic>).map(
      (item) => SowItemResponseModel.fromJson(item as Map<String, dynamic>),
    );
    return {for (final response in responses) response.sowItemId: response};
  }

  static String encodeStorage(Map<int, SowItemResponseModel> responses) =>
      jsonEncode(
        responses.values.map((response) => response.toJson()).toList(),
      );
}
