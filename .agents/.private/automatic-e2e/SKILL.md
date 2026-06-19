---
name: automatic-e2e
description: Web アプリの E2E テストを「計画 → 実行 → エビデンス保存 → 後始末」まで自律的に進めるための skill。グローバルの agent-browser CLI を headless で使い、正常系・異常系・リグレッションの 3 観点（i18n がある場合は言語ごと）でブラウザを操作し、確認結果をスクリーンショットとして hermes に残す。認証が必要なアプリの動作確認、フォーム投入・バリデーションの検証、リリース前の通し確認をするときに使う。単体テストや read-only のコード調査だけで完結するとき、ブラウザ操作を伴わないときは使わない。
allowed-tools: Bash(*)
---

# 目的

Web アプリの E2E テストを、再現可能・エビデンス付きの形で一貫して実施するための workflow。
ブラウザ操作はグローバルの `agent-browser` CLI を使い、テスト計画・認証情報・スクリーンショットは hermes のブランチ領域に残して次回以降に再利用する。

# 使うとき

- 認証が必要なアプリで、正常ルートが期待どおり動くかを確認するとき
- フォーム投入・入力バリデーション・動作機序を検証するとき
- セキュリティ・不正入力など異常系の挙動を確認するとき
- 変更後にリグレッション（既存機能の破壊）が起きていないか通しで確認するとき

# 使わないとき

- 単体テストやコード調査だけで完結するとき
- ブラウザ操作を伴わない確認のとき

# 前提

- E2E テストは必ずグローバルの `agent-browser` CLI を使う（`agent-browser` / `npx agent-browser`）。これは invoke できる skill ではなくコマンドラインツール。コマンド一覧は `agent-browser --help` か `.agents/skills/agent-browser/SKILL.md` を参照する。
- **必ず headless で起動する。** `agent-browser` はデフォルト headless だが、環境変数 `AGENT_BROWSER_HEADED` や config の `"headed": true` で headed になり得る。GUI ウィンドウが立ち上がってユーザーの作業を妨げないよう、起動コマンドに必ず `--headed false` を明示し、`AGENT_BROWSER_HEADED` を設定しない。
- 成果物は hermes のブランチ領域 `.hermes-prj-states/states/<branch>/` 配下に置く。ブランチslug等の特定は同梱スクリプトが行う。

# クイックスタート

この skill ディレクトリ内の `scripts/` を使う（パスはこの skill からの相対）。

```bash
# 1. ワークスペース初期化（ブランチslug 解決 + エビデンスdir リセット + 計画ファイル seed）
#    slug 解決済みのパスを変数に取り込む（EVIDENCE_DIR / HOW_TO_FILE が定義される）
eval "$(bash scripts/init-e2e.sh | grep -E '^(EVIDENCE_DIR|HOW_TO_FILE)=')"

# 2. ブラウザ操作は必ず headless 強制ラッパー ab.sh 経由で実行する
#    保存先は手で <branch> を埋めず、上で得た "$EVIDENCE_DIR" をそのまま使う
bash scripts/ab.sh --session e2e-normal open https://app.example.com
bash scripts/ab.sh --session e2e-normal screenshot --screenshot-dir "$EVIDENCE_DIR"

# 3. 終了時に必ず後始末（全セッションを閉じ、残プロセスを確認）
bash scripts/finish-e2e.sh
```

同梱スクリプト:

- `scripts/init-e2e.sh` — ブランチ領域を初期化。`HOW_TO_E2E_TEST.md` を seed し、**エビデンスdir を毎回リセット**する（回し直し＝1から取り直しを自動担保）。
- `scripts/ab.sh` — `agent-browser` の **headless 強制ラッパー**。`AGENT_BROWSER_HEADED` を unset し `--headed false` を必ず注入するので、GUI ウィンドウが立ち上がらない。ブラウザ操作は必ずこれ経由で行う。
- `scripts/finish-e2e.sh` — 全セッションを閉じ、残プロセスを確認する。

---

# 1. テスト前の準備

## 1-1. 認証情報を確保する

1. ユーザーから認証情報が伝えられているか確認する。
2. 無ければリポジトリ内（`.env`、設定ファイル、docs 等）を探す。
3. それでも見つからなければ、**テストを開始する前に**ユーザーへヒアリングする。

確保した認証情報は次回ヒアリング不要にするため `HOW_TO_E2E_TEST.md`（後述）に記録する。

## 1-2. テスト計画を立てる

確認すべき仕様を事前に洗い出し、次の 3 観点で計画を整理する。

- **正常系** — 正常ルートで期待どおり動くか。動作機序、入力バリデーションの正常系。
- **異常系** — 不正入力・権限外操作・セキュリティ観点でのバリデーションと防御。
- **リグレッション** — 今回の変更で既存機能が壊れていないか。

### i18n がある場合は言語の両軸で確認する

リポジトリに言語設定（i18n 等）の仕組みがある場合は、**日本語と別の言語（デフォルトは英語）の両軸**で確認する。

- 各言語で上記 3 観点（正常系・異常系・リグレッション）を実施する。
- 言語切り替えで文言・レイアウト・バリデーションメッセージが正しく出るかを確認する。

## 1-3. 計画を hermes に記録する

- テスト計画を `.hermes-prj-states/states/<branch>/HOW_TO_E2E_TEST.md` にまとめ、次回から参照できるようにする。
- 認証情報・対象 URL・前提条件・各観点の確認項目を含める。ユーザーが探す手間を省くことが目的。

---

# 2. テスト実行

## 2-1. agent-browser を headless で起動する

- ブラウザ操作は必ず `scripts/ab.sh` 経由で実行する。`--headed false` が常に注入され、GUI ウィンドウが立ち上がらない。素の `agent-browser` を直接叩かない。
- 並列で複数観点を回す場合は、観点ごとに `--session <name>`（例: `--session e2e-normal`）でセッションを分け、プロセス・状態を独立させる。

## 2-2. docker logs を確認する（Docker 構成のリポジトリの場合）

ユーザーから特段の指示がなければ、各ステップごとに `docker logs` を確認する。

- 関係がありそうなエラー → その場で修復する（ユーザーへの事前確認が不要な範囲で）。
- 関係なさそうなエラー → 収集しておき、最後にまとめてユーザーへ報告する。

## 2-3. ブラウザのエラーを必ず確認する

各操作のあとにブラウザ側のエラーを必ず確認する。

- `agent-browser errors` でページエラー、`agent-browser console` でコンソールメッセージを確認する。
- 関係がありそうなエラー → 修復する。
- 関係なさそうなエラー → 収集しておき、最後にユーザーへ報告する。

## 2-4. スクリーンショットでエビデンスを残す

**仕様に関連する箇所・異常系・リグレッションの確認では、必ずスクリーンショットを撮ってエビデンスとして hermes に格納する。**

- 保存先は `init-e2e.sh` が用意・リセットした `e2e-evidence/`。パスは手で `<branch>` を埋めず、`init-e2e.sh` が出力する `EVIDENCE_DIR`（クイックスタート参照）をそのまま使う。
  例: `bash scripts/ab.sh --session e2e-normal screenshot --screenshot-dir "$EVIDENCE_DIR"`
- ファイル名は観点・ケースが分かる形にする（例: `normal_login_ok.png`、`abnormal_invalid_email.png`、`regression_dashboard.png`。i18n がある場合は言語も含める: `en_normal_login_ok.png`）。
- **E2E を回し直すときの「1 からの取り直し」は `init-e2e.sh` がエビデンスdir のリセットで自動的に担保する。** 手動でスクショを消す必要はないが、過去実行のスクショを残したまま混在させないこと。

## 2-5. 複数観点は子エージェントに分散する

複数観点を並行してテストする場合は、観点ごとに子エージェントへ割り振る。

- 各子エージェントは `--session <name>` で**独立した agent-browser セッション**を使い、プロセスを共有しない。
- 3 観点があるため、最低でも 3 つの子エージェントが分担する想定。
- 各子エージェントも本 skill のルール（headless 起動・エラー確認・エビデンス保存）に従う。

---

# 3. テスト後の後始末

- 起動した agent-browser のセッション／プロセスを**必ず**終了させる。`scripts/finish-e2e.sh` を実行して全セッションを閉じ、残プロセスがないことを確認する。
- 収集した「関係なさそうなエラー」を docker・ブラウザ分まとめてユーザーへ報告する。
- エビデンス（スクリーンショット）と `HOW_TO_E2E_TEST.md` が hermes のブランチ領域に揃っていることを確認する。
