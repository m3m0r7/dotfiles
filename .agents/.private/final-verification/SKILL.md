---
name: final-verification
description: Final pre-commit, pre-push, or pre-merge verification for implementation work. Use when Codex needs to confirm the change satisfies the user's request before committing, pushing, opening, updating, or merging a PR; when asked for a final check; or when PR-linked context such as issues, review comments, CI checks, changed files, and acceptance criteria must be verified against the implementation.
---

# Final Verification

変更を commit / push / PR 更新 / merge する直前に、実装が本当に仕様を満たしているか確認する workflow。
不一致、未解決レビュー、CI 失敗、未検証の重要リスクがある場合は作業を止め、commit / push / merge へ進まない。

# 1. 確認元を集める

次の情報を、推測ではなく確認元として扱う。

- ユーザーの最新依頼、会話内の制約、明示された受け入れ条件
- `git status --short`、`git diff`、必要に応じて base branch との差分
- 関連するテスト、lint、型チェック、ビルド設定
- PR がある場合は PR の title / body / changed files / commits / comments / reviews / CI checks
- PR に紐づく issue、closing keywords、本文やコメント内の issue / ticket / docs リンク

PR 情報を取れる場合は `gh` を優先する。

```bash
gh pr view --json number,title,body,url,baseRefName,headRefName,state,isDraft,files,commits,comments,reviews,latestReviews,reviewDecision,statusCheckRollup
gh pr view --comments
```

PR 本文・タイトル・コメントから `Closes` / `Fixes` / `Resolves`、`#123`、`owner/repo#123`、GitHub issue URL、外部 ticket URL を探す。
GitHub issue は可能なら `gh issue view <number> --comments` で確認する。
`gh` が使えない、未ログイン、ネットワーク不可、外部 ticket が認証不可の場合は、その制約を最終報告に明示する。

# 2. 仕様チェックリストを作る

確認元から満たすべき仕様を短いチェックリストに分解する。

- ユーザー依頼の必須要件
- PR / issue の受け入れ条件
- レビューコメントで要求された修正
- 既存挙動を壊してはいけない箇所
- UI 変更、API 契約、DB 状態、権限、エラー処理などの品質観点

各項目について「対応する変更箇所」「確認方法」「結果」を対応付ける。
対応箇所や確認方法が見つからない項目は未達または未検証として扱う。

# 3. 差分を検査する

`git diff` を読み、仕様チェックリストと差分が対応しているか確認する。

- 要件に対して実装が不足していないか
- 仕様と無関係な変更、デバッグコード、不要なログ、生成物、秘密情報が混ざっていないか
- 同じ修正が必要な類似箇所に横展開されているか
- 既存 API、保存データ、権限、バリデーション、エラー表示、i18n、アクセシビリティに副作用がないか
- テストが実装の重要な分岐とリグレッションを押さえているか

PR の changed files とローカル diff が食い違う場合は、どちらを確認対象にしたか明示する。

# 4. PR に紐づくものを確認する

PR が存在する場合は、実装だけでなく PR 周辺の状態も確認する。

- PR title / body が実装内容と一致しているか
- linked issue / ticket の要求、受け入れ条件、コメントに未対応がないか
- review comments と requested changes が解決済み、または今回の差分で明確に対応済みか
- CI / status checks が成功しているか。失敗・pending・skipped があれば意味を確認する
- draft / base branch / head branch / merge target が意図どおりか
- PR に含まれる commit と changed files が今回の目的に対して過不足ないか

レビューコメントを確認した場合は、重要な指摘ごとに「対応済み」「未対応」「対象外」の判断を残す。

# 5. 検証を実行する

リポジトリの既存手順に従い、必要な検証を実行する。
不明な場合は package scripts、README、CI 設定、既存 skill の hermes notes を確認する。

- 変更範囲に対応する unit / integration tests
- lint、format check、type check
- build または compile
- UI 変更がある場合はブラウザ確認。必要なら `automatic-e2e` を使い、スクリーンショットを残す
- DB / API / cookie / localStorage / sessionStorage など状態整合性が関係する場合は `quality-mind` の観点で確認する

検証を実行できない場合は、理由と代替確認を明示する。
重要な検証が未実行のままなら、commit / push / merge に進まない判断を優先する。

# 6. 最終判断を出す

最後に、commit / push / merge に進めるかを明確に判断する。

- **OK**: 仕様チェックリストを満たし、必要な検証が通り、PR 関連の未解決事項がない
- **Blocked**: 仕様未達、テスト失敗、CI 失敗、未解決レビュー、PR-linked issue の未対応、重要な未検証リスクがある
- **Limited**: 外部情報や権限不足で一部確認できないが、ローカルで確認可能な範囲は満たしている

最終報告には次を含める。

- 満たした仕様
- 確認した PR / issue / review / CI の範囲
- 実行した検証コマンドと結果
- 未対応または未検証のリスク
- commit / push / merge に進めるかの判断
