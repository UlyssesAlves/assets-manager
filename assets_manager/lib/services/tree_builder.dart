import 'package:assets_manager/model/data_model/tree_node.dart';
import 'package:assets_manager/model/search_tree_blue_print.dart';

class TreeBuilder {
  final SearchTreeBluePrint _bluePrint;
  final Map<String, TreeNode> _leafNodes = {};
  Map<String, TreeNode> get leafNodes => _leafNodes;

  TreeBuilder(this._bluePrint);

  final TreeNode _rootNode = TreeNode(kRootNodeId, kRootNodeId, parentId: null);

  TreeNode buildTree() {
    for (var location in _bluePrint.searchTreeLocations!.values) {
      if (location.isSubLocation) {
        var parentLocation = _bluePrint.searchTreeLocations![location.parentId];

        if (parentLocation != null) {
          setParentNode(parentLocation, location);
        } else {
          print(
              'Parent location not found, so setting this location to be a direct child of the root node.');

          setRootAsParentNode(location);
        }
      } else {
        setRootAsParentNode(location);
      }
    }

    for (var asset in _bluePrint.searchTreeAssets!.values) {
      if (!asset.isLinkedToALocation && !asset.hasParentId) {
        setRootAsParentNode(asset);
      } else if (asset.hasParentId) {
        var parentAsset = _bluePrint.searchTreeAssets![asset.parentId];

        if (parentAsset != null) {
          setParentNode(parentAsset, asset);
        } else {
          print(
              'Parent asset not found, so setting this asset to be a direct child of the root node.');

          setRootAsParentNode(asset);
        }
      } else {
        var parentLocation = _bluePrint.searchTreeLocations![asset.locationId];

        if (parentLocation != null) {
          setParentNode(parentLocation, asset);
        } else {
          print(
              'Parent location not found, so setting this asset to be a direct child of the root node.');

          setRootAsParentNode(asset);
        }
      }
    }

    _setLeafNodes();

    return _rootNode;
  }

  void setParentNode(TreeNode parent, TreeNode child) {
    parent.addChild(child);
    child.parentNode = parent;
  }

  void setRootAsParentNode(TreeNode node) {
    _rootNode.addChild(node);
    node.parentNode = _rootNode;
  }

  void _setLeafNodes() {
    for (var location in _bluePrint.searchTreeLocations!.values
        .where((l) => !l.hasChildren)) {
      _leafNodes[location.id] = location;
    }

    for (var asset
        in _bluePrint.searchTreeAssets!.values.where((a) => !a.hasChildren)) {
      _leafNodes[asset.id] = asset;
    }
  }
}
