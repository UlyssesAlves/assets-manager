import 'package:assets_manager/model/data_model/asset.dart';
import 'package:assets_manager/model/data_model/location.dart';

const String kRootNodeId = "ROOT NODE";

/// Represents a generic item which can be part of the tree.
class TreeNode {
  final String id;
  final String name;
  final String? parentId;

  TreeNode(this.id, this.name, {this.parentId});

  bool get hasParentId => parentId?.isNotEmpty ?? false;

  bool get isRootNode => id == kRootNodeId && name == kRootNodeId;

  List<TreeNode> _children = [];
  TreeNode? _parentNode;
  bool _collapsed = true;

  bool get isExpanded => !isCollapsed;

  set setCollapsed(bool value) {
    _collapsed = value;
  }

  void expand() {
    setCollapsed = false;
  }

  /// Expands this node if it's collapsed and collaps it if it's expanded.
  void toggleCollapsedState() {
    _collapsed = !_collapsed;
  }

  set parentNode(TreeNode? parent) {
    _parentNode = parent;
  }

  TreeNode? get parentNode => _parentNode;

  List<TreeNode> get children => _children;

  void addChild(TreeNode child) {
    _children.add(child);
  }

  bool get isLocation => this is Location;
  bool get isCollapsed => _collapsed;
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

  bool matchesCriticalSensorStatusFilter(bool filterCriticalSensorStatus) {
    if (!filterCriticalSensorStatus) {
      return true;
    } else if (isInAlertStatus == filterCriticalSensorStatus) {
      return true;
    } else {
      for (var child in children) {
        if (child
            .matchesCriticalSensorStatusFilter(filterCriticalSensorStatus)) {
          return true;
        }
      }
    }

    return false;
  }

  bool matchesEnergySensorFilter(bool filterEnergySensor) {
    if (!filterEnergySensor) {
      return true;
    } else if (hasEnergySensor == filterEnergySensor) {
      return true;
    } else {
      for (var child in children) {
        if (child.matchesEnergySensorFilter(filterEnergySensor)) {
          return true;
        }
      }
    }

    return false;
  }

  TreeNode copy() {
    return TreeNode(id, name, parentId: parentId);
  }

  @override
  String toString() {
    if (this is Asset) {
      return (this as Asset).toString();
    } else {
      return (this as Location).toString();
    }
  }
}
