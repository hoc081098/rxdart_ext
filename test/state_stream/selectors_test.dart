import 'package:built_collection/built_collection.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

class _State {
  final bool isLoading;
  final String? term;
  final BuiltList<String> items;
  final double otherState;

  _State(this.isLoading, this.term, this.items, this.otherState);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _State &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          term == other.term &&
          items == other.items &&
          otherState == other.otherState;

  @override
  int get hashCode =>
      isLoading.hashCode ^ term.hashCode ^ items.hashCode ^ otherState.hashCode;

  @override
  String toString() =>
      '_State{isLoading: $isLoading, term: $term, items: $items, otherState: $otherState}';
}

void main() {
  group('selectors', () {
    test('select', () async {
      final state$ = StateSubject('');

      final length$ = state$.select((s) => s.length);
      expect(length$.value, 0);
      expect(
        length$,
        emitsInOrder(<Object>[
          1,
          2,
          3,
          4,
          emitsDone,
        ]),
      );

      await pumpEventQueue(times: 50);

      for (var i = 0; i <= 1000; i += 10) {
        state$.add(i.toString());
      }
      await pumpEventQueue(times: 50);
      await state$.close();
    });

    test('select2', () async {
      final state$ = StateSubject(_State(true, null, <String>[].build(), 1));
      _State reducer(_State s, int a) {
        // items [*]
        if (a == 0) {
          return _State(
            s.isLoading,
            s.term,
            List.generate(10, (i) => i.toString()).build(),
            s.otherState,
          );
        }

        // loading
        if (a == 1) {
          return _State(!s.isLoading, s.term, s.items, s.otherState);
        }

        // loading
        if (a == 2) {
          return _State(!s.isLoading, s.term, s.items, s.otherState);
        }

        // term [*]
        if (a == 3) {
          return _State(s.isLoading, '4', s.items, s.otherState);
        }

        // otherState
        if (a == 4) {
          return _State(s.isLoading, s.term, s.items, s.otherState + 2);
        }

        // loading & otherState
        if (a == 5) {
          return _State(!s.isLoading, s.term, s.items, -s.otherState);
        }

        throw a;
      }

      await pumpEventQueue(times: 50);

      var termCount = 0;
      var itemsCount = 0;
      var projectorCount = 0;

      final filtered = state$.select2(
        (s) {
          ++termCount;
          return s.term;
        },
        (s) {
          ++itemsCount;
          return s.items;
        },
        (String? term, BuiltList<String> items) {
          ++projectorCount;
          return items.where((i) => i.contains(term ?? '')).toBuiltList();
        },
        equals2: (BuiltList<String> prev, BuiltList<String> next) =>
            prev == next,
      );

      expect(filtered.value, <String>[].build());
      final future = expectLater(
        filtered,
        emitsInOrder(<Object>[
          List.generate(10, (i) => i.toString()).build(),
          ['4'].build(),
          emitsDone,
        ]),
      );

      final numberOfActions = 6;
      for (var i = 0; i < numberOfActions; i++) {
        state$.value = reducer(state$.value, i);
      }
      await pumpEventQueue(times: 50);
      await state$.close();
      await future;

      expect(
          termCount, numberOfActions + 1); // inc. calling to produce seed value
      expect(itemsCount,
          numberOfActions + 1); // inc. calling to produce seed value
      expect(projectorCount,
          2 + 1); // 2 [*] and inc. calling to produce seed value
    });
    //
    // test('select3', () async {
    //   final store = RxReduxStore<int, _State>(
    //     initialState: _State(true, null, <String>[].build(), 2),
    //     sideEffects: [],
    //     reducer: (s, a) {
    //       // items [*]
    //       if (a == 0) {
    //         return _State(
    //           s.isLoading,
    //           s.term,
    //           List.generate(10, (i) => i.toString()).build(),
    //           s.otherState,
    //         );
    //       }
    //
    //       // loading
    //       if (a == 1) {
    //         return _State(!s.isLoading, s.term, s.items, s.otherState);
    //       }
    //
    //       // loading
    //       if (a == 2) {
    //         return _State(!s.isLoading, s.term, s.items, s.otherState);
    //       }
    //
    //       // term [*]
    //       if (a == 3) {
    //         return _State(s.isLoading, '4', s.items, s.otherState);
    //       }
    //
    //       // otherState [*]
    //       if (a == 4) {
    //         return _State(s.isLoading, s.term, s.items, s.otherState + 2);
    //       }
    //
    //       // loading & otherState [*]
    //       if (a == 5) {
    //         return _State(!s.isLoading, s.term, s.items, s.otherState - 1);
    //       }
    //
    //       throw a;
    //     },
    //   );
    //
    //   await pumpEventQueue(times: 50);
    //
    //   var termCount = 0;
    //   var itemsCount = 0;
    //   var otherStateCount = 0;
    //   var projectorCount = 0;
    //
    //   final filtered = store.select3(
    //         (s) {
    //       ++termCount;
    //       return s.term;
    //     },
    //         (s) {
    //       ++itemsCount;
    //       return s.items;
    //     },
    //         (s) {
    //       ++otherStateCount;
    //       return s.otherState.round();
    //     },
    //         (String? term, BuiltList<String> items, int otherState) {
    //       ++projectorCount;
    //       return items
    //           .where((i) => i.contains(term ?? ''))
    //           .take(otherState)
    //           .toBuiltList();
    //     },
    //     equals3: (int prev, int next) => prev == next,
    //   );
    //
    //   expect(filtered.value, <String>[].build());
    //   final future = expectLater(
    //     filtered,
    //     emitsInOrder(<Object>[
    //       ['0', '1'].build(),
    //       ['4'].build(),
    //       emitsDone,
    //     ]),
    //   );
    //
    //   final numberOfActions = 6;
    //   for (var i = 0; i < numberOfActions; i++) {
    //     store.dispatch(i);
    //   }
    //   await pumpEventQueue(times: 50);
    //   await store.dispose();
    //   await future;
    //
    //   expect(termCount,
    //       numberOfActions + 1); // inc. calling to produce seed value
    //   expect(itemsCount,
    //       numberOfActions + 1); // inc. calling to produce seed value
    //   expect(otherStateCount,
    //       numberOfActions + 1); // inc. calling to produce seed value
    //   expect(projectorCount,
    //       4 + 1); // 4 [*] and inc. calling to produce seed value
    // });
    //
    // test('select4', () async {
    //   final initial = Tuple5(0, 1.0, '', true, <String>[].build());
    //
    //   final store = RxReduxStore<int,
    //       Tuple5<int, double, String, bool, BuiltList<String>>>(
    //     initialState: initial,
    //     sideEffects: [],
    //     reducer: (s, a) {
    //       switch (a) {
    //         case 0:
    //           return s;
    //         case 1:
    //           return s.withItem5(s.item5.rebuild((b) => b.remove('01')));
    //         case 2:
    //           return s.withItem1(s.item1 + 1);
    //         case 3:
    //           return s.withItem2(s.item2 + 2);
    //         case 4:
    //           return s.withItem5(s.item5.rebuild((b) => b.add('01')));
    //         case 5:
    //           return s;
    //         case 6:
    //           return s.withItem3(s.item3 + '3');
    //         case 7:
    //           return s.withItem4(!s.item4);
    //         case 8:
    //           return s.withItem5(s.item5.rebuild((b) => b.add('5')));
    //         default:
    //           throw a;
    //       }
    //     },
    //   );
    //
    //   final tuple$ = store.select4(
    //     expectAsync1((state) => state.item1, count: 7 + 1),
    //     // 7 action causes state changed
    //     expectAsync1((state) => state.item2, count: 7 + 1),
    //     // 7 action causes state changed
    //     expectAsync1((state) => state.item3, count: 7 + 1),
    //     // 7 action causes state changed
    //     expectAsync1((state) => state.item4, count: 7 + 1),
    //     // 7 action causes state changed
    //     expectAsync4(
    //           (int subState1, double subState2, String subState3,
    //           bool subState4) =>
    //           Tuple4(subState1, subState2, subState3, subState4),
    //       count: 4 + 1, // inc. calling to produce seed value
    //     ),
    //     equals3: (String prev, String next) => prev == next,
    //   );
    //
    //   final tuple4 = Tuple4<int, double, String, bool>(0, 1.0, '', true);
    //   expect(tuple$.value, tuple4);
    //   final future = expectLater(
    //     tuple$,
    //     emitsInOrder(<Object>[
    //       Tuple4(0, 1.0, '', false), // 7
    //       Tuple4(0, 1.0, '3', false), // 6
    //       Tuple4(0, 3.0, '3', false), // 3
    //       Tuple4(1, 3.0, '3', false), // 2
    //       emitsDone,
    //     ]),
    //   );
    //
    //   for (var i = 8; i >= 0; i--) {
    //     i.dispatchTo(store);
    //   }
    //   await pumpEventQueue(times: 100);
    //   await store.dispose();
    //   await future;
    // });
    //
    // test('select5', () async {
    //   final initial = Tuple6(
    //     0,
    //     1.0,
    //     '',
    //     true,
    //     <String>[].build(),
    //     <String, int>{}.build(),
    //   );
    //
    //   final store = RxReduxStore<
    //       int,
    //       Tuple6<int, double, String, bool, BuiltList<String>,
    //           BuiltMap<String, int>>>(
    //     initialState: initial,
    //     sideEffects: [],
    //     reducer: (s, a) {
    //       switch (a) {
    //         case 0:
    //           return s;
    //         case 1:
    //           return s.withItem1(s.item1 + a); // [item 1]
    //         case 2:
    //           return s.withItem2(s.item2 + a); // [item 2]
    //         case 3:
    //           return s.withItem6(
    //               s.item6.rebuild((b) => b['@'] = a)); // ------------
    //         case 4:
    //           return s.withItem3(s.item3 + a.toString()); // [item 3]
    //         case 5:
    //           return s.withItem4(!s.item4); // [item 4]
    //         case 6:
    //           return s.withItem6(
    //               s.item6.rebuild((b) => b.remove('@'))); // ------------
    //         case 7:
    //           return s.withItem5(
    //               s.item5.rebuild((b) => b.add(a.toString()))); // [item 5]
    //         case 8:
    //           return s;
    //         default:
    //           throw a;
    //       }
    //     },
    //   );
    //
    //   final tuple$ = store.select5(
    //     expectAsync1((state) => state.item1, count: 7 + 1),
    //     // 7 action causes state changed
    //     expectAsync1((state) => state.item2, count: 7 + 1),
    //     // 7 action causes state changed
    //     expectAsync1((state) => state.item3, count: 7 + 1),
    //     // 7 action causes state changed
    //     expectAsync1((state) => state.item4, count: 7 + 1),
    //     // 7 action causes state changed
    //     expectAsync1((state) => state.item5, count: 7 + 1),
    //     // 7 action causes state changed
    //     expectAsync5(
    //           (int subState1, double subState2, String subState3, bool subState4,
    //           BuiltList<String> subState5) =>
    //           Tuple5(subState1, subState2, subState3, subState4, subState5),
    //       count: 5 + 1, // inc. calling to produce seed value
    //     ),
    //     equals3: (String prev, String next) => prev == next,
    //   );
    //
    //   expect(tuple$.value, Tuple5(0, 1.0, '', true, <String>[].build()));
    //   final future = expectLater(
    //     tuple$,
    //     emitsInOrder(<Object>[
    //       Tuple5(1, 1.0, '', true, <String>[].build()),
    //       Tuple5(1, 3.0, '', true, <String>[].build()),
    //       Tuple5(1, 3.0, '4', true, <String>[].build()),
    //       Tuple5(1, 3.0, '4', false, <String>[].build()),
    //       Tuple5(1, 3.0, '4', false, <String>['7'].build()),
    //       emitsDone,
    //     ]),
    //   );
    //
    //   for (var i = 0; i <= 8; i++) {
    //     i.dispatchTo(store);
    //   }
    //   await pumpEventQueue(times: 100);
    //   await store.dispose();
    //   await future;
    // });
    //
    // test('select6', () async {
    //   final initial = Tuple7(
    //     0,
    //     1.0,
    //     '',
    //     true,
    //     <String>[].build(),
    //     <String, int>{}.build(),
    //     <String>{}.build(),
    //   );
    //
    //   final store = RxReduxStore<
    //       int,
    //       Tuple7<int, double, String, bool, BuiltList<String>,
    //           BuiltMap<String, int>, BuiltSet<String>>>(
    //     initialState: initial,
    //     sideEffects: [],
    //     reducer: (s, a) {
    //       switch (a) {
    //         case 0:
    //           return s;
    //         case 1:
    //           return s.withItem1(s.item1 + a); // [item 1]
    //         case 2:
    //           return s.withItem2(s.item2 + a); // [item 2]
    //         case 3:
    //           return s.withItem7(s.item7
    //               .rebuild((b) => b.add(a.toString()))); // ------------
    //         case 4:
    //           return s.withItem3(s.item3 + a.toString()); // [item 3]
    //         case 5:
    //           return s.withItem4(!s.item4); // [item 4]
    //         case 6:
    //           return s.withItem7(s.item7
    //               .rebuild((b) => b.add(a.toString()))); // ------------
    //         case 7:
    //           return s.withItem5(
    //               s.item5.rebuild((b) => b.add(a.toString()))); // [item 5]
    //         case 8:
    //           return s
    //               .withItem6(s.item6.rebuild((b) => b['@'] = a)); // [item 6]
    //         case 9:
    //           return s;
    //         default:
    //           throw a;
    //       }
    //     },
    //   );
    //
    //   final tuple$ = store.select6(
    //     expectAsync1((state) => state.item1, count: 8 + 1),
    //     // 8 action causes state changed
    //     expectAsync1((state) => state.item2, count: 8 + 1),
    //     // 8 action causes state changed
    //     expectAsync1((state) => state.item3, count: 8 + 1),
    //     // 8 action causes state changed
    //     expectAsync1((state) => state.item4, count: 8 + 1),
    //     // 8 action causes state changed
    //     expectAsync1((state) => state.item5, count: 8 + 1),
    //     // 8 action causes state changed
    //     expectAsync1((state) => state.item6, count: 8 + 1),
    //     // 8 action causes state changed
    //     expectAsync6(
    //           (int subState1,
    //           double subState2,
    //           String subState3,
    //           bool subState4,
    //           BuiltList<String> subState5,
    //           BuiltMap<String, int> subState6) =>
    //           Tuple6(subState1, subState2, subState3, subState4, subState5,
    //               subState6),
    //       count: 6 + 1, // inc. calling to produce seed value
    //     ),
    //     equals3: (String prev, String next) => prev == next,
    //   );
    //
    //   expect(
    //       tuple$.value,
    //       Tuple6(
    //           0, 1.0, '', true, <String>[].build(), <String, int>{}.build()));
    //   final future = expectLater(
    //     tuple$,
    //     emitsInOrder(<Object>[
    //       Tuple6(
    //           1, 1.0, '', true, <String>[].build(), <String, int>{}.build()),
    //       Tuple6(
    //           1, 3.0, '', true, <String>[].build(), <String, int>{}.build()),
    //       Tuple6(
    //           1, 3.0, '4', true, <String>[].build(), <String, int>{}.build()),
    //       Tuple6(1, 3.0, '4', false, <String>[].build(),
    //           <String, int>{}.build()),
    //       Tuple6(1, 3.0, '4', false, <String>['7'].build(),
    //           <String, int>{}.build()),
    //       Tuple6(1, 3.0, '4', false, <String>['7'].build(),
    //           <String, int>{'@': 8}.build()),
    //       emitsDone,
    //     ]),
    //   );
    //
    //   for (var i = 0; i <= 9; i++) {
    //     i.dispatchTo(store);
    //   }
    //   await pumpEventQueue(times: 100);
    //   await store.dispose();
    //   await future;
    // });
    //
    // test('select7', () async {
    //   final initial = Tuple8(
    //     0,
    //     1.0,
    //     '',
    //     true,
    //     <String>[].build(),
    //     <String, int>{}.build(),
    //     <String>{}.build(),
    //     BuiltListMultimap<String, int>.build((b) => b
    //       ..add('@', 1)
    //       ..add('@', 2)),
    //   );
    //
    //   final store = RxReduxStore<
    //       int,
    //       Tuple8<
    //           int,
    //           double,
    //           String,
    //           bool,
    //           BuiltList<String>,
    //           BuiltMap<String, int>,
    //           BuiltSet<String>,
    //           BuiltListMultimap<String, int>>>(
    //     initialState: initial,
    //     sideEffects: [],
    //     reducer: (s, a) {
    //       switch (a) {
    //         case 0:
    //           return s;
    //         case 1:
    //           return s.withItem1(s.item1 + a); // [item 1]
    //         case 2:
    //           return s.withItem2(s.item2 + a); // [item 2]
    //         case 3:
    //           return s.withItem8(
    //               s.item8.rebuild((b) => b.remove('@', 1))); // ------------
    //         case 4:
    //           return s.withItem3(s.item3 + a.toString()); // [item 3]
    //         case 5:
    //           return s.withItem4(!s.item4); // [item 4]
    //         case 6:
    //           return s.withItem8(
    //               s.item8.rebuild((b) => b.removeAll('@'))); // ------------
    //         case 7:
    //           return s.withItem5(
    //               s.item5.rebuild((b) => b.add(a.toString()))); // [item 5]
    //         case 8:
    //           return s
    //               .withItem6(s.item6.rebuild((b) => b['@'] = a)); // [item 6]
    //         case 9:
    //           return s.withItem8(
    //               s.item8.rebuild((b) => b.add('#', a))); // ------------
    //         case 10:
    //           return s.withItem7(
    //               s.item7.rebuild((b) => b.add(a.toString()))); // [item 7]
    //         case 11:
    //           return s;
    //         default:
    //           throw a;
    //       }
    //     },
    //   );
    //
    //   var projectCount = 0;
    //
    //   final tuple$ = store.select7(
    //     expectAsync1((state) => state.item1, count: 10 + 1),
    //     // 10 action causes state changed
    //     expectAsync1((state) => state.item2, count: 10 + 1),
    //     // 10 action causes state changed
    //     expectAsync1((state) => state.item3, count: 10 + 1),
    //     // 10 action causes state changed
    //     expectAsync1((state) => state.item4, count: 10 + 1),
    //     // 10 action causes state changed
    //     expectAsync1((state) => state.item5, count: 10 + 1),
    //     // 10 action causes state changed
    //     expectAsync1((state) => state.item6, count: 10 + 1),
    //     // 10 action causes state changed
    //     expectAsync1((state) => state.item7, count: 10 + 1),
    //     // 10 action causes state changed
    //         (int subState1,
    //         double subState2,
    //         String subState3,
    //         bool subState4,
    //         BuiltList<String> subState5,
    //         BuiltMap<String, int> subState6,
    //         BuiltSet<String> subState7) {
    //       ++projectCount;
    //       return Tuple7(subState1, subState2, subState3, subState4, subState5,
    //           subState6, subState7);
    //     },
    //     equals3: (String prev, String next) => prev == next,
    //   );
    //
    //   expect(
    //     tuple$.value,
    //     Tuple7(
    //       0,
    //       1.0,
    //       '',
    //       true,
    //       <String>[].build(),
    //       <String, int>{}.build(),
    //       <String>{}.build(),
    //     ),
    //   );
    //   final future = expectLater(
    //     tuple$,
    //     emitsInOrder(<Object>[
    //       Tuple7(
    //         1,
    //         1.0,
    //         '',
    //         true,
    //         <String>[].build(),
    //         <String, int>{}.build(),
    //         <String>{}.build(),
    //       ),
    //       Tuple7(
    //         1,
    //         3.0,
    //         '',
    //         true,
    //         <String>[].build(),
    //         <String, int>{}.build(),
    //         <String>{}.build(),
    //       ),
    //       Tuple7(
    //         1,
    //         3.0,
    //         '4',
    //         true,
    //         <String>[].build(),
    //         <String, int>{}.build(),
    //         <String>{}.build(),
    //       ),
    //       Tuple7(
    //         1,
    //         3.0,
    //         '4',
    //         false,
    //         <String>[].build(),
    //         <String, int>{}.build(),
    //         <String>{}.build(),
    //       ),
    //       Tuple7(
    //         1,
    //         3.0,
    //         '4',
    //         false,
    //         <String>['7'].build(),
    //         <String, int>{}.build(),
    //         <String>{}.build(),
    //       ),
    //       Tuple7(
    //         1,
    //         3.0,
    //         '4',
    //         false,
    //         <String>['7'].build(),
    //         <String, int>{'@': 8}.build(),
    //         <String>{}.build(),
    //       ),
    //       Tuple7(
    //         1,
    //         3.0,
    //         '4',
    //         false,
    //         <String>['7'].build(),
    //         <String, int>{'@': 8}.build(),
    //         <String>{'10'}.build(),
    //       ),
    //       emitsDone,
    //     ]),
    //   );
    //
    //   for (var i = 0; i <= 11; i++) {
    //     i.dispatchTo(store);
    //   }
    //   await pumpEventQueue(times: 100);
    //   await store.dispose();
    //   await future;
    //
    //   expect(projectCount, 7 + 1); // seed value + 7 items.
    // });
    //
    // test('select8', () async {
    //   final initial = Tuple9(
    //     0,
    //     1.0,
    //     '',
    //     true,
    //     <String>[].build(),
    //     <String, int>{}.build(),
    //     <String>{}.build(),
    //     BuiltListMultimap<String, int>.build((b) => b
    //       ..add('@', 1)
    //       ..add('@', 2)),
    //     BuiltSetMultimap<String, int>.build((b) => b
    //       ..add('@', 1)
    //       ..add('@', 2)),
    //   );
    //
    //   final store = RxReduxStore<
    //       int,
    //       Tuple9<
    //           int,
    //           double,
    //           String,
    //           bool,
    //           BuiltList<String>,
    //           BuiltMap<String, int>,
    //           BuiltSet<String>,
    //           BuiltListMultimap<String, int>,
    //           BuiltSetMultimap<String, int>>>(
    //     initialState: initial,
    //     sideEffects: [],
    //     reducer: (s, a) {
    //       switch (a) {
    //         case 0:
    //           return s;
    //         case 1:
    //           return s.withItem1(s.item1 + a); // [item 1]
    //         case 2:
    //           return s.withItem2(s.item2 + a); // [item 2]
    //         case 3:
    //           return s.withItem9(
    //               s.item9.rebuild((b) => b.remove('@', 1))); // ------------
    //         case 4:
    //           return s.withItem3(s.item3 + a.toString()); // [item 3]
    //         case 5:
    //           return s.withItem4(!s.item4); // [item 4]
    //         case 6:
    //           return s.withItem9(
    //               s.item9.rebuild((b) => b.removeAll('@'))); // ------------
    //         case 7:
    //           return s.withItem5(
    //               s.item5.rebuild((b) => b.add(a.toString()))); // [item 5]
    //         case 8:
    //           return s
    //               .withItem6(s.item6.rebuild((b) => b['@'] = a)); // [item 6]
    //         case 9:
    //           return s.withItem9(
    //               s.item9.rebuild((b) => b.add('#', a))); // ------------
    //         case 10:
    //           return s.withItem7(
    //               s.item7.rebuild((b) => b.add(a.toString()))); // [item 7]
    //         case 11:
    //           return s.withItem8(
    //               s.item8.rebuild((b) => b.add('#', a))); // [item 8]
    //         case 12:
    //           return s;
    //         default:
    //           throw a;
    //       }
    //     },
    //   );
    //
    //   var projectCount = 0;
    //
    //   final tuple$ = store.select8(
    //     expectAsync1((state) => state.item1, count: 11 + 1),
    //     // 11 action causes state changed
    //     expectAsync1((state) => state.item2, count: 11 + 1),
    //     // 11 action causes state changed
    //     expectAsync1((state) => state.item3, count: 11 + 1),
    //     // 11 action causes state changed
    //     expectAsync1((state) => state.item4, count: 11 + 1),
    //     // 11 action causes state changed
    //     expectAsync1((state) => state.item5, count: 11 + 1),
    //     // 11 action causes state changed
    //     expectAsync1((state) => state.item6, count: 11 + 1),
    //     // 11 action causes state changed
    //     expectAsync1((state) => state.item7, count: 11 + 1),
    //     // 11 action causes state changed
    //     expectAsync1((state) => state.item8, count: 11 + 1),
    //     // 11 action causes state changed
    //         (int subState1,
    //         double subState2,
    //         String subState3,
    //         bool subState4,
    //         BuiltList<String> subState5,
    //         BuiltMap<String, int> subState6,
    //         BuiltSet<String> subState7,
    //         BuiltListMultimap<String, int> subState8) {
    //       ++projectCount;
    //       return Tuple8(subState1, subState2, subState3, subState4, subState5,
    //           subState6, subState7, subState8);
    //     },
    //     equals3: (String prev, String next) => prev == next,
    //   );
    //
    //   expect(
    //     tuple$.value,
    //     Tuple8(
    //       0,
    //       1.0,
    //       '',
    //       true,
    //       <String>[].build(),
    //       <String, int>{}.build(),
    //       <String>{}.build(),
    //       BuiltListMultimap<String, int>({
    //         '@': [1, 2]
    //       }),
    //     ),
    //   );
    //   final future = expectLater(
    //     tuple$,
    //     emitsInOrder(<Object>[
    //       Tuple8(
    //         1,
    //         1.0,
    //         '',
    //         true,
    //         <String>[].build(),
    //         <String, int>{}.build(),
    //         <String>{}.build(),
    //         BuiltListMultimap<String, int>(<String, List<int>>{
    //           '@': [1, 2]
    //         }),
    //       ),
    //       Tuple8(
    //         1,
    //         3.0,
    //         '',
    //         true,
    //         <String>[].build(),
    //         <String, int>{}.build(),
    //         <String>{}.build(),
    //         BuiltListMultimap<String, int>(<String, List<int>>{
    //           '@': [1, 2]
    //         }),
    //       ),
    //       Tuple8(
    //         1,
    //         3.0,
    //         '4',
    //         true,
    //         <String>[].build(),
    //         <String, int>{}.build(),
    //         <String>{}.build(),
    //         BuiltListMultimap<String, int>(<String, List<int>>{
    //           '@': [1, 2]
    //         }),
    //       ),
    //       Tuple8(
    //         1,
    //         3.0,
    //         '4',
    //         false,
    //         <String>[].build(),
    //         <String, int>{}.build(),
    //         <String>{}.build(),
    //         BuiltListMultimap<String, int>(<String, List<int>>{
    //           '@': [1, 2]
    //         }),
    //       ),
    //       Tuple8(
    //         1,
    //         3.0,
    //         '4',
    //         false,
    //         <String>['7'].build(),
    //         <String, int>{}.build(),
    //         <String>{}.build(),
    //         BuiltListMultimap<String, int>(<String, List<int>>{
    //           '@': [1, 2]
    //         }),
    //       ),
    //       Tuple8(
    //         1,
    //         3.0,
    //         '4',
    //         false,
    //         <String>['7'].build(),
    //         <String, int>{'@': 8}.build(),
    //         <String>{}.build(),
    //         BuiltListMultimap<String, int>(<String, List<int>>{
    //           '@': [1, 2]
    //         }),
    //       ),
    //       Tuple8(
    //         1,
    //         3.0,
    //         '4',
    //         false,
    //         <String>['7'].build(),
    //         <String, int>{'@': 8}.build(),
    //         <String>{'10'}.build(),
    //         BuiltListMultimap<String, int>(<String, List<int>>{
    //           '@': [1, 2]
    //         }),
    //       ),
    //       Tuple8(
    //         1,
    //         3.0,
    //         '4',
    //         false,
    //         <String>['7'].build(),
    //         <String, int>{'@': 8}.build(),
    //         <String>{'10'}.build(),
    //         BuiltListMultimap<String, int>(<String, List<int>>{
    //           '@': [1, 2],
    //           '#': [11]
    //         }),
    //       ),
    //       emitsDone,
    //     ]),
    //   );
    //
    //   for (var i = 0; i <= 12; i++) {
    //     i.dispatchTo(store);
    //   }
    //   await pumpEventQueue(times: 100);
    //   await store.dispose();
    //   await future;
    //
    //   expect(projectCount, 8 + 1); // seed value + 8 items.
    // });
    //
    // test('select9', () async {
    //   final initial = Tuple10(
    //     0,
    //     1.0,
    //     '',
    //     true,
    //     <String>[].build(),
    //     <String, int>{}.build(),
    //     <String>{}.build(),
    //     BuiltListMultimap<String, int>.build((b) => b
    //       ..add('@', 1)
    //       ..add('@', 2)),
    //     BuiltSetMultimap<String, int>.build((b) => b
    //       ..add('@', 1)
    //       ..add('@', 2)),
    //     DateTime(1998, DateTime.october, 8),
    //   );
    //
    //   final store = RxReduxStore<
    //       int,
    //       Tuple10<
    //           int,
    //           double,
    //           String,
    //           bool,
    //           BuiltList<String>,
    //           BuiltMap<String, int>,
    //           BuiltSet<String>,
    //           BuiltListMultimap<String, int>,
    //           BuiltSetMultimap<String, int>,
    //           DateTime>>(
    //     initialState: initial,
    //     sideEffects: [],
    //     reducer: (s, a) {
    //       switch (a) {
    //         case 0:
    //           return s;
    //         case 1:
    //           return s.withItem1(s.item1 + a); // [item 1]
    //         case 2:
    //           return s.withItem2(s.item2 + a); // [item 2]
    //         case 3:
    //           return s.withItem10(
    //               s.item10.add(const Duration(hours: 1))); // ------------
    //         case 4:
    //           return s.withItem3(s.item3 + a.toString()); // [item 3]
    //         case 5:
    //           return s.withItem4(!s.item4); // [item 4]
    //         case 6:
    //           return s.withItem10(
    //               s.item10.add(const Duration(hours: 1))); // ------------
    //         case 7:
    //           return s.withItem5(
    //               s.item5.rebuild((b) => b.add(a.toString()))); // [item 5]
    //         case 8:
    //           return s
    //               .withItem6(s.item6.rebuild((b) => b['@'] = a)); // [item 6]
    //         case 9:
    //           return s.withItem10(
    //               s.item10.add(const Duration(hours: 1))); // ------------
    //         case 10:
    //           return s.withItem7(
    //               s.item7.rebuild((b) => b.add(a.toString()))); // [item 7]
    //         case 11:
    //           return s.withItem8(
    //               s.item8.rebuild((b) => b.add('#', a))); // [item 8]
    //         case 12:
    //           return s.withItem9(
    //               s.item9.rebuild((b) => b.add('#', a))); // [item 9]
    //         case 13:
    //           return s;
    //         default:
    //           throw a;
    //       }
    //     },
    //   );
    //
    //   var projectCount = 0;
    //
    //   final tuple$ = store.select9(
    //     expectAsync1((state) => state.item1, count: 12 + 1),
    //     // 12 action causes state changed
    //     expectAsync1((state) => state.item2, count: 12 + 1),
    //     // 12 action causes state changed
    //     expectAsync1((state) => state.item3, count: 12 + 1),
    //     // 12 action causes state changed
    //     expectAsync1((state) => state.item4, count: 12 + 1),
    //     // 12 action causes state changed
    //     expectAsync1((state) => state.item5, count: 12 + 1),
    //     // 12 action causes state changed
    //     expectAsync1((state) => state.item6, count: 12 + 1),
    //     // 12 action causes state changed
    //     expectAsync1((state) => state.item7, count: 12 + 1),
    //     // 12 action causes state changed
    //     expectAsync1((state) => state.item8, count: 12 + 1),
    //     // 12 action causes state changed
    //     expectAsync1((state) => state.item9, count: 12 + 1),
    //     // 12 action causes state changed
    //         (int subState1,
    //         double subState2,
    //         String subState3,
    //         bool subState4,
    //         BuiltList<String> subState5,
    //         BuiltMap<String, int> subState6,
    //         BuiltSet<String> subState7,
    //         BuiltListMultimap<String, int> subState8,
    //         BuiltSetMultimap<String, int> subState9) {
    //       ++projectCount;
    //       return Tuple9(subState1, subState2, subState3, subState4, subState5,
    //           subState6, subState7, subState8, subState9);
    //     },
    //     equals3: (String prev, String next) => prev == next,
    //   );
    //
    //   expect(
    //     tuple$.value,
    //     Tuple9(
    //       0,
    //       1.0,
    //       '',
    //       true,
    //       <String>[].build(),
    //       <String, int>{}.build(),
    //       <String>{}.build(),
    //       BuiltListMultimap<String, int>({
    //         '@': [1, 2]
    //       }),
    //       BuiltSetMultimap<String, int>({
    //         '@': {1, 2}
    //       }),
    //     ),
    //   );
    //   final future = expectLater(
    //     tuple$,
    //     emitsInOrder(<Object>[
    //       Tuple9(
    //         1,
    //         1.0,
    //         '',
    //         true,
    //         <String>[].build(),
    //         <String, int>{}.build(),
    //         <String>{}.build(),
    //         BuiltListMultimap<String, int>({
    //           '@': [1, 2]
    //         }),
    //         BuiltSetMultimap<String, int>({
    //           '@': {1, 2}
    //         }),
    //       ),
    //       Tuple9(
    //         1,
    //         3.0,
    //         '',
    //         true,
    //         <String>[].build(),
    //         <String, int>{}.build(),
    //         <String>{}.build(),
    //         BuiltListMultimap<String, int>({
    //           '@': [1, 2]
    //         }),
    //         BuiltSetMultimap<String, int>({
    //           '@': {1, 2}
    //         }),
    //       ),
    //       Tuple9(
    //         1,
    //         3.0,
    //         '4',
    //         true,
    //         <String>[].build(),
    //         <String, int>{}.build(),
    //         <String>{}.build(),
    //         BuiltListMultimap<String, int>({
    //           '@': [1, 2]
    //         }),
    //         BuiltSetMultimap<String, int>({
    //           '@': {1, 2}
    //         }),
    //       ),
    //       Tuple9(
    //         1,
    //         3.0,
    //         '4',
    //         false,
    //         <String>[].build(),
    //         <String, int>{}.build(),
    //         <String>{}.build(),
    //         BuiltListMultimap<String, int>({
    //           '@': [1, 2]
    //         }),
    //         BuiltSetMultimap<String, int>({
    //           '@': {1, 2}
    //         }),
    //       ),
    //       Tuple9(
    //         1,
    //         3.0,
    //         '4',
    //         false,
    //         <String>['7'].build(),
    //         <String, int>{}.build(),
    //         <String>{}.build(),
    //         BuiltListMultimap<String, int>({
    //           '@': [1, 2]
    //         }),
    //         BuiltSetMultimap<String, int>({
    //           '@': {1, 2}
    //         }),
    //       ),
    //       Tuple9(
    //         1,
    //         3.0,
    //         '4',
    //         false,
    //         <String>['7'].build(),
    //         <String, int>{'@': 8}.build(),
    //         <String>{}.build(),
    //         BuiltListMultimap<String, int>({
    //           '@': [1, 2]
    //         }),
    //         BuiltSetMultimap<String, int>({
    //           '@': {1, 2}
    //         }),
    //       ),
    //       Tuple9(
    //         1,
    //         3.0,
    //         '4',
    //         false,
    //         <String>['7'].build(),
    //         <String, int>{'@': 8}.build(),
    //         <String>{'10'}.build(),
    //         BuiltListMultimap<String, int>({
    //           '@': [1, 2]
    //         }),
    //         BuiltSetMultimap<String, int>({
    //           '@': {1, 2}
    //         }),
    //       ),
    //       Tuple9(
    //         1,
    //         3.0,
    //         '4',
    //         false,
    //         <String>['7'].build(),
    //         <String, int>{'@': 8}.build(),
    //         <String>{'10'}.build(),
    //         BuiltListMultimap<String, int>({
    //           '@': [1, 2],
    //           '#': [11]
    //         }),
    //         BuiltSetMultimap<String, int>({
    //           '@': {1, 2}
    //         }),
    //       ),
    //       Tuple9(
    //         1,
    //         3.0,
    //         '4',
    //         false,
    //         <String>['7'].build(),
    //         <String, int>{'@': 8}.build(),
    //         <String>{'10'}.build(),
    //         BuiltListMultimap<String, int>({
    //           '@': [1, 2],
    //           '#': [11]
    //         }),
    //         BuiltSetMultimap<String, int>({
    //           '@': {1, 2},
    //           '#': {12}
    //         }),
    //       ),
    //       emitsDone,
    //     ]),
    //   );
    //
    //   for (var i = 0; i <= 13; i++) {
    //     i.dispatchTo(store);
    //   }
    //   await pumpEventQueue(times: 100);
    //   await store.dispose();
    //   await future;
    //
    //   expect(projectCount, 9 + 1); // seed value + 9 items.
    // });
    //
    // group('selectMany', () {
    //   test('assert', () {
    //     final store = RxReduxStore<int, String>(
    //       initialState: 'initialState',
    //       sideEffects: [],
    //       reducer: (s, a) => s,
    //     );
    //     expect(
    //           () => store.selectMany(
    //         [(s) => s.length, (s) => s.isEmpty ? null : s[0]],
    //         [null, null, null],
    //             (subStates) => subStates,
    //       ),
    //       throwsArgumentError,
    //     );
    //     expect(
    //           () => store.selectMany<Object, Object>(
    //         [],
    //         [],
    //             (subStates) => subStates,
    //       ),
    //       throwsArgumentError,
    //     );
    //     expect(
    //           () => store.selectMany(
    //         [(s) => s.length],
    //         [null],
    //             (subStates) => subStates,
    //       ),
    //       throwsArgumentError,
    //     );
    //   });
    //
    //   test('~= select2', () async {
    //     final store = RxReduxStore<int, _State>(
    //       initialState: _State(true, null, <String>[].build(), 1),
    //       sideEffects: [],
    //       reducer: (s, a) {
    //         // items [*]
    //         if (a == 0) {
    //           return _State(
    //             s.isLoading,
    //             s.term,
    //             List.generate(10, (i) => i.toString()).build(),
    //             s.otherState,
    //           );
    //         }
    //
    //         // loading
    //         if (a == 1) {
    //           return _State(!s.isLoading, s.term, s.items, s.otherState);
    //         }
    //
    //         // loading
    //         if (a == 2) {
    //           return _State(!s.isLoading, s.term, s.items, s.otherState);
    //         }
    //
    //         // term [*]
    //         if (a == 3) {
    //           return _State(s.isLoading, '4', s.items, s.otherState);
    //         }
    //
    //         // otherState
    //         if (a == 4) {
    //           return _State(s.isLoading, s.term, s.items, s.otherState + 2);
    //         }
    //
    //         // loading & otherState
    //         if (a == 5) {
    //           return _State(!s.isLoading, s.term, s.items, -s.otherState);
    //         }
    //
    //         throw a;
    //       },
    //     );
    //
    //     await pumpEventQueue(times: 50);
    //
    //     var termCount = 0;
    //     var itemsCount = 0;
    //     var projectorCount = 0;
    //
    //     final filtered = store.selectMany<Object?, BuiltList<String>>(
    //       [
    //             (s) {
    //           ++termCount;
    //           return s.term;
    //         },
    //             (s) {
    //           ++itemsCount;
    //           return s.items;
    //         }
    //       ],
    //       [null, null],
    //           (List<Object?> subStates) {
    //         ++projectorCount;
    //         return (subStates[1] as BuiltList<String>)
    //             .where((i) => i.contains((subStates[0] as String?) ?? ''))
    //             .toBuiltList();
    //       },
    //     );
    //
    //     expect(filtered.value, <String>[].build());
    //     final future = expectLater(
    //       filtered,
    //       emitsInOrder(<Object>[
    //         List.generate(10, (i) => i.toString()).build(),
    //         ['4'].build(),
    //         emitsDone,
    //       ]),
    //     );
    //
    //     final numberOfActions = 6;
    //     for (var i = 0; i < numberOfActions; i++) {
    //       store.dispatch(i);
    //     }
    //     await pumpEventQueue(times: 50);
    //     await store.dispose();
    //     await future;
    //
    //     expect(termCount,
    //         numberOfActions + 1); // inc. calling to produce seed value
    //     expect(itemsCount,
    //         numberOfActions + 1); // inc. calling to produce seed value
    //     expect(projectorCount,
    //         2 + 1); // 2 [*] and inc. calling to produce seed value
    //   });
    //
    //   test('~= select3', () async {
    //     final store = RxReduxStore<int, _State>(
    //       initialState: _State(true, null, <String>[].build(), 2),
    //       sideEffects: [],
    //       reducer: (s, a) {
    //         // items [*]
    //         if (a == 0) {
    //           return _State(
    //             s.isLoading,
    //             s.term,
    //             List.generate(10, (i) => i.toString()).build(),
    //             s.otherState,
    //           );
    //         }
    //
    //         // loading
    //         if (a == 1) {
    //           return _State(!s.isLoading, s.term, s.items, s.otherState);
    //         }
    //
    //         // loading
    //         if (a == 2) {
    //           return _State(!s.isLoading, s.term, s.items, s.otherState);
    //         }
    //
    //         // term [*]
    //         if (a == 3) {
    //           return _State(s.isLoading, '4', s.items, s.otherState);
    //         }
    //
    //         // otherState [*]
    //         if (a == 4) {
    //           return _State(s.isLoading, s.term, s.items, s.otherState + 2);
    //         }
    //
    //         // loading & otherState [*]
    //         if (a == 5) {
    //           return _State(!s.isLoading, s.term, s.items, s.otherState - 1);
    //         }
    //
    //         throw a;
    //       },
    //     );
    //
    //     await pumpEventQueue(times: 50);
    //
    //     var termCount = 0;
    //     var itemsCount = 0;
    //     var otherStateCount = 0;
    //     var projectorCount = 0;
    //
    //     final filtered = store.selectMany(
    //       [
    //             (s) {
    //           ++termCount;
    //           return s.term;
    //         },
    //             (s) {
    //           ++itemsCount;
    //           return s.items;
    //         },
    //             (s) {
    //           ++otherStateCount;
    //           return s.otherState.round();
    //         },
    //       ],
    //       [null, null, null],
    //           (List<Object?> subStates) {
    //         ++projectorCount;
    //
    //         final term = subStates[0] as String?;
    //         final items = subStates[1] as BuiltList<String>;
    //         final otherState = subStates[2] as int;
    //
    //         return items
    //             .where((i) => i.contains(term ?? ''))
    //             .take(otherState)
    //             .toBuiltList();
    //       },
    //     );
    //
    //     expect(filtered.value, <String>[].build());
    //     final future = expectLater(
    //       filtered,
    //       emitsInOrder(<Object>[
    //         ['0', '1'].build(),
    //         ['4'].build(),
    //         emitsDone,
    //       ]),
    //     );
    //
    //     final numberOfActions = 6;
    //     for (var i = 0; i < numberOfActions; i++) {
    //       store.dispatch(i);
    //     }
    //     await pumpEventQueue(times: 50);
    //     await store.dispose();
    //     await future;
    //
    //     expect(termCount,
    //         numberOfActions + 1); // inc. calling to produce seed value
    //     expect(itemsCount,
    //         numberOfActions + 1); // inc. calling to produce seed value
    //     expect(otherStateCount,
    //         numberOfActions + 1); // inc. calling to produce seed value
    //     expect(projectorCount,
    //         4 + 1); // 4 [*] and inc. calling to produce seed value
    //   });
    //
    //   test('~= select4', () async {
    //     final initial = Tuple5(0, 1.0, '', true, <String>[].build());
    //
    //     final store = RxReduxStore<int,
    //         Tuple5<int, double, String, bool, BuiltList<String>>>(
    //       initialState: initial,
    //       sideEffects: [],
    //       reducer: (s, a) {
    //         switch (a) {
    //           case 0:
    //             return s;
    //           case 1:
    //             return s.withItem5(s.item5.rebuild((b) => b.remove('01')));
    //           case 2:
    //             return s.withItem1(s.item1 + 1);
    //           case 3:
    //             return s.withItem2(s.item2 + 2);
    //           case 4:
    //             return s.withItem5(s.item5.rebuild((b) => b.add('01')));
    //           case 5:
    //             return s;
    //           case 6:
    //             return s.withItem3(s.item3 + '3');
    //           case 7:
    //             return s.withItem4(!s.item4);
    //           case 8:
    //             return s.withItem5(s.item5.rebuild((b) => b.add('5')));
    //           default:
    //             throw a;
    //         }
    //       },
    //     );
    //
    //     final tuple$ = store.selectMany(
    //       [
    //         expectAsync1((state) => state.item1, count: 7 + 1),
    //         // 7 action causes state changed
    //         expectAsync1((state) => state.item2, count: 7 + 1),
    //         // 7 action causes state changed
    //         expectAsync1((state) => state.item3, count: 7 + 1),
    //         // 7 action causes state changed
    //         expectAsync1((state) => state.item4, count: 7 + 1),
    //         // 7 action causes state changed
    //       ],
    //       [null, null, null, null],
    //       expectAsync1(
    //             (List<Object?> subStates) => Tuple4(
    //           subStates[0] as int,
    //           subStates[1] as double,
    //           subStates[2] as String,
    //           subStates[3] as bool,
    //         ),
    //         count: 4 + 1, // inc. calling to produce seed value
    //       ),
    //     );
    //
    //     final tuple4 = Tuple4<int, double, String, bool>(0, 1.0, '', true);
    //     expect(tuple$.value, tuple4);
    //     final future = expectLater(
    //       tuple$,
    //       emitsInOrder(<Object>[
    //         Tuple4(0, 1.0, '', false), // 7
    //         Tuple4(0, 1.0, '3', false), // 6
    //         Tuple4(0, 3.0, '3', false), // 3
    //         Tuple4(1, 3.0, '3', false), // 2
    //         emitsDone,
    //       ]),
    //     );
    //
    //     for (var i = 8; i >= 0; i--) {
    //       i.dispatchTo(store);
    //     }
    //     await pumpEventQueue(times: 100);
    //     await store.dispose();
    //     await future;
    //   });
    //
    //   test('~= select5', () async {
    //     final initial = Tuple6(
    //       0,
    //       1.0,
    //       '',
    //       true,
    //       <String>[].build(),
    //       <String, int>{}.build(),
    //     );
    //
    //     final store = RxReduxStore<
    //         int,
    //         Tuple6<int, double, String, bool, BuiltList<String>,
    //             BuiltMap<String, int>>>(
    //       initialState: initial,
    //       sideEffects: [],
    //       reducer: (s, a) {
    //         switch (a) {
    //           case 0:
    //             return s;
    //           case 1:
    //             return s.withItem1(s.item1 + a); // [item 1]
    //           case 2:
    //             return s.withItem2(s.item2 + a); // [item 2]
    //           case 3:
    //             return s.withItem6(
    //                 s.item6.rebuild((b) => b['@'] = a)); // ------------
    //           case 4:
    //             return s.withItem3(s.item3 + a.toString()); // [item 3]
    //           case 5:
    //             return s.withItem4(!s.item4); // [item 4]
    //           case 6:
    //             return s.withItem6(
    //                 s.item6.rebuild((b) => b.remove('@'))); // ------------
    //           case 7:
    //             return s.withItem5(
    //                 s.item5.rebuild((b) => b.add(a.toString()))); // [item 5]
    //           case 8:
    //             return s;
    //           default:
    //             throw a;
    //         }
    //       },
    //     );
    //
    //     final tuple$ = store.selectMany(
    //       [
    //         expectAsync1((state) => state.item1, count: 7 + 1),
    //         // 7 action causes state changed
    //         expectAsync1((state) => state.item2, count: 7 + 1),
    //         // 7 action causes state changed
    //         expectAsync1((state) => state.item3, count: 7 + 1),
    //         // 7 action causes state changed
    //         expectAsync1((state) => state.item4, count: 7 + 1),
    //         // 7 action causes state changed
    //         expectAsync1((state) => state.item5, count: 7 + 1),
    //         // 7 action causes state changed
    //       ],
    //       [null, null, null, null, null],
    //       expectAsync1(
    //             (subStates) {
    //           return Tuple5(
    //             subStates[0] as int,
    //             subStates[1] as double,
    //             subStates[2] as String,
    //             subStates[3] as bool,
    //             subStates[4] as BuiltList<String>,
    //           );
    //         },
    //         count: 5 + 1, // inc. calling to produce seed value
    //       ),
    //     );
    //
    //     expect(tuple$.value, Tuple5(0, 1.0, '', true, <String>[].build()));
    //     final future = expectLater(
    //       tuple$,
    //       emitsInOrder(<Object>[
    //         Tuple5(1, 1.0, '', true, <String>[].build()),
    //         Tuple5(1, 3.0, '', true, <String>[].build()),
    //         Tuple5(1, 3.0, '4', true, <String>[].build()),
    //         Tuple5(1, 3.0, '4', false, <String>[].build()),
    //         Tuple5(1, 3.0, '4', false, <String>['7'].build()),
    //         emitsDone,
    //       ]),
    //     );
    //
    //     for (var i = 0; i <= 8; i++) {
    //       i.dispatchTo(store);
    //     }
    //     await pumpEventQueue(times: 100);
    //     await store.dispose();
    //     await future;
    //   });
    //
    //   test('~= select6', () async {
    //     final initial = Tuple7(
    //       0,
    //       1.0,
    //       '',
    //       true,
    //       <String>[].build(),
    //       <String, int>{}.build(),
    //       <String>{}.build(),
    //     );
    //
    //     final store = RxReduxStore<
    //         int,
    //         Tuple7<int, double, String, bool, BuiltList<String>,
    //             BuiltMap<String, int>, BuiltSet<String>>>(
    //       initialState: initial,
    //       sideEffects: [],
    //       reducer: (s, a) {
    //         switch (a) {
    //           case 0:
    //             return s;
    //           case 1:
    //             return s.withItem1(s.item1 + a); // [item 1]
    //           case 2:
    //             return s.withItem2(s.item2 + a); // [item 2]
    //           case 3:
    //             return s.withItem7(s.item7
    //                 .rebuild((b) => b.add(a.toString()))); // ------------
    //           case 4:
    //             return s.withItem3(s.item3 + a.toString()); // [item 3]
    //           case 5:
    //             return s.withItem4(!s.item4); // [item 4]
    //           case 6:
    //             return s.withItem7(s.item7
    //                 .rebuild((b) => b.add(a.toString()))); // ------------
    //           case 7:
    //             return s.withItem5(
    //                 s.item5.rebuild((b) => b.add(a.toString()))); // [item 5]
    //           case 8:
    //             return s.withItem6(
    //                 s.item6.rebuild((b) => b['@'] = a)); // [item 6]
    //           case 9:
    //             return s;
    //           default:
    //             throw a;
    //         }
    //       },
    //     );
    //
    //     final tuple$ = store.selectMany(
    //       [
    //         expectAsync1((state) => state.item1, count: 8 + 1),
    //         // 8 action causes state changed
    //         expectAsync1((state) => state.item2, count: 8 + 1),
    //         // 8 action causes state changed
    //         expectAsync1((state) => state.item3, count: 8 + 1),
    //         // 8 action causes state changed
    //         expectAsync1((state) => state.item4, count: 8 + 1),
    //         // 8 action causes state changed
    //         expectAsync1((state) => state.item5, count: 8 + 1),
    //         // 8 action causes state changed
    //         expectAsync1((state) => state.item6, count: 8 + 1),
    //         // 8 action causes state changed
    //       ],
    //       [null, null, null, null, null, null],
    //       expectAsync1(
    //             (subStates) => Tuple6(
    //           subStates[0] as int,
    //           subStates[1] as double,
    //           subStates[2] as String,
    //           subStates[3] as bool,
    //           subStates[4] as BuiltList<String>,
    //           subStates[5] as BuiltMap<String, int>,
    //         ),
    //         count: 6 + 1, // inc. calling to produce seed value
    //       ),
    //     );
    //
    //     expect(
    //         tuple$.value,
    //         Tuple6(0, 1.0, '', true, <String>[].build(),
    //             <String, int>{}.build()));
    //     final future = expectLater(
    //       tuple$,
    //       emitsInOrder(<Object>[
    //         Tuple6(1, 1.0, '', true, <String>[].build(),
    //             <String, int>{}.build()),
    //         Tuple6(1, 3.0, '', true, <String>[].build(),
    //             <String, int>{}.build()),
    //         Tuple6(1, 3.0, '4', true, <String>[].build(),
    //             <String, int>{}.build()),
    //         Tuple6(1, 3.0, '4', false, <String>[].build(),
    //             <String, int>{}.build()),
    //         Tuple6(1, 3.0, '4', false, <String>['7'].build(),
    //             <String, int>{}.build()),
    //         Tuple6(1, 3.0, '4', false, <String>['7'].build(),
    //             <String, int>{'@': 8}.build()),
    //         emitsDone,
    //       ]),
    //     );
    //
    //     for (var i = 0; i <= 9; i++) {
    //       i.dispatchTo(store);
    //     }
    //     await pumpEventQueue(times: 100);
    //     await store.dispose();
    //     await future;
    //   });
    //
    //   test('~= select7', () async {
    //     final initial = Tuple8(
    //       0,
    //       1.0,
    //       '',
    //       true,
    //       <String>[].build(),
    //       <String, int>{}.build(),
    //       <String>{}.build(),
    //       BuiltListMultimap<String, int>.build((b) => b
    //         ..add('@', 1)
    //         ..add('@', 2)),
    //     );
    //
    //     final store = RxReduxStore<
    //         int,
    //         Tuple8<
    //             int,
    //             double,
    //             String,
    //             bool,
    //             BuiltList<String>,
    //             BuiltMap<String, int>,
    //             BuiltSet<String>,
    //             BuiltListMultimap<String, int>>>(
    //       initialState: initial,
    //       sideEffects: [],
    //       reducer: (s, a) {
    //         switch (a) {
    //           case 0:
    //             return s;
    //           case 1:
    //             return s.withItem1(s.item1 + a); // [item 1]
    //           case 2:
    //             return s.withItem2(s.item2 + a); // [item 2]
    //           case 3:
    //             return s.withItem8(
    //                 s.item8.rebuild((b) => b.remove('@', 1))); // ------------
    //           case 4:
    //             return s.withItem3(s.item3 + a.toString()); // [item 3]
    //           case 5:
    //             return s.withItem4(!s.item4); // [item 4]
    //           case 6:
    //             return s.withItem8(
    //                 s.item8.rebuild((b) => b.removeAll('@'))); // ------------
    //           case 7:
    //             return s.withItem5(
    //                 s.item5.rebuild((b) => b.add(a.toString()))); // [item 5]
    //           case 8:
    //             return s.withItem6(
    //                 s.item6.rebuild((b) => b['@'] = a)); // [item 6]
    //           case 9:
    //             return s.withItem8(
    //                 s.item8.rebuild((b) => b.add('#', a))); // ------------
    //           case 10:
    //             return s.withItem7(
    //                 s.item7.rebuild((b) => b.add(a.toString()))); // [item 7]
    //           case 11:
    //             return s;
    //           default:
    //             throw a;
    //         }
    //       },
    //     );
    //
    //     var projectCount = 0;
    //
    //     final tuple$ = store.selectMany(
    //       [
    //         expectAsync1((state) => state.item1, count: 10 + 1),
    //         // 10 action causes state changed
    //         expectAsync1((state) => state.item2, count: 10 + 1),
    //         // 10 action causes state changed
    //         expectAsync1((state) => state.item3, count: 10 + 1),
    //         // 10 action causes state changed
    //         expectAsync1((state) => state.item4, count: 10 + 1),
    //         // 10 action causes state changed
    //         expectAsync1((state) => state.item5, count: 10 + 1),
    //         // 10 action causes state changed
    //         expectAsync1((state) => state.item6, count: 10 + 1),
    //         // 10 action causes state changed
    //         expectAsync1((state) => state.item7, count: 10 + 1),
    //         // 10 action causes state changed
    //       ],
    //       List.filled(7, null),
    //           (subStates) {
    //         ++projectCount;
    //
    //         final subState1 = subStates[0] as int;
    //         final subState2 = subStates[1] as double;
    //         final subState3 = subStates[2] as String;
    //         final subState4 = subStates[3] as bool;
    //         final subState5 = subStates[4] as BuiltList<String>;
    //         final subState6 = subStates[5] as BuiltMap<String, int>;
    //         final subState7 = subStates[6] as BuiltSet<String>;
    //         return Tuple7(subState1, subState2, subState3, subState4,
    //             subState5, subState6, subState7);
    //       },
    //     );
    //
    //     expect(
    //       tuple$.value,
    //       Tuple7(
    //         0,
    //         1.0,
    //         '',
    //         true,
    //         <String>[].build(),
    //         <String, int>{}.build(),
    //         <String>{}.build(),
    //       ),
    //     );
    //     final future = expectLater(
    //       tuple$,
    //       emitsInOrder(<Object>[
    //         Tuple7(
    //           1,
    //           1.0,
    //           '',
    //           true,
    //           <String>[].build(),
    //           <String, int>{}.build(),
    //           <String>{}.build(),
    //         ),
    //         Tuple7(
    //           1,
    //           3.0,
    //           '',
    //           true,
    //           <String>[].build(),
    //           <String, int>{}.build(),
    //           <String>{}.build(),
    //         ),
    //         Tuple7(
    //           1,
    //           3.0,
    //           '4',
    //           true,
    //           <String>[].build(),
    //           <String, int>{}.build(),
    //           <String>{}.build(),
    //         ),
    //         Tuple7(
    //           1,
    //           3.0,
    //           '4',
    //           false,
    //           <String>[].build(),
    //           <String, int>{}.build(),
    //           <String>{}.build(),
    //         ),
    //         Tuple7(
    //           1,
    //           3.0,
    //           '4',
    //           false,
    //           <String>['7'].build(),
    //           <String, int>{}.build(),
    //           <String>{}.build(),
    //         ),
    //         Tuple7(
    //           1,
    //           3.0,
    //           '4',
    //           false,
    //           <String>['7'].build(),
    //           <String, int>{'@': 8}.build(),
    //           <String>{}.build(),
    //         ),
    //         Tuple7(
    //           1,
    //           3.0,
    //           '4',
    //           false,
    //           <String>['7'].build(),
    //           <String, int>{'@': 8}.build(),
    //           <String>{'10'}.build(),
    //         ),
    //         emitsDone,
    //       ]),
    //     );
    //
    //     for (var i = 0; i <= 11; i++) {
    //       i.dispatchTo(store);
    //     }
    //     await pumpEventQueue(times: 100);
    //     await store.dispose();
    //     await future;
    //
    //     expect(projectCount, 7 + 1); // seed value + 7 items.
    //   });
    //
    //   test('~= select8', () async {
    //     final initial = Tuple9(
    //       0,
    //       1.0,
    //       '',
    //       true,
    //       <String>[].build(),
    //       <String, int>{}.build(),
    //       <String>{}.build(),
    //       BuiltListMultimap<String, int>.build((b) => b
    //         ..add('@', 1)
    //         ..add('@', 2)),
    //       BuiltSetMultimap<String, int>.build((b) => b
    //         ..add('@', 1)
    //         ..add('@', 2)),
    //     );
    //
    //     final store = RxReduxStore<
    //         int,
    //         Tuple9<
    //             int,
    //             double,
    //             String,
    //             bool,
    //             BuiltList<String>,
    //             BuiltMap<String, int>,
    //             BuiltSet<String>,
    //             BuiltListMultimap<String, int>,
    //             BuiltSetMultimap<String, int>>>(
    //       initialState: initial,
    //       sideEffects: [],
    //       reducer: (s, a) {
    //         switch (a) {
    //           case 0:
    //             return s;
    //           case 1:
    //             return s.withItem1(s.item1 + a); // [item 1]
    //           case 2:
    //             return s.withItem2(s.item2 + a); // [item 2]
    //           case 3:
    //             return s.withItem9(
    //                 s.item9.rebuild((b) => b.remove('@', 1))); // ------------
    //           case 4:
    //             return s.withItem3(s.item3 + a.toString()); // [item 3]
    //           case 5:
    //             return s.withItem4(!s.item4); // [item 4]
    //           case 6:
    //             return s.withItem9(
    //                 s.item9.rebuild((b) => b.removeAll('@'))); // ------------
    //           case 7:
    //             return s.withItem5(
    //                 s.item5.rebuild((b) => b.add(a.toString()))); // [item 5]
    //           case 8:
    //             return s.withItem6(
    //                 s.item6.rebuild((b) => b['@'] = a)); // [item 6]
    //           case 9:
    //             return s.withItem9(
    //                 s.item9.rebuild((b) => b.add('#', a))); // ------------
    //           case 10:
    //             return s.withItem7(
    //                 s.item7.rebuild((b) => b.add(a.toString()))); // [item 7]
    //           case 11:
    //             return s.withItem8(
    //                 s.item8.rebuild((b) => b.add('#', a))); // [item 8]
    //           case 12:
    //             return s;
    //           default:
    //             throw a;
    //         }
    //       },
    //     );
    //
    //     var projectCount = 0;
    //
    //     final tuple$ = store.selectMany(
    //       [
    //         expectAsync1((state) => state.item1, count: 11 + 1),
    //         // 11 action causes state changed
    //         expectAsync1((state) => state.item2, count: 11 + 1),
    //         // 11 action causes state changed
    //         expectAsync1((state) => state.item3, count: 11 + 1),
    //         // 11 action causes state changed
    //         expectAsync1((state) => state.item4, count: 11 + 1),
    //         // 11 action causes state changed
    //         expectAsync1((state) => state.item5, count: 11 + 1),
    //         // 11 action causes state changed
    //         expectAsync1((state) => state.item6, count: 11 + 1),
    //         // 11 action causes state changed
    //         expectAsync1((state) => state.item7, count: 11 + 1),
    //         // 11 action causes state changed
    //         expectAsync1((state) => state.item8, count: 11 + 1),
    //         // 11 action causes state changed
    //       ],
    //       List.filled(8, null),
    //           (subStates) {
    //         ++projectCount;
    //         return Tuple8(
    //           subStates[0] as int,
    //           subStates[1] as double,
    //           subStates[2] as String,
    //           subStates[3] as bool,
    //           subStates[4] as BuiltList<String>,
    //           subStates[5] as BuiltMap<String, int>,
    //           subStates[6] as BuiltSet<String>,
    //           subStates[7] as BuiltListMultimap<String, int>,
    //         );
    //       },
    //     );
    //
    //     expect(
    //       tuple$.value,
    //       Tuple8(
    //         0,
    //         1.0,
    //         '',
    //         true,
    //         <String>[].build(),
    //         <String, int>{}.build(),
    //         <String>{}.build(),
    //         BuiltListMultimap<String, int>({
    //           '@': [1, 2]
    //         }),
    //       ),
    //     );
    //     final future = expectLater(
    //       tuple$,
    //       emitsInOrder(<Object>[
    //         Tuple8(
    //           1,
    //           1.0,
    //           '',
    //           true,
    //           <String>[].build(),
    //           <String, int>{}.build(),
    //           <String>{}.build(),
    //           BuiltListMultimap<String, int>(<String, List<int>>{
    //             '@': [1, 2]
    //           }),
    //         ),
    //         Tuple8(
    //           1,
    //           3.0,
    //           '',
    //           true,
    //           <String>[].build(),
    //           <String, int>{}.build(),
    //           <String>{}.build(),
    //           BuiltListMultimap<String, int>(<String, List<int>>{
    //             '@': [1, 2]
    //           }),
    //         ),
    //         Tuple8(
    //           1,
    //           3.0,
    //           '4',
    //           true,
    //           <String>[].build(),
    //           <String, int>{}.build(),
    //           <String>{}.build(),
    //           BuiltListMultimap<String, int>(<String, List<int>>{
    //             '@': [1, 2]
    //           }),
    //         ),
    //         Tuple8(
    //           1,
    //           3.0,
    //           '4',
    //           false,
    //           <String>[].build(),
    //           <String, int>{}.build(),
    //           <String>{}.build(),
    //           BuiltListMultimap<String, int>(<String, List<int>>{
    //             '@': [1, 2]
    //           }),
    //         ),
    //         Tuple8(
    //           1,
    //           3.0,
    //           '4',
    //           false,
    //           <String>['7'].build(),
    //           <String, int>{}.build(),
    //           <String>{}.build(),
    //           BuiltListMultimap<String, int>(<String, List<int>>{
    //             '@': [1, 2]
    //           }),
    //         ),
    //         Tuple8(
    //           1,
    //           3.0,
    //           '4',
    //           false,
    //           <String>['7'].build(),
    //           <String, int>{'@': 8}.build(),
    //           <String>{}.build(),
    //           BuiltListMultimap<String, int>(<String, List<int>>{
    //             '@': [1, 2]
    //           }),
    //         ),
    //         Tuple8(
    //           1,
    //           3.0,
    //           '4',
    //           false,
    //           <String>['7'].build(),
    //           <String, int>{'@': 8}.build(),
    //           <String>{'10'}.build(),
    //           BuiltListMultimap<String, int>(<String, List<int>>{
    //             '@': [1, 2]
    //           }),
    //         ),
    //         Tuple8(
    //           1,
    //           3.0,
    //           '4',
    //           false,
    //           <String>['7'].build(),
    //           <String, int>{'@': 8}.build(),
    //           <String>{'10'}.build(),
    //           BuiltListMultimap<String, int>(<String, List<int>>{
    //             '@': [1, 2],
    //             '#': [11]
    //           }),
    //         ),
    //         emitsDone,
    //       ]),
    //     );
    //
    //     for (var i = 0; i <= 12; i++) {
    //       i.dispatchTo(store);
    //     }
    //     await pumpEventQueue(times: 100);
    //     await store.dispose();
    //     await future;
    //
    //     expect(projectCount, 8 + 1); // seed value + 8 items.
    //   });
    //
    //   test('~= select9', () async {
    //     final initial = Tuple10(
    //       0,
    //       1.0,
    //       '',
    //       true,
    //       <String>[].build(),
    //       <String, int>{}.build(),
    //       <String>{}.build(),
    //       BuiltListMultimap<String, int>.build((b) => b
    //         ..add('@', 1)
    //         ..add('@', 2)),
    //       BuiltSetMultimap<String, int>.build((b) => b
    //         ..add('@', 1)
    //         ..add('@', 2)),
    //       DateTime(1998, DateTime.october, 8),
    //     );
    //
    //     final store = RxReduxStore<
    //         int,
    //         Tuple10<
    //             int,
    //             double,
    //             String,
    //             bool,
    //             BuiltList<String>,
    //             BuiltMap<String, int>,
    //             BuiltSet<String>,
    //             BuiltListMultimap<String, int>,
    //             BuiltSetMultimap<String, int>,
    //             DateTime>>(
    //       initialState: initial,
    //       sideEffects: [],
    //       reducer: (s, a) {
    //         switch (a) {
    //           case 0:
    //             return s;
    //           case 1:
    //             return s.withItem1(s.item1 + a); // [item 1]
    //           case 2:
    //             return s.withItem2(s.item2 + a); // [item 2]
    //           case 3:
    //             return s.withItem10(
    //                 s.item10.add(const Duration(hours: 1))); // ------------
    //           case 4:
    //             return s.withItem3(s.item3 + a.toString()); // [item 3]
    //           case 5:
    //             return s.withItem4(!s.item4); // [item 4]
    //           case 6:
    //             return s.withItem10(
    //                 s.item10.add(const Duration(hours: 1))); // ------------
    //           case 7:
    //             return s.withItem5(
    //                 s.item5.rebuild((b) => b.add(a.toString()))); // [item 5]
    //           case 8:
    //             return s.withItem6(
    //                 s.item6.rebuild((b) => b['@'] = a)); // [item 6]
    //           case 9:
    //             return s.withItem10(
    //                 s.item10.add(const Duration(hours: 1))); // ------------
    //           case 10:
    //             return s.withItem7(
    //                 s.item7.rebuild((b) => b.add(a.toString()))); // [item 7]
    //           case 11:
    //             return s.withItem8(
    //                 s.item8.rebuild((b) => b.add('#', a))); // [item 8]
    //           case 12:
    //             return s.withItem9(
    //                 s.item9.rebuild((b) => b.add('#', a))); // [item 9]
    //           case 13:
    //             return s;
    //           default:
    //             throw a;
    //         }
    //       },
    //     );
    //
    //     var projectCount = 0;
    //
    //     final tuple$ = store.selectMany(
    //       [
    //         expectAsync1((state) => state.item1, count: 12 + 1),
    //         // 12 action causes state changed
    //         expectAsync1((state) => state.item2, count: 12 + 1),
    //         // 12 action causes state changed
    //         expectAsync1((state) => state.item3, count: 12 + 1),
    //         // 12 action causes state changed
    //         expectAsync1((state) => state.item4, count: 12 + 1),
    //         // 12 action causes state changed
    //         expectAsync1((state) => state.item5, count: 12 + 1),
    //         // 12 action causes state changed
    //         expectAsync1((state) => state.item6, count: 12 + 1),
    //         // 12 action causes state changed
    //         expectAsync1((state) => state.item7, count: 12 + 1),
    //         // 12 action causes state changed
    //         expectAsync1((state) => state.item8, count: 12 + 1),
    //         // 12 action causes state changed
    //         expectAsync1((state) => state.item9, count: 12 + 1),
    //         // 12 action causes state changed
    //       ],
    //       List.filled(9, null),
    //           (subStates) {
    //         ++projectCount;
    //
    //         return Tuple9(
    //           subStates[0] as int,
    //           subStates[1] as double,
    //           subStates[2] as String,
    //           subStates[3] as bool,
    //           subStates[4] as BuiltList<String>,
    //           subStates[5] as BuiltMap<String, int>,
    //           subStates[6] as BuiltSet<String>,
    //           subStates[7] as BuiltListMultimap<String, int>,
    //           subStates[8] as BuiltSetMultimap<String, int>,
    //         );
    //       },
    //     );
    //
    //     expect(
    //       tuple$.value,
    //       Tuple9(
    //         0,
    //         1.0,
    //         '',
    //         true,
    //         <String>[].build(),
    //         <String, int>{}.build(),
    //         <String>{}.build(),
    //         BuiltListMultimap<String, int>({
    //           '@': [1, 2]
    //         }),
    //         BuiltSetMultimap<String, int>({
    //           '@': {1, 2}
    //         }),
    //       ),
    //     );
    //     final future = expectLater(
    //       tuple$,
    //       emitsInOrder(<Object>[
    //         Tuple9(
    //           1,
    //           1.0,
    //           '',
    //           true,
    //           <String>[].build(),
    //           <String, int>{}.build(),
    //           <String>{}.build(),
    //           BuiltListMultimap<String, int>({
    //             '@': [1, 2]
    //           }),
    //           BuiltSetMultimap<String, int>({
    //             '@': {1, 2}
    //           }),
    //         ),
    //         Tuple9(
    //           1,
    //           3.0,
    //           '',
    //           true,
    //           <String>[].build(),
    //           <String, int>{}.build(),
    //           <String>{}.build(),
    //           BuiltListMultimap<String, int>({
    //             '@': [1, 2]
    //           }),
    //           BuiltSetMultimap<String, int>({
    //             '@': {1, 2}
    //           }),
    //         ),
    //         Tuple9(
    //           1,
    //           3.0,
    //           '4',
    //           true,
    //           <String>[].build(),
    //           <String, int>{}.build(),
    //           <String>{}.build(),
    //           BuiltListMultimap<String, int>({
    //             '@': [1, 2]
    //           }),
    //           BuiltSetMultimap<String, int>({
    //             '@': {1, 2}
    //           }),
    //         ),
    //         Tuple9(
    //           1,
    //           3.0,
    //           '4',
    //           false,
    //           <String>[].build(),
    //           <String, int>{}.build(),
    //           <String>{}.build(),
    //           BuiltListMultimap<String, int>({
    //             '@': [1, 2]
    //           }),
    //           BuiltSetMultimap<String, int>({
    //             '@': {1, 2}
    //           }),
    //         ),
    //         Tuple9(
    //           1,
    //           3.0,
    //           '4',
    //           false,
    //           <String>['7'].build(),
    //           <String, int>{}.build(),
    //           <String>{}.build(),
    //           BuiltListMultimap<String, int>({
    //             '@': [1, 2]
    //           }),
    //           BuiltSetMultimap<String, int>({
    //             '@': {1, 2}
    //           }),
    //         ),
    //         Tuple9(
    //           1,
    //           3.0,
    //           '4',
    //           false,
    //           <String>['7'].build(),
    //           <String, int>{'@': 8}.build(),
    //           <String>{}.build(),
    //           BuiltListMultimap<String, int>({
    //             '@': [1, 2]
    //           }),
    //           BuiltSetMultimap<String, int>({
    //             '@': {1, 2}
    //           }),
    //         ),
    //         Tuple9(
    //           1,
    //           3.0,
    //           '4',
    //           false,
    //           <String>['7'].build(),
    //           <String, int>{'@': 8}.build(),
    //           <String>{'10'}.build(),
    //           BuiltListMultimap<String, int>({
    //             '@': [1, 2]
    //           }),
    //           BuiltSetMultimap<String, int>({
    //             '@': {1, 2}
    //           }),
    //         ),
    //         Tuple9(
    //           1,
    //           3.0,
    //           '4',
    //           false,
    //           <String>['7'].build(),
    //           <String, int>{'@': 8}.build(),
    //           <String>{'10'}.build(),
    //           BuiltListMultimap<String, int>({
    //             '@': [1, 2],
    //             '#': [11]
    //           }),
    //           BuiltSetMultimap<String, int>({
    //             '@': {1, 2}
    //           }),
    //         ),
    //         Tuple9(
    //           1,
    //           3.0,
    //           '4',
    //           false,
    //           <String>['7'].build(),
    //           <String, int>{'@': 8}.build(),
    //           <String>{'10'}.build(),
    //           BuiltListMultimap<String, int>({
    //             '@': [1, 2],
    //             '#': [11]
    //           }),
    //           BuiltSetMultimap<String, int>({
    //             '@': {1, 2},
    //             '#': {12}
    //           }),
    //         ),
    //         emitsDone,
    //       ]),
    //     );
    //
    //     for (var i = 0; i <= 13; i++) {
    //       i.dispatchTo(store);
    //     }
    //     await pumpEventQueue(times: 100);
    //     await store.dispose();
    //     await future;
    //
    //     expect(projectCount, 9 + 1); // seed value + 9 items.
    //   });
    // });
  });
}
