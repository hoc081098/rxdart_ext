import 'debug_test.dart' as debug_test;
import 'distinct_by_test.dart' as distinct_by_test;
import 'distinct_unique_by_test.dart' as distinct_unique_by_test;
import 'do_on_test.dart' as do_on_test;
import 'ignore_test.dart' as ignore_test;
import 'map_not_null_test.dart' as map_not_null_test;
import 'to_single_subscription_test.dart' as to_single_subscription_test;
import 'where_not_null_test.dart' as where_not_null_test;

import 'value/not_replay_value_connectable_stream_tests.dart'
    as not_replay_value_connectable_stream_tests;
import 'value/value_controller_test.dart' as value_controller_test;
import 'value/value_subject_test.dart' as value_subject_test;

import 'single/single_test.dart' as single_test;

void main() {
  debug_test.main();
  distinct_by_test.main();
  distinct_unique_by_test.main();
  do_on_test.main();
  ignore_test.main();
  map_not_null_test.main();
  to_single_subscription_test.main();
  where_not_null_test.main();

  not_replay_value_connectable_stream_tests.main();
  value_controller_test.main();
  value_subject_test.main();

  single_test.main();
}
