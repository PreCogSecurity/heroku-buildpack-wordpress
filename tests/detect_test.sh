#!/usr/bin/env bash
# Tests for bin/detect.
#
# bin/detect must exit 0 and print "WordPress" when the build directory
# contains config/public/wp-config.php, and exit non-zero otherwise.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# 1. Non-WordPress app: detect must fail.
mkdir -p "$tmp/app/config/public"
if "$root/bin/detect" "$tmp/app" >/dev/null 2>&1; then
  echo "FAIL: detect should exit non-zero when wp-config.php is missing" >&2
  exit 1
fi

# 2. WordPress app: detect must succeed and print the framework name.
touch "$tmp/app/config/public/wp-config.php"
out="$("$root/bin/detect" "$tmp/app")"
if [ "$out" != "WordPress" ]; then
  echo "FAIL: expected 'WordPress', got '$out'" >&2
  exit 1
fi

# 3. Missing build dir argument: detect must fail cleanly.
if "$root/bin/detect" >/dev/null 2>&1; then
  echo "FAIL: detect should exit non-zero without a build dir argument" >&2
  exit 1
fi

echo "detect tests passed"
