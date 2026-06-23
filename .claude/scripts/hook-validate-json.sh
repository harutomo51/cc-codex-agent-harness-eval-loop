#!/usr/bin/env bash
for f in $CLAUDE_FILE_PATHS; do
  case "$f" in
    *.json)
      err=$(python -m json.tool "$f" 2>&1 >/dev/null) || {
        echo "fix: file=$f rule=json-syntax expected=valid-json actual=$err" >&2
        exit 2
      }
      ;;
  esac
done
