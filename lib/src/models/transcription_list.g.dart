// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transcription_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TranscriptionList _$TranscriptionListFromJson(Map<String, dynamic> json) =>
    TranscriptionList(
      firstUrl: json['first'] as String?,
      currentUrl: json['current'] as String?,
      nextUrl: json['next'] as String?,
      items: (json['items'] as List<dynamic>?)
          ?.map(
              (e) => TranscriptionListItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TranscriptionListToJson(TranscriptionList instance) =>
    <String, dynamic>{
      'first': instance.firstUrl,
      'current': instance.currentUrl,
      'next': instance.nextUrl,
      'items': instance.items,
    };
