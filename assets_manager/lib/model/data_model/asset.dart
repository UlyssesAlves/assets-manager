import 'package:assets_manager/model/data_model/tree_node.dart';
import 'package:assets_manager/model/data_model/location.dart';

class Asset extends TreeNode {
  String? sensorId;
  String? sensorType;
  String? status;
  String? gatewayId;
  String? locationId;

  List<Asset>? get subAssets => children.whereType<Asset>().toList();

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

  @override
  TreeNode copy() {
    return Asset(
      status,
      id,
      name,
      parentId,
      gatewayId,
      locationId: locationId,
      sensorId: sensorId,
      sensorType: sensorType,
    );
  }

  @override
  String toString() {
    return '[ASSET] $name ($id)';
  }

  Asset.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    gatewayId = json['gatewayId'];
    locationId = json['locationId'];
    sensorId = json['sensorId'];
    sensorType = json['sensorType'];
    status = json['status'];
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parentId': parentId,
      'gatewayId': gatewayId,
      'locationId': locationId,
      'sensorId': sensorId,
      'sensorType': sensorType,
      'status': status
    };
  }
}
