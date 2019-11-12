# README

Upgrade PostgreSQL data inside Docker

## Usage

```sh
export CONTAINER_NEW_IMAGE=postgres:11-alpine
export CONTAINER_NEW_NAME=postgresql-new-version
export CONTAINER_OLD_IMAGE=postgres:10-alpine
export CONTAINER_OLD_NAME=postgresql-old-version
export VOLUME_CURRENT_VERSION=postgresql-current-volume
export VOLUME_NEW_VERSION=postgresql-new-volume
export VOLUME_OLD_VERSION=postgresql-old-volume

docker run --env CONTAINER_NEW_IMAGE --env CONTAINER_NEW_NAME --env CONTAINER_OLD_IMAGE --env CONTAINER_OLD_NAME --env VOLUME_CURRENT_VERSION --env VOLUME_NEW_VERSION --env VOLUME_OLD_VERSION --rm --init --volume /var/run/docker.sock:/var/run/docker.sock:ro mauchede/postgresql-upgrader
```

## Contributing

1. Fork it.
2. Create your branch: `git checkout -b my-new-feature`.
3. Commit your changes: `git commit -am 'Add some feature'`.
4. Push to the branch: `git push origin my-new-feature`.
5. Submit a [merge request](https://docs.gitlab.com/ee/user/project/merge_requests/).

__Note 1__: [GitHub repository](https://github.com/mauchede/postgresql-upgrader) is a mirror. [Merge request](https://docs.gitlab.com/ee/user/project/merge_requests/) has to be submitted on the [GitLab repository](https://gitlab.com/mauchede/postgrsql-upgrader).

__Note 2__: Use the script `bin/build-image` to test your modifications locally.

If you like / use this project, please let me known by adding a [★](https://help.github.com/articles/about-stars/) on the [GitHub repository](https://github.com/mauchede/postgresql-upgrader) or on the [GitLab repository](https://gitlab.com/mauchede/postgresql-upgrader).

## Links

* [gdiepen/docker-convenience-scripts](https://github.com/gdiepen/docker-convenience-scripts)
* [image "mauchede/postgresql-upgrader"](https://hub.docker.com/r/mauchede/postgresql-upgrader/)
* [pg_dumpall](https://www.postgresql.org/docs/current/static/app-pg-dumpall.html)
* [pg_isready](https://www.postgresql.org/docs/current/static/app-pg-isready.html)
* [safer bash scripts with "set -euxo pipefail"](https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/)
* [tianon/docker-postgres-upgrade](https://github.com/tianon/docker-postgres-upgrade)
* [upgrade postgres container to version 10](https://peter.grman.at/upgrade-postgres-9-container-to-10/)
