// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'structured_data_extarction_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StructuredDataExtractionConfig _$StructuredDataExtractionConfigFromJson(
        Map<String, dynamic> json) =>
    StructuredDataExtractionConfig(
      classes:
          (json['classes'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$StructuredDataExtractionConfigToJson(
        StructuredDataExtractionConfig instance) =>
    <String, dynamic>{
      'classes': instance.classes,
    };
