class PlanFilter {
  final String? keyword;
  final String? category;
  final String? region;
  final double? minPrice;
  final double? maxPrice;
  final int? maxDuration;
  final String? difficulty;
  final String sortBy;
  final String sortOrder;

  const PlanFilter({
    this.keyword,
    this.category,
    this.region,
    this.minPrice,
    this.maxPrice,
    this.maxDuration,
    this.difficulty,
    this.sortBy = 'rating',
    this.sortOrder = 'DESC',
  });

  bool get hasActiveFilters =>
      keyword != null ||
      category != null ||
      region != null ||
      minPrice != null ||
      maxPrice != null ||
      maxDuration != null ||
      difficulty != null;

  Map<String, dynamic> toGraphQLVariables() {
    final map = <String, dynamic>{};
    if (keyword != null && keyword!.isNotEmpty) map['keyword'] = keyword;
    if (category != null) map['category'] = category;
    if (region != null) map['region'] = region;
    if (minPrice != null) map['minPrice'] = minPrice;
    if (maxPrice != null) map['maxPrice'] = maxPrice;
    if (maxDuration != null) map['maxDuration'] = maxDuration;
    if (difficulty != null) map['difficulty'] = difficulty;
    map['sortBy'] = sortBy;
    map['sortOrder'] = sortOrder;
    return map;
  }

  PlanFilter copyWith({
    String? keyword,
    String? category,
    String? region,
    double? minPrice,
    double? maxPrice,
    int? maxDuration,
    String? difficulty,
    String? sortBy,
    String? sortOrder,
    bool clearKeyword = false,
    bool clearCategory = false,
    bool clearRegion = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearMaxDuration = false,
    bool clearDifficulty = false,
  }) {
    return PlanFilter(
      keyword: clearKeyword ? null : (keyword ?? this.keyword),
      category: clearCategory ? null : (category ?? this.category),
      region: clearRegion ? null : (region ?? this.region),
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      maxDuration: clearMaxDuration ? null : (maxDuration ?? this.maxDuration),
      difficulty: clearDifficulty ? null : (difficulty ?? this.difficulty),
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlanFilter &&
          runtimeType == other.runtimeType &&
          keyword == other.keyword &&
          category == other.category &&
          region == other.region &&
          minPrice == other.minPrice &&
          maxPrice == other.maxPrice &&
          maxDuration == other.maxDuration &&
          difficulty == other.difficulty &&
          sortBy == other.sortBy &&
          sortOrder == other.sortOrder;

  @override
  int get hashCode => Object.hash(
        keyword,
        category,
        region,
        minPrice,
        maxPrice,
        maxDuration,
        difficulty,
        sortBy,
        sortOrder,
      );
}
