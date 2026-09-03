#!/usr/bin/env bash
set -u
BASE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
fail=0
for t in "$BASE_DIR"/tests/test_*.sh; do
    bash "$t" || fail=1
done
exit "$fail"
