#!/usr/bin/env bash
# Tests for bin/compile.
#
# bin/compile normally downloads Nginx, PHP, and WordPress from the
# network. These tests prepend tests/bin to PATH so the stub curl there
# serves local fixture tarballs, making the suite hermetic and offline.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# Prepend a wrapper dir to PATH so bin/compile's `curl` calls hit the stub
# in tests/bin/curl. The wrapper invokes the stub via bash explicitly, so
# this works even if the stub's executable bit is not set in git.
stub_dir="$tmp/bin"
mkdir -p "$stub_dir"
{
  echo '#!/usr/bin/env bash'
  echo "exec bash \"$root/tests/bin/curl\" \"\$@\""
} > "$stub_dir/curl"
chmod +x "$stub_dir/curl"
export PATH="$stub_dir:$PATH"

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

# 1. Default install: WordPress lands in public/, vendored apps in vendor/.
build="$tmp/build-default"
cache="$tmp/cache-default"
mkdir -p "$build" "$cache"
"$root/bin/compile" "$build" "$cache" "$tmp/env"

[ -f "$build/public/wp-settings.php" ] || fail "wordpress not installed into public/ (wp-settings.php missing)"
[ -f "$build/public/index.php" ] || fail "wordpress not installed into public/ (index.php missing)"
[ -d "$build/vendor/nginx" ] || fail "nginx not installed into vendor/nginx"
[ -d "$build/vendor/php" ] || fail "php not installed into vendor/php"
[ -f "$build/bin/start.sh" ] || fail "bin/start.sh not generated"
[ -f "$build/bin/setup.sh" ] || fail "bin/setup.sh not generated"
[ -f "$build/bin/cron.sh" ] || fail "bin/cron.sh not generated"
[ -x "$build/bin/start.sh" ] || fail "bin/start.sh not executable"
[ -x "$build/bin/setup.sh" ] || fail "bin/setup.sh not executable"
[ -x "$build/bin/cron.sh" ] || fail "bin/cron.sh not executable"

# 2. WORDPRESS_DIR: WordPress installs into public/<dir> instead of public/.
build="$tmp/build-subdir"
cache="$tmp/cache-subdir"
mkdir -p "$build" "$cache"
WORDPRESS_DIR=mywordpress "$root/bin/compile" "$build" "$cache" "$tmp/env"

[ -f "$build/public/mywordpress/wp-settings.php" ] || fail "WORDPRESS_DIR install failed (public/mywordpress/wp-settings.php missing)"
[ -f "$build/bin/cron.sh" ] || fail "bin/cron.sh not generated for WORDPRESS_DIR install"

# 3. ENV_DIR: config vars in the env dir are exported into the compile.
build="$tmp/build-envdir"
cache="$tmp/cache-envdir"
mkdir -p "$build" "$cache" "$tmp/env"
echo "mywordpress" > "$tmp/env/WORDPRESS_DIR"
"$root/bin/compile" "$build" "$cache" "$tmp/env"

[ -f "$build/public/mywordpress/wp-settings.php" ] || fail "ENV_DIR WORDPRESS_DIR not honored (public/mywordpress/wp-settings.php missing)"

# 4. Unknown tarball URL: compile must fail (set -o pipefail catches curl).
build="$tmp/build-fail"
cache="$tmp/cache-fail"
mkdir -p "$build" "$cache"
if NGINX_VERSION=99.99.99 "$root/bin/compile" "$build" "$cache" "$tmp/env" >/dev/null 2>&1; then
  fail "compile should fail when a tarball cannot be fetched"
fi

echo "compile tests passed"
