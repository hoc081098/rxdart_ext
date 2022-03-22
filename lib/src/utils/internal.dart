import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:stack_trace/stack_trace.dart';

import '../state_stream/state_stream.dart';

// ignore_for_file: public_member_api_docs

/// Default equals comparison, uses [Object.==].
@internal
Equality<Object?> get defaultEquals => StateStream.defaultEquality;

/// Default hash code. returns [Object.hashCode].
@internal
int defaultHashCode(Object? o) => o.hashCode;

@internal
extension FormattedFrameExtension on Frame {
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  String get formatted {
    final trimmedFile = path.basename(uri.toString());
    return '$trimmedFile:$line ($member)';
  }
}

@internal
extension StringTakeExtensions on String {
  @internal
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  String take(int n) {
    if (n < 0) {
      throw ArgumentError.value(
        n,
        'n',
        'Requested character count is less than zero.',
      );
    }
    return substring(0, math.min(n, length));
  }

  @internal
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  String takeLast(int n) {
    if (n < 0) {
      throw ArgumentError.value(
        n,
        'n',
        'Requested character count is less than zero.',
      );
    }
    return substring(length - math.min(n, length));
  }
}
