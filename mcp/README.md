# MCP Server

Model Context Protocol (MCP) サーバーの実装。OpenAI、Gemini、GitHub GraphQL API、Playwrightブラウザ自動化を統合したツールセットを提供します。

## 機能

- **OpenAI API**: モデル一覧取得、チャット補完
- **Gemini API**: モデル一覧取得、生成AI機能
- **GitHub GraphQL API**: リポジトリ情報取得、Issue/PR操作
- **Playwright**: ブラウザ自動化タスク

## セキュリティ機能

このプロジェクトには以下のセキュリティ機能が実装されています：

### 1. 環境変数の型安全性
Zodを使用した起動時の環境変数検証により、設定ミスを早期に検出します。

### 2. Playwrightドメインホワイトリスト
ブラウザ自動化で許可されるドメインを制限し、SSRF攻撃を防ぎます。

デフォルト許可ドメイン:
- github.com
- stackoverflow.com
- developer.mozilla.org
- npmjs.com

カスタマイズ:
```bash
export PLAYWRIGHT_ALLOWED_DOMAINS="example.com,test.com"
```

### 3. コマンド実行ホワイトリスト
実行可能なコマンドを制限します。

デフォルト許可コマンド:
- git
- node
- npm/npx/pnpm/yarn
- tsc
- eslint

カスタマイズ:
```bash
export ALLOWED_COMMANDS="git,node,npm"
```

### 4. エラーハンドリング
全てのツールで構造化エラーレスポンスを実装し、エラー時もプロセスを継続します。

## セットアップ

### 1. 依存関係のインストール

```bash
npm install
```

### 2. 環境変数の設定

プロジェクトルートに `.env` ファイルを作成:

```bash
# 必須
OPENAI_API_KEY=your_openai_api_key
GEMINI_API_KEY=your_gemini_api_key
GITHUB_TOKEN=your_github_token  # または GH_TOKEN

# オプション
NODE_ENV=development  # development | production | test

# セキュリティ設定（オプション）
PLAYWRIGHT_ALLOWED_DOMAINS="github.com,example.com"
ALLOWED_COMMANDS="git,node,npm"
```

### 3. ビルド

```bash
npm run build
```

### 4. 起動

```bash
npm start
```

## 開発

```bash
npm run dev
```

## アーキテクチャ

プロジェクトはClean Architectureに基づいて構成されています:

```
src/
├── config/           # 環境変数検証と設定
├── domain/           # ビジネスロジック
│   ├── schemas/      # Zod検証スキーマ
│   ├── services/     # ドメインサービス
│   ├── types/        # 型定義
│   └── utils/        # ユーティリティ関数
├── infrastructure/   # 外部インターフェース
│   ├── clients/      # APIクライアント（OpenAI、Gemini、GitHub）
│   └── system/       # システムユーティリティ（Git、Command、Playwright）
├── tools/            # MCPツール登録
├── index.ts          # アプリケーションエントリーポイント
└── server.ts         # MCPサーバー設定
```

### レイヤー責務

- **Application Layer** (`index.ts`, `server.ts`): サーバー起動とツール登録
- **Domain Layer** (`domain/`): ビジネスロジックと型定義
- **Infrastructure Layer** (`infrastructure/`): 外部APIとシステムとの統合

## テスト

現在のアーキテクチャはテスト可能な設計になっています:

- クライアントファクトリーは依存性注入をサポート
- 各ツールは独立してテスト可能
- 環境変数は起動時に検証

## セキュリティベストプラクティス

1. **API キーの管理**: `.env` ファイルは `.gitignore` に含め、絶対にコミットしない
2. **ドメインホワイトリスト**: 本番環境では必要最小限のドメインのみ許可
3. **コマンド制限**: 信頼できるコマンドのみホワイトリストに追加
4. **エラーログ**: 機密情報をログに含めない

## トラブルシューティング

### 環境変数エラー

```
ZodError: OPENAI_API_KEY is required
```

→ `.env` ファイルに必須の環境変数を設定してください。

### ドメインアクセス拒否

```
Security Error: Domain "example.com" is not in the allowed list
```

→ `PLAYWRIGHT_ALLOWED_DOMAINS` に許可するドメインを追加してください。

### コマンド実行拒否

```
Security Error: Command "curl" is not in the allowed list
```

→ `ALLOWED_COMMANDS` に許可するコマンドを追加してください。

## ライセンス

ISC
