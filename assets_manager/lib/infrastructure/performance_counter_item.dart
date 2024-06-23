class PerformanceCounterItem implements Comparable<PerformanceCounterItem> {
  final String key;
  final DateTime startTime;
  DateTime? finishTime;

  PerformanceCounterItem(this.key, this.startTime);

  Duration? get ellapsedTime => finishTime?.difference(startTime);

  @override
  int compareTo(PerformanceCounterItem other) {
    return ellapsedTime!.compareTo(other.ellapsedTime as Duration);
  }
}
