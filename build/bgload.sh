#!/bin/sh

repo="/repo"
tmp="/tmp/cvm"

if [ ! -d "$repo" ]; then
   echo "Git repo not found, ensure the repo exists at '$repo'"
   exit 1
fi

mkdir -p $tmp

for file in `find $repo -type f -name '*.nt'`; do
   echo "Loading file: $file"
   rake triplestore_loader:process file=$file write_report=true update_triplestore=true write_update_file=true output_dir=$tmp
done
