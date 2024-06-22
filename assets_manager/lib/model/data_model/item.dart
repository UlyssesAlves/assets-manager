import 'package:assets_manager/model/data_model/asset.dart';
import 'package:assets_manager/model/data_model/location.dart';

/// Represents a generic item which can be part of the tree.
class TreeNode {
  final String id;
  final String name;
  final String? parentId;

  TreeNode(this.id, this.name, {this.parentId});

  bool get hasParentId => parentId?.isNotEmpty ?? false;

  List<TreeNode> _children = [];
  TreeNode? _parentNode;

  set parentNode(TreeNode parent) {
    _parentNode = parent;
  }

  List<TreeNode> get children => _children;

  void addChild(TreeNode child) {
    _children.add(child);
  }

  bool get isLocation => this is Location;
  bool get isAsset => this is Asset;
  bool get isComponent => this is Asset && (this as Asset).isComponent;
  bool get hasEnergySensor =>
      this is Asset && (this as Asset).sensorType == 'energy';
  bool get isInAlertStatus =>
      this is Asset && (this as Asset).status == 'alert';
  bool get hasChildren => children.isNotEmpty;

  bool matchesTextFilter(String textFilter) {
    if (textFilter.isEmpty) {
      return true;
    } else if (name.toLowerCase().contains(textFilter)) {
      return true;
    } else {
      for (var child in children) {
        if (child.matchesTextFilter(textFilter)) {
          return true;
        }
      }
    }

    return false;
  }
}
