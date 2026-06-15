# GoRoute テンプレート集

`app_router.dart` の既存コードスタイルに合わせたテンプレート。
編集前に必ず `app_router.dart` を Read してから使用すること。

---

## 1. 通常 GoRoute（パラメータなし）

親ルートの `routes: [...]` に追加するか、`StatefulShellRoute` 外側の `routes` に追加する。

```dart
GoRoute(
  path: '/your-path',
  name: 'your-path-name',     // kebab-case で命名
  builder: (context, state) => const YourScreen(),
),
```

**使用例**: `/favorites`、`/booking-history` など固定パスの画面

---

## 2. パラメータ付き GoRoute（pathParameters 取得コード込み）

パス内に `:paramName` が含まれる場合は `state.pathParameters` で取得する。

```dart
GoRoute(
  path: 'your-path/:paramName',
  name: 'your-path-name',
  builder: (context, state) {
    final paramName = state.pathParameters['paramName']!;
    return YourScreen(paramName: paramName);
  },
),
```

**使用例**: `plan/:id`、`review/:planId` など動的セグメントを含む画面

### extra データを併用する場合

`context.go('/path', extra: {'key': value})` で渡したデータを受け取る:

```dart
GoRoute(
  path: '/your-path/:paramName',
  name: 'your-path-name',
  builder: (context, state) {
    final paramName = state.pathParameters['paramName']!;
    final extra = state.extra as Map<String, dynamic>?;
    return YourScreen(
      paramName: paramName,
      optionalData: extra?['optionalData'] as String? ?? '',
    );
  },
),
```

**使用例**: 既存の `booking-confirmation` ルート（`bookingId` + extra データ）を参照

---

## 3. StatefulShellBranch タブテンプレート

`StatefulShellRoute.indexedStack` の `branches` リスト末尾に追加する。
**branch の index は Read で確認した既存数から採番する（ハードコード禁止）**。

```dart
StatefulShellBranch(
  routes: [
    GoRoute(
      path: '/your-tab-path',
      name: 'your-tab-name',
      builder: (context, state) => const YourTabScreen(),
      routes: [
        // タブ内のネストルートが必要な場合はここに追加
        // 例: favorites ブランチの favorites-plan-detail のような子ルート
      ],
    ),
  ],
),
```

**使用例**: ホーム（`/`）・お気に入り（`/favorites`）と同列に並ぶ新しいタブ

---

## 4. BottomNavigationBarItem 追加テンプレート

`_ScaffoldWithBottomNav` の `BottomNavigationBar.items` リスト末尾に追加する。
**`StatefulShellBranch` の追加と必ずセットで行うこと**（index のズレを防ぐため）。

```dart
BottomNavigationBarItem(
  icon: Icon(Icons.your_icon_outlined),    // 非選択時: outlined 系アイコン
  activeIcon: Icon(Icons.your_icon),       // 選択時: 塗りつぶし系アイコン
  label: 'タブ名',                          // 日本語ラベル推奨
),
```

### アイコン選択ガイド

| 機能 | 非選択（outlined） | 選択（塗りつぶし） |
|------|-------------------|------------------|
| 予約履歴 | `Icons.receipt_long_outlined` | `Icons.receipt_long` |
| 検索 | `Icons.search_outlined` | `Icons.search` |
| プロフィール | `Icons.person_outline` | `Icons.person` |
| 通知 | `Icons.notifications_outlined` | `Icons.notifications` |
| マップ | `Icons.map_outlined` | `Icons.map` |
| カレンダー | `Icons.calendar_today_outlined` | `Icons.calendar_today` |

**既存タブの参考**:
- ホーム: `Icons.explore_outlined` / `Icons.explore`
- お気に入り: `Icons.favorite_outline` / `Icons.favorite`

---

## 既存ルート構造（2026-06 時点）

```
StatefulShellRoute.indexedStack
├── branch[0]: StatefulShellBranch
│   └── GoRoute(path: '/', name: 'home')
│       └── GoRoute(path: 'plan/:id', name: 'plan-detail')
│           └── GoRoute(path: 'booking', name: 'booking')
└── branch[1]: StatefulShellBranch
    └── GoRoute(path: '/favorites', name: 'favorites')
        └── GoRoute(path: 'plan/:id', name: 'favorites-plan-detail')

GoRoute(path: '/booking/confirmation/:bookingId', name: 'booking-confirmation')  ← ShellRoute 外
```

新しいタブを追加する場合は `branch[2]` から始める。
ShellRoute 外のルートはグローバルに遷移するダイアログ・確認画面に適している。
