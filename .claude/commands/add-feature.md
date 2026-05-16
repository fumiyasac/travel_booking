機能名: $ARGUMENTS

このプロジェクトの MVVM + Repository パターンに従って、上記の機能名で新しい機能をスキャフォールドしてください。

作成するファイル（機能名を snake_case に変換して使用）:

**データ層** (`travel_booking_mobile/lib/data/`):
1. `models/{feature_name}.dart` — データモデルクラス（`fromJson` / `toJson` メソッド付き）
2. `datasources/remote/{feature_name}_remote_datasource.dart` — GraphQL クエリ/ミューテーション（既存の `TravelPlanRemoteDataSource` を参考に）
3. `repositories/{feature_name}_repository.dart` — Repository 抽象インターフェース
4. `repositories/{feature_name}_repository_impl.dart` — Repository 実装クラス

**プレゼンテーション層** (`travel_booking_mobile/lib/presentation/`):
5. `viewmodels/{feature_name}_viewmodel.dart` — `@riverpod` アノテーション付き `AsyncNotifier`
6. `screens/{feature_name}/{feature_name}_screen.dart` — 画面ウィジェット（ConsumerWidget、ローディング/エラー/データ状態を含む）

作成後の手順:
- `app_router.dart` への新ルート追加方法を案内する
- `melos run build_runner` を実行して `.g.dart` ファイルを生成する
- 各ファイルに TODO コメントで GraphQL クエリ追加箇所を明示する

既存ファイルのスタイル参考:
- ViewModel: `plan_list_viewmodel.dart`
- Screen: `home_screen.dart`
- Repository: `travel_plan_repository.dart`
