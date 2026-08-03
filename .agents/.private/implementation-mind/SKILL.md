---
name: implementation-mind
description: コードの実装、修正、リファクタリングで、正しい置き場所、既存実装、責務分離、本質的な解決を確認する。read-only の調査だけでは使わない。
---

# Implementation Mind

変更前に正本と責務を特定し、症状を隠す実装を避ける。

## 書く前

1. project docs、同種の変更、隣接 code、git history から正しい directory と layer を特定する。
2. 同じ責務の function、component、型、schema、設定、命名を `rg` で探す。
3. protocol、parse、日時、通貨などは既存 library と project の採用方針を確認する。
4. 仕様の根拠と、変更してよい public surface を確認する。

## 避ける実装

- `catch`、空値、既定値で不整合を隠す fallback。
- 特定の名前、ID、file、具象 class に依存する分岐。
- test を通すだけの stub、認証 bypass、環境別の隠し分岐。
- 要求されていない互換 layer、旧 format 対応、public API。
- 同じ状態、lock、retry、副作用の再実装。

必要な例外には、理由、削除条件、保証する test を付ける。

## 構造

- 挙動は表示名や順序ではなく、型、属性、relation、状態から導出する。
- 変更は責務の owner に置き、presentation 層から永続化しない。
- file が複数責務を持ち始めたら domain 単位で分ける。
- global mutable state を避け、並列実行と test isolation を保つ。

## 変更と検証

- バグは原因の場所で直し、必要なら履歴から混入点を特定する。
- 同じ失敗パターンを repository 全体へ横展開する。
- 破壊的変更が複数機能、永続データ、公開 API、権限モデルに及ぶ場合は実装前に確認する。
- migration は環境ごとの手作業ではなく、再実行可能な手順にする。
