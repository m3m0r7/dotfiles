# `STATE.md` template

このテンプレートは `.hermes-prj-states/STATE.md` を新規作成するときの雛形。
更新時は全文を見直し、現時点の状態に書き換える。
履歴ログにはしない。日付見出しや task ごとの追記は書かない。
薄い初稿で止めず、少なくとも 3 回は読み返して掘り下げる。

## Scope

- Repository:
- Primary product or deliverable:
- Last reviewed on:
- Reviewed areas:
- Unknown areas not inspected yet:

## Tooling and Workspace

- Languages and versions:
- Package managers and workspaces:
- Runtime entry commands:
- Linters / formatters:
- Test frameworks:
- CI providers:
- Build tools:

## Repository Topology

- Main apps / packages / services:
- Shared libraries / common layers:
- Main entry points:
- Configuration roots:
- Generated code / fixtures / vendor areas:

## Execution Model

- Primary request or event flows:
- Persistence / state boundaries:
- External services / APIs:
- Background jobs / async paths:
- Startup / bootstrapping path:

## Module Boundaries

- Stable seams that are safe to change:
- Modules with broad fan-out:
- Areas with mixed responsibilities:
- Dependency direction / layering:
- Parts that will likely resist a small diff:

## Test Surface

- Strong unit-test areas:
- Strong integration / E2E areas:
- Weak or missing coverage:
- Fastest trustworthy feedback loops:
- Risky paths that deserve tests before refactors:

## Complexity and Risks

### Security

- Current strengths:
- Current risks:

### Performance

- Current strengths:
- Current risks:

### Boundaries and Cohesion

- Clear module boundaries:
- Mixed responsibilities:
- Areas likely to resist small changes:

### Debuggability and Operations

- Logging / observability strengths:
- Blind spots during failures:
- Operational dependencies that make verification harder:

## Change Guidance

- Safe change zones and why:
- Files or modules that need extra care:
- Signals that a small fix is becoming a refactor:
- Facts that must be re-validated before merge:
