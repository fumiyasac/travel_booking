ViewModel名: $ARGUMENTS

指定された ViewModel のユニットテストをこのプロジェクトの既存パターンに従って追加・拡充してください。

## 調査と準備

1. `travel_booking_mobile/lib/presentation/viewmodels/$ARGUMENTS_viewmodel.dart` を読み込む
2. `travel_booking_mobile/test/viewmodels/$ARGUMENTS_viewmodel_test.dart` の存在を確認する
   - **存在する場合**: 現在のテストを読み込み、未テストのパブリックメソッドやエッジケースを特定して追加する
   - **存在しない場合**: 以下のパターンで新規作成する

## テストファイルの構成（`plan_list_viewmodel_test.dart` に準拠）

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
// 必要な import を追加

import 'xxxxx_viewmodel_test.mocks.dart';

@GenerateMocks([XxxxxRepository])  // 依存する Repository インターフェースを列挙
void main() {
  late MockXxxxxRepository mockRepository;
  late ProviderContainer container;

  // テストデータは日本語の現実的な値を使う

  setUp(() {
    mockRepository = MockXxxxxRepository();
    container = ProviderContainer(
      overrides: [
        xxxxxRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('XxxxxViewModel', () {
    // テストケース
  });
}
```

## カバーすべきテストケース

- **初期状態**: 各フィールドのデフォルト値が正しいか
- **成功パス**: データ取得後に state が正しく更新されるか
- **失敗パス**: 例外発生時に `error` がセットされ `isLoading: false` になるか
- **入力更新**: `updateXxx()` メソッドが state を正しく更新するか
- **エッジケース**: 空リスト、null 値、ページネーション境界値、二重送信防止など
- **リセット**: `reset()` や `clearError()` が正しく動作するか

## 実装後の手順

モッククラス（`.mocks.dart`）を再生成する:
```bash
melos run build_runner
```

その後 `melos run test` でテストが通ることを確認する。
