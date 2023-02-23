#! /usr/bin/env bash

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

help() {
    cat <<EOF
zkg package tester

Arguments:

  -p|--pkg <URL|name|path>

    Package to install package from. Defaults to ".", the current
    directory (usually a clone of the Zeek package repo we're running
    on). Can also be a package repo URL, or any name resolved by
    Zeek's standard package source.

  -v|--pkg-version <version>

    Package version: a tag, branch name, or specific commit of the
    package to install. When ommitted, zkg's default versiom selection
    applies.

  -s|--pkg-sysdeps <packages>

    A whitespace-separated list of any additional Debian packages to
    install prior to package testing. This allows you to satisfy
    external dependencies that packages with a build_command might
    require.

  -u|--pkg-uservars <name=val> [<name=val> ...]

    A whitespace-separated list of "name=val" pairs that spell out
    zkg user variables to define during the package build process.

  -z|--zeek-version <OBS version>

    Zeek version: one of the supported OBS Zeek builds:
    - "zeek": latest released Zeek version (default)
    - "zeek-lts": long-term support version
    - "zeek-nightly": latest nightly build

  -l|--load-packages <yes|no>

    After successful zkg install, launch/don't launch Zeek with the
    installed package (or packages, if the requested one had
    dependencies) in parse-mode. This can catch problems with packages
    that do not include tests, or whose testing is too narrow.

EOF
    exit 0
}

zeekver="zeek"
pkgurl="."
pkgver=
pkgsysdeps=
pkguservars=()
loadpackages=no

while [ "$#" -gt 0 ]; do
    case "$1" in
        "-h"|"--help"|"-?")
            help
            # notreached
            ;;
        "-p"|"--pkg")
            if [ -n "$2" ] && [[ "$2" != -* ]]; then
                pkgurl="$2"
                shift
            fi
            ;;
        "-v"|"--pkg-version")
            if [ -n "$2" ] && [[ "$2" != -* ]]; then
                pkgver="$2"
                shift
            fi
            ;;
        "-s"|"--pkg-sysdeps")
            if [ -n "$2" ] && [[ "$2" != -* ]]; then
                pkgsysdeps="$2"
                shift
            fi
            ;;
        "-u"|"--pkg-uservars")
            while [ -n "$2" ] && [[ "$2" != -* ]]; do
                pkguservars+=("$2")
                shift
            done
            ;;
        "-z"|"--zeek-version")
            if [ -n "$2" ] && [[ "$2" != -* ]]; then
                zeekver="$2"
                shift
            fi
            ;;
        "-l"|"--load-packages")
            if [ -n "$2" ] && [[ "$2" != -* ]]; then
                if [ "$2" = yes ] || [ "$2" = true ] || [ "$2" = 1 ]; then
                    loadpackages=yes
                fi
                shift
            fi
            ;;
        *)
            ;;
    esac
    shift
done

export PATH=$PATH:/opt/zeek/bin

if [ -n "$GITHUB_WORKSPACE" ]; then
    # When running in GitHub, we preserve artifacts for later
    # retrieval. We rely on $GITHUB_WORKSPACE, which the Github VM
    # shares with the container.
    export ARTIFACTS_DIR=$GITHUB_WORKSPACE/.action-zkg-install/artifacts
    rm -rf $ARTIFACTS_DIR
    mkdir -p $ARTIFACTS_DIR
fi

$dir/zeek-install.sh "$zeekver" || exit $?

if [ -n "$pkgsysdeps" ]; then
    apt-get install -y $pkgsysdeps || exit $?
fi

# If installing a local package, add it the path to safe.directory
if [ "$pkgurl" == "." ]; then
    /usr/bin/git config --global --add safe.directory $(pwd)
fi

$dir/zkg.sh --pkg "$pkgurl" --pkg-version "$pkgver" --pkg-uservars "${pkguservars[@]}"
res=$?

if [ $res -eq 0 ] && [ $loadpackages = yes ]; then
    $dir/zeek-loadpackages.sh
    res=$?
fi

exit $res
