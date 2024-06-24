class FilterCacheKey {
  final String textFilter;
  final bool energySensorFilter;
  final bool criticalStatusFilter;

  FilterCacheKey(
      this.textFilter, this.energySensorFilter, this.criticalStatusFilter);

  String get key => '$textFilter-$energySensorFilter-$criticalStatusFilter';

  @override
  String toString() {
    return key;
  }
}
