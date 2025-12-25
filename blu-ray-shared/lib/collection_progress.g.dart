// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CollectionProgressImpl _$$CollectionProgressImplFromJson(
        Map<String, dynamic> json) =>
    _$CollectionProgressImpl(
      type: $enumDecode(_$ProgressEventTypeEnumMap, json['type']),
      currentPage: (json['currentPage'] as num?)?.toInt(),
      totalPages: (json['totalPages'] as num?)?.toInt(),
      itemsOnCurrentPage: (json['itemsOnCurrentPage'] as num?)?.toInt(),
      totalItemsFound: (json['totalItemsFound'] as num).toInt(),
      progressPercentage: (json['progressPercentage'] as num?)?.toDouble(),
      message: json['message'] as String?,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$$CollectionProgressImplToJson(
        _$CollectionProgressImpl instance) =>
    <String, dynamic>{
      'type': _$ProgressEventTypeEnumMap[instance.type]!,
      'currentPage': instance.currentPage,
      'totalPages': instance.totalPages,
      'itemsOnCurrentPage': instance.itemsOnCurrentPage,
      'totalItemsFound': instance.totalItemsFound,
      'progressPercentage': instance.progressPercentage,
      'message': instance.message,
      'error': instance.error,
    };

const _$ProgressEventTypeEnumMap = {
  ProgressEventType.started: 'started',
  ProgressEventType.pageStarted: 'pageStarted',
  ProgressEventType.pageCompleted: 'pageCompleted',
  ProgressEventType.itemsFound: 'itemsFound',
  ProgressEventType.completed: 'completed',
  ProgressEventType.error: 'error',
};
