# DBA eval-loop Prompt Examples

## ER図 / データモデル

```text
/run-eval-loop docs/database/schema-design.md の ER図・エンティティ・リレーション・多重度を要件定義と業務ルールに基づいて改善する。主要エンティティ、リレーション、多重度、ライフサイクル、未決事項を明確化する。成果物は docs/database/schema-design.md に反映し、変更理由を同ファイル内の Design Notes に追記する。 criteria: 要件トレーサビリティ,エンティティ抽出,リレーションと多重度,ライフサイクル,未決事項 threshold: 85 max: 3 evaluator: assign-dba-erd-evaluator
```

## テーブル定義

```text
/run-eval-loop docs/database/schema-design.md のテーブル定義を ER図、DB標準、非機能要件に基づいて改善する。PK/FK/UK、型、NULL可否、index、監査項目、削除方針、migration上の注意点を明確化する。成果物は docs/database/schema-design.md と docs/database/index-strategy.md に反映する。 criteria: ER図準拠,カラム定義,制約,インデックス,監査履歴,命名規約 threshold: 85 max: 3 evaluator: assign-dba-table-evaluator
```

## ER図 ↔ テーブル定義 整合性

```text
/run-eval-loop docs/database/schema-design.md、docs/database/index-strategy.md、docs/database/migration-strategy.md を対象に、ER図・エンティティ定義・テーブル定義・index・migration方針の矛盾を検出し、必要な修正を反映する。矛盾の原因が要件にある場合は docs/database/schema-design.md の Open Questions に分離する。 criteria: エンティティ対応,リレーション対応,多重度と制約,用語一貫性,削除履歴,未決事項 threshold: 90 max: 3 evaluator: assign-dba-consistency-evaluator
```
