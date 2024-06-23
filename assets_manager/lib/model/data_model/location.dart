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
}
