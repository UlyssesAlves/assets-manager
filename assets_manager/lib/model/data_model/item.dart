/// Represents a generic item which can be part of the tree.
abstract class TreeNode {
  final String id;
  final String name;
  final String? parentId;

  TreeNode(this.id, this.name, {this.parentId});

  bool get isLinkedToAParentItem => parentId?.isNotEmpty ?? false;

  List<TreeNode>? children;
  TreeNode? parentNode;
}
