---
name: design-mind
description: UI、component、form、dialog、style、文言、client state、UX の実装や review で使う。既存 design system、accessibility、i18n、IME、再レンダリングを確認する。
---

# Design Mind

project の既存 design system と利用者の操作目的を正とする。

## 実装前

1. 同種の画面、component、form、test、文言を探す。
2. 採用済み UI library、theme token、icon、spacing、responsive 規約を確認する。
3. 参照画面がある場合は、見た目だけでなく状態、操作、error、keyboard behavior を揃える。
4. 新規 UI は既存 component で表現できない場合だけ作る。

## Text and interaction

- i18n 採用 project では key と設定済み全言語を更新する。未採用 project に新しい i18n layer を追加しない。
- 利用者に権限がない操作は既存の権限 UX に従う。状態により一時的に実行不能な操作は、理由を keyboard でも取得できる形で示す。
- submit の可否と validation 表示は既存 form 規約に従い、利用者が error を発見して修正できるようにする。
- field error は対象 field の近くへ、画面全体の一時的な結果は既存 notification へ出す。
- loading と二重送信防止を入れ、失敗後の再試行可否を示す。
- drag and drop には keyboard で完結する代替操作を用意する。
- 内部 ID や raw error を表示しない。

## State and input

- state は利用範囲に最も近い owner へ置き、不要な global state と effect chain を増やさない。
- derived state を重複保存せず、再レンダリングで focus と入力値を失わないようにする。
- IME composing 中の validation、自動保存、shortcut、remote update を確認する。
- 全角半角、結合文字、長文、空状態、複数 tab、戻る進むを対象に応じて確認する。

## 完了

- 実 browser で主要導線を操作し、表示、keyboard 操作、console error、関連する API または保存値を確認する。
- 同じ component を使う他画面と、project が対応する viewport、language への影響を確認する。
