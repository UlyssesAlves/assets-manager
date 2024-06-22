/// Represents a generic item which can be part of the tree.
class TreeNode {
  final String id;
  final String name;
  final String? parentId;

  TreeNode(this.id, this.name, {this.parentId});

  bool get hasParentId => parentId?.isNotEmpty ?? false;

  List<TreeNode> children = [];
  TreeNode? parentNode;
}
