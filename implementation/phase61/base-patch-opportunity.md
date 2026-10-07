# Base patch representation: read-only census

**Defer representation changes during state08 qualification.** All 296 saved
checked patches change only a declaration's `value`. A small body-only patch
variant would remove 549,292 serialized bytes, 9.69% of the whole frame. Deeper
subtree reuse has a larger gross opportunity but requires a patch interpreter and
new validation obligations. Neither a codec nor compiler source was changed.

The [saved census](../../selfhost/build/phase61/base-patch-census01.json) binds the
actual state06 frame SHA `31e2e80c447e4f404964798df50c7cb5627a17ecfe3d3760619f0e3f5f49bd9a`.
It verifies all three existing segment hashes, compact serialization and exact
raw-plus-new-body reconstruction for every checked patch.

| Current frame component | Serialized bytes |
| --- | ---: |
| Header including newline | 898 |
| Raw Base declaration events | 3,470,270 |
| Checked prefix state | 2,196,240 |
| Fresh-prefix state | 50 |
| Complete frame | 5,667,458 |

There are 484 raw events, 463 final names after last-declaration selection, and
296 checked patches, all of kind `Def`. Their name, kind, arity, templates, type,
constructor list, native flag and unsafe flag are unchanged. Unchanged type
fields alone occupy 524,724 bytes inside the patches. The changed bodies occupy
1,623,592 bytes.

The body-only size model uses a concrete tagged record
`KBasePatchBody{name,value}` inside the existing list and prefix-state envelope.
Its state is 1,646,948 bytes: a 25.01% state reduction and a modeled complete frame
of 5,118,166 bytes. The calculation holds the header size fixed; actual new format
metadata would need its own identity and may differ slightly. This is a byte
model, not an implemented serialization format or a peak-heap estimate.

Exact subtree comparison retains variants, binder IDs, quantities, names,
removed constructors and both source coordinates. The changed bodies contain
2,764 maximal nonoverlapping KTerm subtrees, totaling 799,561 bytes, identical to
subtrees already present in that same raw declaration body (49.25% of body
bytes). Searching every final raw declaration finds no additional reuse. These
are gross bytes before references, paths or rebuilding metadata; they are not
additive nested-node counts or an achievable compression claim.

## Smallest sound source design, if later justified

The current [base_prefix_deltas](../../selfhost/src/check/prefix-state.bend#L90)
already compares complete checked definitions with final raw definitions and
omits unchanged definitions. A narrowly extended private patch type could have
two variants: name plus replacement body when all other fields are exactly
equal, and a complete replacement definition for every other case. Application
would reconstruct the body variant from the **same final raw definition**.
Missing names, wrong shapes and mismatched provenance must refuse optional state
and use the existing full-check path. A changed type or constructor must use the
complete variant; today's body-only observation is not a language invariant.

Preparation must keep the existing exact replay test against the complete
checked list, plus fresh-bound/stamp/world/memo conditions. The identity-bound
private carrier, Base/API/source interval hashes, span checks and immutable raw
tree remain necessary. Hashing a compact state is provenance for this prepared
data, not a new kernel proof or permission to trust arbitrary caller patches.
The state version, ordinary adapter constructor registry and host shape/span
validator would all need an explicit successor. It is more than removing fields
from JSON, though it avoids a general tree-patch interpreter.

A subtree design would additionally need stable within-definition references or
paths, exact source-variant/span retention, bounded application, no cycles or
out-of-range references, and reconstruction equality. It may share immutable
raw subtrees in memory, but cannot assume arbitrary host inputs are frozen.
Defer that larger change until end-to-end profiling justifies it.

Root's current cache-path estimates are about 21% of Numeric and 7% of Map CPU.
Under an optimistic **proportional byte-cost assumption**, a 9.69% payload cut
corresponds to roughly 2.0% and 0.7% whole-request reductions before reconstruction
and validation overhead. This is a planning estimate, not a measured gain or a
formal time bound. The earlier binary-codec experiment was 2.26× worse; smaller
transport alone did not offset generic validation/state-hash work. The present
census identifies representation duplication, not evidence that another format
will make requests faster.

Replay the read-only producer on the exact `input.file` recorded in the census:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase61/base-patch-census.py FRAME2_CACHE_FILE
```

It only prints a report and checks its input again before returning. It never
loads an API, checks Bend source, runs a generated program or writes a cache.
The analysis ran on CPU0; no compiler or target timing was collected.
