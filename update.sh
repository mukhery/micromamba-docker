#!/bin/bash

set -euf -o pipefail

function clean_up {
  find "$1" -name "*.bak" -type f -delete
}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
trap 'clean_up "${SCRIPT_DIR}"' EXIT

function display_help {
  echo ""
  echo -e "Usage: $(basename "${0}") version"
  echo ""
  echo "   version:  version number of micromamba to put into files"
  echo ""
}

if [[ $# -ne 1 ]]; then
  display_help
  exit 128
fi

VERSION="${1}"

DOCKERFILES=$(find "${SCRIPT_DIR}" -not -path "./test/bats/*" -name '*Dockerfile')

for f in $DOCKERFILES; do
  sed -i.bak  "s%^FROM mambaorg/micromamba:[^ \t ]*%FROM mambaorg/micromamba:${VERSION}%" "$f"
done

sed -i.bak  "s%^ARG VERSION=[^ \t]*%ARG VERSION=${VERSION}%" "${SCRIPT_DIR}/Dockerfile"

for f in README.md FAQ.md; do
  sed -i.bak "s%mambaorg/micromamba:[^ \t]*%mambaorg/micromamba:${VERSION}%" "${SCRIPT_DIR}/$f"
done
