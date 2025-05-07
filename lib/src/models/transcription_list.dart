import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';

import 'transcription_list_item.dart';

part 'transcription_list.g.dart';

/// List of transcriptions
@immutable
@JsonSerializable()
class TranscriptionList {
  /// First page URL
  @JsonKey(name: 'first')
  final String? firstUrl;

  /// Current page URL
  @JsonKey(name: 'current')
  final String? currentUrl;

  /// Next page URL
  @JsonKey(name: 'next')
  final String? nextUrl;

  /// List of transcription items
  @JsonKey(name: 'items')
  final List<TranscriptionListItem>? items;

  /// Creates a new instance of [TranscriptionList]
  const TranscriptionList({
    this.firstUrl,
    this.currentUrl,
    this.nextUrl,
    this.items,
  });

  /// Returns the first page URL
  String? get firstPage => firstUrl;

  /// Returns the current page URL
  String? get currentPage => currentUrl;

  /// Returns the next page URL
  String? get nextPage => nextUrl;

  /// Returns the list of transcriptions
  List<TranscriptionListItem> get list => items ?? [];

  /// Creates a new instance of [TranscriptionList] from JSON
  factory TranscriptionList.fromJson(Map<String, dynamic> json) =>
      _$TranscriptionListFromJson(json);

  /// Converts to JSON
  Map<String, dynamic> toJson() => _$TranscriptionListToJson(this);
}
