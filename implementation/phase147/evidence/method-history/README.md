# Retained renderer methods

The five superseded renderer native-harness files are retained byte-for-byte in `render-native-methods.tar.xz`. The [inventory](inventory.json) maps every original repository path to its exact archive member, byte size and SHA-256. Every member was reopened and compared with its original before the obsolete HEAD copy was removed.

This includes two source-review failures, the corrected first native workload, and its consumed preparation/timing methods. Their original ignored build sources, commands and reports remain unchanged. Current tests use the generalized `render-fragment-*` harness. An old receipt whose input path was retired resolves through this explicit inventory; the archived method is not substituted into a current operational path.

To inspect or reproduce an old experiment, extract into a fresh directory with `tar -xJf render-native-methods.tar.xz -C FRESH_DIRECTORY`. Restore the old path in an isolated checkout only when intentionally replaying that receipt. No compiler, native program or benchmark was run for this retention step.
