#!/usr/bin/env bash
# Tests for bin/release.
#
# bin/release emits the YAML manifest Heroku uses to provision addons,
# config vars, and default process types. Assert the fields the buildpack
# contract depends on are present.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
out="$("$root/bin/release" /tmp/fake-build-dir)"

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

echo "$out" | grep -q '^addons:' || fail "missing 'addons:' section"
echo "$out" | grep -q 'cleardb:ignite' || fail "missing cleardb addon"
echo "$out" | grep -q 'sendgrid:starter' || fail "missing sendgrid addon"
echo "$out" | grep -q 'memcachier:dev' || fail "missing memcachier addon"
echo "$out" | grep -q '^config_vars:' || fail "missing 'config_vars:' section"
echo "$out" | grep -q 'DISABLE_WP_CRON: true' || fail "missing DISABLE_WP_CRON config var"
echo "$out" | grep -q '^default_process_types:' || fail "missing 'default_process_types:' section"
echo "$out" | grep -q 'web: start.sh' || fail "missing web process type"

echo "release tests passed"
