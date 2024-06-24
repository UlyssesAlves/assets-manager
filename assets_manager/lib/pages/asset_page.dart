import 'package:assets_manager/components/asset_tree/asset_tree_node_view.dart';
import 'package:assets_manager/components/simple_button_with_icon.dart';
import 'package:assets_manager/constants/styles.dart';
import 'package:assets_manager/infrastructure/performance_counter.dart';
import 'package:assets_manager/model/data_model/asset.dart';
import 'package:assets_manager/model/data_model/filter_cache_item.dart';
import 'package:assets_manager/model/data_model/location.dart';
import 'package:assets_manager/model/data_model/tree_node.dart';
import 'package:assets_manager/services/tree_builder.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AssetPage extends StatefulWidget {
  AssetPage(this.assetsTree, this.companyName, this.companyAssetsMap,
      this.companyLocationsMap, this.leafNodes);

  final TreeNode assetsTree;
  final List<TreeNode> leafNodes;
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

                            await Future.delayed(
                                const Duration(milliseconds: 750));

                            setState(() {
                              refreshSearchTree();
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

                        refreshSearchTree();
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

  bool applyFilters(TreeNode item) =>
      item.matchesTextFilter(appliedTextFilter) &&
      item.matchesEnergySensorFilter(appliedFilterEnergySensor) &&
      item.matchesCriticalSensorStatusFilter(appliedFilterCriticalSensorStatus);

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
    searchTree = buildSearchTree({}, {});
  }

  void refreshSearchTree() {
    performanceCounter.trackActionStartTime(kActionRefreshSearchTreeCall);

    if (!filtersAreActive()) {
      collapseAllNodes();
    }

    searchTree = getNewSearchTree();

    performanceCounter.trackActionFinishTime(kActionRefreshSearchTreeCall);
  }

  TreeNode getNewSearchTree() {
    Map<String, Asset> searchTreeAssets = {};
    Map<String, Location> searchTreeLocations = {};

    final FilterCacheKey filterCacheKey = FilterCacheKey(appliedTextFilter,
        appliedFilterEnergySensor, appliedFilterCriticalSensorStatus);

    if (filtersAreActive()) {
      if (searchTreeCache.containsKey(filterCacheKey.key)) {
        print('Using search tree from cache.');

        return searchTreeCache[filterCacheKey.key]!;
      }

      resetCacheAutomaticallyExpandedNodesAfterLatestFilterApplication();

      List<TreeNode> leafNodesFilterResults = getLeafNodesFilterResults();

      for (var leafNode in leafNodesFilterResults) {
        TreeNode currentNode = leafNode;

        while (!currentNode.isRootNode) {
          if (currentNode.isAsset &&
              !searchTreeAssets.containsKey(currentNode.id)) {
            var currentNodeCopy = currentNode.copy() as Asset;

            searchTreeAssets[currentNode.id] = currentNodeCopy;
          } else if (currentNode.isLocation &&
              !searchTreeLocations.containsKey(currentNode.id)) {
            var currentNodeCopy = currentNode.copy() as Location;

            searchTreeLocations[currentNode.id] = currentNodeCopy;
          }

          currentNode = currentNode.parentNode!;
        }
      }
    }

    var newSearchTree = buildSearchTree(searchTreeAssets, searchTreeLocations);

    if (filtersAreActive()) {
      searchTreeCache[filterCacheKey.key] = newSearchTree;
    }

    return newSearchTree;
  }

  TreeNode buildSearchTree(Map<String, Asset> searchTreeAssets,
      Map<String, Location> searchTreeLocations) {
    TreeBuilder searchTreeBuilder =
        TreeBuilder(searchTreeAssets, searchTreeLocations);

    return searchTreeBuilder.buildTree();
  }

  List<TreeNode> getLeafNodesFilterResults() {
    List<TreeNode> leafNodesFilterResults = [];

    for (var leaf in widget.leafNodes) {
      TreeNode? no = leaf;

      while (!no!.isRootNode) {
        if (applyFilters(no)) {
          leafNodesFilterResults.add(no);

          break;
        } else {
          no = no.parentNode;
        }
      }
    }
    return leafNodesFilterResults;
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
