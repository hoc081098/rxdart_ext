import 'debug_test.dart' as debug_test;
import 'distinct_by_test.dart' as distinct_by_test;
import 'distinct_unique_by_test.dart' as distinct_unique_by_test;
import 'ignore_test.dart' as ignore_test;
import 'map_not_null_test.dart' as map_not_null_test;
import 'to_single_subscription_test.dart' as to_single_subscription_test;
import 'value/value_subject_test.dart' as value_subject_test;

void main() {
  value_subject_test.main();
  debug_test.main();
  distinct_by_test.main();
  distinct_unique_by_test.main();
  ignore_test.main();
  map_not_null_test.main();
  to_single_subscription_test.main();
}
