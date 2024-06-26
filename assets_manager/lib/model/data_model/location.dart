import 'package:assets_manager/model/data_model/tree_node.dart';

class Location extends TreeNode {
  Location(
    String id,
    String name, [
    String? parentId,
  ]) : super(id, name, parentId: parentId);

  bool get isSubLocation => parentId?.isNotEmpty ?? false;

  Location? parentLocation;
  List<Location>? subLocations;

  @override
  TreeNode copy() {
    return Location(id, name, parentId);
  }

  @override
  String toString() {
    return '[LOCATION] $name ($id)';
  }

  Location.fromJson(Map<String, dynamic> json) : super.fromJson(json);

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parentId': parentId,
    };
  }
}
