import 'package:assets_manager/infrastructure/performance_counter_item.dart';

const kActionRefreshSearchTreeCall = 'refreshSearchTreeCall';
const kIsolateSearchTreeRebuildingProcess =
    'IsolateSearchTreeRebuildingProcess';
const kGetLeafNodesFilterResults = 'getLeafNodesFilterResults';
const kLoopleafNodesFilterResults = 'LoopleafNodesFilterResults';
const kCollapseAllNodes = 'collapseAllNodes';
const kBuildSearchTree = 'buildSearchTree';
const kActionBuildAssetsPage = 'BuildAssetsPage';
const kActionBuildTreeNode = 'BuildTreeNode';
const kCreateSearchTreeBluePrint = 'CreateSearchTreeBluePrint';
const kCreateNewSearchTree = 'CreateNewSearchTree';

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

    List<PerformanceCounterItem?> listOfActions =
        getlistOfActionsOrderedByPerformance();

    PerformanceCounterItem? firstNonPendingAction;

    try {
      firstNonPendingAction =
          listOfActions.firstWhere((a) => a?.ellapsedTime != null);
    } catch (e) {
      print(
          'Ignoring error of no pending action available to compare with other actions performances.');
    }

    for (var action in listOfActions) {
      if (firstNonPendingAction != null && action?.ellapsedTime != null) {
        int delayDifferenceComparedToBestPerformingAction =
            action!.ellapsedTime!.inMicroseconds -
                firstNonPendingAction.ellapsedTime!.inMicroseconds;

        final performanceDecayComparedToBestPerformingAction =
            delayDifferenceComparedToBestPerformingAction /
                firstNonPendingAction.ellapsedTime!.inMicroseconds;

        print(
            '${listOfActions.indexOf(action) + 1}º EllapsedTime = ${action.ellapsedTime}, PerformanceDecrease = ${performanceDecayComparedToBestPerformingAction.toStringAsFixed(0)}%, Action = ${action.key}');
      } else {
        print('?º PENDING/STILL RUNNING Action = ${action?.key}');
      }
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
