# GraphQL エンドポイント プラットフォーム別設定ガイド

## 環境別の推奨設定

### iOS シミュレーター
```
http://localhost:4000/graphql
```
シミュレーターはホストマシンのネットワークを共有するため `localhost` が直接使える。

### Android エミュレーター
```
http://10.0.2.2:4000/graphql
```
Android エミュレーターでは `10.0.2.2` がホストマシンのループバックアドレスに対応する。
`localhost` は使えないため注意。

### 実機（LAN 接続）
```
http://<ホストPCのIPアドレス>:4000/graphql
```
端末とホストPCが同じ Wi-Fi ネットワークに接続している必要がある。

**ホストPCのIPアドレス確認コマンド:**
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
# または
ipconfig getifaddr en0
```

---

## `--dart-define` を使った環境変数化（推奨）

### 1. `graphql_config.dart` の変更

```dart
GraphQLHttpClient({
  String baseUrl = const String.fromEnvironment(
    'GRAPHQL_URL',
    defaultValue: 'http://localhost:4000/graphql',
  ),
  http.Client? client,
}) : _baseUrl = baseUrl,
     _httpClient = client;
```

### 2. 実行時の指定方法

```bash
# iOS シミュレーター（デフォルト値を使うためオプション不要）
flutter run

# Android エミュレーター
flutter run --dart-define=GRAPHQL_URL=http://10.0.2.2:4000/graphql

# 実機
flutter run --dart-define=GRAPHQL_URL=http://192.168.1.50:4000/graphql
```

### 3. IDE での設定

**VS Code** (`launch.json`):
```json
{
  "configurations": [
    {
      "name": "Flutter (Simulator)",
      "type": "dart",
      "request": "launch"
    },
    {
      "name": "Flutter (Device)",
      "type": "dart",
      "request": "launch",
      "toolArgs": ["--dart-define=GRAPHQL_URL=http://192.168.1.50:4000/graphql"]
    }
  ]
}
```

**IntelliJ/Android Studio** の Run Configuration で `Additional run args` に指定する。

---

## iOS ATS（App Transport Security）設定

`http://` のエンドポイントを使う場合、iOS は ATS によりブロックされる。

`ios/Runner/Info.plist` に以下を追加する：

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
```

> **注意**: `NSAllowsArbitraryLoads` は開発環境のみ有効とし、本番リリース時は `NSExceptionDomains` で特定ホストのみ許可する。
