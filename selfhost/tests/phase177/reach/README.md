# Phase177 reachability membership reuse

This is an unexecuted source overlay. It replaces only `reach_book`; it does not
change maintained source, `kr_visit`, resolution, dependency discovery, stops,
parent expansion, or the index implementation. Source checking and all controls
still need coordinator-owned acquisition and execution.

The original traversal maintains both an exact visited-name list and a
`P142JSeen` membership index, returns the list, discards that index, and builds a
new `P128ReachMember` index for the final ordered filter. The replacement returns
the first membership index and filters the original book with it directly.
It removes the duplicate list/index construction and destruction. It does not
claim to remove constructor scans or repeated dependency traversal.

The simulation invariant is that `members` denotes exactly the names in the
original `seen` list at the corresponding worklist step. Both paths perform the
same queried-name test, record a new query before resolving it, and record every
successful resolved definition name before continuing through the same
dependencies. A missing resolution still records the query. Repeated successful
parent expansion is deliberately retained, even when its name already belongs
to the set. At completion both membership sets therefore agree. Filtering the
same original book retains exactly the same record payloads, order and duplicate
rows. Internal tree shape and marker kind are not exposed by `reach_book`.

This applies to finite compiler data, including arbitrary raw books and stale
caches under the original resolution rules. No claim is made for hostile host
getters, forged runtime objects or cyclic host graphs. In particular, the patch
does not use checked-source uniqueness to suppress repeated parent expansion.

For baseline preparation, append only `controls.bend`. For candidate preparation,
also pass `--prelude selfhost/tests/phase177/reach/reuse-prelude.bend`,
`--module selfhost/tests/phase177/reach/reuse.bend`, and `--replace reach_book`
to `selfhost/tests/phase177/prepare.py`. Export these four names for both roles:

- `reach_book`
- `kr_visit`
- `p177rv_original`
- `p177rv_cases`

Acquire both with the unchanged checked-hosted API workflow. Then run
`values.mjs --baseline <baseline-report> --candidate <candidate-report>
--out <fresh-build-directory>` under the root-owned guard. The harness requires
checked receipts, verifies their input identities, compares all fields against
32 literal complete ordered outputs, checks the unchanged `kr_visit` with three
initial lists per case, and checks retained caller inputs. It preserves complete
observations in `values.json`; digest/status agreement is not the oracle.

The cases cover cycles, repeated parents, first-parent choice, top-level
shadowing, non-Ctr constructor-list entries, stops, type/constructor/body
dependencies, qualified and Unicode names, the known `costarring`/`liquid` hash
collision, empty names and index variants, Absent records, duplicate definition
payloads, stale-cache misses/hits, and full literal/lambda/definition metadata.
The duplicate-parent case specifically prevents the tempting but invalid change
that skips a differently resolved payload because its parent name was seen.

For the real frontend screen use the same overlay with the existing complete
frontend entry and observation contract. Include construction, filtering and
teardown in timing. Its known exposure is only part of the old reach/annotation
stage; no speed estimate is inferred from source counts or profiler owners.
