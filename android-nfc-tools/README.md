# NFC Tools - Android版

NFCタグの読み取り、書き込み、削除が簡単にできるAndroidアプリです。

## 機能

### 🔍 読み取り機能
- NFCタグの内容を読み取り
- テキストとURL情報の表示
- 読み取り結果をダイアログで確認

### ✏️ 書き込み機能
- テキストやURLをNFCタグに書き込み
- 複数フォーマットに対応
- 容量チェック機能

### 🗑️ 削除機能
- NFCタグの情報を安全に削除
- 削除前の確認ダイアログ
- 現在の内容表示

### 🌐 多言語対応
以下の言語に対応：
- 日本語
- 英語
- 中国語（簡体字・繁体字）
- 韓国語
- アラビア語
- フランス語
- ドイツ語
- スペイン語
- ポルトガル語（ブラジル）
- ロシア語
- イタリア語
- その他多数

### 📱 その他の機能
- チュートリアル機能
- Google AdMob広告統合
- 広告削除オプション

## 技術仕様

### 開発環境
- **言語**: Kotlin
- **最小SDK**: API 21 (Android 5.0)
- **対象SDK**: API 34 (Android 14)
- **アーキテクチャ**: MVVM
- **UI**: Material Design 3

### 使用ライブラリ
- **AndroidX**: Core KTX, AppCompat, Material Design
- **NFC**: Android NFC API
- **広告**: Google AdMob
- **UI**: ViewPager2, ConstraintLayout

### 必要な権限
```xml
<uses-permission android:name="android.permission.NFC" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### 必要なハードウェア
```xml
<uses-feature
    android:name="android.hardware.nfc"
    android:required="true" />
```

## セットアップ手順

### 1. プロジェクトのクローン
```bash
git clone [repository-url]
cd android-nfc-tools
```

### 2. Android Studioでプロジェクトを開く
1. Android Studioを起動
2. "Open an existing Android Studio project"を選択
3. プロジェクトディレクトリを選択

### 3. Google AdMob設定
1. [Firebase Console](https://console.firebase.google.com/)でプロジェクトを作成
2. AdMobを有効化
3. 広告ユニットIDを取得
4. `google-services.json`ファイルを`app/`ディレクトリに配置

### 4. ビルドと実行
```bash
./gradlew assembleDebug
```

## プロジェクト構造

```
app/
├── src/main/
│   ├── java/com/nfctools/
│   │   ├── MainActivity.kt          # メインアクティビティ
│   │   ├── TutorialActivity.kt      # チュートリアル
│   │   ├── NFCUtils.kt             # NFC操作ユーティリティ
│   │   └── LocalizationManager.kt  # 多言語化管理
│   ├── res/
│   │   ├── layout/                 # レイアウトファイル
│   │   ├── values/                 # 文字列リソース
│   │   ├── drawable/               # 画像リソース
│   │   └── xml/                    # 設定ファイル
│   └── AndroidManifest.xml
└── build.gradle
```

## 使用方法

### NFCタグの読み取り
1. アプリを起動
2. "Read"ボタンをタップ
3. NFCタグをスマートフォンの背面に近づける
4. 読み取り結果がダイアログに表示される

### NFCタグの削除
1. "Delete"ボタンをタップ
2. NFCタグをスマートフォンの背面に近づける
3. 確認ダイアログで"削除"をタップ
4. 削除完了メッセージが表示される

## トラブルシューティング

### NFCが動作しない場合
1. デバイスのNFC機能が有効になっているか確認
2. アプリにNFC権限が付与されているか確認
3. NFCタグが対応フォーマットかどうか確認

### ビルドエラーが発生する場合
1. Android Studio とGradleが最新版か確認
2. `google-services.json`が正しく配置されているか確認
3. 必要な依存関係がすべてインストールされているか確認

## リリース手順

### デバッグビルド
```bash
./gradlew assembleDebug
```

### リリースビルド
1. キーストアファイルを作成
2. `app/build.gradle`の署名設定を更新
3. リリースビルドを実行
```bash
./gradlew assembleRelease
```

## 貢献

バグ報告や機能追加の提案は、GitHubのIssuesまでお願いします。

## ライセンス

このプロジェクトは[ライセンス名]の下で公開されています。

## 著者

[あなたの名前]

## 更新履歴

### v3.0.0
- Android版初回リリース
- NFC読み取り・削除機能実装
- 多言語対応
- チュートリアル機能追加
- AdMob広告統合