import 'package:assets_manager/infrastructure/performance_counter.dart';
import 'package:assets_manager/model/data_model/tree_node.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AssetTreeNodeView extends StatelessWidget {
  final TreeNode item;
  final Function(TreeNode) onNodeTap;
  final Function(VisibilityInfo, TreeNode) onVisibilityChanged;

  final PerformanceCounter _performanceCounter = PerformanceCounter(false);

  AssetTreeNodeView(
    this.item,
    this.onNodeTap,
    this.onVisibilityChanged, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    _performanceCounter.trackActionStartTime(performanceCounterTrackingKey);

    List<Widget> itemViewMainColumnComponents = [
      VisibilityDetector(
        key: Key(item.toString()),
        onVisibilityChanged: (vi) {
          onVisibilityChanged(vi, item);
        },
        child: GestureDetector(
          onTap: () {
            onNodeTap(item);
          },
          child: SizedBox(
            height: 28,
            child: Row(
              children: [
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
                const SizedBox(width: 3),
                Text(
                  item.name,
                  overflow: TextOverflow.fade,
                ),
                const SizedBox(
                  width: 3,
                ),
                Visibility(
                  visible: item.hasEnergySensor,
                  maintainSize: false,
                  child: const Icon(
                    FontAwesomeIcons.boltLightning,
                    color: Colors.green,
                    size: 12,
                  ),
                ),
                Visibility(
                  visible: item.isInAlertStatus,
                  maintainSize: false,
                  child: const Icon(
                    FontAwesomeIcons.solidCircle,
                    color: Colors.red,
                    size: 8,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    ];

    if (item.hasChildren && item.isExpanded) {
      List<Widget> itemChildrenViews = [];

      for (var child in item.children) {
        itemChildrenViews
            .add(AssetTreeNodeView(child, onNodeTap, onVisibilityChanged));
      }

      itemViewMainColumnComponents.add(
        IntrinsicHeight(
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 3),
                child: VerticalDivider(
                  color: Colors.grey,
                  thickness: 1,
                ),
              ),
              Expanded(
                child: Column(
                  children: itemChildrenViews,
                ),
              )
            ],
          ),
        ),
      );
    }

    var nodeView = Column(
      children: itemViewMainColumnComponents,
    );

    _performanceCounter.trackActionFinishTime(performanceCounterTrackingKey);

    return nodeView;
  }

  String get performanceCounterTrackingKey => 'kActionBuildTreeNode $item';

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
