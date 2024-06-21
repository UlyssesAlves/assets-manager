import 'package:assets_manager/model/data_model/item.dart';
import 'package:assets_manager/model/data_model/location.dart';

class Asset extends TreeNode {
  final String? sensorId;
  final String? sensorType;
  final String status;
  final String gatewayId;
  final String? locationId;

  List<Asset>? get subAssets => children?.whereType<Asset>().toList();

  Asset(
    this.status,
    String id,
    String name,
    String? parentId,
    this.gatewayId, {
    this.locationId,
    this.sensorType,
    this.sensorId,
  }) : super(id, name, parentId: parentId);

  Location? location;

  bool get isComponent => sensorType?.isNotEmpty ?? false;

  bool get isLinkedToALocation => locationId?.isNotEmpty ?? false;

  bool get hasParentAsset =>
      ((parentId?.isNotEmpty ?? false) && (sensorId?.isNotEmpty ?? false));

  List<Asset>? get components =>
      subAssets?.where((a) => a.isComponent).toList();
}