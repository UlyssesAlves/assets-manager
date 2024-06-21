import 'package:assets_manager/model/data_model/asset.dart';
import 'package:assets_manager/model/data_model/item.dart';
import 'package:assets_manager/model/data_model/location.dart';

class TreeManager {
  List<Asset> _assets;
  List<Location> _locations;

  TreeManager(this._assets, this._locations);

  TreeNode? _treeRoot;

  /// The tree is a reference which points to its own root.
  /// Tree and treeRoot can thus be used interchangeably as it best fits the context at hand.
  TreeNode? get tree => _treeRoot;

  void buildTree() {
    // TODO: implement logic for building the tree.
  }
}
