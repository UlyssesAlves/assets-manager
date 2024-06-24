import 'package:assets_manager/infrastructure/performance_counter_item.dart';

const kActionRefreshSearchTreeCall = 'refreshSearchTreeCall';
const kGetLeafNodesFilterResults = 'getLeafNodesFilterResults';
const kLoopleafNodesFilterResults = 'LoopleafNodesFilterResults';
const kCollapseAllNodes = 'collapseAllNodes';
const kBuildSearchTree = 'buildSearchTree';
const kActionBuildAssetsPage = 'BuildAssetsPage';
const kActionBuildTreeNode = 'BuildTreeNode';

class PerformanceCounter {
  static final PerformanceCounter _instance = PerformanceCounter._internal();

  factory PerformanceCounter(bool logActionsTracking) {
    return _instance..logActionsTracking = logActionsTracking;
  }

  bool logActionsTracking = true;

  PerformanceCounter._internal();

  Map<String, PerformanceCounterItem> _actionsMap = {};

  void trackActionStartTime(String key) {
    final now = DateTime.now();

    _actionsMap[key] = PerformanceCounterItem(key, DateTime.now());

    if (logActionsTracking) {
      print('Action $key started at $now');
    }
  }

  void trackActionFinishTime(String key) {
    final now = DateTime.now();

    if (!_actionsMap.containsKey(key)) {
      throw Exception(
          'Cannot track the finish time for an action which start time has not been tracked.');
    }

    _actionsMap[key]?.finishTime = now;

    if (logActionsTracking) {
      print('Action $key finished at $now');
    }
  }

  void printWorsePerformanceTrackedSoFar() {
    print('### WORSE PERFORMANCE TRACKED SO FAR ###');

    var worsePerformanceAction = getlistOfActionsOrderedByPerformance().last;

    print(
        'Action ${worsePerformanceAction.key} took ${worsePerformanceAction.ellapsedTime} to execute.');
  }

  void printPerformanceReport() {
    print('### PERFORMANCE REPORT - HIGHEST TO LOWEST PERFORMANCE ACTIONS ###');

    List<PerformanceCounterItem> listOfActions =
        getlistOfActionsOrderedByPerformance();

    for (var action in listOfActions) {
      int delayDifferenceComparedToBestPerformingAction =
          action.ellapsedTime!.inMicroseconds -
              listOfActions.first.ellapsedTime!.inMicroseconds;

      final performanceDecayComparedToBestPerformingAction =
          delayDifferenceComparedToBestPerformingAction /
              listOfActions.first.ellapsedTime!.inMicroseconds;

      print(
          '${listOfActions.indexOf(action) + 1}º EllapsedTime = ${action.ellapsedTime}, PerformanceDecrease = ${performanceDecayComparedToBestPerformingAction.toStringAsFixed(0)}%, Action = ${action.key}');
    }
  }

  List<PerformanceCounterItem> getlistOfActionsOrderedByPerformance() {
    var listOfActions = _actionsMap.values.toList();

    listOfActions.sort();

    return listOfActions;
  }

  void reset() {
    print('Performance tracker reset and ready to build next report.');

    _actionsMap.clear();
  }
}
