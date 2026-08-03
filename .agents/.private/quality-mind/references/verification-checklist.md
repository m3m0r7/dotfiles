# Verification Checklist

変更リスクに関係する項目だけを選ぶ。
全項目を機械的に test へ移さない。

## Normal

- 現実的な入力と既存データで主要な成功経路が通る。
- DB 更新、通知、event、cache など期待する副作用が一度だけ起きる。
- 入力、状態、権限の組み合わせが複数ある場合は代表例を分ける。

## Boundaries

- 数値: `min - 1`、`min`、`max`、`max + 1`、0、負数、小数、巨大値、丸め。
- 文字列: 空、空白、最大長、改行、絵文字、結合文字、正規化差、制御文字。
- 日時: 月末、年末、うるう年、期限ちょうど、timezone、DST、未来、過去。
- collection: 0 件、1 件、上限、重複、順序、pagination 境界。
- file: 0 byte、上限超過、MIME 不一致、破損、同名。
- text input: IME composing、focus 喪失、再レンダリング。

## Out-of-domain and malicious input

- 単位、通貨、日付順、状態遷移など、保存してはいけない値を境界で拒否する。
- ID、tenant、role、所有者、金額、時刻を client 入力から信用しない。
- 対象に応じて injection、XSS、CSRF、SSRF、path traversal、open redirect、IDOR、過大 payload を確認する。
- 二重送信、並列 request、複数 tab、reload、途中失敗で不整合を残さない。
- error response と log に secret、個人情報、内部情報を出さない。

## State consistency

- transaction、idempotency、unique、foreign key、監査 log の要否を決める。
- UI、API response、DB record、履歴、集計、cache の値を突合する。
- cookie と web storage の期限、scope、logout 後の消去を確認する。
- 外部 API の成功後に内部保存が失敗するなど、部分失敗を扱う。

## Regression

- 呼び出し元、共有 component、型、schema、API、既存データへの影響を検索する。
- 近い既存 test を拡張し、同じ意図の重複 test を増やさない。
- 時刻、乱数、外部 service、既存 DB 状態を固定し、flaky な test を避ける。
