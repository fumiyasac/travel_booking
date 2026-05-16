対象ファイル: `travel_booking_mobile/lib/core/config/graphql_config.dart`

GraphQL エンドポイント設定を確認・変更します。引数: $ARGUMENTS

---

## 引数が指定されている場合（新しい IP アドレスまたはホスト名）

1. 現在の `_baseUrl` の値を確認する
2. 指定されたアドレスに変更する（ポート `4000/graphql` を維持）
   - 例: `192.168.1.50` → `http://192.168.1.50:4000/graphql`
   - 例: `localhost` → `http://localhost:4000/graphql`
3. 変更後の URL を表示して確認を求める

---

## 引数が空の場合

現在の `_baseUrl` の値を表示し、以下の選択肢を提案する:

### 環境別の推奨設定

| 実行環境 | 設定値 |
|---|---|
| iOS シミュレーター | `http://localhost:4000/graphql` |
| Android エミュレーター | `http://10.0.2.2:4000/graphql` |
| 実機（LAN） | `http://<ホストPCのIP>:4000/graphql` |

ホストPCのIPアドレス確認方法:
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

### flutter --dart-define を使う方法（推奨）

`graphql_config.dart` を以下のように変更することで環境ごとに切り替えが可能になる:
```dart
GraphQLHttpClient({
  String baseUrl = const String.fromEnvironment(
    'GRAPHQL_URL',
    defaultValue: 'http://localhost:4000/graphql',
  ),
  ...
})
```
実行時: `flutter run --dart-define=GRAPHQL_URL=http://192.168.x.x:4000/graphql`

### iOS 実機で http:// を使う場合の追加設定

`ios/Runner/Info.plist` に以下を追加する必要があることを案内する:
```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
```

ユーザーの希望する方法を確認してから変更を実施する。
