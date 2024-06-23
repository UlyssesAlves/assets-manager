import 'package:assets_manager/components/simple_button_with_icon.dart';
import 'package:assets_manager/constants/styles.dart';
import 'package:assets_manager/model/data_model/tree_node.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AssetPage extends StatefulWidget {
  AssetPage(this.assetsTree);

  final TreeNode assetsTree;

  @override
  _AssetPageState createState() => _AssetPageState();
}

class _AssetPageState extends State<AssetPage> {
  String textFilter = '';
  bool filterEnergySensor = false, filterCriticalSensorStatus = false;

  final scrollController = ScrollController();
  TreeNode paginatedAssetsTree = TreeNode('0', 'PAGINATED-TREE');

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
        textFilter = textFilterController?.text.toLowerCase() ?? '';
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

      if (filtersAreActive()) {
        toastMessage =
            "Remove the filters to view the new items justed loaded into the list.";
        toastBackgroundColor = Colors.brown;
      } else {
        toastMessage = "Scroll down to view more items.";
        toastBackgroundColor = Colors.black;
      }
    } else {
      totalItemsToAdd = totalItems - totalLoadedItems;
      toastMessage = 'Finished loading all items.';
      toastBackgroundColor = Colors.green;
    }

    paginatedAssetsTree.children.addAll(widget.assetsTree.children
        .getRange(totalLoadedItems, totalLoadedItems + totalItemsToAdd));

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
        title: const Text(
          'Assets',
          textAlign: TextAlign.center,
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
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
                ),
              ),
            ),
            Row(
              children: [
                SimpleButtonWithIcon(
                  'Sensor de Energia',
                  Icon(
                    FontAwesomeIcons.boltLightning,
                    size: 16,
                  ),
                  () {
                    setState(() {
                      filterEnergySensor = !filterEnergySensor;
                    });
                  },
                  foregroundColor:
                      buttonFilterForegroundColorByState[filterEnergySensor],
                  backgroundColor:
                      buttonFilterBackgroundColorByState[filterEnergySensor],
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
                      filterCriticalSensorStatus = !filterCriticalSensorStatus;
                    });
                  },
                  foregroundColor: buttonFilterForegroundColorByState[
                      filterCriticalSensorStatus],
                  backgroundColor: buttonFilterBackgroundColorByState[
                      filterCriticalSensorStatus],
                )
              ],
            ),
            const Divider(),
            // TODO: allow the user to horizontally scroll the assets tree to view text which goes beyond the screen limits.
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: totalLoadedItems,
                itemBuilder: ((context, index) {
                  var nodeToBuild = paginatedAssetsTree.children[index];

                  if (applyFilters(nodeToBuild)) {
                    if (filtersAreActive()) {
                      nodeToBuild.setCollapsed = false;
                    }

                    return buildItemView(nodeToBuild);
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool applyFilters(TreeNode item) =>
      item.matchesTextFilter(textFilter) &&
      item.matchesEnergySensorFilter(filterEnergySensor) &&
      item.matchesCriticalSensorStatusFilter(filterCriticalSensorStatus);

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
    return textFilter.isNotEmpty ||
        filterCriticalSensorStatus ||
        filterEnergySensor;
  }
}
