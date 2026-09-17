#!/usr/bin/env bash
# Buildpack test suite entrypoint.
#
# Usage: ./test.sh   (or: bash test.sh)
#
# Runs every tests/*_test.sh file and exits non-zero if any of them
# fail, so it can be wired straight into CI.
set -euo pipefail

root="$(cd "$(dirname "$0")" && pwd)"
failures=0

for test_file in "$root"/tests/*_test.sh; do
  name="$(basename "$test_file")"
  echo "==> Running $name"
  if bash "$test_file"; then
    echo "    PASS"
  else
    echo "    FAIL"
    failures=$((failures + 1))
  fi
done

if [ "$failures" -ne 0 ]; then
  echo "FAILED: $failures test file(s)"
  exit 1
fi

echo "All tests passed."
