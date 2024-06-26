import 'dart:convert';
import 'dart:isolate';

import 'package:assets_manager/components/asset_tree/asset_tree_node_view.dart';
import 'package:assets_manager/components/simple_button_with_icon.dart';
import 'package:assets_manager/constants/styles.dart';
import 'package:assets_manager/infrastructure/performance_counter.dart';
import 'package:assets_manager/model/data_model/asset.dart';
import 'package:assets_manager/model/data_model/filter_cache_item.dart';
import 'package:assets_manager/model/data_model/location.dart';
import 'package:assets_manager/model/data_model/tree_node.dart';
import 'package:assets_manager/model/search_tree_blue_print.dart';
import 'package:assets_manager/services/tree_builder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AssetPage extends StatefulWidget {
  AssetPage(this.assetsTree, this.companyName, this.companyAssetsMap,
      this.companyLocationsMap, this.leafNodes);

  final TreeNode assetsTree;
  final Map<String, TreeNode> leafNodes;
  final Map<String, Asset> companyAssetsMap;
  final Map<String, Location> companyLocationsMap;
  final String companyName;

  @override
  _AssetPageState createState() => _AssetPageState();
}

class _AssetPageState extends State<AssetPage> {
  PerformanceCounter performanceCounter = PerformanceCounter(false);
  String appliedTextFilter = '';
  String? textFilterCurrentValue;
  bool appliedFilterEnergySensor = false,
      appliedFilterCriticalSensorStatus = false;
  bool energySensorFilterButtonState = false,
      criticalSensorStatusFilterButtonState = false;
  bool applyingFilters = false;

  final scrollController = ScrollController();
  TreeNode paginatedAssetsTree = TreeNode('0', 'PAGINATED-TREE');
  TreeNode searchTree = TreeNode('1', 'SEARCH-TREE');
  Map<String, bool> automaticallyExpandedNodesAfterLatestFilterApplication = {};
  Map<String, TreeNode> searchTreeCache = {};
  double assetsTreeListViewBuildingProgress = 0.0;

  /// How many items are loaded to increase the tree each time the user hits the bottom of the scroller.
  final pageSize = 50;

  Map<bool, Color> buttonFilterForegroundColorByState = {
    true: Colors.white,
    false: kAssetsSearchInactiveFilterForegroundColor
  };

  Map<bool, Color> buttonFilterBackgroundColorByState = {
    true: Color.fromARGB(255, 33, 136, 255),
    false: kAssetsSearchInactiveFilterBackgroundColor
  };

  TextEditingController? textFilterController = TextEditingController();

  @override
  void initState() {
    super.initState();

    performanceCounter.reset();

    addMoreItemsToPaginatedTree();

    scrollController.addListener(loadMoreItems);

    textFilterController?.addListener(() {
      setState(() {
        textFilterCurrentValue = textFilterController?.text;
      });
    });
  }

  @override
  void dispose() {
    scrollController.dispose();

    super.dispose();
  }

  void loadMoreItems() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (filtersAreActive() && totalLoadedItems < totalItems) {
        showToastMessage(
            "Por favor remova os filtros para carregar mais itens na lista.",
            Colors.brown);

        return;
      }

      if (totalLoadedItems == totalItems) {
        return;
      }

      setState(() {
        addMoreItemsToPaginatedTree();
      });
    }
  }

  int get totalItems {
    return widget.assetsTree.children.length;
  }

  int get totalLoadedItems {
    return paginatedAssetsTree.children.length;
  }

  void addMoreItemsToPaginatedTree() {
    int totalItemsToAdd = 0;
    String toastMessage = '';
    Color toastBackgroundColor;

    if (totalItems - totalLoadedItems > pageSize) {
      totalItemsToAdd = pageSize;

      toastMessage = "Role para baixo para carregar mais itens.";
      toastBackgroundColor = Colors.black;
    } else {
      totalItemsToAdd = totalItems - totalLoadedItems;
      toastMessage = 'Carregamento dos assets concluído.';
      toastBackgroundColor = Colors.green;
    }

    paginatedAssetsTree.children.addAll(widget.assetsTree.children
        .getRange(totalLoadedItems, totalLoadedItems + totalItemsToAdd));

    showToastMessage(toastMessage, toastBackgroundColor);
  }

  void showToastMessage(String toastMessage, Color toastBackgroundColor) {
    Fluttertoast.showToast(
        msg: toastMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: toastBackgroundColor,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    performanceCounter.trackActionStartTime(kActionBuildAssetsPage);

    final widgetTree = Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.companyName} Assets',
          textAlign: TextAlign.center,
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: TextField(
                      controller: textFilterController,
                      style: const TextStyle(
                        color: kAssetsSearchInactiveFilterForegroundColor,
                        fontFamily: 'Regular',
                        fontSize: 14,
                      ),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color.fromARGB(255, 234, 239, 243),
                        hintText: 'Buscar Ativo ou Local',
                        prefixIcon: Icon(
                          FontAwesomeIcons.magnifyingGlass,
                          color: kAssetsSearchInactiveFilterForegroundColor,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SimpleButtonWithIcon(
                  'Sensor de Energia',
                  const Icon(
                    FontAwesomeIcons.boltLightning,
                    size: 16,
                  ),
                  () {
                    setState(() {
                      energySensorFilterButtonState =
                          !energySensorFilterButtonState;
                    });
                  },
                  foregroundColor: buttonFilterForegroundColorByState[
                      energySensorFilterButtonState],
                  backgroundColor: buttonFilterBackgroundColorByState[
                      energySensorFilterButtonState],
                ),
                const SizedBox(
                  width: 8,
                ),
                SimpleButtonWithIcon(
                  'Crítico',
                  const Icon(
                    FontAwesomeIcons.circleExclamation,
                    size: 16,
                  ),
                  () {
                    setState(() {
                      criticalSensorStatusFilterButtonState =
                          !criticalSensorStatusFilterButtonState;
                    });
                  },
                  foregroundColor: buttonFilterForegroundColorByState[
                      criticalSensorStatusFilterButtonState],
                  backgroundColor: buttonFilterBackgroundColorByState[
                      criticalSensorStatusFilterButtonState],
                )
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: SimpleButtonWithIcon(
                    'Aplicar Filtros',
                    const Icon(
                      FontAwesomeIcons.magnifyingGlass,
                      size: 16,
                    ),
                    shouldEnableApplyFiltersButton()
                        ? () async {
                            setState(() {
                              applyingFilters = true;

                              appliedTextFilter =
                                  textFilterController?.text.toLowerCase() ??
                                      '';
                              appliedFilterEnergySensor =
                                  energySensorFilterButtonState;
                              appliedFilterCriticalSensorStatus =
                                  criticalSensorStatusFilterButtonState;

                              clearSearchTree();
                            });

                            await refreshSearchTree();

                            setState(() {
                              applyingFilters = false;
                            });
                          }
                        : null,
                    backgroundColor: shouldEnableApplyFiltersButton()
                        ? Colors.green
                        : Colors.grey,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: SimpleButtonWithIcon(
                    'Resetar Filtros',
                    const Icon(
                      FontAwesomeIcons.ban,
                      size: 16,
                    ),
                    () {
                      setState(() {
                        textFilterController?.clear();
                        appliedTextFilter = '';

                        appliedFilterEnergySensor = false;
                        energySensorFilterButtonState = false;

                        appliedFilterCriticalSensorStatus = false;
                        criticalSensorStatusFilterButtonState = false;

                        clearSearchTree();
                      });
                    },
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
            const Divider(),
            Visibility(
              visible: !applyingFilters &&
                  filtersAreActive() &&
                  !searchTree.hasChildren,
              child: const Center(
                child: Text(
                  'Não foram encontrados itens com os filtros informados. Por favor, altere ou limpe os filtros e tente novamente.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            Center(
              child: Visibility(
                visible: applyingFilters,
                child: Column(
                  children: [
                    Text('Aplicando filtros. Por favor, aguarde...'),
                    SizedBox(
                      height: 10,
                    ),
                    CircularProgressIndicator(
                      value: null,
                    ),
                  ],
                ),
              ),
            ),
            // TODO: allow the user to horizontally scroll the assets tree to view text which goes beyond the screen limits.
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: getAssetsTreeListViewItemsCount(),
                itemBuilder: ((context, index) {
                  assetsTreeListViewBuildingProgress =
                      index / getAssetsTreeListViewItemsCount();

                  TreeNode treeNodeToBuild;

                  if (filtersAreActive()) {
                    treeNodeToBuild = searchTree.children[index];
                  } else {
                    treeNodeToBuild = paginatedAssetsTree.children[index];
                  }

                  return AssetTreeNodeView(
                    treeNodeToBuild,
                    nodeItemTap,
                    nodeVisibilityChanged,
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );

    performanceCounter.trackActionFinishTime(kActionBuildAssetsPage);

    performanceCounter.printPerformanceReport();

    return widgetTree;
  }

  int getAssetsTreeListViewItemsCount() {
    return filtersAreActive() ? searchTree.children.length : totalLoadedItems;
  }

  bool shouldEnableApplyFiltersButton() {
    return (textFilterCurrentValue != null && textFilterCurrentValue != '') ||
        energySensorFilterButtonState ||
        criticalSensorStatusFilterButtonState;
  }

  TreeNode? getMapNodeReference(TreeNode node) {
    return node.isLocation
        ? widget.companyLocationsMap[node.id]
        : widget.companyAssetsMap[node.id];
  }

  void nodeItemTap(TreeNode tappedItem) {
    if (tappedItem.hasChildren) {
      setState(() {
        tappedItem.toggleCollapsedState();
      });
    }
  }

  void nodeVisibilityChanged(VisibilityInfo visibilityInfo, TreeNode node) {
    bool nodeIsFullyVisible = visibilityInfo.visibleFraction > 0;

    bool shouldAutomaticallyExpandNode = nodeIsFullyVisible &&
        node.hasChildren &&
        node.isCollapsed &&
        filtersAreActive();

    if (shouldAutomaticallyExpandNode) {
      var nodeHasAlreadyBeenAutomaticallyExpandedAfterLatestFilterApplication =
          automaticallyExpandedNodesAfterLatestFilterApplication[
              node.toString()];

      if (nodeHasAlreadyBeenAutomaticallyExpandedAfterLatestFilterApplication ==
          true) {
        return;
      }

      automaticallyExpandedNodesAfterLatestFilterApplication[node.toString()] =
          true;

      setState(() {
        node.expand();
      });
    }
  }

  bool filtersAreActive() {
    return appliedTextFilter.isNotEmpty ||
        appliedFilterCriticalSensorStatus ||
        appliedFilterEnergySensor;
  }

  void clearSearchTree() {
    searchTree = buildSearchTree(SearchTreeBluePrint.empty());
  }

  Future<void> refreshSearchTree() async {
    performanceCounter.trackActionStartTime(kActionRefreshSearchTreeCall);

    if (!filtersAreActive()) {
      collapseAllNodes();
    }

    if (searchTreeCache.containsKey(currentlyAppliedFilterCacheKey.key)) {
      print('Using search tree from cache.');

      searchTree = searchTreeCache[currentlyAppliedFilterCacheKey.key]!;
    } else {
      performanceCounter.trackActionStartTime(kCreateNewSearchTree);

      searchTree = await createNewSearchTree();

      performanceCounter.trackActionFinishTime(kCreateNewSearchTree);
    }

    performanceCounter.trackActionFinishTime(kActionRefreshSearchTreeCall);
  }

  FilterCacheKey get currentlyAppliedFilterCacheKey => FilterCacheKey(
      appliedTextFilter,
      appliedFilterEnergySensor,
      appliedFilterCriticalSensorStatus);

  Future<TreeNode> createNewSearchTree() async {
    resetCacheAutomaticallyExpandedNodesAfterLatestFilterApplication();

    String leafNodesJson = jsonEncode(widget.leafNodes);
    String companyAssetsJson = jsonEncode(widget.companyAssetsMap);
    String companyLocationsJson = jsonEncode(widget.companyLocationsMap);

    String leafNodesFilterResultsJson = await compute(isolateProcessor, [
      leafNodesJson,
      companyAssetsJson,
      companyLocationsJson,
      appliedTextFilter,
      appliedFilterEnergySensor,
      appliedFilterCriticalSensorStatus
    ]);

    final idsLeafNodesFilterResults = jsonDecode(leafNodesFilterResultsJson);

    List<TreeNode> leafNodesFilterResults = [];

    leafNodesFilterResults.addAll(widget.companyAssetsMap.values
        .where((asset) => idsLeafNodesFilterResults.contains(asset.id)));

    leafNodesFilterResults.addAll(widget.companyLocationsMap.values
        .where((location) => idsLeafNodesFilterResults.contains(location.id)));

    performanceCounter.trackActionStartTime(kCreateSearchTreeBluePrint);

    SearchTreeBluePrint bluePrint =
        createSearchTreeBluePrint(leafNodesFilterResults);

    performanceCounter.trackActionFinishTime(kCreateSearchTreeBluePrint);

    performanceCounter.trackActionStartTime(kBuildSearchTree);

    var newSearchTree = buildSearchTree(bluePrint);

    searchTreeCache[currentlyAppliedFilterCacheKey.key] = newSearchTree;

    performanceCounter.trackActionFinishTime(kBuildSearchTree);

    return newSearchTree;
  }

  SearchTreeBluePrint createSearchTreeBluePrint(
      List<TreeNode> leafNodesFilterResults) {
    SearchTreeBluePrint searchTreeBluePrint = SearchTreeBluePrint.empty();

    for (var leafNode in leafNodesFilterResults) {
      TreeNode currentNode = leafNode;

      while (!currentNode.isRootNode) {
        if (currentNode.isAsset &&
            !searchTreeBluePrint.searchTreeAssets!
                .containsKey(currentNode.id)) {
          var currentNodeCopy = currentNode.copy() as Asset;

          searchTreeBluePrint.searchTreeAssets![currentNode.id] =
              currentNodeCopy;
        } else if (currentNode.isLocation &&
            !searchTreeBluePrint.searchTreeLocations!
                .containsKey(currentNode.id)) {
          var currentNodeCopy = currentNode.copy() as Location;

          searchTreeBluePrint.searchTreeLocations![currentNode.id] =
              currentNodeCopy;
        }

        if (searchTreeBluePrint.searchTreeAssets!
            .containsKey(currentNode.parentNode!.id)) {
          break;
        }

        currentNode = currentNode.parentNode!;
      }
    }

    return searchTreeBluePrint;
  }

  TreeNode buildSearchTree(SearchTreeBluePrint bluePrint) {
    TreeBuilder searchTreeBuilder = TreeBuilder(bluePrint);

    return searchTreeBuilder.buildTree();
  }

  void resetCacheAutomaticallyExpandedNodesAfterLatestFilterApplication() {
    for (var key
        in automaticallyExpandedNodesAfterLatestFilterApplication.keys) {
      automaticallyExpandedNodesAfterLatestFilterApplication[key] = false;
    }
  }

  void collapseAllNodes() {
    for (var asset in widget.companyAssetsMap.values) {
      asset.setCollapsed = true;
    }

    for (var location in widget.companyLocationsMap.values) {
      location.setCollapsed = true;
    }
  }
}

String getLeafNodesFilterResults(
  String leafNodesJson,
  String companyAssetsJson,
  String companyLocationsJson,
  String appliedTextFilter,
  bool appliedFilterEnergySensor,
  bool appliedFilterCriticalSensorStatus,
) {
  Map<String, dynamic> leafNodesFilterResultsMap = {};

  Map<String, dynamic> leafNodesMap = decodeNodesMap(leafNodesJson),
      companyAssetsMap = decodeNodesMap(companyAssetsJson),
      companyLocationsMap = decodeNodesMap(companyLocationsJson);

  for (dynamic nodeMap in leafNodesMap.values) {
    while (nodeMap != null) {
      if (!leafNodesFilterResultsMap.containsKey(nodeMap['id']) &&
          applyFilters(nodeMap, appliedTextFilter, appliedFilterEnergySensor,
              appliedFilterCriticalSensorStatus)) {
        leafNodesFilterResultsMap[nodeMap['id']] = nodeMap;
      }

      if (nodeMap['locationId'] != null) {
        nodeMap = companyLocationsMap[nodeMap['locationId']];
      } else if (nodeMap['parentId'] != null) {
        nodeMap = companyAssetsMap[nodeMap['parentId']] ??
            companyLocationsMap[nodeMap['parentId']];
      } else {
        nodeMap = null;
      }
    }
  }

  return jsonEncode(leafNodesFilterResultsMap.keys.toList());
}

bool nodeMapHasParentNode(nodeMap) {
  return nodeMap['locationId'] != null || nodeMap['parentId'] != null;
}

Map<String, dynamic> decodeNodesMap(String leafNodesJson) =>
    jsonDecode(leafNodesJson) as Map<String, dynamic>;

bool applyFilters(dynamic item, String appliedTextFilter,
    bool appliedFilterEnergySensor, bool appliedFilterCriticalSensorStatus) {
  bool matchesTextFilter = appliedTextFilter.isEmpty ||
      item['name'].toLowerCase().contains(appliedTextFilter.toLowerCase());

  bool matchesEnergySensorFilter =
      !appliedFilterEnergySensor || item['sensorType'] == 'energy';

  bool matchesCriticalSensorStatusFilter =
      !appliedFilterCriticalSensorStatus || item['status'] == 'alert';

  return matchesTextFilter &&
      matchesEnergySensorFilter &&
      matchesCriticalSensorStatusFilter;
}

String isolateProcessor(List<dynamic> params) {
  return getLeafNodesFilterResults(
      params[0], params[1], params[2], params[3], params[4], params[5]);
}
