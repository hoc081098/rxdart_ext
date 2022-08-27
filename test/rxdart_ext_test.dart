import 'not_replay_value_stream/not_replay_value_connectable_stream_tests.dart'
    as not_replay_value_connectable_stream_tests;
import 'not_replay_value_stream/value_controller_test.dart'
    as value_controller_test;
import 'not_replay_value_stream/value_subject_test.dart' as value_subject_test;

//
import 'operators/debug_test.dart' as debug_test;
import 'operators/distinct_by_test.dart' as distinct_by_test;
import 'operators/distinct_unique_by_test.dart' as distinct_unique_by_test;
import 'operators/do_on_test.dart' as do_on_test;
import 'operators/done_on_error_test.dart' as done_on_error_test;
import 'operators/flat_map_batches_test.dart' as flat_map_batches_test;
import 'operators/ignore_test.dart' as ignore_test;
import 'operators/map_not_null_test.dart' as map_not_null_test;
import 'operators/to_single_subscription_test.dart'
    as to_single_subscription_test;
import 'operators/void_test.dart' as void_test;
import 'operators/where_not_null_test.dart' as where_not_null_test;

//
import 'single/as_single_test.dart' as as_single_test;
import 'single/as_void_test.dart' as as_void_test;
import 'single/async_expand_test.dart' as async_expand_test;
import 'single/debug_test.dart' as single_debug_test;
import 'single/delay_test.dart' as delay_test;
import 'single/do_test.dart' as do_test;
import 'single/flat_map_either_single_test.dart' as flat_map_either_single_test;
import 'single/map_to_test.dart' as map_to_test;
import 'single/on_error_resume_test.dart' as on_error_resume_test;
import 'single/rx_singles_test.dart' as rx_singles_test;
import 'single/single_or_error_test.dart' as single_or_error_test;
import 'single/single_test.dart' as single_test;
import 'single/switch_flat_exhaust_map_test.dart'
    as switch_flat_exhaust_map_test;
import 'single/to_either_single_test.dart' as to_either_single_test;

//
import 'state_stream/as_broadcast_test.dart' as as_broadcast_test;
import 'state_stream/selectors_test.dart' as selectors_test;
import 'state_stream/state_connectable_stream_test.dart'
    as state_connectable_stream_test;
import 'state_stream/state_subject_test.dart' as state_subject_test;
import 'state_stream/to_state_stream_test.dart' as to_state_stream_test;

//
import 'utils/add_null_test.dart' as add_null_test;
import 'utils/disposable_test.dart' as disposable_test;

void main() {
  debug_test.main();
  distinct_by_test.main();
  distinct_unique_by_test.main();
  do_on_test.main();
  done_on_error_test.main();
  flat_map_batches_test.main();
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
  flat_map_either_single_test.main();
  map_to_test.main();
  on_error_resume_test.main();
  single_or_error_test.main();
  single_test.main();
  rx_singles_test.main();
  switch_flat_exhaust_map_test.main();
  to_either_single_test.main();

  add_null_test.main();
  disposable_test.main();

  as_broadcast_test.main();
  selectors_test.main();
  state_connectable_stream_test.main();
  to_state_stream_test.main();
  state_subject_test.main();
}
