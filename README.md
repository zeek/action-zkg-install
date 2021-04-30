# Github Action for Testing & Installing Zeek Packages

This is a Github Action that will run `zkg install` on a Zeek
package. It currently runs Debian 10 via Docker, but we may broaden
support to additional distros and platforms via branches.

## Example usage

Test the local Zeek package sources at version tag `latest`, using the
latest Zeek nightly build:

```yaml
- uses: zeek/action-zkg-install@v1
  with:
    pkg_version: 'latest'
    zeek_version: 'zeek-nightly'
```

## Input arguments

The action supports the following inputs:

- `pkg`: the name, URL, or path of the package to install. Defaults to
  ".", meaning that by default it will install the local repository,
  assuming we're running this action on a Zeek package repo.

- `pkg_version`: the version of the package. This defaults to using zkg's
  package-determination algorithm, but you can also provide a tag,
  branch, or SHA-1 commit has.

  If you're using `actions/checkout` to clone the repository and
  request a specific tag, you'll need to include `with: fetch-depth:
  0` so the complete history is available in the clone.

- `pkg_sysdeps`: additional Debian packages to install in order to
  satisfy external dependencies required by the package.

- `zeek_version`: the Zeek version to use, as defined by the SuSE OBS
  builds we maintain: `zeek` for the latest release, `zeek-lts` for
  the latest long-term-support release, and `zeek-nightly` for the
  latest nightly Zeek build.

- `load_packages`: when enabled (by passing "yes", "true", or "1"), a
  successful package installation via zkg is followed by a parse-only
  Zeek invocation that loads all of zkg's installed packages. This can
  catch basic problems in a package that doesn't include tests, but
  also detect more subtle ones that its tests might not cover.

## Artifacts

On failure, the action collects `zkg` logs in case you'd like to process them
into artifacts, output them, etc. After the action completes, the logs reside in
`${{ github.workspace }}/.action-zkg-install/artifacts`.

## Versions

The current version of this action is `v1`.

## Docker

The contained Docker image works as a standalone setup for testing
Zeek packages. See `docker run -it <image> --help` for details once
you've build the image.
