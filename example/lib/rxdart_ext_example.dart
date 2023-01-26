import 'snippets/debug_and_collect.dart';
import 'snippets/disposable_mixin.dart';
import 'snippets/flat_map_batches_single.dart';
import 'snippets/rx_singles_using.dart';
import 'snippets/rx_singles_zip2.dart';
import 'snippets/state_stream.dart';
import 'utils.dart';

void main() async {
  final functions = <Future<void> Function()>[
    runDebugAndCollectOperatorExample,
    runFlatMapBatchesSingleExample,
    runRxSinglesZip2Example,
    runRxSinglesUsingExample,
    runDisposableMixinExample,
    runStateStreamExample,
  ];
  for (final f in functions) {
    await f();
    printSeparator();
  }
}
