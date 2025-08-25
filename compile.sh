#!/bin/bash

SRC_DIR="$(dirname $0)"
DEST_DIR="$1"

[ -z "$DEST_DIR" ] && exit 1

find "$SRC_DIR" -type f -name "*.typ" | while read -r source; do
    filename="${source#$SRC_DIR/}"
    target="$DEST_DIR/${filename%.typ}.pdf"
    mkdir -p "$(dirname "$target")"
    typst compile "$source" "$target"
done
