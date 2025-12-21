/// DTO representing a movie item extracted from the Blu-ray.com search endpoint
/// Contains only the fields that are actually populated from search results
class BluRayItem {
  final String? title;
  final String? year;
  final String? format; // Blu-ray, DVD, 4K, etc.
  final String? upc;
  final String? movieUrl; // Link to the movie's specific page
  final String? coverImageUrl; // URL to the movie cover image
  final String? productId; // Blu-ray.com product ID
  final String? globalProductId; // Blu-ray.com global product ID
  final String? globalParentId; // Blu-ray.com global parent ID
  final String? categoryId; // Blu-ray.com category ID
  final String? category; // Derived category name from categoryId
  final String? endYear; // End year for collections (e.g., "2020" or "-" for ongoing)

  const BluRayItem({
    this.title,
    this.year,
    this.format,
    this.upc,
    this.movieUrl,
    this.coverImageUrl,
    this.productId,
    this.globalProductId,
    this.globalParentId,
    this.categoryId,
    this.category,
    this.endYear,
  });

  /// Creates a BluRayItem from a map (useful for JSON serialization)
  factory BluRayItem.fromMap(Map<String, dynamic> map) {
    return BluRayItem(
      title: map['title']?.toString(),
      year: map['year']?.toString(),
      format: map['format']?.toString(),
      upc: map['upc']?.toString(),
      movieUrl: map['movieUrl']?.toString(),
      coverImageUrl: map['coverImageUrl']?.toString(),
      productId: map['productId']?.toString(),
      globalProductId: map['globalProductId']?.toString(),
      globalParentId: map['globalParentId']?.toString(),
      categoryId: map['categoryId']?.toString(),
      category: null, // Will be set by consumer if needed
      endYear: map['endYear']?.toString(),
    );
  }

  /// Converts the item to a map (useful for JSON serialization)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'year': year,
      'format': format,
      'upc': upc,
      'movieUrl': movieUrl,
      'coverImageUrl': coverImageUrl,
      'productId': productId,
      'globalProductId': globalProductId,
      'globalParentId': globalParentId,
      'categoryId': categoryId,
      'category': category,
      'endYear': endYear,
    };
  }

  /// Creates a copy with some fields updated
  BluRayItem copyWith({
    String? title,
    String? year,
    String? format,
    String? upc,
    String? movieUrl,
    String? coverImageUrl,
    String? productId,
    String? globalProductId,
    String? globalParentId,
    String? categoryId,
    String? category,
    String? endYear,
  }) {
    return BluRayItem(
      title: title ?? this.title,
      year: year ?? this.year,
      format: format ?? this.format,
      upc: upc ?? this.upc,
      movieUrl: movieUrl ?? this.movieUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      productId: productId ?? this.productId,
      globalProductId: globalProductId ?? this.globalProductId,
      globalParentId: globalParentId ?? this.globalParentId,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      endYear: endYear ?? this.endYear,
    );
  }

  @override
  String toString() {
    return 'BluRayItem(title: $title, year: $year, format: $format, upc: $upc)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BluRayItem &&
        other.title == title &&
        other.year == year &&
        other.format == format &&
        other.upc == upc;
  }

  @override
  int get hashCode {
    return title.hashCode ^ year.hashCode ^ format.hashCode ^ upc.hashCode;
  }
}
