Sentry
======

See https://docs.sentry.io/server/installation/

This is a Sentry installation running in a single container using supervisord.
Meant to be run behind a reverse proxy within internal network. Users are created
automatically and given Manager -role.

Note:
- Sentry requires its own database for initial migration, won't work against a schema.
- REMOTE_USER variable mimics reverse proxy while developing

Development
===========

```
docker build --rm -t futurice/sentry:$(git rev-parse --short HEAD) .
docker run --name postgres -e POSTGRES_PASSWORD=secret -d postgres
docker run --rm -it -p 8000:8000 --name sentry \
    -e SENTRY_URL_PREFIX=http://localhost:8000 \
    -e SENTRY_DB_NAME=sentry \
    -e SENTRY_DB_USER=postgres \
    -e SENTRY_DB_PASSWORD=secret \
    -e SENTRY_POSTGRES_HOST=postgres \
    -e SENTRY_REDIS_HOST=localhost \
    -e SENTRY_MEMCACHED_HOST=localhost \
    -e DEBUG=true \
    -e CELERY_LOG_LEVEL=debug \
    -e REMOTE_USER=myusername \
    -v $(pwd):/opt/app:rw \
    --link postgres:postgres \
    futurice/sentry
# Run 'sentry upgrade' to initialize the database
```
