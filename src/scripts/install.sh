#!/usr/bin/env bash

# shellcheck disable=SC2086,SC2002

# ktlint version of default to latest
DETEKT_VERSION=${DETEKT_VERSION:-latest}
DETEKT_VERBOSE_INSTALL=${DETEKT_VERBOSE_INSTALL:-false}

if [ "$DETEKT_VERBOSE_INSTALL" = "true" ] || [ "$DETEKT_VERBOSE_INSTALL" = "1" ]; then
  set -x
fi

CURL_RETRY_PARAMETERS="--retry 5 --retry-delay 5 --retry-connrefused"

if [ "$DETEKT_VERSION" = "latest" ]; then
  # Use the HTTP redirection to avoid too many requests to the GitHub API
  location_header=$(
    curl --silent --head $CURL_RETRY_PARAMETERS https://github.com/detekt/detekt/releases/latest |
    grep -i "^location:"
  )

  # See https://www.linuxjournal.com/article/8919
  DETEKT_VERSION=$(echo "${location_header##*/}" | tr -d 'v')
fi

DETEKT_VERSION=$(echo "$DETEKT_VERSION" | tr -d '\r' | xargs)

curl -SLO $CURL_RETRY_PARAMETERS \
  "https://github.com/detekt/detekt/releases/download/v$DETEKT_VERSION/detekt-cli-$DETEKT_VERSION.zip"

unzip "detekt-cli-$DETEKT_VERSION.zip"

#os_id=$(cat /etc/os-release | grep "^ID=" | cut -d'=' -f2 | tr -d '"')
#if [ "$os_id" = "alpine" ]; then
#  if [ "$ID" = 0 ]; then export SUDO=""; else export SUDO="sudo"; fi
#else
#  if [[ $EUID == 0 ]]; then export SUDO=""; else export SUDO="sudo"; fi
#fi

SUDO=""
DESTINATION="/usr/local"

$SUDO cp "detekt-cli-$DETEKT_VERSION/bin/detekt-cli" "$DESTINATION/bin"

$SUDO mkdir -p "$DESTINATION/lib"
$SUDO cp "detekt-cli-$DETEKT_VERSION/lib/detekt-cli-$DETEKT_VERSION-all.jar" "$DESTINATION/lib"

rm -rvf "./detekt-cli-$DETEKT_VERSION*"
