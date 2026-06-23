# init-workspace.ps1 — プロジェクトワークスペースを冪等に初期化する

$dirs = @(
    ".agent-team\dispatch",
    ".agent-team\results",
    ".agent-team\tasks",
    ".agent-team\reviews",
    ".agent-team\reports",
    ".agent-team\knowledge\graph",
    ".agent-team\routing",
    ".agent-team\loops-summary",
    "docs\requirements",
    "docs\architecture",
    "docs\design",
    "docs\design\wireframes",
    "docs\database",
    "docs\adr",
    "docs\api",
    "docs\quality",
    "docs\operations",
    "docs\loop-criteria",
    "docs\loop-prompts"
)

foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    # .gitkeep で構造を git 管理下に置く
    $gitkeep = Join-Path $dir ".gitkeep"
    if (-not (Test-Path $gitkeep)) {
        New-Item -ItemType File -Path $gitkeep | Out-Null
    }
}

# Hook 依存ツールの確認・インストール
if (-not (Get-Command markdownlint -ErrorAction SilentlyContinue)) {
    npm install -g markdownlint-cli
}
try {
    python -c "import jsonschema" 2>$null
} catch {
    uv pip install jsonschema
}

Write-Host "Workspace initialized."
