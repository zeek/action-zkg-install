#! /usr/bin/env bash

echo -n "Running Zeek with installed packages, in parse-only mode ... "
zeeklog=zeek-loadpackages.txt

zeek -a packages >$zeeklog 2>&1
res=$?

if [ $res -ne 0 ]; then
    echo "failed:"
    cat $zeeklog
    if [ -d "$ARTIFACTS_DIR" ]; then
        cp $zeeklog $ARTIFACTS_DIR
    fi
else
    echo "succeeded."
fi

exit $res
