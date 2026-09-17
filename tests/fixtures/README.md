# Test fixtures

These tarballs stand in for the real Nginx, PHP, and WordPress downloads
that `bin/compile` fetches at build time. The stub `../bin/curl` (prepended
to `PATH` by the test scripts) serves them instead of hitting the network,
so the test suite runs fully offline.

Regenerate them with GNU tar:

```bash
mkdir -p /tmp/fixtures-src/wordpress
echo '<?php // placeholder' > /tmp/fixtures-src/wordpress/wp-settings.php
echo '<?php // placeholder' > /tmp/fixtures-src/wordpress/index.php
tar -czf wordpress.tar.gz -C /tmp/fixtures-src wordpress

mkdir -p /tmp/fixtures-src/nginx/bin
echo '#!/bin/sh' > /tmp/fixtures-src/nginx/bin/nginx
tar -czf nginx.tar.gz -C /tmp/fixtures-src nginx

mkdir -p /tmp/fixtures-src/php/bin /tmp/fixtures-src/php/fpm
echo '#!/bin/sh' > /tmp/fixtures-src/php/bin/php
echo '<html>status</html>' > /tmp/fixtures-src/php/fpm/status.html
tar -czf php.tar.gz -C /tmp/fixtures-src php
```

The stub maps the exact default URLs that `bin/compile` requests (see the
`NGINX_VERSION`, `PHP_VERSION`, and `WORDPRESS_VERSION` defaults in
`bin/compile`) to fixtures:

| URL contains | Fixture served |
| ------------ | -------------- |
| `nginx-1.4.2-heroku.tar.gz` | `nginx.tar.gz` |
| `php-5.5.2-with-fpm-heroku.tar.gz` | `php.tar.gz` |
| `wordpress-3.9.1.tar.gz` | `wordpress.tar.gz` |

Any other URL makes the stub exit non-zero, which lets the test suite
exercise `bin/compile`'s failure path (it runs with `set -o pipefail`).
