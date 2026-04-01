# Southgate Research — HTML車窓風景再現素材の実現可能性調査

Date: 2026-03-31
Author: Southgate Research president (Compass role)
Scope: HTML/CSS/Canvasで車窓風景を再現し、GIF/MP4として書き出せるか

---

## Option Table

### Option A: Pure CSS パララックス横スクロール（最も軽量）

**仕組み:** 複数のCSSレイヤー（空、遠景の山、中景の木、近景の建物/電柱）を異なる速度で左に流す。`@keyframes` + `translateX` で無限ループ。

**既存の類似例:**
- [Moving Train Animation [Pure CSS]](https://codepen.io/kh-mamun/pen/qQZaVM) — 夜景、月、山、煙突の煙、回転する車輪、すべてCSS
- [Pure CSS Landscape – An Evening in Southwold](https://codepen.io/ivorjetski/pen/xxGYWQG) — 画像なし、CSSだけで海岸風景
- [SVG + CSS Landscape Animation](https://codepen.io/guillaume_lt/pen/qdgoNL) — SVGとCSSで風景アニメ

**車窓への応用:**
```
レイヤー構成（手前→奥）:
  1. 窓枠（固定） — 電車の窓フレーム
  2. 電柱・フェンス（最速スクロール） — 0.5s/繰り返し
  3. 建物・木（中速） — 2s/繰り返し
  4. 田園・丘（低速） — 8s/繰り返し
  5. 山並み（超低速） — 30s/繰り返し
  6. 空・雲（ほぼ静止） — 120s/繰り返し
```

| 項目 | 評価 |
|---|---|
| 難易度 | 低 |
| ブラウザ互換 | 全ブラウザ |
| 品質 | イラスト調（フラットデザイン向き） |
| GIF/MP4書き出し | 画面録画 or Puppeteer + ffmpeg |
| カスタマイズ性 | CSS変数で速度・色・密度を調整可能 |
| 適用場面 | Lo-fi動画背景、配信用背景、リラックス系コンテンツ |

### Option B: HTML5 Canvas プロシージャル生成（最も柔軟）

**仕組み:** Canvas APIで風景を手続き的に生成。山の輪郭はPerlinノイズ、木はランダム配置、建物はパターンタイル。`requestAnimationFrame`で描画ループ。

**既存技術:**
- [SUMMUS — 3D on 2D Canvas](https://summus.io/articles/bring-the-third-dimension-to-a-two-dimensional-html5-canvas) — レイヤーごとに異なるスクロール速度
- [canvas-sketch](https://frontendmasters.com/courses/webgl-shaders/exporting-animations-in-canvas-sketch/) — フレームをffmpegでMP4/GIFに直接ストリーム
- [Animatron](https://www.animatron.com/blog/how-we-render-animated-content-from-html5-canvas/) — PhantomJSでスクリーンショット → ffmpegで動画化

**車窓への応用:**
- 地形をノイズ関数で無限生成（繰り返しパターンが見えにくい）
- 時間帯パラメータで朝焼け→昼→夕焼け→夜の変化
- 天候パラメータで晴れ→曇り→雨→雪
- 季節パラメータで春（桜）→夏（緑）→秋（紅葉）→冬（雪景色）

| 項目 | 評価 |
|---|---|
| 難易度 | 中 |
| ブラウザ互換 | 全ブラウザ |
| 品質 | パラメトリック（リアル寄りも可） |
| GIF/MP4書き出し | canvas-sketch + ffmpeg で直接書き出し |
| カスタマイズ性 | 高（地形・天候・季節・時間帯・速度すべてパラメータ化可能） |
| 適用場面 | 動画素材販売、ASMR/リラックス動画、ゲーム背景 |

### Option C: CSS + SVGフィルター + WebGL（最高品質）

**仕組み:** WebGLシェーダーで大気散乱や光の表現を追加。SVGフィルターで柔らかいぼかし（被写界深度）。

| 項目 | 評価 |
|---|---|
| 難易度 | 高 |
| 品質 | フォトリアリスティック寄り |
| 書き出し | 可能だが重い |
| 適用場面 | ハイエンド映像素材 |

---

## Recommendation

**Option B（Canvas プロシージャル生成）を推奨。**

理由:
1. パラメータ化で無限バリエーション → 素材としての商品価値が高い
2. ffmpegで直接GIF/MP4書き出し → ワークフローが完結
3. プロシージャルなので繰り返しパターンが見えにくい → 長尺動画に向く
4. 時間帯・天候・季節の組み合わせで、1つのエンジンから大量の素材を生成できる

**Option Aから始めてPoC**を作り、**Option Bに進化**させるのが段階的で安全。

---

## 収益化の可能性

| 販売先 | 単価目安 | 備考 |
|---|---|---|
| 動画素材サイト（PIXTA, Adobe Stock等） | 500-3,000円/素材 | 素材数で稼ぐモデル |
| YouTube用背景素材（BOOTH等） | 1,000-5,000円/パック | 配信者・動画制作者向け |
| Lo-fi/ASMR チャンネル用ループ動画 | 制作依頼 5,000-20,000円 | カスタム制作 |
| npmパッケージ/ツール公開 | 間接収益（知名度→案件） | オープンソース + 有料テンプレート |

**Tier 1到達の現実性:** 週3-5素材を制作・販売すれば月15,000円は現実的。ドキュメント制作と併行可能。

---

## 技術実装の骨格（Option A → B移行パス）

### Phase 1: CSSパララックスPoC
```
index.html — 窓枠 + 6レイヤーの横スクロール
style.css — @keyframes, レイヤー速度, 色彩
→ 動くプロトタイプを今日中に作れる
```

### Phase 2: Canvas化 + パラメータ
```
engine.js — Perlinノイズ地形生成, レイヤー描画
config.json — 速度, 季節, 天候, 時間帯
→ パラメータを変えるだけで別の風景
```

### Phase 3: 書き出しパイプライン
```
export.js — canvas-sketch or Puppeteer + ffmpeg
→ GIF/MP4/WebM自動書き出し
```

## Uncertainty Note

- 動画素材市場での「AIっぽいプロシージャル素材」の需要はまだ測定されていない
- PIXTA等のストックサイトでAI生成素材の受け入れポリシーが変わる可能性
- 品質がイラスト調に留まる場合、需要は限定的かもしれない

## Next Action

CSSパララックスのPoCを作成し、実際に動く車窓風景を見せる。スポンサー判断で進めるか決定。

## Unresolved Risk

素材販売は単価が低く数で勝負。制作自動化の仕組みがないと、手動制作ではTier 1に届かない可能性がある。プロシージャル生成（Option B）への移行が収益化の鍵。
