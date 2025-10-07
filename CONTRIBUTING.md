# Contributing

We rely on you to test your changes sufficiently (GitHub Actions will ensure you did).

## Pull Requests

All submissions, including submissions by project members, require review. We use GitHub pull requests for this purpose. Consult [GitHub Help](https://help.github.com/articles/about-pull-requests/) for more information on using pull requests.

See the [PR template](.github/pull_request_template.md) for more information on what to include in your PR.

## Documentation

The documentation for each module is generated with [terraform-docs](https://terraform-docs.io) using [`pre-commit`](https://terraform-docs.io/how-to/pre-commit-hooks).


## Versioning

Each modules version follows the [semver standard](https://semver.org/).

New modules should start at version `1.0.0`, if it's considered stable. If it isn't considered stable, it must be released as `prerelease`. Azure modules start at version `2.0.0` due to the fact that Unique already supported a lot of modules prior to the public repository which are summarized as `1.x`.

Any breaking changes to a module (backwards incompatible) require a major version bump.

## Release

Modules are automatically released after merge given that `module.yaml` was modified (which should have been). If not, each release workflow has a dispatch handle.