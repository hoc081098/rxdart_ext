import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:stack_trace/stack_trace.dart';

// ignore_for_file: public_member_api_docs

/// Default equals comparison, uses [Object.==].
bool defaultEquals(Object? lhs, Object? rhs) => lhs == rhs;

/// Default hash code. returns [Object.hashCode].
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
