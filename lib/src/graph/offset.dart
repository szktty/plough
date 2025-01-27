import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';

/// Converts between [Offset] objects and JSON representations.
///
/// Enables the serialization and deserialization of [Offset] values in graph data
/// structures, maintaining the dx and dy coordinates.
final class OffsetJsonConverter
    extends JsonConverter<Offset, Map<String, dynamic>> {
  /// Creates a converter for [Offset] serialization.
  const OffsetJsonConverter();

  /// Creates an [Offset] from its JSON representation.
  ///
  /// Expects a map with 'dx' and 'dy' numeric values.
  @override
  Offset fromJson(Map<String, Object?> json) {
    return Offset(
      (json['dx']! as num).toDouble(),
      (json['dy']! as num).toDouble(),
    );
  }

  /// Converts an [Offset] to a JSON map.
  ///
  /// The resulting map contains 'dx' and 'dy' keys with their respective values.
  @override
  Map<String, Object?> toJson(Offset object) {
    return <String, Object?>{
      'dx': object.dx,
      'dy': object.dy,
    };
  }
}
