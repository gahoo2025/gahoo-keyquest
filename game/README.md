# game/（Godotプロジェクト）

gahoo-keyquestのゲーム本体。[Godot](https://godotengine.org/) 4系を想定（`gahoo-shooter`と同じ構成）。

## 開き方

1. [Godot](https://godotengine.org/download) をインストール（4.7以降推奨）
2. Godotエディタの「Import」からこのフォルダ内の `project.godot` を選択して開く
3. `scenes/main.tscn` を実行（F6またはF5）すると、プレースホルダー画面が表示される

## 現在の状況（初期スキャフォールド）

`scenes/main.tscn` ＋ `scripts/main.gd` のみの最小構成。実際のコアループ（横スクロール探索・接触＝バンプ戦闘＋方向依存の有利不利・鍵集め）は、`gahoo-company/gamedev/gahoo-keyquest-spec.md`の仕様ドラフトを踏まえた改修計画（実装計画第1弾）策定後に実装する。

## 構成（現時点）

```
game/
├── project.godot
├── scenes/
│   └── main.tscn   # プレースホルダー（起動確認用）
└── scripts/
    └── main.gd
```
