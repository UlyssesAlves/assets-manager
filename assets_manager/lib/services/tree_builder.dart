import 'package:assets_manager/model/data_model/asset.dart';
import 'package:assets_manager/model/data_model/tree_node.dart';
import 'package:assets_manager/model/data_model/location.dart';

class TreeBuilder {
  final Map<String, Asset> _assets;
  final Map<String, Location> _locations;

  TreeBuilder(this._assets, this._locations);

  final TreeNode _rootNode = TreeNode("0", "ROOT NODE", parentId: null);

  Future<TreeNode> buildTree() async {
    for (var location in _locations.values) {
      if (location.isSubLocation) {
        var parentLocation = _locations[location.parentId];

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

    for (var asset in _assets.values) {
      if (!asset.isLinkedToALocation && !asset.hasParentId) {
        setRootAsParentNode(asset);
      } else if (asset.hasParentId) {
        var parentAsset = _assets[asset.parentId];

        if (parentAsset != null) {
          setParentNode(parentAsset, asset);
        } else {
          print(
              'Parent asset not found, so setting this asset to be a direct child of the root node.');

          setRootAsParentNode(asset);
        }
      } else {
        var parentLocation = _locations[asset.locationId];

        if (parentLocation != null) {
          setParentNode(parentLocation, asset);
        } else {
          print(
              'Parent location not found, so setting this asset to be a direct child of the root node.');

          setRootAsParentNode(asset);
        }
      }
    }

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
}
