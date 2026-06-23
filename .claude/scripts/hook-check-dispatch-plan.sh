#!/usr/bin/env bash
# SubagentStop フック: 専門エージェントが AR 経由で起動されたか確認する
# AR (agent-router) を経由せずに直接呼ばれた場合は警告を出す（ブロックはしない）

set -u

# サブエージェント名を環境変数から取得
SUBAGENT_NAME="${CLAUDE_SUBAGENT_NAME:-}"

# 名前が取れない場合はスキップ
[ -z "$SUBAGENT_NAME" ] && exit 0

# AR 経由が不要なエージェント（直呼び許可）
case "$SUBAGENT_NAME" in
  ceo|knowledge-manager|context-graph|architect-evaluator|design-evaluator|reviewer|agent-router)
    exit 0
    ;;
esac

# 専門エージェントの場合、dispatch plan の存在を確認
if ls .agent-team/routing/PLAN-*.md 2>/dev/null | grep -q . || \
   ls .agent-team/dispatch/DISPATCH-*.md 2>/dev/null | grep -q .; then
  exit 0
fi

cat 1>&2 <<EOF
⚠️  hook-check-dispatch-plan: 専門エージェント '$SUBAGENT_NAME' が AR (agent-router) 経由なしに起動された可能性があります。
   .agent-team/routing/PLAN-*.md または .agent-team/dispatch/DISPATCH-*.md が見つかりません。
   CLAUDE.md の「エージェントの使い方」を確認してください:
     - 開発タスクは CEO → AR → 専門エージェントの経路で実行する
     - reviewer のみ条件付きで直呼び可（docs/agents.md 末尾参照）
EOF

exit 0
