#!/bin/bash -e
set -o pipefail

TMP_DIR=$(mktemp -d /tmp/toplist.XXXXXX)

SRC_URL="https://s3.amazonaws.com/alexa-static/top-1m.csv.zip"
DEST_FILE="dist/toplist/toplist.txt"

gen_list() {
  pushd $TMP_DIR > /dev/null

  curl -sSL $SRC_URL |
    # unzip
    gunzip |
    # extract domain
    awk -F ',' '{print $2}' > toplist.txt

  popd > /dev/null
}

copy_dest() {
  install -D -m 644 $TMP_DIR/toplist.txt $DEST_FILE
}

clean_up() {
  rm -r $TMP_DIR
}

gen_list
copy_dest
clean_up
