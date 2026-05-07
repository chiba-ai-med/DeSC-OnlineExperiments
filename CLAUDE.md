# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

[OnlinePCA.jl](https://github.com/rikenbit/OnlinePCA.jl) と [OnlineNMF.jl](https://github.com/rikenbit/OnlineNMF.jl) のスケーラビリティ（時間・メモリ）を、サイズの異なるシミュレーションスパース行列で比較するベンチマーク実験リポジトリです。コンテナ化された Snakemake ワークフローとして構成されています。

## ワークフロー実行

3 つの Snakefile を順番に実行する 3 段階パイプラインです。各ルールは `container:` を宣言しているため、Singularity（または互換ランタイム）が必要で、`--use-singularity` フラグを付けて起動します。

```bash
# 1. シミュレーション行列を生成し、.zst バイナリ形式に変換
snakemake -s workflow/preprocess.smk --use-singularity --cores <N>

# 2. .zst 入力に対して OnlinePCA / OnlineNMF を実行
snakemake -s workflow/onlinexxx.smk --use-singularity --cores <N>

# 3. ベンチマーク結果をプロット
snakemake -s workflow/plot.smk --use-singularity --cores <N>
```

`preprocess` → `onlinexxx` → `plot` は **依存関係を持つ別々の Snakefile** です（単一の DAG ではありません）。前段の出力ファイル（`data/simulation/{row}/Data.{mtx,bincoo}.zst`、`output/simulation/{row}/.../*.csv`）を後段が入力として参照しているだけなので、順序を守って実行する必要があります。

補助スクリプト:

- `bash workflow/dag.sh` — 各 Snakefile の rulegraph を `plot/*.png` に出力（`graphviz` の `dot` が必要）
- `bash workflow/report.sh` — 実行後に `report/*.html` の Snakemake HTML レポートを生成

特定の行サイズだけ動かしたい場合は、目的の出力をターゲットに渡します（例: `snakemake -s workflow/onlinexxx.smk --use-singularity --cores 4 output/simulation/10000/sparse_dnmf/U.csv`）。

## アーキテクチャ

### レイヤ分離

各計算ルールは 3 層に分かれています:

1. **`workflow/*.smk`** — Snakemake の入出力宣言、Docker コンテナ、リソース、ベンチマーク／ログのパス
2. **`src/*.sh`** — `JULIA_DEPOT_PATH=/usr/local/julia` を設定して `.jl` を呼ぶ薄いラッパ（コンテナ内のパッケージプリインストール先と一致させるため必須）
3. **`src/*.jl`（または `*.R`）** — 実際の計算

`.smk` のルールを編集する際は、対応する `src/<rule>.sh` と `src/<rule>.jl` も同じ命名規則で揃っていることが前提です（例: `onlinepca_exact_ooc_pca_sparse_mm` ルール → `src/onlinepca_exact_ooc_pca_sparse_mm.{sh,jl}`）。

### データ形式

二系統の入力形式を並行して評価しています:

- **Sparse MatrixMarket (`.mtx` → `.mtx.zst`)** — `OnlinePCA.mm2bin` で OnlinePCA/NMF 用バイナリに変換され、`mode="sparse_mm"` / `sparse_dnmf` で読み込まれる
- **BinCOO (`.bincoo` → `.bincoo.zst`)** — `OnlinePCA.bincoo2bin` で変換され、`mode="sparse_bincoo"` / `bincoo_dnmf` で読み込まれる

シミュレーションは `ncols=7581`（`src/simulation_mm.jl`、`src/simulation_bincoo.jl` にハードコード）で、各行の非ゼロ数は 1〜2 個のスパース行列を生成します。`ROWS = ['1000', '10000', '100000', '1000000']` は **3 つの Snakefile すべてに重複定義** されているため、スケールを変えるときは 3 ファイルとも更新する必要があります。

### コンテナ

ルールごとに固定タグの異なるコンテナを使い分けています:

- `docker://koki/desc_investigation_julia:20240701` — シミュレーション生成（`simulation_mm`、`simulation_bincoo`）
- `docker://ghcr.io/rikenbit/onlinepcajl:f3532d4` — フォーマット変換と OnlinePCA 本体
- `docker://ghcr.io/rikenbit/onlinenmfjl:e7a5cc3` — OnlineNMF 本体
- `docker://koki/desc_investigation:20240508` — R によるプロット（ggplot2、dplyr）

OnlinePCA/NMF のコンテナは `JULIA_DEPOT_PATH=/usr/local/julia` にパッケージを焼き込んでいるため、新しいシェルラッパを作る場合もこの環境変数の export を忘れないでください。

### ベンチマークとプロット

各ルールは `benchmark:` ディレクティブで `benchmarks/<rule>_<row>.txt` に Snakemake のベンチマーク表（`s`、`max_rss` など）を出力します。`src/plot_time_memory.R` はこれらを読み込み時間／メモリのバー図を出力し、`src/plot_scalability.R` は 4 手法をまとめて log-log で線形回帰し、スケーリング指数を比較します。プロット用 R スクリプトは共通の `src/Functions.R`（`rows` ベクトルの定義のみ）を読み込みます。

`plot_time_memory.R` は **出力ファイルパスの文字列に対する grep で入力ベンチマークファイルを切り替える** 仕組みなので、`plot/simulation/<手法名>/...` というディレクトリ構造を変えると壊れます。
