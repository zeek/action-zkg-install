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

  -z|--zeek-version <OBS version>

    Zeek version: one of the supported OBS Zeek builds:
    - "zeek": latest released Zeek version (default)
    - "zeek-lts": long-term support version
    - "zeek-nightly": latest nightly build

EOF
    exit 0
}

zeekver="zeek"
pkgurl="."
pkgver=
pkgsysdeps=

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
        "-z"|"--zeek-version")
            if [ -n "$2" ] && [[ "$2" != -* ]]; then
                zeekver="$2"
                shift
            fi
            ;;
        *)
            ;;
    esac
    shift
done

export PATH=$PATH:/opt/zeek/bin

$dir/zeek-install.sh "$zeekver" || exit $?

if [ -n "$pkgsysdeps" ]; then
    apt-get install -y $pkgsysdeps || exit $?
fi

$dir/zkg.sh "$pkgurl" "$pkgver"

res=$?

if [ $res -ne 0 ]; then
    $dir/artifacts.sh
fi

exit $res
