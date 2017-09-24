#!/bin/bash

set -e

DEBUG="${DEBUG:-n}"
COMMANDS="chpst runit runit-init runsv runsvchdir runsvdir sv svlogd utmpset"

function .log() {
  echo '***' $@ >&2
}

function .install-deps() {
  .log "Installing Build Dependencies..."
  yum install -y $@ >/dev/null
}

function .build() {
  .log "Downloading and Verifying..."

  mkdir -p /tmp/runit

  wget -q -O /tmp/runit.tar.gz \
    http://smarden.org/runit/runit-2.1.2.tar.gz

  test "$(sha256sum /tmp/runit.tar.gz | awk '{print $1;}')" == \
    "6fd0160cb0cf1207de4e66754b6d39750cff14bb0aa66ab49490992c0c47ba18"

  tar xzf /tmp/runit.tar.gz -C /tmp/runit --strip-components=1

  .log "Compiling..."

  (
    export PREFIX=/usr
    cd /tmp/runit/runit-2.1.2/src

    # make the binaries
    make $COMMANDS

    # install commands
    for i in $COMMANDS ; do
      install -o root -g root -m 0755 $i /usr/sbin
    done
  ) >/dev/null

  if [ "$DEBUG" != "y" ]; then
    rm -r /tmp/runit.tar.gz /tmp/runit
  fi
}

function .clean-deps() {
  .log "Removing Build Dependencies..."
  yum remove -y $@ >/dev/null
}

function .main() {
  local package_deps="make gcc glibc-static wget rsync"

  .install-deps $package_deps
  .build

  if [ "$DEBUG" != "y" ]; then
    .clean-deps $package_deps
  fi

  # remove self
  if [ "$DEBUG" != "y" ]; then
    rm $0
  fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  .main $@
fi
