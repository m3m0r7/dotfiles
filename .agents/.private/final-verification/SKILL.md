---
name: final-verification
description: Commit、push、PR 作成や更新、merge の直前、または明示的な最終確認で、変更が依頼、issue、review、CI、test を満たすか判定する。
---

# Final Verification

仕様未達、重要な未検証、失敗した test、未解決 review がある状態で commit、push、merge へ進めない。

## 1. 確認元

- 最新の依頼、制約、受け入れ条件。
- `git status --short`、local diff、必要なら base branch との差分。
- 関連 test、lint、typecheck、build、実行手順。
- PR がある場合は title、body、files、commits、review、comments、CI、linked issue。

外部情報を取得できない場合は、その範囲を未確認とする。

## 2. 対応付け

要件ごとに変更箇所、確認方法、結果を対応付ける。
次を横断して不足と余計な変更を探す。

- API、schema、保存データ、権限、validation、error、i18n、accessibility。
- 同じ修正が必要な類似箇所。
- debug code、不要な log、生成物、secret、scope 外の refactor。
- 実装の重要な分岐を test が確認しているか。

PR の内容と local diff が異なる場合は、確認対象を明示する。

## 3. 実行確認

- 変更に最も近い test から実行し、必要範囲の lint、typecheck、build を追加する。
- UI 変更は実 browser で主要導線、console、必要な API や保存値を確認する。
- 実行不能な確認は理由と代替確認を示し、重要なら進行を止める。

## 4. 判定

- `OK`: 要件と必要な検証を満たし、既知の未解決事項がない。
- `Blocked`: 仕様未達、test や CI の失敗、未解決 review、重要な未検証がある。
- `Limited`: 外部権限などで一部を確認できないが、local で確認可能な範囲は満たす。

報告には満たした要件、確認範囲、実行 command、残る risk、次の Git 操作へ進めるかを含める。
