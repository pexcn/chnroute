#!/bin/bash -e
set -o pipefail

CUR_DIR=$(pwd)
TMP_DIR=$(mktemp -d /tmp/chinalist.XXXXXX)

SRC_URL_1="https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/apple.china.conf"
SRC_URL_2="https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/google.china.conf"
SRC_URL_3="https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf"
SRC_FILE="$CUR_DIR/dist/toplist/toplist.txt"
DEST_FILE_1="dist/chinalist/chinalist.txt"
DEST_FILE_2="dist/chinalist/chinalist-lite.txt"

fetch_src() {
  cd $TMP_DIR

  curl -sSL $SRC_URL_1 -o apple.conf
  curl -sSL $SRC_URL_2 -o google.conf
  curl -sSL $SRC_URL_3 -o china.conf
  cp $SRC_FILE .

  cd $CUR_DIR
}

gen_list() {
  cd $TMP_DIR

  cat apple.conf google.conf china.conf |
    # remove empty lines
    sed '/^[[:space:]]*$/d' |
    # remove comment lines
    sed '/^#/ d' |
    # extract domains
    awk '{split($0, arr, "/"); print arr[2]}' |
    # remove TLDs
    grep "\." |
    # remove duplicates
    awk '!x[$0]++' > chinalist.tmp

  # find intersection set
  grep -Fx -f chinalist.tmp toplist.txt > chinalist_head.tmp
  # find difference set
  grep -Fxv -f toplist.txt chinalist.tmp > chinalist_tail.tmp
  # merge to chinalist
  cat chinalist_head.tmp chinalist_tail.tmp > chinalist.txt
  # lite version
  cat chinalist_head.tmp > chinalist-lite.txt

  cd $CUR_DIR
}

copy_dest() {
  install -D -m 644 $TMP_DIR/chinalist.txt $DEST_FILE_1
  install -D -m 644 $TMP_DIR/chinalist-lite.txt $DEST_FILE_2
}

clean_up() {
  rm -r $TMP_DIR
  echo "[$(basename $0 .sh)]: done."
}

fetch_src
gen_list
copy_dest
clean_up
