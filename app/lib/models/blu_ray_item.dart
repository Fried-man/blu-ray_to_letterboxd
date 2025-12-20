/// Represents a Blu-ray collection item with all possible fields from both data sources
class BluRayItem {
  final String? title;
  final String? year;
  final String? format; // Blu-ray, DVD, 4K, etc.
  final String? region;
  final String? edition;
  final String? condition;
  final String? dateAdded;
  final String? notes;
  final String? category; // From printer-friendly view or mapped from categoryId
  final String? categoryId; // From API response
  final String? upc;
  final String? movieUrl; // Link to the movie's specific page
  final String? coverImageUrl; // URL to the movie cover image
  final String? productId; // Blu-ray.com product ID
  final String? globalProductId; // Blu-ray.com global product ID
  final String? globalParentId; // Blu-ray.com global parent ID
  final String? asin;
  final String? imdbId;
  final String? genre;
  final String? director;
  final String? actors;
  final String? runtime;
  final String? rating;
  final String? studio;
  final String? releaseDate;
  final String? purchaseDate;
  final String? price;
  final String? location;
  final String? wishlist; // Boolean as string
  final String? watched; // Boolean as string
  final String? loanStatus;
  final String? loanTo;
  final String? loanDate;

  const BluRayItem({
    this.title,
    this.year,
    this.format,
    this.region,
    this.edition,
    this.condition,
    this.dateAdded,
    this.notes,
    this.category,
    this.categoryId,
    this.upc,
    this.movieUrl,
    this.coverImageUrl,
    this.productId,
    this.globalProductId,
    this.globalParentId,
    this.asin,
    this.imdbId,
    this.genre,
    this.director,
    this.actors,
    this.runtime,
    this.rating,
    this.studio,
    this.releaseDate,
    this.purchaseDate,
    this.price,
    this.location,
    this.wishlist,
    this.watched,
    this.loanStatus,
    this.loanTo,
    this.loanDate,
  });

  /// Creates a BluRayItem from a map (matches backend API BluRayItem model exactly)
  factory BluRayItem.fromMap(Map<String, dynamic> map) {
    return BluRayItem(
      // Fields that exist in backend API response
      title: map['title']?.toString(),
      year: map['year']?.toString(),
      format: map['format']?.toString(),
      upc: map['upc']?.toString(),
      movieUrl: map['movieUrl']?.toString(),
      coverImageUrl: map['coverImageUrl']?.toString(),
      productId: map['productId']?.toString(),
      globalProductId: map['globalProductId']?.toString(),
      globalParentId: map['globalParentId']?.toString(),
      category: _getCategoryFromId(map['categoryId']?.toString()), // Map categoryId to category name
      categoryId: map['categoryId']?.toString(),

      // Fields not in API response (will be null)
      region: null,
      edition: null,
      condition: null,
      dateAdded: null,
      notes: null,
      asin: null,
      imdbId: null,
      genre: null,
      director: null,
      actors: null,
      runtime: null,
      rating: null,
      studio: null,
      releaseDate: null,
      purchaseDate: null,
      price: null,
      location: null,
      wishlist: null,
      watched: null,
      loanStatus: null,
      loanTo: null,
      loanDate: null,
    );
  }

static String? _getCategoryFromId(String? categoryId) {
  if (categoryId == null) return null;

  // Map category IDs to category names based on blu-ray.com categories
  switch (categoryId) {
    case '1':
      return 'Action';
    case '2':
      return 'Animation';
    case '3':
      return 'Comedy';
    case '4':
      return 'Drama';
    case '5':
      return 'Horror';
    case '6':
      return 'Sci-Fi';
    case '7':
      return 'Movies'; // General movies category
    case '8':
      return 'TV Shows';
    case '9':
      return 'Documentary';
    default:
      return 'Movies'; // Default fallback
  }
}

/// Creates a BluRayItem from a CSV-style map (keeps the old capitalized version for backward compatibility)
  factory BluRayItem.fromCsvMap(Map<String, dynamic> map) {
    return BluRayItem(
      title: map['Title']?.toString(),
      year: map['Year']?.toString(),
      format: map['Format']?.toString(),
      region: map['Region']?.toString(),
      edition: map['Edition']?.toString(),
      condition: map['Condition']?.toString(),
      dateAdded: map['Date Added']?.toString(),
      notes: map['Notes']?.toString(),
      category: map['Category']?.toString(),
      categoryId: map['CategoryId']?.toString(),
      upc: map['UPC']?.toString(),
      movieUrl: map['MovieUrl']?.toString(),
      coverImageUrl: map['CoverImageUrl']?.toString(),
      productId: map['ProductId']?.toString(),
      globalProductId: map['GlobalProductId']?.toString(),
      globalParentId: map['GlobalParentId']?.toString(),
      asin: map['ASIN']?.toString(),
      imdbId: map['IMDB ID']?.toString(),
      genre: map['Genre']?.toString(),
      director: map['Director']?.toString(),
      actors: map['Actors']?.toString(),
      runtime: map['Runtime']?.toString(),
      rating: map['Rating']?.toString(),
      studio: map['Studio']?.toString(),
      releaseDate: map['Release Date']?.toString(),
      purchaseDate: map['Purchase Date']?.toString(),
      price: map['Price']?.toString(),
      location: map['Location']?.toString(),
      wishlist: map['Wishlist']?.toString(),
      watched: map['Watched']?.toString(),
      loanStatus: map['Loan Status']?.toString(),
      loanTo: map['Loan To']?.toString(),
      loanDate: map['Loan Date']?.toString(),
    );
  }

  /// Converts the item to a map (useful for JSON serialization)
  Map<String, dynamic> toMap() {
    return {
      'Title': title,
      'Year': year,
      'Format': format,
      'Region': region,
      'Edition': edition,
      'Condition': condition,
      'Date Added': dateAdded,
      'Notes': notes,
      'Category': category,
      'CategoryId': categoryId,
      'UPC': upc,
      'MovieUrl': movieUrl,
      'CoverImageUrl': coverImageUrl,
      'ProductId': productId,
      'GlobalProductId': globalProductId,
      'GlobalParentId': globalParentId,
      'ASIN': asin,
      'IMDB ID': imdbId,
      'Genre': genre,
      'Director': director,
      'Actors': actors,
      'Runtime': runtime,
      'Rating': rating,
      'Studio': studio,
      'Release Date': releaseDate,
      'Purchase Date': purchaseDate,
      'Price': price,
      'Location': location,
      'Wishlist': wishlist,
      'Watched': watched,
      'Loan Status': loanStatus,
      'Loan To': loanTo,
      'Loan Date': loanDate,
    };
  }

  /// Creates a copy with some fields updated
  BluRayItem copyWith({
    String? title,
    String? year,
    String? format,
    String? region,
    String? edition,
    String? condition,
    String? dateAdded,
    String? notes,
    String? category,
    String? categoryId,
    String? upc,
    String? movieUrl,
    String? coverImageUrl,
    String? productId,
    String? globalProductId,
    String? globalParentId,
    String? asin,
    String? imdbId,
    String? genre,
    String? director,
    String? actors,
    String? runtime,
    String? rating,
    String? studio,
    String? releaseDate,
    String? purchaseDate,
    String? price,
    String? location,
    String? wishlist,
    String? watched,
    String? loanStatus,
    String? loanTo,
    String? loanDate,
  }) {
    return BluRayItem(
      title: title ?? this.title,
      year: year ?? this.year,
      format: format ?? this.format,
      region: region ?? this.region,
      edition: edition ?? this.edition,
      condition: condition ?? this.condition,
      dateAdded: dateAdded ?? this.dateAdded,
      notes: notes ?? this.notes,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      upc: upc ?? this.upc,
      movieUrl: movieUrl ?? this.movieUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      productId: productId ?? this.productId,
      globalProductId: globalProductId ?? this.globalProductId,
      globalParentId: globalParentId ?? this.globalParentId,
      asin: asin ?? this.asin,
      imdbId: imdbId ?? this.imdbId,
      genre: genre ?? this.genre,
      director: director ?? this.director,
      actors: actors ?? this.actors,
      runtime: runtime ?? this.runtime,
      rating: rating ?? this.rating,
      studio: studio ?? this.studio,
      releaseDate: releaseDate ?? this.releaseDate,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      price: price ?? this.price,
      location: location ?? this.location,
      wishlist: wishlist ?? this.wishlist,
      watched: watched ?? this.watched,
      loanStatus: loanStatus ?? this.loanStatus,
      loanTo: loanTo ?? this.loanTo,
      loanDate: loanDate ?? this.loanDate,
    );
  }

  @override
  String toString() {
    return 'BluRayItem(title: $title, year: $year, format: $format, category: $category, upc: $upc)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BluRayItem &&
        other.title == title &&
        other.year == year &&
        other.format == format &&
        other.category == category &&
        other.upc == upc;
  }

  @override
  int get hashCode {
    return title.hashCode ^ year.hashCode ^ format.hashCode ^ category.hashCode ^ upc.hashCode;
  }
}
