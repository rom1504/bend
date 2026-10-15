# Lazy indexed fork propagation candidate

The earlier indexed version removes linear root-list membership but still uses
Bend's eager `Bool.and`/`Bool.or` arguments. That means the scan performs name and
reference queries even for explicit fork segments or names already in the set;
the reference walker examines all refs even when its first query succeeds.

`fork-lazy.bend` changes only two function bodies. `p90_fork_reaches` explicitly
selects a thunk after testing the first ref. `p90_fork_scan` selects a False result
for fork segments before testing membership, then selects False for existing
members before calling reaches. The insertion and next-segment calls remain
unchanged. The root list, private exact-name index, initial duplicates, hash
collision behavior, count-based convergence, fuel and flags remain unchanged.
The retained legacy `nb_fork_step`/`nb_fork_next` helpers are also unchanged.

Equivalence is for finite well-formed pure Data. Skipping evaluation can change
behavior for unchecked partial/cyclic host values, and changes resource use or
failure timing even for finite but impractically large inputs. This is a private
native-profile candidate, not admission of a new raw JS API contract. Avoidable
predicate evaluation is removed at source; shared-data ownership/drop and thunk
costs remain, so no measured speedup is claimed before target runs.

`prepare-fork-lazy.py` reuses the exact frozen fork03 bounded fixtures and legacy
source. It substitutes only the two declarations in the existing indexed source;
all 46 expected complete products and labels are copied unchanged. It deliberately
does not copy the old Python short-circuit name-comparison diagnostics, which did
not model eager Bend demand. The existing comparator can be used unchanged:

```sh
python3 -B selfhost/tools/performance/phase90/observation/compare-fork.py \
  selfhost/tools/performance/phase90/observation/fork-lazy01/manifest.json \
  OLD_JS_STDOUT LAZY_JS_STDOUT OLD_NATIVE_STDOUT LAZY_NATIVE_STDOUT --out NEW_REPORT
```

Fresh `fork-lazy01/lazy.bend` is SHA `d20b3465…`. The optional full native-profile
source is an incremental derivative of indexed compiler `d8a94ce9…`, SHA
`ed851cbc…`, with four additional lines / 113 bytes. Its receipt records the exact
two function replacements and byte-exact inverse back to the indexed source.
Canonical modules, source74 and all earlier fixtures/attempts remain untouched.
Python AST, all source input pins, full source replay/inverse and unchanged expected
products passed offline; no compiler, native executable or benchmark was run by
the preparing agent. Root owns checked acquisition, whole-product comparison and
any subsequent compiler-image measurements.
