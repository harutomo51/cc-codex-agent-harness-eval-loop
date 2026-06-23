# eval-loop Windows Git Bash 対応メモ

この版の `plugins/eval-loop` は、macOS / Linux 前提だった shell 実装を Windows の Git Bash でも動くように調整しています。

## 前提

Windows では、以下が Git Bash から実行できる状態にしてください。

```bash
bash --version
git --version
jq --version
cygpath --version
```

`jq` がない場合、hook は安全のため何もせず終了します。`jq` は `winget install jqlang.jq` などで入れてから、Git Bash の `PATH` で見えることを確認してください。

## 対応内容

- Claude Code hook の command を `.sh` 直接実行から `bash -lc ... exec bash <script>` 形式に変更
- `${CLAUDE_PLUGIN_ROOT}` や hook 入力の `cwd` が `C:\Users\...` / `C:/Users/...` 形式でも `cygpath -u` で POSIX パスへ変換
- `.mso/sessions` / `.mso/agents` / snapshot の `project_dir` / `state_file` を Git Bash 形式に正規化
- `mktemp` / `stat` を Git Bash, Linux, macOS の順で扱える helper に集約
- `write_targets` に Windows 区切りのパスが入っても、snapshot restore 時に `/` 区切りへ正規化
- `CLAUDE_PLUGIN_ROOT` を参照する skill 内 bash 例を、スペース入りパスでも壊れにくい引用付きに変更

## 変更された主なファイル

```text
plugins/eval-loop/hooks/hooks.json
plugins/eval-loop/scripts/git-bash-compat.sh
plugins/eval-loop/scripts/hook-prompt-submit.sh
plugins/eval-loop/scripts/hook-stop.sh
plugins/eval-loop/scripts/hook-subagent-start.sh
plugins/eval-loop/scripts/hook-subagent-stop.sh
plugins/eval-loop/scripts/loop-start.sh
plugins/eval-loop/scripts/loop-control.sh
plugins/eval-loop/scripts/loop-cancel.sh
plugins/eval-loop/scripts/loop-snapshot.sh
plugins/eval-loop/skills/*/SKILL.md
plugins/eval-loop/skills/assign-debate-evaluator/scripts/codex-debate-eval.sh
```

## Git Bash での確認コマンド

プロジェクトルートで実行します。

```bash
claude plugin marketplace add .
claude plugin install eval-loop@eval-loop --scope project
claude plugin validate plugins/eval-loop --strict
```

Claude CLI がない環境でも、最低限の shell 構文と JSON は確認できます。

```bash
find plugins/eval-loop/scripts plugins/eval-loop/skills -name '*.sh' -type f -print0 \
  | xargs -0 -n1 bash -n

find plugins/eval-loop -name '*.json' -type f -print0 \
  | xargs -0 -n1 jq empty
```

## 使い方の注意

Git Bash から起動してください。PowerShell から直接 `.sh` を実行する運用は対象外です。PowerShell で作業する場合も、Claude Code の hook / skill の bash 実行部分は Git Bash 経由にしてください。

実装ファイルを変更する eval-loop は、従来どおりハーネスの worktree 制約に従って、対象 worktree 内で実行してください。
