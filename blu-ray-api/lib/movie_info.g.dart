// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MovieInfoImpl _$$MovieInfoImplFromJson(Map<String, dynamic> json) =>
    _$MovieInfoImpl(
      url: json['url'] as String,
      title: json['title'] as String,
      year: (json['year'] as num?)?.toInt(),
      endYear: (json['endYear'] as num?)?.toInt(),
      isCollection: json['isCollection'] as bool? ?? false,
      movies: (json['movies'] as List<dynamic>)
          .map((e) => MovieItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$MovieInfoImplToJson(_$MovieInfoImpl instance) =>
    <String, dynamic>{
      'url': instance.url,
      'title': instance.title,
      'year': instance.year,
      'endYear': instance.endYear,
      'isCollection': instance.isCollection,
      'movies': instance.movies,
      'metadata': instance.metadata,
    };

_$MovieItemImpl _$$MovieItemImplFromJson(Map<String, dynamic> json) =>
    _$MovieItemImpl(
      title: json['title'] as String,
      year: (json['year'] as num?)?.toInt(),
      endYear: (json['endYear'] as num?)?.toInt(),
      url: json['url'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      format: (json['format'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      upc: json['upc'] == null ? null : BigInt.parse(json['upc'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$MovieItemImplToJson(_$MovieItemImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'year': instance.year,
      'endYear': instance.endYear,
      'url': instance.url,
      'coverImageUrl': instance.coverImageUrl,
      'format': instance.format,
      'upc': instance.upc?.toString(),
      'metadata': instance.metadata,
    };
