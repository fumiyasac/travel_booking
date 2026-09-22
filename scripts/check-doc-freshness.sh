#!/bin/bash
# ドキュメント鮮度チェックスクリプト
# 「信頼できる情報源の件数」と「ドキュメントの記述件数」を比較し、
# 不一致があれば exit 1 する。
#
# 使用方法:
#   bash scripts/check-doc-freshness.sh         # ローカル実行
#   bash scripts/check-doc-freshness.sh --debug # デバッグ出力あり

set -euo pipefail

# リポジトリルート (travel_booking/) を基準ディレクトリとする
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

ERRORS=0
DEBUG=${1:-}

if [ "${DEBUG}" = "--debug" ]; then
  echo "📁 REPO_ROOT: ${REPO_ROOT}"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# チェック 1: スキル数（.claude/skills/ vs skill_guidance.md）
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SKILL_DIRS=$(find .claude/skills -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')

# skill_guidance.md のスキル一覧テーブルを識別するパターン:
# 各スキル行は「| ✓ |」または「| — |」で終わる（自動起動列）
SKILL_ROWS=$(grep -cE '\| [✓—] \|$' skill_guidance.md 2>/dev/null || echo 0)

if [ "${DEBUG}" = "--debug" ]; then
  echo "  [1] SKILL_DIRS=${SKILL_DIRS}, SKILL_ROWS=${SKILL_ROWS}"
fi

if [ "$SKILL_DIRS" != "$SKILL_ROWS" ]; then
  echo "❌ [チェック1] スキル数の不一致"
  echo "   .claude/skills/ ディレクトリ数       : ${SKILL_DIRS} 件"
  echo "   skill_guidance.md テーブル行数       : ${SKILL_ROWS} 件"
  ERRORS=$((ERRORS + 1))
else
  echo "✅ [チェック1] スキル数: ${SKILL_DIRS} 件"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# チェック 2: Screen ディレクトリ数
#   lib/presentation/screens/ のディレクトリ数 vs
#   README.md プロジェクト構成ツリーの screens/ コメント件数
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SCREEN_DIRS=$(find travel_booking_mobile/lib/presentation/screens \
  -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')

# README.md の「└── screens/ ... # aaa / bbb / ccc」行からスクリーン名を数える
# 例: "└── screens/                     # home / plan_detail / booking / favorites"
SCREEN_COMMENT_LINE=$(grep 'screens/.*# ' README.md 2>/dev/null | head -1 || echo "")
if [ -n "$SCREEN_COMMENT_LINE" ]; then
  README_SCREEN_COUNT=$(echo "$SCREEN_COMMENT_LINE" \
    | sed 's/.*#//' \
    | tr '/' '\n' \
    | tr -d ' ' \
    | grep -v '^$' \
    | wc -l \
    | tr -d ' ')
else
  README_SCREEN_COUNT=0
fi

if [ "${DEBUG}" = "--debug" ]; then
  echo "  [2] SCREEN_DIRS=${SCREEN_DIRS}, README_SCREEN_COUNT=${README_SCREEN_COUNT}"
fi

if [ "$SCREEN_DIRS" != "$README_SCREEN_COUNT" ]; then
  echo "❌ [チェック2] Screen ディレクトリ数の不一致"
  echo "   lib/presentation/screens/ ディレクトリ数 : ${SCREEN_DIRS} 件"
  echo "   README.md screens/ コメント件数          : ${README_SCREEN_COUNT} 件"
  ERRORS=$((ERRORS + 1))
else
  echo "✅ [チェック2] Screen ディレクトリ数: ${SCREEN_DIRS} 件"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# チェック 3: テストファイル数
#   test/viewmodels/ + test/widgets/ の *_test.dart vs
#   README.md テスト一覧テーブルの行数
#   ※ test/widget_test.dart（Flutter デフォルト）は対象外
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TEST_FILES=$(find travel_booking_mobile/test \
  -name '*_test.dart' \
  ! -name 'widget_test.dart' \
  2>/dev/null | wc -l | tr -d ' ')

# README.md のテスト一覧テーブル行を識別するパターン:
# 各行は「| `...._test.dart` | ...」形式
README_TEST_ROWS=$(grep -c '^| `.*_test\.dart' README.md 2>/dev/null || echo 0)

if [ "${DEBUG}" = "--debug" ]; then
  echo "  [3] TEST_FILES=${TEST_FILES}, README_TEST_ROWS=${README_TEST_ROWS}"
fi

if [ "$TEST_FILES" != "$README_TEST_ROWS" ]; then
  echo "❌ [チェック3] テストファイル数の不一致"
  echo "   test/ の *_test.dart ファイル数 (widget_test.dart 除外): ${TEST_FILES} 件"
  echo "   README.md テスト一覧テーブル行数                       : ${README_TEST_ROWS} 件"
  ERRORS=$((ERRORS + 1))
else
  echo "✅ [チェック3] テストファイル数: ${TEST_FILES} 件"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# チェック 4〜6: PR コンテキストでのみ実行（git diff ベース）
#   push on main の場合はチェック1〜3の件数比較のみ実施済み
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if [ "${GITHUB_EVENT_NAME:-}" = "pull_request" ]; then
  CHANGED_FILES=$(git diff origin/main...HEAD --name-only 2>/dev/null || echo "")

  if [ "${DEBUG}" = "--debug" ]; then
    echo "  [4-6] 変更ファイル一覧:"
    echo "$CHANGED_FILES" | sed 's/^/    /'
  fi

  # チェック 4: app_router.dart 変更 → README.md 変更チェック
  if echo "$CHANGED_FILES" | grep -q "app_router\.dart"; then
    if ! echo "$CHANGED_FILES" | grep -q "README\.md"; then
      echo "⚠️  [チェック4] app_router.dart が変更されましたが README.md が更新されていません"
      echo "   ルーティング図（README.md「### ルーティング」）の更新を検討してください"
      ERRORS=$((ERRORS + 1))
    else
      echo "✅ [チェック4] app_router.dart と README.md が同時更新されています"
    fi
  else
    echo "✅ [チェック4] app_router.dart の変更なし（スキップ）"
  fi

  # チェック 5: seed.ts 変更 → README.md 変更チェック
  if echo "$CHANGED_FILES" | grep -q "seed\.ts"; then
    if ! echo "$CHANGED_FILES" | grep -q "README\.md"; then
      echo "⚠️  [チェック5] seed.ts が変更されましたが README.md が更新されていません"
      echo "   シードデータ一覧（README.md「### シードデータ」）の更新を検討してください"
      ERRORS=$((ERRORS + 1))
    else
      echo "✅ [チェック5] seed.ts と README.md が同時更新されています"
    fi
  else
    echo "✅ [チェック5] seed.ts の変更なし（スキップ）"
  fi

  # チェック 6: .claude/skills/ 変更 → skill_guidance.md 変更チェック
  if echo "$CHANGED_FILES" | grep -q "\.claude/skills/"; then
    if ! echo "$CHANGED_FILES" | grep -q "skill_guidance\.md"; then
      echo "⚠️  [チェック6] .claude/skills/ が変更されましたが skill_guidance.md が更新されていません"
      echo "   スキル一覧テーブル（skill_guidance.md）の更新を検討してください"
      ERRORS=$((ERRORS + 1))
    else
      echo "✅ [チェック6] .claude/skills/ と skill_guidance.md が同時更新されています"
    fi
  else
    echo "✅ [チェック6] .claude/skills/ の変更なし（スキップ）"
  fi

else
  echo "ℹ️  [チェック4〜6] PR コンテキスト外のためスキップ（件数チェック 1〜3 のみ実施済み）"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 最終結果
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo ""
if [ "$ERRORS" -gt 0 ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "❌ ${ERRORS} 件のドキュメント更新漏れが検出されました"
  echo ""
  echo "💡 /doc-sync を実行してドキュメントを同期してください"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ ドキュメントは最新です"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
