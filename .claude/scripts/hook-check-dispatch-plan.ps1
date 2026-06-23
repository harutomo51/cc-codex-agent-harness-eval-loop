# SubagentStop フック: 専門エージェントが AR 経由で起動されたか確認する
# AR (agent-router) を経由せずに直接呼ばれた場合は警告を出す（ブロックはしない）
param()

$subagentName = $env:CLAUDE_SUBAGENT_NAME

# 名前が取れない場合はスキップ
if (-not $subagentName) { exit 0 }

# AR 経由が不要なエージェント（直呼び許可）
$allowedDirect = @('ceo', 'knowledge-manager', 'context-graph', 'architect-evaluator', 'design-evaluator', 'reviewer', 'agent-router')
if ($allowedDirect -contains $subagentName) { exit 0 }

# 専門エージェントの場合、dispatch plan の存在を確認
$planExists = (Get-Item ".agent-team\routing\PLAN-*.md" -ErrorAction SilentlyContinue) -or `
              (Get-Item ".agent-team\dispatch\DISPATCH-*.md" -ErrorAction SilentlyContinue)

if ($planExists) { exit 0 }

Write-Error @"
⚠️  hook-check-dispatch-plan: 専門エージェント '$subagentName' が AR (agent-router) 経由なしに起動された可能性があります。
   .agent-team\routing\PLAN-*.md または .agent-team\dispatch\DISPATCH-*.md が見つかりません。
   CLAUDE.md の「エージェントの使い方」を確認してください:
     - 開発タスクは CEO -> AR -> 専門エージェントの経路で実行する
     - reviewer のみ条件付きで直呼び可（docs/agents.md 末尾参照）
"@

exit 0
