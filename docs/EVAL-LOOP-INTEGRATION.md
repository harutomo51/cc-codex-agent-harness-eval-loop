# eval-loop Integration for cc-codex-agent-harness

このハーネスでは、`eval-loop` を **外付け同梱プラグイン** として扱います。  
ハーネス本体は CEO / AR / Agent / Gate / worktree / schema を管理し、eval-loop は個別成果物を `score >= threshold` まで改善する内側ループを担当します。

## 位置づけ

```text
ハーネス
  ├─ CEO / AR / 専門Agent / Gate
  ├─ 権限・worktree・schema・review管理
  └─ plugins/eval-loop
      ├─ 成果物ループ
      ├─ 整合性ループ
      └─ score / threshold / max による停止判定
```

## 初期インストール

このリポジトリには、以下を同梱しています。

```text
.claude-plugin/marketplace.json
plugins/eval-loop/
```

Claude Code で利用する場合は、プロジェクトルートで以下を実行します。

```bash
claude plugin marketplace add .
claude plugin install eval-loop@eval-loop --scope project
claude plugin validate plugins/eval-loop --strict
```

ワークスペース初期化も実行してください。

```bash
bash .claude/scripts/init-workspace.sh
# Windows:
# pwsh -File .claude/scripts/init-workspace.ps1
```


## Windows Git Bash 対応

この同梱版の `eval-loop` は Windows の Git Bash でも動くように、hook command、`${CLAUDE_PLUGIN_ROOT}`、`cwd`、snapshot restore のパス処理を調整済みです。詳細は [docs/EVAL-LOOP-WINDOWS-GIT-BASH.md](EVAL-LOOP-WINDOWS-GIT-BASH.md) を参照してください。

Windows では、Git Bash から `bash` / `git` / `jq` / `cygpath` が見えることを確認してください。`jq` が無い場合、hook は安全側で何もせず終了します。

## 状態管理の分離

最初は状態を分けます。

```text
.mso/
  eval-loop の実行状態、turns、state.json、snapshot
  Git 管理外

.agent-team/
  ハーネス側の公式結果、dispatch、reviews、results、gate判定

.agent-team/loops-summary/
  eval-loop 完了後の要約だけを必要に応じて保存
```

`eval-loop` の生ログをハーネスの review schema に無理に合わせないでください。必要な場合は、要約を `.agent-team/loops-summary/` に別ファイルとして出力します。

## MVP 対象

最初の対象は DBA 成果物です。

```text
DBA
  ├─ ER図 / データモデルループ
  ├─ テーブル定義ループ
  └─ ER図 ↔ テーブル定義 整合性ループ

DESIGN-EVAL
  └─ 上記ループ完了後に設計フェーズゲートとして独立評価
```

成果物ループは DESIGN-EVAL の代替ではありません。DBA が DESIGN-EVAL に出す前に成果物を磨くための前処理です。

## 推奨順序

1. DBA が `docs/database/schema-design.md` を作成する
2. `assign-dba-erd-evaluator` で ER図 / データモデル品質ループを回す
3. `assign-dba-table-evaluator` でテーブル定義品質ループを回す
4. `assign-dba-consistency-evaluator` で ER図 ↔ テーブル定義の整合性ループを回す
5. ループ結果の要約を `.agent-team/loops-summary/` に保存する
6. DESIGN-EVAL が成果物を実物確認し、次工程に進めるか判定する

## DBA ループ起動例

### ER図 / データモデル

```text
/run-eval-loop docs/database/schema-design.md の ER図・エンティティ・リレーション・多重度を要件定義と業務ルールに基づいて改善する。主要エンティティ、リレーション、多重度、ライフサイクル、未決事項を明確化する。 criteria: 要件トレーサビリティ,エンティティ抽出,リレーションと多重度,ライフサイクル,未決事項 threshold: 85 max: 3 evaluator: assign-dba-erd-evaluator
```

### テーブル定義

```text
/run-eval-loop docs/database/schema-design.md のテーブル定義を ER図、DB標準、非機能要件に基づいて改善する。PK/FK/UK、型、NULL可否、index、監査項目、削除方針を明確化する。 criteria: ER図準拠,カラム定義,制約,インデックス,監査履歴,命名規約 threshold: 85 max: 3 evaluator: assign-dba-table-evaluator
```

### ER図 ↔ テーブル定義 整合性

```text
/run-eval-loop docs/database/schema-design.md 内の ER図・エンティティ定義・テーブル定義の矛盾を検出し、必要な修正を反映する。矛盾の原因が要件にある場合は未決事項として分離する。 criteria: エンティティ対応,リレーション対応,多重度と制約,用語一貫性,削除履歴,未決事項 threshold: 90 max: 3 evaluator: assign-dba-consistency-evaluator
```

## 運用ルール

- 最初は `run-eval-loop` の serial のみ使う
- `parallel` は DBA ループで運用が安定してから使う
- 実装ファイル、`backend/`、`frontend/`、`tests/`、`.github/workflows/` を変更するループは必ず worktree 内で実行する
- `score` が伸びない場合、まず threshold や max ではなく criteria を疑う
- max 到達で不合格の場合、目標・採点軸・成果物分割のどれかを見直す
- DESIGN-EVAL は loop 結果を参考にしてよいが、必ず実物ファイルを自分で開いて評価する

## 追加された domain evaluator

```text
plugins/eval-loop/skills/assign-dba-erd-evaluator/
plugins/eval-loop/skills/assign-dba-table-evaluator/
plugins/eval-loop/skills/assign-dba-consistency-evaluator/
```

各 evaluator は固定の `breakdown_keys` を持ち、周回ごとの採点軸の揺れを抑えます。
