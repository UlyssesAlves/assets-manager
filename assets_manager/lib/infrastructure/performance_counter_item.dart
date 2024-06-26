class PerformanceCounterItem implements Comparable<PerformanceCounterItem> {
  final String key;
  final DateTime startTime;
  DateTime? finishTime;

  PerformanceCounterItem(this.key, this.startTime);

  Duration? get ellapsedTime => finishTime?.difference(startTime);

  @override
  int compareTo(PerformanceCounterItem other) {
    if (ellapsedTime == null && other.ellapsedTime == null) {
      return 1;
    }

    if (ellapsedTime != null && other.ellapsedTime == null) {
      return -1;
    }

    if (ellapsedTime == null && other.ellapsedTime != null) {
      return 1;
    }

    return ellapsedTime!.compareTo(other.ellapsedTime as Duration);
  }
}
