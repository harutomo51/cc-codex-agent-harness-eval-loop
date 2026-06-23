#!/usr/bin/env bash
# init-workspace.sh — プロジェクトワークスペースを冪等に初期化する
set -euo pipefail

mkdir -p .agent-team/{dispatch,results,tasks,reviews,reports,knowledge/graph,routing,loops-summary}
mkdir -p docs/{requirements,architecture,design,design/wireframes,database,adr,api,quality,operations,loop-criteria,loop-prompts}

# .gitkeep で構造をgit管理下に置く
find .agent-team docs -type d | while read -r dir; do
  touch "$dir/.gitkeep"
done

# Hook 依存ツールの確認・インストール
command -v markdownlint >/dev/null 2>&1 || npm install -g markdownlint-cli
python -c "import jsonschema" 2>/dev/null || uv pip install jsonschema

echo "Workspace initialized."
