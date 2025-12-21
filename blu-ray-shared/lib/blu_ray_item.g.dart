// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blu_ray_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BluRayItemImpl _$$BluRayItemImplFromJson(Map<String, dynamic> json) =>
    _$BluRayItemImpl(
      title: json['title'] as String?,
      year: (json['year'] as num?)?.toInt(),
      format:
          (json['format'] as List<dynamic>?)?.map((e) => e as String).toList(),
      upc: json['upc'] == null ? null : BigInt.parse(json['upc'] as String),
      movieUrl: json['movieUrl'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      productId: json['productId'] as String?,
      globalProductId: json['globalProductId'] as String?,
      globalParentId: json['globalParentId'] as String?,
      categoryId: json['categoryId'] as String?,
      endYear: (json['endYear'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$BluRayItemImplToJson(_$BluRayItemImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'year': instance.year,
      'format': instance.format,
      'upc': instance.upc?.toString(),
      'movieUrl': instance.movieUrl,
      'coverImageUrl': instance.coverImageUrl,
      'productId': instance.productId,
      'globalProductId': instance.globalProductId,
      'globalParentId': instance.globalParentId,
      'categoryId': instance.categoryId,
      'endYear': instance.endYear,
    };
