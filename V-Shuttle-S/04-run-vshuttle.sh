#!/bin/bash -x

TARGET=$1
export UBSAN_OPTIONS=symbolize=1:halt_on_error=0:print_stacktrace=1
TIMEOUT=10s
for ROUND in $(seq 0 9); do
    LLVM_PROFILE_FILE=profile-vshuttle-$TARGET-$ROUND cpulimit -l 100 -- bash -x 02-fuzz.sh $TARGET $ROUND >vshuttle-$TARGET-$ROUND.log 2>&1 &
    sleep 1
done
