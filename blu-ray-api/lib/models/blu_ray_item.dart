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
  final String? category; // From printer-friendly view or search results
  final String? upc;
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

  // Additional fields from search results
  final String? movieUrl; // Link to the movie's specific page
  final String? coverImageUrl; // URL to the movie cover image
  final String? productId; // Blu-ray.com product ID
  final String? globalProductId; // Blu-ray.com global product ID
  final String? globalParentId; // Blu-ray.com global parent ID
  final String? categoryId; // Blu-ray.com category ID

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
    this.upc,
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
    this.movieUrl,
    this.coverImageUrl,
    this.productId,
    this.globalProductId,
    this.globalParentId,
    this.categoryId,
  });

  /// Creates a BluRayItem from a map (useful for CSV parsing)
  factory BluRayItem.fromMap(Map<String, dynamic> map) {
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
      upc: map['UPC']?.toString(),
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
      movieUrl: map['Movie URL']?.toString(),
      coverImageUrl: map['Cover Image URL']?.toString(),
      productId: map['Product ID']?.toString(),
      globalProductId: map['Global Product ID']?.toString(),
      globalParentId: map['globalParentId']?.toString(),
      categoryId: map['categoryId']?.toString(),
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
      'UPC': upc,
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
      'Movie URL': movieUrl,
      'Cover Image URL': coverImageUrl,
      'Product ID': productId,
      'Global Product ID': globalProductId,
      'globalParentId': globalParentId,
      'categoryId': categoryId,
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
    String? upc,
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
    String? movieUrl,
    String? coverImageUrl,
    String? productId,
    String? globalProductId,
    String? globalParentId,
    String? categoryId,
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
      upc: upc ?? this.upc,
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
      movieUrl: movieUrl ?? this.movieUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      productId: productId ?? this.productId,
      globalProductId: globalProductId ?? this.globalProductId,
      globalParentId: globalParentId ?? this.globalParentId,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  @override
  String toString() {
    return 'BluRayItem(title: $title, year: $year, format: $format, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BluRayItem &&
        other.title == title &&
        other.year == year &&
        other.format == format &&
        other.category == category;
  }

  @override
  int get hashCode {
    return title.hashCode ^ year.hashCode ^ format.hashCode ^ category.hashCode;
  }
}
