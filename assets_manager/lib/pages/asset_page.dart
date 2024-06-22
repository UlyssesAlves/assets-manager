import 'package:assets_manager/components/simple_button_with_icon.dart';
import 'package:assets_manager/constants/styles.dart';
import 'package:assets_manager/model/data_model/item.dart';
import 'package:flutter/material.dart';
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

    textFilterController?.addListener(() {
      setState(() {
        textFilter = textFilterController?.text.toLowerCase() ?? '';
      });
    });
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
              child: ListView(
                children: renderAssetsTreeView(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TODO: improve the performance of the assets tree view by rendering it in parts rather than in total.
  List<Widget> renderAssetsTreeView() {
    List<Widget> assetsTreeView = [];

    for (var item in widget.assetsTree.children) {
      if (applyFilters(item)) {
        Container itemView = buildItemView(item);

        assetsTreeView.add(itemView);
      }
    }

    if (assetsTreeView.isEmpty) {
      assetsTreeView.add(Center(
        child: Text(
          'No assets match the provided filter. Please try changing the filters to view assets.',
          style: TextStyle(
            fontStyle: FontStyle.italic,
          ),
        ),
      ));
    }

    return assetsTreeView;
  }

  bool applyFilters(TreeNode item) =>
      item.matchesTextFilter(textFilter) &&
      item.matchesEnergySensorFilter(filterEnergySensor) &&
      item.matchesCriticalSensorStatusFilter(filterCriticalSensorStatus);

  Container buildItemView(TreeNode item) {
    List<Widget> itemViewMainColumnComponents = [
      Row(
        children: [
          // TODO: This icon should point to the right when this tree node is collapsed and downwards when the node is expanded.
          Visibility(
            visible: item.hasChildren,
            child: const Icon(
              Icons.keyboard_arrow_down,
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
    ];

    if (item.hasChildren) {
      List<Widget> itemChildrenViews = [];

      for (var child in item.children) {
        if (applyFilters(child)) {
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
}
