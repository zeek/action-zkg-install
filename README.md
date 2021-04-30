# Github Action for Testing Zeek Packages

This is a Github Action that will run `zkg install` on a Zeek
package. It currently runs Debian 10 via Docker, but we may broaden
support to additional distros and platforms in the future.

## Input arguments

The action supports the following inputs:

- `pkg`: the name, URL, or local path of the package to
  install. Defaults to ".", which installs a locally cloned Zeek
  package. Precede this action with
  [`actions/checkout`](https://github.com/actions/checkout) to use
  this default on a Zeek package repository.

  > :rotating_light: With local git clones, `zkg`'s default version
  > selection logic works differently. Instead of looking for the latest
  > version tag and falling back to the default branch, it will
  > install the checked-out state. If you'd like to test with `zkg`'s
  > regular behavior, use the following `pkg` line:
  > ```
  > with:
  >   pkg: ${{ github.server_url }}/${{ github.repository }}
  > ```
  > You do not need `action/checkout` in this setting, since `zkg`
  > will install straight from the repository's URL.

- `pkg_version`: the version of the package. Defaults to zkg's
  version-determination algorithm. You can provide a git tag,
  branch, or SHA-1 commit hash.

  > :rotating_light: If you're running the action on a local clone
  > with a version tag, make sure to pass `with: fetch-depth: 0`
  > (or a sufficient depth) to `actions/checkout`, so the git tags
  > are available in the clone.

- `pkg_sysdeps`: additional Debian packages to install in order to
  satisfy external dependencies required by the package.

- `zeek_version`: the Zeek version to use, based on our
  [binary packages](https://github.com/zeek/zeek/wiki/Binary-Packages):
  `zeek` for the latest release, `zeek-lts` for the latest
  long-term-support release, and `zeek-nightly` for the latest nightly
  Zeek build.

- `load_packages`: when enabled (by passing `yes`, `true`, or `1`), a
  successful package installation via zkg is followed by a parse-only
  Zeek invocation that loads all of zkg's installed packages. This can
  catch basic problems in a package that doesn't include tests, but
  also detect more subtle ones that its tests might not cover.

## Example usage

Test the local Zeek package sources at version `v1.2.3`, with the LTS release:

```yaml
- uses: actions/checkout@v2
  with:
    fetch-depth: 0
- uses: zeek/action-zkg-install@v1
  with:
    pkg_version: v1.2.3
    zeek_version: zeek-lts
```

Use `zkg'`s default install logic, with the Zeek nightly build:

```yaml
- uses: zeek/action-zkg-install@v1
  with:
    pkg: ${{ github.server_url }}/${{ github.repository }}
    zeek_version: zeek-nightly
```

- `load_packages`: when enabled (by passing "yes", "true", or "1"), a
  successful package installation via zkg is followed by a parse-only
  Zeek invocation that loads all of zkg's installed packages. This can
  catch basic problems in a package that doesn't include tests, but
  also detect more subtle ones that its tests might not cover.

## Artifacts

On failure, the action collects `zkg` logs in case you'd like to process them
into artifacts, output them, etc. After the action completes, the logs reside in
`${{ github.workspace }}/.action-zkg-install/artifacts`. Here's a possible
artifact upload snippet:

```yaml
- uses: actions/upload-artifact@v2
  if: failure()
    with:
      name: zkg-logs
      path: ${{ github.workspace }}/.action-zkg-install/artifacts
```

## Versions

The latest released version of this action is `v1`. In-development work
is available by using the action with `@master`.

## Docker

The contained Docker image works as a standalone setup for testing
Zeek packages. See `docker run -it <image> --help` for details once
you've built the image.
