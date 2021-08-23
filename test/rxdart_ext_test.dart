import 'debug_test.dart' as debug_test;
import 'distinct_by_test.dart' as distinct_by_test;
import 'distinct_unique_by_test.dart' as distinct_unique_by_test;
import 'do_on_test.dart' as do_on_test;
import 'ignore_test.dart' as ignore_test;
import 'map_not_null_test.dart' as map_not_null_test;
import 'to_single_subscription_test.dart' as to_single_subscription_test;
import 'void_test.dart' as void_test;
import 'where_not_null_test.dart' as where_not_null_test;

import 'value/not_replay_value_connectable_stream_tests.dart'
    as not_replay_value_connectable_stream_tests;
import 'value/value_controller_test.dart' as value_controller_test;
import 'value/value_subject_test.dart' as value_subject_test;

import 'single/as_single_test.dart' as as_single_test;
import 'single/as_void_test.dart' as as_void_test;
import 'single/async_expand_test.dart' as async_expand_test;
import 'single/debug_test.dart' as single_debug_test;
import 'single/delay_test.dart' as delay_test;
import 'single/do_test.dart' as do_test;
import 'single/map_to_test.dart' as map_to_test;
import 'single/on_error_resume_test.dart' as on_error_resume_test;
import 'single/single_or_error_test.dart' as single_or_error_test;
import 'single/single_test.dart' as single_test;
import 'single/singles_test.dart' as singles_test;
import 'single/switch_flat_exhaust_map_test.dart'
    as switch_flat_exhaust_map_test;

import 'controller/add_null_test.dart' as add_null_test;

import 'state_stream/to_state_stream_test.dart' as to_state_stream_test;

void main() {
  debug_test.main();
  distinct_by_test.main();
  distinct_unique_by_test.main();
  do_on_test.main();
  ignore_test.main();
  map_not_null_test.main();
  to_single_subscription_test.main();
  void_test.main();
  where_not_null_test.main();

  not_replay_value_connectable_stream_tests.main();
  value_controller_test.main();
  value_subject_test.main();

  as_single_test.main();
  as_void_test.main();
  async_expand_test.main();
  single_debug_test.main();
  delay_test.main();
  do_test.main();
  map_to_test.main();
  on_error_resume_test.main();
  single_or_error_test.main();
  single_test.main();
  singles_test.main();
  switch_flat_exhaust_map_test.main();

  add_null_test.main();

  to_state_stream_test.main();
}
