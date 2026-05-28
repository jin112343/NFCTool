---
name: ios-build
description: Build the NFC-Tools iOS app and run it on a simulator with the correct xcodebuild arguments. Use when asked to build, compile, run, or launch the app, or to verify a Swift change compiles.
user-invocable: true
allowed-tools:
  - "Bash(xcodebuild:*)"
  - "Bash(xcrun:*)"
  - "Bash(pod:*)"
  - "Bash(open:*)"
  - "Read"
  - "Grep"
---

# ios-build スキル

このプロジェクトは **CocoaPods ワークスペース**。`.xcodeproj` を直接ビルドすると Pods が
リンクされず失敗する。**必ず `-workspace NFC-Tools.xcworkspace` を使う。**

- ワークスペース: `NFC-Tools.xcworkspace`
- スキーム / ターゲット: `NFC-Tools`
- 最小 OS: iOS 15.0 / 言語: Swift 5
- 自動テストターゲットは無い。検証は「ビルド成功」＋必要なら「シミュレータ起動」で行う。

## ビルド（コンパイル確認）

リポジトリルートで:

```bash
xcodebuild -workspace NFC-Tools.xcworkspace -scheme NFC-Tools \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -configuration Debug build
```

- `name=...` は同名/複数OSで曖昧になり `Unable to find a device matching the provided destination specifier`
  で失敗することがある。その場合は**デバイス id 指定が確実**:
  ```bash
  xcodebuild -workspace NFC-Tools.xcworkspace -scheme NFC-Tools -showdestinations 2>&1 \
    | grep -i "Simulator.*iPhone"      # 使える id を確認
  xcodebuild -workspace NFC-Tools.xcworkspace -scheme NFC-Tools \
    -destination 'id=<SIMULATOR-UDID>' -configuration Debug build
  ```
- 成功なら最後に `** BUILD SUCCEEDED **`。
- ログが長いので、出力末尾の `error:` / `warning:` を抜き出して要約する
  （`... | grep -E "error:|warning:|BUILD (SUCCEEDED|FAILED)"` などで絞る）。
- ビルドが長い時は**バックグラウンド実行**にしてログを追う。

## シミュレータで起動

NFC の読み書きはシミュレータでは動かない（UI/レイアウト/課金フロー確認用と割り切る）。

1. シミュレータ起動: `xcrun simctl boot 'iPhone 16 Pro'`（または `open -a Simulator`）
2. ビルド（上記）。生成 `.app` のパスは
   `xcodebuild -showBuildSettings ... | grep TARGET_BUILD_DIR` で確認できる。
3. インストール＆起動:
   ```bash
   xcrun simctl install booted "<TARGET_BUILD_DIR>/NFC-Tools.app"
   xcrun simctl launch booted <bundle-id>
   ```
   bundle-id は `NFC-Tools/Info.plist` の `CFBundleIdentifier`、または
   `xcodebuild -showBuildSettings | grep PRODUCT_BUNDLE_IDENTIFIER` で確認。

利用可能なシミュレータ一覧: `xcrun simctl list devices available | grep iPhone`

## 依存（Pods）が壊れた / 更新したとき

```bash
pod install        # Podfile に追従（通常はこれ）
```

`error: Sandbox: ... Pods-NFC-Tools` 系や「scheme が見つからない」場合は `pod install`
を実行してから再ビルド。`pod repo update` は重いので、必要と判断したときだけ。

## つまずきポイント

- `-project` ではなく `-workspace` を使う（Pods のため）。
- スキームが共有されていない場合 `-list` に出ないことがある。その時は Xcode で
  Scheme > Manage Schemes > "Shared" にチェック、または上記コマンドはスキーム名
  `NFC-Tools` 直指定で通る。
- コード署名はシミュレータ向けには不要。実機ビルドを頼まれたら署名チームの確認が要るので
  ユーザーに確認する。
- `GoogleService-Info.plist` が無いと Firebase 初期化でクラッシュする（コミット済みのはず）。
