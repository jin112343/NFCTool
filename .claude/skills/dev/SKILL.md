---
name: dev
description: End-to-end development workflow for the NFC-Tools iOS app — investigate, plan, implement & fix, then test (code/compile tests only). Use when asked to add a feature, fix a bug, or make a non-trivial change to the app.
argument-hint: <やりたいこと / バグ内容>
user-invocable: true
---

# dev ワークフロー

NFC-Tools（Swift + UIKit、CocoaPods、41 言語ローカライズ）の開発を
**調査 → 計画 → 実装と修正 → テスト** の 4 フェーズで進める。
このプロジェクトの既存資産を束ねて使う:

- `/ios-build` スキル — ビルド/コンパイル検証
- `/localize` スキル — 文言を 41 言語へ一括反映
- `swift-reviewer` エージェント — 差分の静的レビュー

各フェーズの終わりに**短く状況を報告**し、計画は承認を得てから実装に進む。

---

## フェーズ 1：調査

目的：何を変えるか・どこに影響するかを、コードの実態に基づいて把握する。

1. `CLAUDE.md` の前提（ビルド方法・アーキテクチャ・ローカライズの罠）を踏まえる。
2. 要求を分解し、不明点があれば**ここでユーザーに確認**する（推測で進めない）。
3. 関連コードを調べる。広く探す必要があれば **Explore エージェント**に投げ、
   結論だけ受け取る。最低限、次を特定する:
   - 影響する ViewController / マネージャ（`ViewController*.swift`, `*Manager.swift` など）
   - **ユーザー向け文言**の有無（`NSLocalizedString(_, tableName: "Main", _)`）→ 41 言語反映が要るか
   - **NFC / 課金（SwiftyStoreKit）/ Firebase / 広告**に触れるか（スレッド・コールバック注意）
   - 永続化（`SafeUserDefaults` / `KeychainHelper` / `NFCHistoryManager`）への影響
4. 既存パターンと再利用できる箇所を洗い出す。

**出力**：影響ファイル一覧、ローカライズ要否、リスク、既存パターンの要約。

---

## フェーズ 2：計画

目的：実装前に具体的な手順へ落とし、承認を得る。

1. 変更内容を**ファイル単位の手順**にする（追加/修正する関数・新キー・新規ファイルなど）。
2. 必要な新規ローカライズキー（`new_key` と日本語原文・comment）を列挙する。
3. リスクと検証方法（後述のテスト範囲）を明記する。
4. **プランモード（`EnterPlanMode`）で計画を提示し、ユーザー承認を得てから実装に進む。**
   小さく自明な修正なら一言断って進めてよい。

**出力**：承認済みの実装計画。

---

## フェーズ 3：実装と修正

目的：計画どおりに実装する。プロジェクト規約を守る。

1. 既存コードのスタイル・命名・構成に合わせて編集する（UIKit/Storyboard 前提）。
2. 規約を守る:
   - **UI 更新は必ずメインスレッド**（NFC/課金/Firestore のコールバックは別スレッド）。
   - クロージャ・デリゲート・通知・タイマーの**循環参照**に注意（`[weak self]`）。
   - 強制アンラップ `!` / `as!` / `try!` を避ける。
3. **ユーザー向け文言を足した/変えたら `/localize` で 41 言語へ反映**する（手作業しない）。
4. 実装中に判明した不足は計画へ反映しつつ修正する。

**出力**：変更差分（必要なら全 41 言語の `Main.strings` 更新含む）。

---

## フェーズ 4：テスト（コードテストのみ）

目的：**コンパイルが通り、静的に問題が無いこと**を確認する。
このプロジェクトには XCTest ターゲットが無く、NFC は実機必須のため、
**実機/シミュレータでの実行・手動テストは行わない**。コードレベルの確認で止める。
（ユーザーが明示的に実機/シミュレータ確認を依頼した場合のみ `/ios-build` の起動手順を案内する。）

1. **ビルド検証**：`/ios-build` の手順で
   `xcodebuild -workspace NFC-Tools.xcworkspace -scheme NFC-Tools ... build` を実行。
   `** BUILD SUCCEEDED **` を確認。`error:` が出たら原因を直して再ビルド（成功するまで）。
2. **静的レビュー**：`swift-reviewer` エージェントに差分をレビューさせる。
   🔴 致命・🟡 要確認の指摘は対応し、再ビルドする。
3. **ローカライズ検証**：新キーがあれば
   `python3 .claude/skills/localize/sync_strings.py check <key>` で 41 言語の抜けが無いか確認。

**出力**：ビルド結果、レビュー所見と対応、ローカライズ確認結果。

---

## 完了報告

- 何を変えたか（ファイル/差分の要約）
- ビルド結果（成功 / 残課題）
- レビュー所見と対応
- ローカライズ反映状況
- 未検証事項（実機での NFC 動作など、コードテストの範囲外）を明示

コミット/PR は**ユーザーが明示的に依頼したときだけ**行う。
