---
name: automatic-e2e
description: Web application の実利用導線を headless browser で検証し、UI と API・DB・storage、console、server log を突合して証跡を残す。認証、form、validation、regression、release 前確認で使う。
---

# Automatic E2E

既存 code から URL、locator、待機条件、期待状態を決めてから browser を動かす。

## Safety

- browser 操作には global `agent-browser` と、この skill の `scripts/ab.sh` だけを使う。
- 名前付き session を run ごとに分離し、この run が作った session だけを閉じる。
- 本番、staging、共有 DB は明示指示がない限り read-only とし、環境を判別できなければ本番として扱う。
- submit など外部副作用の直前に、対象、環境、変更内容が依頼範囲内か確認する。

## Initialize

script path はこの `SKILL.md` から解決し、対象 repository の root を明示的に渡す。
現在 directory が skill directory または project root だと仮定しない。

```bash
PROJECT_ROOT="$(git rev-parse --show-toplevel)"
INIT_OUTPUT="$(bash "${E2E_SKILL_DIR}/scripts/init-e2e.sh" "$PROJECT_ROOT")" || exit $?
eval "$(printf '%s\n' "$INIT_OUTPUT" | sed -n '/^export /p')"
agent-browser skills get core
```

`E2E_SKILL_DIR` には、この file を含む absolute directory を設定する。
初期化失敗、または export された path と prefix が空の場合は browser 操作へ進まない。

認証情報は project の `AGENTS.md` と docs に定めた保存場所から使う。
`HOW_TO_FILE` には secret の値を書かず、利用する vault、profile、session、環境変数の所在だけを記録する。

## Build the execution map

browser を起動する前に次を調べ、scenario の開始 URL、操作、待機条件、期待結果、証跡名を `HOW_TO_FILE` に書く。

1. Project guidance、起動方法、base URL、認証方法。
2. Route、page、component、form、validation schema。
3. 既存 E2E、integration test、fixture、seed、factory。
4. 安定した label、role、`data-testid`、name 属性。
5. API contract、永続化先、期待する副作用。

locator は label と role、test ID、安定した属性、CSS の順で選ぶ。
生成 class、表示順、翻訳で変わる文言に依存しない。

## Select coverage

`../quality-mind/references/verification-checklist.md` から変更リスクに関係する scenario だけを選ぶ。
純粋な validation は unit、API と DB 境界は integration、実利用導線と client state は E2E を優先する。
i18n は主要導線を対応言語で確認し、言語に依存しない認可や DB 制約を重複実行しない。

## Execute and diagnose

```bash
bash "${E2E_SKILL_DIR}/scripts/ab.sh" --session "${E2E_SESSION_PREFIX}-normal" open "$TARGET_URL"
```

- runtime DOM が不明なときだけ snapshot を取り、既知の完了条件を待つ。
- 固定 sleep を避け、URL、element、text、JavaScript condition を待つ。
- scenario 終了時に browser errors、console、関連 server log の差分を確認する。
- 失敗した場合だけ、操作単位へ診断を細分化して再現する。
- 関係する error が残る scenario を pass にしない。

## Verify and record

操作後に UI、API response、DB record、履歴、集計、cookie、localStorage、sessionStorage のうち関係する実体を突合する。
件数だけでなく値の中身を確認する。
scenario の成否を示す screenshot を `EVIDENCE_DIR` に保存し、file 名に scenario、language、result を含める。

完了時と中断時に実行する。

```bash
bash "${E2E_SKILL_DIR}/scripts/finish-e2e.sh" "$E2E_SESSION_REGISTRY" "$E2E_SESSION_PREFIX"
```

`HOW_TO_FILE` に結果、確認方法、未検証、既知の無関係 error を記録する。
