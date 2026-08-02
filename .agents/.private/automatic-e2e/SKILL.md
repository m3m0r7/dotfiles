---
name: automatic-e2e
description: Web アプリの E2E テストを、既存コードとテストから実行経路を先に組み立て、headless browser で検証し、UI と API・DB・storage の整合性およびログを確認して証跡を残す。認証が必要な導線、フォーム、バリデーション、リグレッション、リリース前確認に使う。コード調査や unit・integration test だけで完結する依頼には使わない。
---

# Automatic E2E

既存コードから URL、locator、待機条件、期待状態を先に確定し、ブラウザ上で必要な事実だけを確認する。

## 実行原則

- グローバルの `agent-browser` を headless で使う。
- 最初に `scripts/init-e2e.sh` を実行する。CLI の互換性と headless 起動が通らない場合は、ブラウザ操作へ進まない。
- `agent-browser skills get core` を実行し、インストール済み CLI と一致する core workflow を最後まで読む。
- ブラウザ操作は `scripts/ab.sh` 経由に限定する。
- 一つの実利用導線は画面遷移を最初から通す。反復する境界値や異常系は直接 URL を使ってよい。
- 所有する名前付き session だけを使い、終了時は `scripts/finish-e2e.sh` でその session だけを閉じる。
- 本番、staging、共有 DB は明示指示がない限り read-only とする。対象環境を判別できない場合は本番として扱う。

## 1. 初期化

skill directory を基準に、次を実行する。

```bash
eval "$(bash scripts/init-e2e.sh | grep '^export ')"
agent-browser skills get core
```

初期化で次の変数が export される。

- `HOW_TO_FILE`: テスト計画と実行マップ
- `EVIDENCE_DIR`: 今回の run 専用の証跡 directory
- `E2E_SESSION_PREFIX`: 所有 session 名の prefix
- `E2E_SESSION_REGISTRY`: 今回起動した session の記録先

認証情報が必要な場合は、リポジトリの `AGENTS.md` と docs に定められた場所を確認する。
`HOW_TO_FILE` には secret を書かず、auth vault、profile、session、環境変数など認証手段の名前と所在だけを記録する。
認証手段を確保できない場合は、ブラウザ操作前にユーザーへ確認する。

## 2. コードから実行マップを作る

ブラウザを起動する前に、対象リポジトリで次を確認する。

1. `AGENTS.md`、仕様、起動手順、base URL、認証手順を読む。
2. route 定義から開始 URL と遷移先 URL を特定する。
3. 対象 page、component、form、validation schema を読む。
4. 既存 E2E、integration test、fixture、seed、factory を読む。
5. label、role、`data-testid`、安定した name 属性を収集する。
6. API request と response、永続化先、期待する状態変更を特定する。
7. 各 scenario の開始 URL、操作列、待機条件、期待結果、証跡名を `HOW_TO_FILE` に記録する。

locator は label・role、`data-testid`、安定した属性、CSS selector の順で選ぶ。
生成 class、表示順、翻訳で変わる文言へ依存しない。

## 3. テスト範囲を決める

`quality-mind` の正常系、境界値、ドメイン外値、悪意ある異常系、状態整合性、リグレッションから、変更リスクに対応する scenario を選ぶ。
すべてを E2E へ移さず、純粋な validation は unit、API・DB 境界は integration、実利用導線と client state は E2E で確認する。

i18n がある場合も全 scenario を全言語で重複実行しない。
主要な正常導線は日本語と既定の別言語で通し、言語依存の文言、layout、validation message だけを追加確認する。
認可や DB 制約など言語に依存しない scenario は一言語でよい。

複数 scenario の並列化は、認証状態とテストデータを分離でき、起動コストを上回る効果がある場合だけ行う。

## 4. ブラウザで実行する

session 名には初期化で得た prefix を使う。

```bash
bash scripts/ab.sh --session "${E2E_SESSION_PREFIX}-normal" open "$TARGET_URL"
```

- コードから操作列を確定できる場合は、インストール済み CLI の batch 機能で一回の CLI 呼び出しへまとめる。
- snapshot は、初見の runtime DOM、コードと異なる表示、曖昧な locator、視覚確認が必要な状態で使う。
- DOM 変更後も次の locator と期待状態が既知なら、再 snapshot せず具体的な URL、要素、文言、JavaScript 条件を待つ。
- `open` 後の重複 wait と固定時間 wait を避ける。固定時間は、観測可能な完了条件がない場合の最終手段とする。
- destructive な送信や外部副作用を batch の判断境界越しに置かない。実行前に対象、環境、期待される副作用を確定する。

## 5. scenario 単位で診断する

各 click や fill の直後に診断コマンドを挟まない。

1. scenario 開始前に browser errors、console、Docker logs の基準位置を決める。
2. 操作列を実行する。
3. scenario 終了時に `agent-browser errors`、`agent-browser console`、関連する server・container logs の差分を確認する。
4. 失敗した場合だけ、失敗操作の直後へ診断を細分化して再現する。

関係する error が残っている scenario を pass にしない。

## 6. 表示と実体を突合する

操作後は、確認可能な範囲で次を突合する。

- UI の表示値と状態
- API response の status、body、必要な headers
- DB の対象 record、関連 record、履歴、集計、監査情報
- cookie、localStorage、sessionStorage

件数だけでなく対象データの中身を確認する。
テスト都合の認証 bypass や本番相当の防御を弱める設定は追加しない。

## 7. 証跡を残す

正常系の到達結果、重要な異常系、状態整合性、リグレッションについて、対象箇所が写る screenshot を `EVIDENCE_DIR` に保存する。
途中操作を機械的に全件撮影せず、scenario の成否を判定できる状態を残す。
ファイル名には scenario ID、言語、結果を含める。

再試行は新しい run directory に保存されるため、過去の証跡を削除しない。

## 8. 後始末

完了時と中断時に必ず実行する。

```bash
bash scripts/finish-e2e.sh "$E2E_SESSION_REGISTRY"
```

`HOW_TO_FILE` へ実行結果、確認方法、未検証事項、既知の無関係 error を記録する。
