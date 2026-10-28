// ===== VIEW STATE TEST - PENGUJIAN STATUS STATE =====

import 'package:flutter_test/flutter_test.dart';
import 'package:campus_lost_found/utils/view_state.dart';

void main() {
  group('ViewState Enum Tests', () {
    test(
      'ViewState memuat 4 status wajib UTS (loading, loaded, error, empty)',
      () {
        expect(ViewState.values.contains(ViewState.loading), isTrue);
        expect(ViewState.values.contains(ViewState.loaded), isTrue);
        expect(ViewState.values.contains(ViewState.error), isTrue);
        expect(ViewState.values.contains(ViewState.empty), isTrue);
      },
    );

    test('ViewState memiliki representasi nama yang tepat', () {
      expect(ViewState.loading.name, 'loading');
      expect(ViewState.loaded.name, 'loaded');
      expect(ViewState.error.name, 'error');
      expect(ViewState.empty.name, 'empty');
    });
  });
}
