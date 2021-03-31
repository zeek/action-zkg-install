#! /usr/bin/env bash
set -e

pkgurl="$1"
pkgver="$2"

if [ -n "$pkgver" ]; then
    pkgverarg="--version $pkgver"
    pkgverdesc="version $pkgver"
fi

echo "Installing package from '$pkgurl', ${pkgverdesc:-unversioned}"
zkg install --force $pkgverarg $pkgurl || {
    for log in $(zeek-config --prefix)/var/lib/zkg/logs/*-build.log; do
        if [ -r "$log" ]; then
            echo "*** $log:"
            cat $log
            echo
        fi
    done

    exit 1
}

echo "Package information:"
zkg info "$pkgurl"
