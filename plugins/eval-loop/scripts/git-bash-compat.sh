#!/usr/bin/env bash
# git-bash-compat.sh — Windows Git Bash / MSYS2 compatibility helpers for eval-loop.
# This file is intentionally POSIX-ish bash and has no side effects when sourced.

# Return 0 when a path looks like a Windows drive/UNC path.
eval_loop_is_windows_path() {
  case "${1:-}" in
    [A-Za-z]:\\*|[A-Za-z]:/*|\\\\*|//*) return 0 ;;
    *) return 1 ;;
  esac
}

# Convert Windows paths (C:\foo, C:/foo, \\server\share) to Git Bash POSIX paths.
# Non-Windows paths are returned unchanged. If cygpath is unavailable or conversion
# fails, this function falls back to a conservative slash-normalization.
eval_loop_posix_path() {
  local p="${1:-}"
  [ -n "$p" ] || { printf '%s\n' "$p"; return 0; }
  if command -v cygpath >/dev/null 2>&1 && eval_loop_is_windows_path "$p"; then
    cygpath -u "$p" 2>/dev/null && return 0
  fi
  # Safe fallback for C:\foo style strings. It is intentionally simple; cygpath is
  # preferred on real Git Bash installations.
  p="${p//\\//}"
  printf '%s\n' "$p"
}

# Convert a directory path to an absolute POSIX path when possible.
eval_loop_abs_dir() {
  local p
  p="$(eval_loop_posix_path "${1:-.}")"
  if [ -d "$p" ]; then
    (cd "$p" 2>/dev/null && pwd -P) || printf '%s\n' "$p"
  else
    printf '%s\n' "$p"
  fi
}

# Portable mtime: GNU stat first (Linux/Git Bash), BSD stat second (macOS).
eval_loop_mtime() {
  stat -c %Y "$1" 2>/dev/null || stat -f %m "$1" 2>/dev/null
}

# Create a temporary file. Git Bash supports mktemp -t; some environments prefer
# TMPDIR. This wrapper keeps callers simple and avoids /tmp assumptions.
eval_loop_mktemp() {
  mktemp -t "${1:-eval-loop}.XXXXXX" 2>/dev/null || mktemp 2>/dev/null
}

# Quote a path for copy-paste shell hints.
eval_loop_shell_quote() {
  printf '%q' "$1"
}
