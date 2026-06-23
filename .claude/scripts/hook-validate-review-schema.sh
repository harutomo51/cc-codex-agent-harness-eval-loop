#!/usr/bin/env bash
for f in $CLAUDE_FILE_PATHS; do
  case "$f" in
    .agent-team/reviews/*.json)
      err=$(python -c "import json,sys; s=json.load(open('.claude/shared/review-findings.schema.json')); d=json.load(open(sys.argv[1])); import jsonschema; jsonschema.validate(d,s)" "$f" 2>&1) || {
        echo "fix: file=$f rule=review-findings.schema expected=conform actual=$err" >&2
        exit 2
      }
      ;;
  esac
done
