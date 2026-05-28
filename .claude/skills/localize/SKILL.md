---
name: localize
description: Add, update, or sync a localized string across all 41 language .lproj/Main.strings files in this iOS project. Use when adding a new NSLocalizedString key, changing user-facing text, or checking which languages are missing a key.
argument-hint: [key] [説明]
user-invocable: true
allowed-tools:
  - "Bash(python3 .claude/skills/localize/sync_strings.py:*)"
  - "Read"
  - "Edit"
  - "Write"
  - "Glob"
  - "Grep"
---

# localize スキル

このプロジェクトのユーザー向け文言は、**41 言語** の `NFC-Tools/<lang>.lproj/Main.strings`
（UTF-8、`Base.lproj` を除く）に格納される。コードの文言も Storyboard の文言も、すべて
この `Main.strings`（`tableName: "Main"`）に入る。専用の `Localizable.strings` は存在しない。

文言を 1 つ足す/直すと **41 言語全部** に反映が要る。手作業はキー漏れ・順序ずれ・
エスケープ崩れを起こすので、必ずこのスキルの手順とヘルパースクリプトを使う。

## ヘルパースクリプト

`python3 .claude/skills/localize/sync_strings.py <command>`（リポジトリルートで実行）

- `check <key>` — そのキーを持っていない `.lproj` を一覧表示
- `get <key>` — 全言語の現在値を表示（差分確認用）
- `set <key> --json <file>` — JSON マップ `{ "ja": "値", "en-GB": "値", ... }` から
  各言語の `Main.strings` にキーを追記/更新（既存なら上書き、無ければ追記）
- `langs` — 対象言語コードを一覧表示（JSON を作るとき用）

スクリプトは値を自動で正しくエスケープし、`"key" = "value";` 形式で書く。

## 手順

### A. 新しい文言を追加する

1. まずコード側で `NSLocalizedString("new_key", tableName: "Main", comment: "日本語の意味")`
   を使っていることを確認（無ければ実装する）。
2. `python3 .claude/skills/localize/sync_strings.py langs` で対象言語コードを確認。
3. **全 41 言語ぶんの翻訳を生成する。** 日本語の原文と comment を元に、各言語コードへ
   自然な訳を当てる（地域差も考慮: `pt-BR` vs `pt-PT`、`zh-Hans` vs `zh-Hant` vs `zh-HK`、
   `es` / `es-419` / `es-US` など）。アプリ UI に収まる簡潔さを優先。
4. 訳を JSON ファイルにまとめる（例 `/tmp/new_key.json`）:
   ```json
   { "ja": "...", "en-GB": "...", "de": "...", "...": "..." }
   ```
   JSON のキーは `sync_strings.py langs` が出す言語コードに厳密に一致させる。
5. 反映: `python3 .claude/skills/localize/sync_strings.py set new_key --json /tmp/new_key.json`
6. 抜けが無いか確認: `python3 .claude/skills/localize/sync_strings.py check new_key`
   （何も出なければ全言語に存在＝OK）。

### B. 既存の文言を直す

1. `python3 .claude/skills/localize/sync_strings.py get <key>` で現状を確認。
2. 変更後の値を全 41 言語ぶん用意して JSON 化（A-3〜4 と同じ）。
3. `set <key> --json ...` で上書き → `get` で確認。

### C. キーの抜けを調べる/埋める

1. `python3 .claude/skills/localize/sync_strings.py check <key>` で欠けている言語を特定。
2. 欠けている言語ぶんだけ訳を作り、JSON にして `set` で反映。

## ルール

- **ObjectID キー**（例 `7qV-0H-MQh.normalTitle`）は Storyboard が生成する。手で訳語だけ
  直すのは可だが、新規追加・削除は Storyboard / `ibtool` 側の都合があるので避ける。
  このスキルが扱うのは主にコード由来の手動キー（`loading`, `nfc_*`, `result_*` など）。
- 値内のダブルクォートは `\"` にエスケープ（スクリプトが自動処理）。
- 言語コードを推測で増やさない。`langs` が出す 41 個に対してのみ書く。
- 翻訳は機械的な逐語訳でなく、UI として自然で短い表現にする。意味が不確かな言語は
  ユーザーに確認するか、英語ベース訳を当ててコメントで明記する。
