foreach ($f in ($env:CLAUDE_FILE_PATHS -split '\s+' | Where-Object { $_ })) {
    if ($f -match '[/\\]\.agent-team[/\\]reviews[/\\][^/\\]+\.json$') {
        $err = python -c "import json,sys; s=json.load(open('.claude/shared/review-findings.schema.json')); d=json.load(open(sys.argv[1])); import jsonschema; jsonschema.validate(d,s)" $f 2>&1
        if ($LASTEXITCODE -ne 0) {
            [Console]::Error.WriteLine("fix: file=$f rule=review-findings.schema expected=conform actual=$err")
            exit 2
        }
    }
}
