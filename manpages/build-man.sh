#!/usr/bin/env bash

set -e

for i in $(ls ./*.txt)
do
    echo "Building ${i::-4} Manpage..."
	asciidoctor -b manpage  $i
#   a2x --doctype manpage --format manpage --no-xmllint $i
done

echo "All Done!"
