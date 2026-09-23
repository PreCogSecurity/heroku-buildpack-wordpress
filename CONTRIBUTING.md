# Contributing to heroku-buildpack-wordpress

Thanks for helping out. This project is a Heroku buildpack: a set of shell
scripts (`bin/compile`, `bin/detect`, `bin/release`) that Heroku runs when
an app is pushed. Keep that contract in mind when changing things.

## Running the test suite

The test suite is hermetic — it stubs the Nginx/PHP/WordPress downloads
that `bin/compile` performs, so it runs offline with no Heroku account and
no Docker:

```bash
./test.sh
```

or, if the scripts are not executable on your checkout:

```bash
bash test.sh
```

The suite exits non-zero if any test fails, so it can be wired directly
into CI. Individual test files live in `tests/`:

* `tests/detect_test.sh` — `bin/detect` accepts WordPress apps and rejects
  everything else.
* `tests/release_test.sh` — `bin/release` emits the addons, config vars,
  and process types the buildpack contract requires.
* `tests/compile_test.sh` — `bin/compile` installs WordPress and the
  vendored Nginx/PHP packages, honors `WORDPRESS_DIR` (via env var and via
  the `ENV_DIR` argument), and fails when a download cannot be fetched.

See `tests/fixtures/README.md` for how the fixture tarballs work.

## Linting

Scripts are linted with [ShellCheck](https://www.shellcheck.net/). Run it
the same way CI does:

```bash
shellcheck bin/compile bin/detect bin/release \
  support/package_nginx support/package_php support/wordup \
  support/aws/s3 support/aws/hmac \
  test.sh tests/detect_test.sh tests/release_test.sh \
  tests/compile_test.sh tests/bin/curl
```

## Before submitting a PR

1. Make your change in a small, focused commit.
2. Add or update a test in `tests/` that pins the new behavior.
3. Run `./test.sh` and `shellcheck` on the files you touched.
4. Push and open the PR. CI runs the same suite and lint on every push.

## Buildpack contract

* `bin/detect <build-dir>` — exit 0 and print `WordPress` when the app has
  `config/public/wp-config.php`, exit non-zero otherwise.
* `bin/compile <build-dir> <cache-dir> <env-dir>` — install WordPress,
  Nginx, and PHP into the build dir and generate `bin/start.sh`,
  `bin/setup.sh`, and `bin/cron.sh`.
* `bin/release <build-dir>` — print the YAML manifest of addons, config
  vars, and default process types.

Breaking any of these contracts breaks every app that uses the buildpack,
so the tests above are the gate.
