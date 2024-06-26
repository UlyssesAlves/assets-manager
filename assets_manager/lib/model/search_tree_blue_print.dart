import 'package:assets_manager/model/data_model/asset.dart';
import 'package:assets_manager/model/data_model/location.dart';

class SearchTreeBluePrint {
  SearchTreeBluePrint(this.searchTreeAssets, this.searchTreeLocations);

  SearchTreeBluePrint.empty() {
    searchTreeAssets = {};
    searchTreeLocations = {};
  }

  Map<String, Asset>? searchTreeAssets;
  Map<String, Location>? searchTreeLocations;
}
