# Database Design Loop Criteria

DBA 成果物を eval-loop で改善するための採点基準です。  
このドキュメントは、`database-specialist`、`design-evaluator`、および `assign-dba-*` evaluator が共通参照する物差しです。

## 原則

- 個別品質は成果物ループで磨く
- 成果物間の矛盾は整合性ループで検出する
- 次工程に進めるかは DESIGN-EVAL がフェーズゲートとして判断する
- 採点者は作成者の報告ではなく、実ファイルを自分で開いて評価する
- 計画への忠実度より、要件・業務ルール・設計原則への絶対適合を優先する

## 1. ER図 / データモデルループ

対象:

```text
docs/database/schema-design.md
```

見るもの:

- 要件定義から必要な業務概念が抽出されているか
- エンティティの粒度が業務ライフサイクルと一致しているか
- リレーション、多重度、所有関係が明確か
- 業務用語とエンティティ名が一致しているか
- 未決事項と決定事項が分離されているか

採点軸:

| Key | 日本語名 | Weight | 合格目安 |
|-----|----------|--------|----------|
| `requirements_traceability` | 要件トレーサビリティ | 25 | 主要要件からエンティティ・関係への対応が説明できる |
| `entity_modeling` | エンティティ抽出の妥当性 | 25 | 業務概念、集約、ライフサイクルが不自然に混在していない |
| `relationship_cardinality` | リレーションと多重度 | 25 | 1:1 / 1:N / N:M と中間概念が明確 |
| `business_lifecycle` | 削除・履歴・状態遷移 | 15 | 状態、履歴、削除方針が業務ルールと矛盾しない |
| `open_questions` | 未決事項の分離 | 10 | 決めきれない論点が本文に紛れず分離されている |

## 2. テーブル定義ループ

対象:

```text
docs/database/schema-design.md
docs/database/index-strategy.md
docs/database/migration-strategy.md
```

見るもの:

- ER図のエンティティがテーブルへ過不足なく対応しているか
- カラム型、桁数、NULL可否、DEFAULT、制約が妥当か
- PK/FK/UK/CHECK が明確か
- 検索・JOIN・ソートに必要な index が定義されているか
- 監査項目、履歴、削除、移行方針が実装可能な粒度か

採点軸:

| Key | 日本語名 | Weight | 合格目安 |
|-----|----------|--------|----------|
| `erd_alignment` | ER図準拠 | 20 | ER図の概念・関係がテーブル、FK、中間テーブルに反映されている |
| `column_definition` | カラム定義 | 25 | 型、桁、NULL、DEFAULT、説明が用途に合う |
| `constraints_integrity` | 制約と整合性 | 20 | PK/FK/UK/CHECK、参照整合性、削除方針が明確 |
| `index_performance` | インデックス・性能 | 15 | 主要クエリパターンに対する index 方針がある |
| `operation_migration` | 監査・履歴・移行 | 10 | created/updated/deleted、履歴、migration、rollback が考慮されている |
| `naming_standards` | 命名規約 | 10 | テーブル・カラム・制約・index の命名が一貫している |

## 3. ER図 ↔ テーブル定義 整合性ループ

対象:

```text
docs/database/schema-design.md
docs/database/index-strategy.md
docs/database/migration-strategy.md
```

見るもの:

- エンティティとテーブルが対応しているか
- リレーションと FK / 中間テーブルが対応しているか
- 多重度と NOT NULL / UNIQUE / FK 制約が矛盾していないか
- 命名・用語がぶれていないか
- 削除・履歴・状態遷移の扱いが成果物間で矛盾していないか

採点軸:

| Key | 日本語名 | Weight | 合格目安 |
|-----|----------|--------|----------|
| `entity_table_mapping` | エンティティとテーブル対応 | 25 | 全エンティティと全テーブルの対応が説明できる |
| `relationship_fk_mapping` | リレーションとFK対応 | 25 | ER上の関係が FK / UK / 中間テーブルに落ちている |
| `cardinality_constraints` | 多重度と制約 | 20 | 多重度と NOT NULL / UNIQUE / FK が矛盾しない |
| `terminology_consistency` | 命名・用語一貫性 | 10 | 業務用語、ER名、テーブル名、カラム名が対応する |
| `lifecycle_consistency` | 削除・履歴・状態遷移整合性 | 10 | 削除方式、履歴保持、状態遷移が成果物間で一致している |
| `issue_routing` | 差し戻し先の明確性 | 10 | 問題が ER / テーブル / 要件 / 未決事項のどこに属するか明確 |

## ループ完了後の summary 形式

`.agent-team/loops-summary/DBA-<task-id>.md` に以下を残します。

```markdown
# Loop Summary: DBA-<task-id>

## Target
- ER図 / テーブル定義 / 整合性

## Result
- Status: PASSED | MAX_REACHED | CANCELLED
- Best score: NN
- Threshold: NN
- Iterations: N

## Main Improvements
- ...

## Remaining Risks
- ...

## Artifacts
- docs/database/schema-design.md
- docs/database/index-strategy.md
- docs/database/migration-strategy.md
- .mso/sessions/<session_id>/turns/...
```
