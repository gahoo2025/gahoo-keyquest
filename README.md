# gahoo-keyquest

鍵を集めて進む横スクロール探索アクションRPG（個人開発、ザナドゥ風・旧称gahoo-xanadu）。

このリポジトリは [gahoo-company](https://github.com/gahoo2025/gahoo-company) の秘書室・`gamedev/`部署が担当するプロジェクト（第2弾）です。企画・仕様検討・作業ログは `gahoo-company/gamedev/` 側に記録されます。実際のコード変更はこちら（`gahoo-keyquest`）で行います。

## 技術スタック

- **ゲーム本体**：[Godot](https://godotengine.org/)（Godot 4系、`gahoo-shooter`と同じ構成）
- **配布**：Web先行公開（Godotの HTML5 書き出し）。将来的なモバイル展開は追って検討

バックエンド（サーバー・DB）は現時点では未使用です。将来スコア保存・ランキング等が必要になった際に、`gahoo-shooter`と同様の構成（Node.js/Express + PostgreSQL）を追加することを想定しています。

## ディレクトリ構成

```
gahoo-keyquest/
└── game/     # Godotプロジェクト（ゲーム本体）
```

## 現在の状況（2026-09-21時点）

初期スキャフォールドのみの状態です（起動すると「gahoo-keyquest — 開発中」と表示されるだけの空プロジェクト）。詳細仕様は `gahoo-company/gamedev/gahoo-keyquest-spec.md` にドラフトがありますが、改修計画（実装計画第1弾）はこれから策定します。進め方は `gahoo-company/CLAUDE.md`「アプリ開発の基本動作」（①仕様の策定 → ②改修計画の策定 → ③改修の実施）に従います。

## セットアップ（ゲーム本体）

1. [Godot](https://godotengine.org/download) をインストール（4.7以降推奨）
2. Godotエディタで `game/project.godot` を開く
3. `scenes/main.tscn` を実行（F6）するとプレースホルダー画面が表示される
