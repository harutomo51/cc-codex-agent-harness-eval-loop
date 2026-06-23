# cc-codex-agent-harness

Claude Code × Codex によるマルチエージェント開発基盤。

22の専門エージェントが連携し、要件定義（REQ）→設計→実装→品質統括（QA）のサイクルを自動化します。実装フェーズは Codex（FE / BE / INFRA / CICD / SRE）に委任します。

## 概要

- **性質**: Claude Code Agent Team のスキル定義・運用基盤（コード開発プロジェクトではない）
- **主要ファイル形式**: Markdown（エージェント定義）、JSON（スキーマ、タスク）
- **エージェント定義**: `.claude/agents/`（22エージェント）

## アーキテクチャ

```
Human → CEO → AR → REQ（要件定義 / Gate 0）
                 ↓
         設計エージェント群（ARCH / TL / UIUX / DBA / PM / SRE）
                 ↓
         実装エージェント
           ├─ FE / INFRA / CICD / SRE → codex:codex-rescue（worktree 分離）
           └─ BE                      → codex:codex-rescue（worktree 分離）
                 ↓
         レビューエージェント（REV / SEC / TEST）→ QA（品質統括 / Quality Gate）
                 ↓ 承認
         人間が gh pr merge
```

FE / BE / INFRA / CICD / SRE は `codex:codex-rescue`（worktree 分離）に実装を委任します。TEST は `tests/` に直接書き込みます。

## エージェント構成

| エージェント | 略称 | 役割 |
|------------|------|------|
| **ceo** | CEO | 統括者・人間との唯一の窓口 |
| **agent-router** | AR | 専門エージェントへのルーティング・実行計画策定 |
| **knowledge-manager** | KM | 知識・コンテキスト管理 |
| **context-graph** | CG | 依存関係グラフ・変更影響分析 |
| **architect-evaluator** | ARCH-EVAL | Gate 1: アーキテクチャ評価 |
| **design-evaluator** | DESIGN-EVAL | Gate 2: デザイン評価 |
| requirements-analyst | REQ | 要件定義・PRD・受入基準（Phase 0） |
| architect | ARCH | システム構造設計 |
| tech-lead | TL | 技術スタック選定・規約策定 |
| ui-ux-designer | UIUX | UI/UX設計 |
| database-specialist | DBA | DB設計・スキーマ |
| project-manager | PM | タスク管理・WBS |
| frontend-expert | FE | UI実装（Codex 経由） |
| backend-expert | BE | API実装（codex:codex-rescue 経由） |
| infra-expert | INFRA | インフラ構築（Codex 経由） |
| cicd-engineer | CICD | CI/CDパイプライン（Codex 経由） |
| sre-expert | SRE | SLO・可観測性・運用設計・ロールバック（Codex 経由） |
| security-expert | SEC | セキュリティレビュー |
| reviewer | REV | コードレビュー |
| tester | TEST | テスト |
| qa-lead | QA | 品質統括・受入判定（Phase 3） |
| document-writer | DOC | ドキュメント整備 |

詳細は [docs/agents.md](docs/agents.md) を参照。



## eval-loop 同梱

この版では、品質スコアが目標に達するまで成果物を改善する `eval-loop` プラグインを外付け同梱しています。

```bash
claude plugin marketplace add .
claude plugin install eval-loop@eval-loop --scope project
claude plugin validate plugins/eval-loop --strict
```

最初のMVP対象は DBA 成果物です。

- ER図 / データモデル: `assign-dba-erd-evaluator`
- テーブル定義: `assign-dba-table-evaluator`
- ER図 ↔ テーブル定義 整合性: `assign-dba-consistency-evaluator`

詳細は [docs/EVAL-LOOP-INTEGRATION.md](docs/EVAL-LOOP-INTEGRATION.md)、[docs/EVAL-LOOP-WINDOWS-GIT-BASH.md](docs/EVAL-LOOP-WINDOWS-GIT-BASH.md)、[docs/loop-criteria/design-database.md](docs/loop-criteria/design-database.md) を参照してください。

## 使い方

開発タスクは **CEO エージェント** に委任してください。

```
CEO -> AR -> 専門エージェント群
```

詳細なオペレーションシーケンスは [OPERATION-SEQUENCE.md](docs/OPERATION-SEQUENCE.md) を参照。

## ワークスペース初期化

初回利用前（または新規クローン後）にワークスペースを初期化してください。
セッション開始時にも自動実行されます。

- Windows: `pwsh -File .claude/scripts/init-workspace.ps1`
- Linux / macOS: `bash .claude/scripts/init-workspace.sh`

## 環境

- OS: Windows 11 / シェル: bash (Git Bash) または PowerShell
- Python: 3.11+（検証スクリプト用）/ 依存管理: `uv`
- Hook 依存: `jsonschema`, `markdownlint-cli`
- eval-loop on Windows Git Bash: `bash`, `git`, `jq`, `cygpath`

## ライセンス

[MIT](LICENSE)
