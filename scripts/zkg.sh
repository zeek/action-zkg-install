#! /usr/bin/env bash
set -e

pkgurl=
pkgverarg=
pkgverdesc=

while [ "$#" -gt 0 ]; do
    case "$1" in
        "-p"|"--pkg")
            if [ -n "$2" ] && [[ "$2" != -* ]]; then
                pkgurl="$2"
                shift
            fi
            ;;
        "-v"|"--pkg-version")
            if [ -n "$2" ] && [[ "$2" != -* ]]; then
                pkgverarg="--version $2"
                pkgverdesc="version $2"
                shift
            fi
            ;;
        "-u"|"--pkg-uservars")
            if [ -n "$2" ] && [[ "$2" != -* ]]; then
                echo "Defining user variables:"
                while [ -n "$2" ] && [[ "$2" != -* ]]; do
                    echo "- $2"
                    export "$2"
                    shift
                done
            fi
            ;;
        *)
            ;;
    esac
    shift
done


echo "Installing package from '$pkgurl', ${pkgverdesc:-unversioned}:"
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
