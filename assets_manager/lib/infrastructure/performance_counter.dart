import 'package:assets_manager/infrastructure/performance_counter_item.dart';

const kActionRefreshSearchTreeCall = 'refreshSearchTreeCall';
const kGetLeafNodesFilterResults = 'getLeafNodesFilterResults';
const kLoopleafNodesFilterResults = 'LoopleafNodesFilterResults';
const kCollapseAllNodes = 'collapseAllNodes';
const kBuildSearchTree = 'buildSearchTree';

class PerformanceCounter {
  Map<String, PerformanceCounterItem> _actionsMap = {};

  void trackActionStartTime(String key) {
    final now = DateTime.now();

    _actionsMap[key] = PerformanceCounterItem(key, DateTime.now());

    print('Action $key started at $now');
  }

  void trackActionFinishTime(String key) {
    final now = DateTime.now();

    if (!_actionsMap.containsKey(key)) {
      throw Exception(
          'Cannot track the finish time for an action which start time has not been tracked.');
    }

    _actionsMap[key]?.finishTime = now;

    print('Action $key finished at $now');
  }

  void printWorsePerformanceTrackedSoFar() {
    print('### WORSE PERFORMANCE TRACKED SO FAR ###');

    var worsePerformanceAction = getlistOfActionsOrderedByPerformance().last;

    print(
        'Action ${worsePerformanceAction.key} took ${worsePerformanceAction.ellapsedTime} to execute.');
  }

  void printPerformanceReport() {
    print('### PERFORMANCE REPORT ###');

    List<PerformanceCounterItem> listOfActions =
        getlistOfActionsOrderedByPerformance();

    for (var action in listOfActions) {
      print(
          '${listOfActions.indexOf(action) + 1}º Action ${action.key} took ${action.ellapsedTime} to execute.');
    }
  }

  List<PerformanceCounterItem> getlistOfActionsOrderedByPerformance() {
    var listOfActions = _actionsMap.values.toList();

    listOfActions.sort();

    return listOfActions;
  }
}
