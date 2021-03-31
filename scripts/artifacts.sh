#! /usr/bin/env bash
#
# Preserve zkg's logs as artifacts. This uses the $RUNNER_TEMP
# directory, which the Github VM shares with the container.

[ -z "$RUNNER_TEMP" ] && exit 0

artifacts_dir=$GITHUB_WORKSPACE/.action-zkg-install/artifacts

rm -rf $artifacts_dir
mkdir -p $artifacts_dir

zkg_logs_dir=$(zeek-config --prefix)/var/lib/zkg/logs

if [ -d $zkg_logs_dir ]; then
    echo "Preserving artifacts in in $artifacts_dir:"
    cp -pr $zkg_logs_dir $artifacts_dir
    tree $artifacts_dir
fi
