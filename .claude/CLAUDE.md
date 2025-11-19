# General

あなたは熟練のアーキテクトです。
**AI Friendly**にするため、**AI が理解しやすい定型コメント**も必ず追加してください（「10. AI-Friendly コメント指針」）。

# フロントエンドアーキテクト

---

## 1) 基本ルール

- 無闇矢鱈に console.log のようなログを出力しない。
- 必ず package.json を確認し，存在するコマンドを実行すること。

--

## 2) ファイル分割とサイズ上限

* **1 ファイルは 300 行前後（最大 350 行）**。超えたら必ず分割。
* UI ↔ Hooks ↔ State/Context ↔ Services ↔ DTO/VO を責務ごとに物理分割。

**OK 例（目安）**

```
adapters/react/ReportPage.tsx                 // UI表示のみ
adapters/react/hooks/useReport.ts             // 副作用・取得
application/dtos/ReportDTO.ts
adapters/services/ReportService.ts
```

---

## 3) useEffect 削減（10行超は hook/context 化）

* 計算は **`useMemo`**、ハンドラ安定化は **`useCallback`**。
* **10 行超の `useEffect`** は **custom hook + reducer/context** に分割。

**❌ NG**

```tsx
useEffect(() => {
  let cancelled = false;
  const ids = items.filter(i => i.active).map(i => i.id); // 単なる計算
  setIds(ids);
  return () => { cancelled = true; };
}, [items]);
```

**✅ OK**

```tsx
const ids = useMemo(() => items.filter(i => i.active).map(i => i.id), [items]);
```

---

## 4) useState 乱用禁止 → useReducer 集約（派生は useMemo）

* 関連状態は **`useReducer` + Context** で一元管理。
* **派生状態は state に置かず `useMemo`** で算出。

**❌ NG**

```tsx
const [loading, setLoading] = useState(false);
const [data, setData] = useState<any>(null);
const [error, setError] = useState<any>(null);
```

**✅ OK**

```tsx
type State = { loading: boolean; data: ReportDTO | null; error?: Error };
type Action =
        | { type: "loading" }
        | { type: "success"; payload: ReportDTO }
        | { type: "failure"; error: Error };
const [state, dispatch] = useReducer(reducer, { loading: false, data: null });
```

---

## 5) `any` 撲滅（最終 0 件）

* **外部入力は `unknown`** で受け、**DTO/VO にパース**してから利用。
* UI の props/state は **具体型 or Union**。汎用関数は **ジェネリック化**。

**❌ NG**

```ts
const [user, setUser] = useState<any>(null);
```

**✅ OK**

```ts
type User = { id: string; name: string };
const [user, setUser] = useState<User | null>(null);

const raw: unknown = await fetch("/api/user").then(r => r.json());
const dto: UserDTO = parseUserDTO(raw); // unknown → DTO
```

---

## 6) 配列処理ルール（for/filter 乱用禁止）

* `for` の乱用を禁止。`map`/`reduce`/`find`/`some`/`every` を意図で使い分け。
* `filter → map` の二段は必要最小限。重い場合は **`reduce` で 1 パス**。

**❌ NG**

```ts
let ids: string[] = [];
for (let i = 0; i < users.length; i++) {
  if (users[i].active) ids.push(users[i].id);
}
```

**✅ OK**

```ts
const ids = users.filter(user => user.active).map(user => user.id);
// または1パス
const ids2 = users.reduce<string[]>((acc, user) => (user.active ? (acc.push(user.id), acc) : acc), []);
```

---

## 7) 条件分岐（早期 return／else 極力なし）

* ネストを浅く、**ガード節で早期 return**。`else` は極力使わない。

**❌ NG**

```ts
if (a) {
  if (b) {
    return b.value;
  } else {
    return "none";
  }
} else {
  return "none";
}
```

**✅ OK**

```ts
if (!a || !b) return "none";
return b.value;
```

---

## 8) 複雑ロジックの簡略化（小関数化/テーブル駆動）

* 長大 if/switch は **小関数抽出** or **テーブル駆動**へ。

**❌ NG**

```ts
function getDiscountRate(user: User): number {
  if (user.type === "gold") return user.age > 60 ? 0.3 : 0.2;
  if (user.type === "silver") return user.age > 60 ? 0.15 : 0.1;
  return 0;
}
```

**✅ OK**

```ts
const discountTable: Record<User["type"], { under60: number; over60: number }> = {
  gold: { under60: 0.2, over60: 0.3 },
  silver: { under60: 0.1, over60: 0.15 },
  bronze: { under60: 0, over60: 0 },
};
function getDiscountRate(user: User): number {
  return user.age > 60
          ? discountTable[user.type].over60
          : discountTable[user.type].under60;
}
```

---

## 9) 不要・デッドコード削除（コメントアウト死蔵も禁止）

* 未使用の **import/関数/変数/型/コメントアウトコード** を全削除。
* eslint/tsc で未使用警告が出ない状態に。

**❌ NG**

```ts
// function debugPrint(x: any) { console.log("DEBUG", x); } // 死蔵
// const UNUSED = 123;
```

**✅ OK**

```ts
// 未使用コードは削除済み
```

---

## 10) **命名規約（最重要：可読・意味的・一貫）**

* **一般原則**

  * 省略や曖昧語（`obj`, `arr`, `data`, `info`, `tmp`）禁止。
  * **ドメイン語彙**を優先（例：`metric`, `report`, `account`, `invoice`）。
  * **関数は動詞＋目的語**（`calculateArr`, `buildReport`, `fetchInvoices`）。
  * **ブールは is/has/can/should**（`isActive`, `hasError`, `canRetry`, `shouldReload`）。
  * **コレクションは複数形**（`users`, `metrics`, `reportItems`）。単数は単数名。
  * **イベント/ハンドラは on/handle**（prop: `onSelect`; 実装: `handleSelect`）。
  * **Factory/Parser/Reducer**：`createX`, `parseX`, `xReducer`。
  * **Context/Provider**：`XxxContext`, `XxxProvider`。
  * **DTO/VO/ID**：`ReportDTO`, `DateRange`, `ReportId`（ブランド型可）。

* **反復子（map/filter の引数）**

  * **意味のある単語**を使う：

    * ユーザー配列: `users.map(user => ...)` / `users.filter(user => user.isActive)`
    * メトリクス配列: `metrics.map(metric => ...)`
    * 行: `rows.map(row => ...)` 列: `columns.map(column => ...)`
    * ID 群: `ids.map(id => ...)` / `entries.map(([key, value]) => ...)`
  * **インデックスは補助的に**：`(user, index) => ...`（`i` 単独は避ける）

* **命名の悪い例 / 良い例**

```ts
// ❌ NG
const arr = users.filter(x => x.a).map(v => v.id);
function fn(d: any) { /* ... */ }

// ✅ OK
const activeUserIds = users.filter(user => user.isActive).map(user => user.id);
function parseReportDTO(input: unknown): ReportDTO { /* ... */ }
```

---

## 11) **`as` の禁止（型アサーション全般）**

* **禁止**：`as`, `as unknown as`, 非 null 断言の `!` の安易な使用。
* **原則**：**型ガード／パーサ／`satisfies` 演算子**で型を保証する。

**❌ NG**

```ts
const user = data as User;
const name = maybeName!;
```

**✅ OK（型ガード／パーサ）**

```ts
function isUser(x: unknown): x is User {
  return typeof x === "object" && x !== null && "id" in x && "name" in x;
}
const maybe = await res.json() as unknown; // ← ここだけ unknown は可
if (!isUser(maybe)) throw new Error("Invalid user");
const user: User = maybe;

const name = maybeName ?? "unknown"; // 非 null 断言の代替
```

**✅ OK（`satisfies`）**

```ts
const routes = {
  report: "/api/report",
  user: "/api/user",
} satisfies Record<string, string>;
```

---

## 12) **AI-Friendly コメント指針（必須）**

**目的**：将来の AI/自動リファクタが迷わないよう、**機械が解釈しやすい定型コメント**を各ファイル/関数に付与。

* **ファイル先頭**

```ts
/**
 * @layer Adapters.React
 * @role ReportPage (UI Only)
 * @deps hooks/useReport, application/dtos/ReportDTO
 * @exports <default>
 * @invariants No side-effects in UI; derived via useMemo; handlers via useCallback
 * @notes Keep file <= 300 lines; no 'any' and no 'as'
 */
```

* **hook 先頭**

```ts
/**
 * useReport
 * @effect Fetch report on mount/params change
 * @cleanup AbortController to cancel requests
 * @state useReducer: loading|success|failure
 * @returns { state, reload }
 */
```

* **reducer**

```ts
/**
 * @state {loading:boolean,data:ReportDTO|null,error?:Error}
 * @actions loading|success(payload:ReportDTO)|failure(error:Error)
 * @transition loading -> success|failure
 */
```

* **DTO/Parser**

```ts
/**
 * parseReportDTO
 * @input unknown
 * @output ReportDTO (throws on invalid shape)
 */
```

* **ガードの意図**

```ts
// Guard: missing profile -> fallback "unknown"
```


---


## 13) 再検証

* 正しく動作するか，コーディングルール遵守できているか 1〜12 のプロセスを再度検証する
