---
name: fix-endpoint
description: |
  GraphQL エンドポイント（graphql_config.dart の _baseUrl）を確認・変更する。
  実行環境の切り替え（iOS シミュレーター/Android エミュレーター/実機）や
  PC の IP アドレス変更時に使用する。
  「エンドポイントを変更して」「IP を変えて」「接続先を localhost にして」
  「実機でテストしたい」「SocketException が出る」などのリクエストで使用する。
  設定ファイルを変更するため手動実行専用。
argument-hint: "新しいIPアドレスまたはホスト名 (例: 192.168.1.50, localhost)"
disable-model-invocation: true
allowed-tools:
  - Read
  - Edit
  - Bash
metadata:
  version: "1.0.0"
---

# fix-endpoint — GraphQL エンドポイント設定

`travel_booking_mobile/lib/core/config/graphql_config.dart` の `_baseUrl` を確認・変更します。

詳細な環境別設定: `references/platform-guide.md` を参照。

## 実行手順

### 1. 現在の設定確認

```
Read: travel_booking_mobile/lib/core/config/graphql_config.dart
```

現在の `_baseUrl` の値をユーザーに表示する。

### 2a. 引数が指定されている場合（直接変更）

`$ARGUMENTS` に IP アドレスまたはホスト名が指定されている場合：

1. 指定されたアドレスで URL を組み立てる（例: `192.168.1.50` → `http://192.168.1.50:4000/graphql`）
2. `graphql_config.dart` の `_baseUrl` デフォルト値を変更する
3. 変更後の URL をユーザーに確認してもらう

### 2b. 引数なしの場合（対話的に設定）

環境別の推奨設定を提示して選択を求める（`references/platform-guide.md` を参照）：

| 環境 | 推奨値 |
|---|---|
| iOS シミュレーター | `http://localhost:4000/graphql` |
| Android エミュレーター | `http://10.0.2.2:4000/graphql` |
| 実機（LAN） | `http://<ホストPCのIP>:4000/graphql` |

ホストPC の IP 確認コマンドも案内する：
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

### 3. `--dart-define` への移行提案

現在の実装がハードコードの場合、`--dart-define` による環境変数化を提案する（詳細は `references/platform-guide.md`）。

### 4. iOS ATS 設定の確認

`http://` を使う場合、`ios/Runner/Info.plist` の ATS 設定が必要かを確認して案内する。
