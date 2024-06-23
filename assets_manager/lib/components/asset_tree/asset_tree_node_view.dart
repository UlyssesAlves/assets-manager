import 'package:assets_manager/model/data_model/tree_node.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AssetTreeNodeView extends StatelessWidget {
  final TreeNode item;
  final Function(TreeNode) onNodeTap;

  const AssetTreeNodeView(
    this.item,
    this.onNodeTap, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> itemViewMainColumnComponents = [
      GestureDetector(
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
              Text(
                item.name,
                overflow: TextOverflow.fade,
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
    ];

    if (item.hasChildren && item.isExpanded) {
      List<Widget> itemChildrenViews = [];

      for (var child in item.children) {
        itemChildrenViews.add(AssetTreeNodeView(
          child,
          onNodeTap,
        ));
      }

      itemViewMainColumnComponents.add(
        Row(
          children: [
            // TODO: fix the vertical line, which is not showing up as it should at the left of each item on the tree.
            const Center(
              child: VerticalDivider(
                width: 20,
                thickness: 1,
                indent: 1,
                color: Colors.red,
              ),
            ),
            Column(
              children: itemChildrenViews,
            )
          ],
        ),
      );
    }

    return Column(
      children: itemViewMainColumnComponents,
    );
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
