# Zenn本 構成設計

## メタ情報

- **タイトル:** Codex + Ollama + Runtimeで「AI社長組織」を止めない実践ガイド
- **サブタイトル:** Northbridge Systems視点で学ぶ、長時間運転・評価・復旧・収益化の設計
- **価格:** ¥1,500
- **対象読者:** Claude Code / Codex / ローカルLLM / MCP / 長時間運転に興味があるエンジニア
- **立ち位置:** Southgate本が「AI社長組織を立ち上げる本」なら、本書は「AI社長組織を運用し、壊れたら直し、売れる形に整える本」
- **差別化:** 概念説明ではなく、実際に壊れた runtime をどう直したか、worker 品質をどう上げたか、どう商品へ寄せたかまでを書く
- **無料公開:** 第1〜2章

## 本書の狙い

AI社長組織は、作るだけなら意外とできる。

難しいのはその先だ。

- unattended で本当に回るか
- local LLM が落ちた時に止まり方が分かるか
- 長時間運転の status が stale になった時、どう見抜くのか
- memory が膨らんだ時、何を残し何を圧縮するのか
- AIが作った成果物を、どうやって売れる品質まで押し上げるのか

本書は、この「作った後」の問題に答える。

## チャプター構成

### 無料パート

**第1章: なぜAI社長組織には運用OSが必要なのか**
- Southgate本との役割分担
- AI社長組織は「社長」と「部下」だけでは足りない
- Runtime OS, supervisor, Dream, health check, approval gate の必要性
- 本書で作れるもの

**第2章: Northbridge Systems の全体像**
- スポンサー / Northbridge / Southgate の三層
- relay bot, recurring tick supervisor, local runtime health, worker factory
- 現在の5 worker roster と実際の評価結果

### 有料パート

**第3章: 長時間運転を成立させる recurring tick supervisor**
- なぜ「長生きする1プロセス」より recurring tick が良いのか
- Task Scheduler と in-process worker batch
- stale status の見抜き方
- lock / state / log の設計

**第4章: local LLM runtime を死なせない**
- Ollama health check
- ready / unreachable / soft-block の分離
- auto-recovery の設計
- local runtime が死んでいても会社全体は止めない考え方

**第5章: worker を評価し、矯正する**
- Forge / Ledger / Compass / Quill / Lantern の役割
- smoke eval と full eval
- fail case を prompt 修正へ落とす
- なぜ model split が必要なのか

**第6章: Dream と memory 圧縮**
- Active / Durable memory の役割分担
- archive を残しつつ本体を軽くする
- Dream report から次の修正対象を出す
- 200 lines / 25 KB budget の考え方

**第7章: Runtime Audit Studio を作る**
- なぜ最初の商品は evidence-first であるべきか
- Technical Brief Studio がまだ弱い理由
- Runtime Audit Studio の入出力
- 最初の売り物をどう小さく安全にするか

**第8章: 承認制を壊さずに自律性を上げる**
- sponsor gate
- company gate
- worker escalation
- 自律化と無断実行は違う

**付録A: 状態ファイル一覧**
**付録B: 障害例と復旧例**
**付録C: worker評価テンプレート**

## 想定する読者の課題

- AIエージェントを作ったが、長時間運転で止まる
- local LLM を入れたが、worker 品質が安定しない
- 仕組みはあるが、何を売ればよいか分からない
- Claude Code / Codex / Ollama をどう役割分担すべきか迷っている

## この本で出したい価値

本書の価値は、華やかな未来像ではない。

- 実際に動く運用
- 実際に壊れる箇所
- 実際に直した方法
- 実際に売り物へ変換する道筋

を、一つの系として見せることにある。
