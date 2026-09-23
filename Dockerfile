# Local buildpack test environment.
#
# Mimics the toolchain the buildpack needs (the Heroku cedar/heroku-20
# stacks are Ubuntu-based) so bin/compile and the test suite can run
# locally without a Heroku account or Docker networking:
#
#   docker compose up --build
#
# The test suite is hermetic (tests/bin/curl stubs the downloads), so the
# container only needs the shell toolchain, not Nginx/PHP/WordPress.
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        curl \
        grep \
        ruby-erubis \
        sed \
        tar \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# The buildpack is mounted at /workspace by docker-compose.yml.
CMD ["bash", "test.sh"]
