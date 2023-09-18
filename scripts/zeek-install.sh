#! /usr/bin/env bash

set -e

package="$1"

if [ -z "$package" ]; then
    echo "Need package name to install."
    exit 1
fi

if ! [[ "$package" =~ ^(zeek|zeek-lts|zeek-nightly|zeek-[0-9]+\.0)$ ]]; then
    echo "Zeek package version must be 'zeek', 'zeek-lts', 'zeek-nightly' or 'zeek-<LTS version>.0'."
    exit 1
fi

apt-get install -y $package

# Get the Zeek package's bin folder into the PATH. This accommodates
# the name variants used by the different OBS packages.
if ! [ -d /opt/zeek ]; then
    ln -s /opt/zeek* /opt/zeek
fi

echo -e "\nZeek install info:"
echo "zeek: $(zeek-config --version)"
echo "zkg:  $(zkg --version)"
