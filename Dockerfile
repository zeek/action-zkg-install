FROM debian:10
LABEL maintainer="Christian Kreibich <christian@corelight.com>"

ENV DEBIAN_FRONTEND noninteractive

RUN echo 'Acquire::https::Timeout "15";' >/etc/apt/apt.conf.d/https-timeout
RUN apt-get -y update

# Install some common dependencies to reduce dependencies pulled in by
# the Zeek install later.
RUN apt-get -y install bison bzip2 cmake curl flex g++ gcc git gpg libmaxminddb-dev \
    libpcap-dev libssl-dev make nullmailer python3 python3-dev python3-smmap \
    python3-gitdb python3-git python3-semantic-version swig tree zlib1g-dev

# Set up repo to install from SUSE OBS, as per
# https://software.opensuse.org//download.html?project=security%3Azeek&package=zeek-nightly:
RUN echo 'deb http://download.opensuse.org/repositories/security:/zeek/Debian_10/ /' \
    | tee /etc/apt/sources.list.d/security:zeek.list
RUN curl -fsSL -m 15 https://download.opensuse.org/repositories/security:zeek/Debian_10/Release.key \
    | gpg --dearmor \
    | tee /etc/apt/trusted.gpg.d/security_zeek.gpg > /dev/null

RUN apt-get -y update

# Populate helper scripts, including entrypoint
RUN mkdir -p /opt/action/
COPY scripts/*.sh /opt/action/

# When running as a Github action, Github mounts and enters the workdir:
# https://docs.github.com/en/actions/creating-actions/dockerfile-support-for-github-actions#workdir

ENTRYPOINT ["/opt/action/entrypoint.sh"]
