FROM docker:stable

LABEL \
    maintainer="Morgan AUCHEDE <morgan.auchede@gmail.com>"

ENV \
    PGDATA=/var/lib/postgresql/data \
    POSTGRES_USER=postgres

RUN set -e -u -x \
\
    # Install packages
\
    && apk add --no-cache --no-progress bash

COPY rootfs/ /

ENTRYPOINT [ "docker-entrypoint.sh" ]
