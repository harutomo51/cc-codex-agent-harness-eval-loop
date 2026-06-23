# エージェント一覧

## 全エージェント

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
| backend-expert | BE | API実装（Codex 経由） |
| infra-expert | INFRA | インフラ構築（Codex 経由） |
| cicd-engineer | CICD | CI/CDパイプライン（Codex 経由） |
| sre-expert | SRE | SLO・可観測性・運用設計・ロールバック（Phase 1.5設計 + Phase 2監視設定） |
| security-expert | SEC | セキュリティ |
| reviewer | REV | コードレビュー |
| tester | TEST | テスト |
| qa-lead | QA | 品質統括・受入判定（Phase 1.6テスト戦略 + Phase 3品質統括） |
| document-writer | DOC | ドキュメント整備 |

## ディスパッチ経路

```
Human → CEO
  ├─ CEO が直接ディスパッチ: AR / KM / CG / ARCH-EVAL / DESIGN-EVAL
  └─ AR 経由でディスパッチ: REQ / ARCH / TL / UIUX / DBA / PM / FE / BE / INFRA / CICD / SRE / SEC / REV / TEST / QA / DOC
```

## フェーズ別の主要ディスパッチ

| Phase | 主要Agent | ゲート |
|-------|----------|--------|
| Phase 0 要件定義 | REQ | Gate 0: CEO要件確認 |
| Phase 1 アーキテクチャ | ARCH → TL | Gate 1: ARCH-EVAL |
| Phase 1.5 設計 | UIUX / DBA / DOC / INFRA / CICD / SRE | — |
| Phase 1.6 設計品質事前チェック | SEC / TEST / QA | — |
| Phase 1.7 知識同期 | KM → CG | Gate 2: DESIGN-EVAL |
| Phase 1.9 計画 | PM → DOC | — |
| Phase 2 実装 | DBA → BE / FE / SRE | — |
| Phase 3 品質 | REV / SEC / TEST → QA | Quality Gate: QA統括 |
| Phase 4 ドキュメント | DOC | — |

## CEO を経由しない直呼び条件

次の**すべて**を満たす場合のみ `reviewer` を直呼びしてよい:

- 対象が 1 ファイル以内
- lint / タイポ / フォーマット修正のみ（仕様変更を伴わない）
- 他エージェントの成果物への影響がない

それ以外は必ず CEO 経由。迷ったら CEO。
