---
name: hermes
description: 非自明なコード変更、未知のリポジトリへの着手、CI 失敗調査、既存規約を読み解きながら進める bugfix / feature 実装の前に使う。プロジェクト状態、実装規約、CI/テスト手順を調査し、`.hermes-prj-states/STATE.md` と `states/<branch>/YYYYMMDD.md`、`PROGRAMMING_KNOWN.md`、`CI.md` を整備してから実装・検証・セルフレビューまで進める。単発の質問、read-only 調査、軽微な 1 ファイル修正だけのタスクでは使わない。
compatibility: Shell が使え、リポジトリ内に調査メモを書ける環境を前提とする
allowed-tools: Bash(*)
---

# 目的

この skill は、実装前の調査を再利用可能な形で残し、未知のコードベースでも小さい差分で安全に進めるための workflow。
常設のグローバルルールではなく、非自明な変更に着手するときだけ使う。

# 使うとき

- 初めて触るリポジトリで feature 実装や bugfix を始めるとき
- 既存の命名、責務分割、テスト習慣を読んでから変更すべきとき
- CI failure をローカルで再現しながら直すとき
- 変更対象の近傍だけでは判断できず、プロジェクト全体の開発手順が必要なとき

# 使わないとき

- 単発の質問に答えるだけのとき
- read-only のコード調査だけで終わるとき
- `date` や `git status` のような軽いコマンド実行だけのとき
- 明らかに局所的で、既存規約の再調査が不要な 1 ファイル修正のとき

# クイックスタート

1. プロジェクトルートを特定する
   `PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)`
2. 状態ディレクトリ、branch ごとの一時領域、当日メモを作る
   `bash scripts/init-hermes.sh "$PROJECT_ROOT"`
3. 初期化スクリプトが出力した `Branch slug`、`Branch temp dir`、`Branch state note` を確認する
4. 既存の状態ファイル、branch メモ、一時ファイルがあれば先に読む
5. 今回のタスクに必要な範囲だけ、スナップショットは上書き更新し、branch メモは当日分を更新する

# 初期調査の順序

1. ルートとエコシステムを確認する
   - `package.json`
   - `pnpm-workspace.yaml`
   - `pyproject.toml`
   - `Cargo.toml`
   - `go.mod`
   - `Gemfile`
   - `composer.json`
   - `Makefile`
2. CI と自動化を確認する
   - `.github/workflows/`
   - `.gitlab-ci.yml`
   - `Makefile`
   - `taskfile.yml`
   - `justfile`
3. lint / typecheck / test 設定を確認する
4. 変更対象の近傍コードと近傍テストを読む
5. 共通基盤や既存の設計ルールが効いていそうなら、その周辺まで広げて読む
6. `STATE.md` の初稿を書いたら、それを読み直しながら少なくとも 3 パスで掘り下げる
   - 1 パス目: リポジトリ形状、ツールチェーン、主要パッケージ
   - 2 パス目: 実行経路、データ境界、依存方向、責務分割
   - 3 パス目: 変更しやすい場所、壊れやすい場所、unit / integration / E2E の観点

# 状態ディレクトリ

作業開始時に、プロジェクトルート直下の `.hermes-prj-states/`、`.hermes-prj-states/states/`、`.hermes-prj-states/tmp/` の存在を確認し、なければ作成する。

branch 名は現在の git branch 名からディレクトリ安全な slug に正規化して使う。名前付き branch でなければ `detached-head` を使う。

- `.hermes-prj-states/`
  - リポジトリ全体の現時点スナップショットと共通知識を保管する
- `.hermes-prj-states/STATE.md`
  - リポジトリ全体の状態を表す単一のスナップショット
  - 履歴ログではない。日付見出しや task ごとの追記は禁止
- `.hermes-prj-states/states/<branch>/YYYYMMDD.md`
  - branch ごとの当日メモ
  - その branch で今回の作業によって変わった事実、確認できた事実、テスト観点を保管する
- `.hermes-prj-states/tmp/<branch>/`
  - その branch のテスト用ファイル、スクリーンショット、ログなど、LLM が生成する一時ファイルを保管する

この skill の指示で補助ファイルを作るとき、保存先が指定されていなければ以下を使う。

- 一時ファイル: `.hermes-prj-states/tmp/<branch>/`
- branch ごとの作業メモ: `.hermes-prj-states/states/<branch>/YYYYMMDD.md`
- リポジトリ全体の状態整理: `.hermes-prj-states/STATE.md` ほか共通ファイル

# 読み込む参考ファイル

- `STATE.md` を作るか更新するときは [references/state-template.md](references/state-template.md) を使う
- `states/<branch>/YYYYMMDD.md` を作るか更新するときは [references/branch-state-template.md](references/branch-state-template.md) を使う
- `PROGRAMMING_KNOWN.md` を作るか更新するときは [references/programming-known-template.md](references/programming-known-template.md) を使う
- `CI.md` を作るか更新するときは [references/ci-template.md](references/ci-template.md) を使う

# 読み込み順序

- `.hermes-prj-states/STATE.md`、`PROGRAMMING_KNOWN.md`、`CI.md` があれば先に読む
- `.hermes-prj-states/states/<branch>/` に当日メモがあれば読む。なければ最新の関連メモを読む
- `.hermes-prj-states/tmp/<branch>/` に既存ファイルがあれば一覧を見て、今回の作業に関係するものだけ読む
- 新しいメモや一時ファイルを作る前に、同名・同日・同 branch の既存資産がないか確認する

# 更新ルール

## `STATE.md`

- `.hermes-prj-states/STATE.md` がなければ作成する
- あれば読んで、現時点で正しいスナップショットに全体を書き換える
- 履歴を追記せず、現時点のスナップショットとして更新する
- `## 2026-04-29 Plan Excel Import` のような日付見出し、task 見出し、作業ログを足さない
- リポジトリ構成、主要実行経路、データ境界、依存方向、変更リスク、テストの厚い場所と薄い場所まで書く
- 初稿のまま確定せず、少なくとも 3 回は読み直して具体性を増やす
- 推測で埋めず、確認できた事実だけを書く

## `states/<branch>/YYYYMMDD.md`

- 当日分のファイルがなければ作成する
- あれば読んで、今回の作業で変わった事実だけを当日スナップショットとして更新する
- `STATE.md` の要約コピーにしない。branch 固有の差分と判断材料に絞る
- 変更された挙動、影響モジュール、追加や更新が必要な unit test 観点、integration / E2E 観点、実行した検証結果を書く
- 推測で埋めず、確認できた事実だけを書く

## `PROGRAMMING_KNOWN.md`

- 今回触る言語やフレームワークに関係する部分だけ更新する
- 既存コードから抽出できる流儀を優先し、一般論は補助に留める
- 命名、責務分割、よく使う API、テストの書き方を記録する

## `CI.md`

- ローカルで再現可能な最短手順を優先して書く
- lint / test / build / typecheck を分けて整理する
- 追加ツールが必要なら、導入せずに済むかを先に確認する
- 導入が必要でも高リスクなら実施せず、必要条件として記録する

# 実装ルール

コード変更時は、少なくとも次を確認する。

- セキュリティ
  - DDoS、CSRF、権限漏れ、入力検証不足、既知の危険な既定値
- パフォーマンス
  - N+1、不要な永続接続、不要な I/O、過剰な再計算
- 設計
  - 境界分離、凝集、責務の過不足、既存構成との整合

また、以下を守る。

- 変更スコープは当該タスクに絞る
- 既存コードの書きぶり、命名、採用ライブラリ、テストパターンを尊重する
- まず動く最小差分を作り、その後に必要な補強を行う
- ユーザー指示なしに、互換性維持のためだけの過剰実装をしない

# 検証順序

1. 変更対象に最も近いテストを回す
2. 関連 lint / typecheck を回す
3. 必要なら build を回す
4. 共通基盤や広い呼び出し元に触れたときだけ、より広い test suite へ広げる
5. 必要ならブラウザ確認や E2E を行う

# 停止して確認する条件

- 新しい依存、外部ツール、認証情報が必要
- 複数の実装流儀が混在し、どれに合わせるべきか判断できない
- CI とローカル手順が食い違い、どちらを正とすべきか不明
- タスクの途中で、要求スコープが別機能や大規模整理へ広がった
- 状態ファイルの更新が、今回の作業範囲を超えて全体見直しになりそう

# 開発プロセス

1. タスクを分解し、今回触る範囲を明確にする
2. `STATE.md`、`PROGRAMMING_KNOWN.md`、`CI.md`、current branch の当日メモ、current branch の tmp 配下を確認し、足りない事実だけ補う
3. 調査結果に沿って最小スコープで実装する
4. 実装が書き方の方針に反していないか見直す
5. 関連するユニットテスト、E2E テストを追加または更新する
6. agent-browser で動作を確認する
7. `CI.md` に従って検証する
8. セルフレビューし、問題があれば実装に戻る
9. 今回の作業で判明した新事実を `STATE.md` と current branch の当日メモへ反映する
10. ユーザーに、実行した検証と未実行の検証を明示して返す

# 仕上げの基準

- 書いたコード、テスト、検証手順が今回のタスクに対して閉じている
- `STATE.md`、current branch の当日メモ、`PROGRAMMING_KNOWN.md` に再利用可能な判断材料を残せている
- 必要な検証を実行済み、または未実行の理由を説明できる
- コミットが必要な場合だけ、英語の conventional commits を使い、クレジットは書かない
