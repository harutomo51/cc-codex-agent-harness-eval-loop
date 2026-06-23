foreach ($f in ($env:CLAUDE_FILE_PATHS -split '\s+' | Where-Object { $_ })) {
    if ($f -match '\.json$') {
        $err = python -m json.tool $f 2>&1 1>$null
        if ($LASTEXITCODE -ne 0) {
            [Console]::Error.WriteLine("fix: file=$f rule=json-syntax expected=valid-json actual=$err")
            exit 2
        }
    }
}
