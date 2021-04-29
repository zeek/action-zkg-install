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
    zkg_logs_dir=$(zeek-config --prefix)/var/lib/zkg/logs
    for log in $zkg_logs_dir/*-build.log; do
        if [ -r "$log" ]; then
            echo "*** $log:"
            cat $log
            echo
        fi
    done

    if [ -d "$zkg_logs_dir" ] && [ -d "$ARTIFACTS_DIR" ]; then
        cp -pr $zkg_logs_dir $ARTIFACTS_DIR
    fi

    exit 1
}

echo "Package information:"
zkg info "$pkgurl"
