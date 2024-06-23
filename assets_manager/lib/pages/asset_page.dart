import 'package:assets_manager/components/simple_button_with_icon.dart';
import 'package:assets_manager/constants/styles.dart';
import 'package:assets_manager/infrastructure/performance_counter.dart';
import 'package:assets_manager/model/data_model/asset.dart';
import 'package:assets_manager/model/data_model/location.dart';
import 'package:assets_manager/model/data_model/tree_node.dart';
import 'package:assets_manager/services/tree_builder.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  String appliedTextFilter = '';
  String? textFilterCurrentValue;
  bool appliedFilterEnergySensor = false,
      appliedFilterCriticalSensorStatus = false;
  bool energySensorFilterButtonState = false,
      criticalSensorStatusFilterButtonState = false;
  PerformanceCounter performanceCounter = PerformanceCounter();

  final scrollController = ScrollController();
  TreeNode paginatedAssetsTree = TreeNode('0', 'PAGINATED-TREE');
  TreeNode searchTree = TreeNode('1', 'SEARCH-TREE');

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
            "Please remove the filters to load more items into the list.",
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

      toastMessage = "Scroll upwards to load more items.";
      toastBackgroundColor = Colors.black;
    } else {
      totalItemsToAdd = totalItems - totalLoadedItems;
      toastMessage = 'Finished loading all items.';
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
    return Scaffold(
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
                        hintText: 'Buscar Ativo ou Local (min 4 caracteres))',
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
                SizedBox(
                  width: 8,
                ),
                SimpleButtonWithIcon(
                  'Crítico',
                  Icon(
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
                        ? () {
                            setState(() {
                              appliedTextFilter =
                                  textFilterController?.text.toLowerCase() ??
                                      '';
                              appliedFilterEnergySensor =
                                  energySensorFilterButtonState;
                              appliedFilterCriticalSensorStatus =
                                  criticalSensorStatusFilterButtonState;

                              refreshSearchTree();
                            });
                          }
                        : null,
                    backgroundColor: shouldEnableApplyFiltersButton()
                        ? Colors.green
                        : Colors.grey,
                  ),
                ),
                SizedBox(
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
              visible: filtersAreActive() && !searchTree.hasChildren,
              child: Center(
                child: Text(
                  'Não foram encontrados itens com os filtros informados. Por favor, altere ou limpe os filtros e tente novamente.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            // TODO: allow the user to horizontally scroll the assets tree to view text which goes beyond the screen limits.
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: filtersAreActive()
                    ? searchTree.children.length
                    : totalLoadedItems,
                itemBuilder: ((context, index) {
                  if (filtersAreActive()) {
                    TreeNode filteredLeafNodeToBuild =
                        searchTree.children[index];

                    var performanceCounterKey =
                        'BuildItemViewFILTERED $filteredLeafNodeToBuild';

                    performanceCounter
                        .trackActionStartTime(performanceCounterKey);

                    var itemView = buildItemView(filteredLeafNodeToBuild);

                    performanceCounter
                        .trackActionFinishTime(performanceCounterKey);

                    performanceCounter.printWorsePerformanceTrackedSoFar();

                    return itemView;
                  } else {
                    var paginatedNodeToBuild =
                        paginatedAssetsTree.children[index];

                    var itemView = buildItemView(paginatedNodeToBuild);

                    return itemView;
                  }
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool shouldEnableApplyFiltersButton() {
    return (textFilterCurrentValue != null &&
            textFilterCurrentValue != '' &&
            textFilterCurrentValue!.length >= 4) ||
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

  Container buildItemView(TreeNode item) {
    List<Widget> itemViewMainColumnComponents = [
      GestureDetector(
        onTap: () {
          if (item.hasChildren) {
            setState(() {
              item.toggleCollapsedState();
            });
          }
        },
        child: Container(
          height: 28,
          child: Row(
            children: [
              // TODO: This icon should point to the right when this tree node is collapsed and downwards when the node is expanded.
              Visibility(
                visible: item.hasChildren,
                maintainSize: true,
                maintainState: true,
                maintainAnimation: true,
                child: Icon(
                  item.isExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                  size: 22,
                ),
              ),
              getItemIcon(item),
              Text(
                item.name,
                overflow: TextOverflow.fade,
              ),
              Visibility(
                visible: item.hasEnergySensor,
                maintainSize: false,
                child: Icon(
                  FontAwesomeIcons.boltLightning,
                  color: Colors.green,
                  size: 12,
                ),
              ),
              Visibility(
                visible: item.isInAlertStatus,
                maintainSize: false,
                child: Icon(
                  FontAwesomeIcons.solidCircle,
                  color: Colors.red,
                  size: 8,
                ),
              )
            ],
          ),
        ),
      ),
    ];

    if (item.hasChildren && item.isExpanded) {
      List<Widget> itemChildrenViews = [];

      for (var child in item.children) {
        if (applyFilters(child)) {
          if (filtersAreActive()) {
            child.setCollapsed = false;
          }

          itemChildrenViews.add(buildItemView(child));
        }
      }

      itemViewMainColumnComponents.add(
        Container(
          child: Row(
            children: [
              // TODO: fix the vertical line, which is not showing up as it should at the left of each item on the tree.
              VerticalDivider(
                width: 20,
                thickness: 1,
                indent: 1,
                color: Colors.red,
              ),
              Column(
                children: itemChildrenViews,
              )
            ],
          ),
        ),
      );
    }

    var itemView = Container(
      child: Column(
        children: itemViewMainColumnComponents,
      ),
    );

    return itemView;
  }

  Image getItemIcon(TreeNode item) {
    String iconImageFileNameWithoutExtension;

    if (item.isLocation) {
      iconImageFileNameWithoutExtension = 'location';
    } else if (item.isComponent) {
      iconImageFileNameWithoutExtension = 'component';
    } else {
      iconImageFileNameWithoutExtension = 'asset';
    }

    return Image.asset(
      'images/$iconImageFileNameWithoutExtension.png',
      height: 22,
      width: 22,
    );
  }

  bool filtersAreActive() {
    return appliedTextFilter.isNotEmpty ||
        appliedFilterCriticalSensorStatus ||
        appliedFilterEnergySensor;
  }

  void refreshSearchTree() {
    performanceCounter.trackActionStartTime(kActionRefreshSearchTreeCall);

    Map<String, Asset> searchTreeAssets = {};
    Map<String, Location> searchTreeLocations = {};

    if (filtersAreActive()) {
      performanceCounter.trackActionStartTime(kGetLeafNodesFilterResults);

      var leafNodesFilterResults =
          widget.leafNodes.where((n) => applyFilters(n)).toList();

      performanceCounter.trackActionFinishTime(kGetLeafNodesFilterResults);

      performanceCounter.trackActionStartTime(kLoopleafNodesFilterResults);

      for (var leafNode in leafNodesFilterResults) {
        TreeNode currentNode = leafNode;

        currentNode.setCollapsed = false;

        while (!currentNode.isRootNode) {
          if (currentNode.isAsset &&
              !searchTreeAssets.containsKey(currentNode.id)) {
            var currentNodeCopy = currentNode.copy() as Asset;

            currentNodeCopy.setCollapsed = false;
            getMapNodeReference(currentNode)?.setCollapsed = false;

            searchTreeAssets[currentNode.id] = currentNodeCopy;
          } else if (currentNode.isLocation &&
              !searchTreeLocations.containsKey(currentNode.id)) {
            var currentNodeCopy = currentNode.copy() as Location;

            currentNodeCopy.setCollapsed = false;
            getMapNodeReference(currentNode)?.setCollapsed = false;

            searchTreeLocations[currentNode.id] = currentNodeCopy;
          }

          currentNode = currentNode.parentNode!;
        }
      }

      performanceCounter.trackActionFinishTime(kLoopleafNodesFilterResults);
    } else {
      performanceCounter.trackActionStartTime(kCollapseAllNodes);

      collapseAllNodes();

      performanceCounter.trackActionFinishTime(kCollapseAllNodes);
    }

    performanceCounter.trackActionStartTime(kBuildSearchTree);

    TreeBuilder searchTreeBuilder =
        TreeBuilder(searchTreeAssets, searchTreeLocations);

    searchTree = searchTreeBuilder.buildTree();

    performanceCounter.trackActionFinishTime(kBuildSearchTree);

    performanceCounter.trackActionFinishTime(kActionRefreshSearchTreeCall);

    performanceCounter.printPerformanceReport();
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
