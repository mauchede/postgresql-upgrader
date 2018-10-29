#!/bin/bash
set -e -E -o pipefail -u -x

_clear() {
    local container_new_name="${CONTAINER_NEW_NAME:-}"
    if [ -n "${container_new_name}" ]; then
        docker rm --force --volumes "${container_new_name}" || :
    fi

    local container_old_name="${CONTAINER_OLD_NAME:-}"
    if [ -n "${container_old_name}" ]; then
        docker rm --force --volumes "${container_old_name}" || :
    fi

    local volume_new_version="${VOLUME_NEW_VERSION:-}"
    if [ -n "${volume_new_version}" ]; then
        docker volume rm --force "${volume_new_version}"
    fi

    local volume_old_version="${VOLUME_OLD_VERSION:-}"
    if [ -n "${volume_old_version}" ]; then
        docker volume rm --force "${volume_old_version}"
    fi
}
trap _clear ERR INT

_fail() {
    echo 1>&2 "$1"
    exit 255
}

# Check environment

export CONTAINER_NEW_IMAGE="${CONTAINER_NEW_IMAGE:-}"
if [ -z "${CONTAINER_NEW_IMAGE}" ]; then
    _fail "Environment variable \"CONTAINER_NEW_IMAGE\" must be defined."
fi
docker pull "${CONTAINER_NEW_IMAGE}"

export CONTAINER_NEW_NAME="${CONTAINER_NEW_NAME:-}"
if [ -z "${CONTAINER_NEW_NAME}" ]; then
    _fail "Environment variable \"CONTAINER_NEW_NAME\" must be defined."
fi
docker rm --force --volumes "${CONTAINER_NEW_NAME}" || :

export CONTAINER_OLD_IMAGE="${CONTAINER_OLD_IMAGE:-}"
if [ -z "${CONTAINER_OLD_IMAGE}" ]; then
    _fail "Environment variable \"CONTAINER_OLD_IMAGE\" must be defined."
fi
docker pull "${CONTAINER_OLD_IMAGE}"

export CONTAINER_OLD_NAME="${CONTAINER_OLD_NAME:-}"
if [ -z "${CONTAINER_OLD_NAME}" ]; then
    _fail "Environment variable \"CONTAINER_OLD_NAME\" must be defined."
fi
docker rm --force --volumes "${CONTAINER_OLD_NAME}" || :

export VOLUME_CURRENT_VERSION="${VOLUME_CURRENT_VERSION:-}"
if [ -z "${VOLUME_CURRENT_VERSION}" ]; then
    _fail "Environment variable \"VOLUME_CURRENT_VERSION\" must be defined."
fi
docker volume inspect "${VOLUME_CURRENT_VERSION}"

export VOLUME_NEW_VERSION="${VOLUME_NEW_VERSION:-}"
if [ -z "${VOLUME_NEW_VERSION}" ]; then
    _fail "Environment variable \"VOLUME_NEW_VERSION\" must be defined."
fi
docker volume rm --force "${VOLUME_NEW_VERSION}"

export VOLUME_OLD_VERSION="${VOLUME_OLD_VERSION:-}"
if [ -z "${VOLUME_OLD_VERSION}" ]; then
    _fail "Environment variable \"VOLUME_OLD_VERSION\" must be defined."
fi
docker volume rm --force "${VOLUME_OLD_VERSION}"

# Copy data from "VOLUME_CURRENT_VERSION" to "VOLUME_OLD_VERSION"

docker volume create "${VOLUME_OLD_VERSION}"
docker run --init --rm --volume "${VOLUME_CURRENT_VERSION}":/from --volume "${VOLUME_OLD_VERSION}":/to alpine:latest sh -c "rm -f -r /to/* && cd /from && cp -a -v . /to"

# Start containers "CONTAINER_NEW_NAME" and "CONTAINER_OLD_NAME"

docker run --detach $(compgen -A variable | grep -E "^POSTGRES_" | awk "{print \"--env\", \$1}") --init --name "${CONTAINER_NEW_NAME}" --volume "${VOLUME_NEW_VERSION}":"${PGDATA}" "${CONTAINER_NEW_IMAGE}"
sleep 5
until docker exec --interactive --user postgres "${CONTAINER_NEW_NAME}" pg_isready; do
    sleep 1
done

docker run --detach $(compgen -A variable | grep -E "^POSTGRES_" | awk "{print \"--env\", \$1}") --init --name "${CONTAINER_OLD_NAME}" --volume "${VOLUME_OLD_VERSION}":"${PGDATA}" "${CONTAINER_OLD_IMAGE}"
sleep 5
until docker exec --interactive --user postgres "${CONTAINER_NEW_NAME}" pg_isready; do
    sleep 1
done

# Dump data from "CONTAINER_OLD_NAME" to "CONTAINER_NEW_NAME"

docker exec --interactive --user postgres "${CONTAINER_OLD_NAME}" pg_dumpall --username "${POSTGRES_USER}" | docker exec --interactive --user postgres "${CONTAINER_NEW_NAME}" psql --username "${POSTGRES_USER}"

# Stop containers "CONTAINER_NEW_NAME" and "CONTAINER_OLD_NAME"

docker stop "${CONTAINER_NEW_NAME}"
docker stop "${CONTAINER_OLD_NAME}"

# Copy data from "VOLUME_NEW_VERSION" to "VOLUME_CURRENT_VERSION"

docker run --init --rm --volume "${VOLUME_NEW_VERSION}":/from --volume "${VOLUME_CURRENT_VERSION}":/to alpine:latest sh -c "rm -f -r /to/* && cd /from && cp -a -v . /to"

# Clear system

_clear
