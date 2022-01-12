#!/bin/bash
TARGET=$1
NUMBER=$2
ROUND=$3
rm -rf $1-in-$ROUND $1-out-$ROUND $1-seed-$ROUND
mkdir $1-in-$ROUND $1-out-$ROUND $1-seed-$ROUND
for (( id=0; id<=$NUMBER; id++ )); do
    mkdir $1-in-$ROUND/$id
    dd if=/dev/zero of=$1-in-$ROUND/$id/seed bs=1 count=4086
done
