import 'package:assets_manager/model/data_model/asset.dart';
import 'package:assets_manager/model/data_model/item.dart';
import 'package:assets_manager/model/data_model/location.dart';

class TreeBuilder {
  final List<Asset> _assets;
  final List<Location> _locations;

  TreeBuilder(this._assets, this._locations);

  final TreeNode _rootNode = TreeNode("0", "ROOT NODE", parentId: null);

  TreeNode buildTree() {
    for (var asset in _assets) {
      if (asset.isLinkedToALocation &&
          _locations.any((l) => l.id == asset.locationId)) {
        var assetLocation =
            _locations.firstWhere((l) => l.id == asset.locationId);

        assetLocation.children.add(asset);
        asset.parentNode = assetLocation;
      } else if (asset.hasParentId &&
          _assets.any((a) => a.id == asset.parentId)) {
        var parentAsset = _assets.firstWhere((a) => a.id == asset.parentId);

        parentAsset.children.add(asset);
        asset.parentNode = parentAsset;
      } else {
        _rootNode.children.add(asset);
        asset.parentNode = _rootNode;
      }
    }

    for (var location in _locations) {
      if (location.isSubLocation) {
        var parentLocation =
            _locations.firstWhere((l) => l.id == location.parentId);

        parentLocation.children.add(location);
        location.parentNode = parentLocation;
      } else {
        _rootNode.children.add(location);
        location.parentNode = _rootNode;
      }
    }

    return _rootNode;
  }
}
