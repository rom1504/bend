# Phase89: consume ordinary native-match products once

Status: both root-run component gates pass, and generated C confirms removal of
the repeated child-product projection path. A frozen full native02 derivative is
ready for root's checked acquisition and timing. No compiler build, target
execution or production edit was performed by this lane. Root owns serial
guarded validation, timing and any integration decision.

Phase88's native02 Map profile attributes 349/3,015 request samples (11.58%) to
the continuation implementing `nc_match_apply_slow_to`. Two physical destruction
sites account for 348 samples and are bound to retained hit/miss body strings
after parent text construction. This is stronger evidence than a generic
reference-counting hotspot. See the exact image/site bindings in
[the ownership audit](../phase88/ownership.md).

The current source lowers hit, retains its entire `NC_Code`, lowers miss using
`nc_fresh(hit)`, retains miss, and invokes five projections per child while
constructing the parent. `nc_first_error` projects errors again. Because the
whole child products remain live, output text can be copied while the old child
strings still need later destruction.

[The candidate](../../selfhost/tools/performance/phase89/composition/candidate.patch)
adds two small consuming helpers and 14 physical lines in one module. The first
matches hit's `NC_Code` exactly once and supplies its fresh field directly to
miss lowering. The second matches miss once and builds the parent from owned
body, segment and call fields. Only hit's error string is explicitly shared to
test emptiness and preserve it on the error branch. There is no new IR, cache,
chunk type, runtime patch or source-program special case.

The child lowering expressions and their order remain unchanged. Miss is still
lowered after hit even if hit reports an error. Its starting fresh counter is
hit's result, and the parent's final fresh counter is miss's result. The first
nonempty error remains hit's, otherwise miss's. Segment and call lists keep hit
before miss, including duplicate calls. The guard, condition, destructuring and
body concatenation order remain byte-for-byte equivalent expressions. Parent
body assembly still copies linked String prefixes; this is not a complete output
chunking optimization.

[Controls and commands](../../selfhost/tools/performance/phase89/composition/README.md)
first compare 19 whole `NC_Code` products in a small standalone source. Actual
types, legacy expression, candidate helper and formatting functions are extracted
from frozen modules. Independent assertions cover error/fresh state, segment and
call order, nested body markers and Emit/Halt guards. This cheap gate tests the
join only. A second full-manifest entry exercises nine actual lowering cases,
including field-count fresh changes and hit/miss closure segments, with complete
old JS == new JS == new native output comparison. Both pass root's target runs;
synthetic controls do not establish source-language conformance.

## Passing component evidence

The [19-case join comparison](../../selfhost/build/phase89/composition-control01-products.json)
passes in raw JS and native: 22,303-byte outputs are identical, SHA256
`861a6be92aa0c576d0982586c2d6676f8327127fbb59a8b614dee07946025f4b`.
Every old/candidate product and independent state/order assertion passes.

The [nine actual-lowering cases](../../selfhost/build/phase89/lowering-products01.json)
also pass old JS == new JS == new native, including every printed body, segment,
fresh counter, error and call field. The common output is 2,614 bytes, SHA256
`98d58e7288a46ae283abfb488849f737b8cfe634af7badc422a94dbd74064f4e`.
Field count raises final fresh 100→102; one/two closure branches produce one/two
segments and fresh 101/102. Both-error chooses the hit error, miss-error preserves
the miss error, and the flat escaping-closure refusal remains explicit.

## Generated ownership evidence

[Static generated-C accounting](../../selfhost/tools/performance/phase89/composition/generated-ownership.json)
pins both complete C files and every examined continuation/projection definition.
For the `NC_MATCH_APPLY_SLOW_TO` family in this component image:

| Textual operation sites | Baseline | Candidate |
| --- | ---: | ---: |
| `term_keep` | 63 | 36 |
| Direct `term_sink` | 5 | 1 |
| Body/calls/segments/fresh projection calls | 8 | 0 |
| Whole-product `NC_FIRST_ERROR` jumps | 1 | 0 |
| `String.append` jumps | 12 | 12 |
| Continuation cases | 49 | 52 |

These are static source sites, not dynamic operation counts or saved time. The
separate `NC_MATCH_APPLY_ORIGINAL_TO` family remains 15 cases and eight keeps in
this image. Inlining differs from the full compiler's Phase88 profile, where the
same source mechanism appeared under the original-route continuation name.

The baseline's `K4839`/`K4841` at lines 128885/129026 retain each entire flattened
child tuple, project a body through `spin_24`, then append while keeping the
original child fields live. Its final `K4850` at line 129636 still carries
12 saved slots. `spin_26` sinks each child body while projecting segments; the
continuation then explicitly sinks the retained miss body and other miss fields
after reading freshness. Candidate `K4905` at line 129500 carries five slots,
joins already-owned segment lists and returns the five parent fields. It has no
child-body projection or late child-body sink. Each exact case source hash,
line interval and relevant operation is retained in the accounting JSON.

The evidence therefore supports trying the full image: this source change does
alter generated lifetime handling, rather than merely renaming wrappers. It does
not remove nested text copying, and the slightly larger continuation count is a
reason to measure rather than predict a net gain from keep counts alone.

## Frozen full native compiler derivative

[`compiler-native-owned01.bend`](../../selfhost/tools/performance/phase89/composition/compiler-native-owned01.bend)
has SHA256 `31080dedefd42b08a1103ea980a7d708d7f842ef2b715d1cccb7771471395d3b`.
Its adjacent derivation receipt binds the checked native02 parent
`08ea659193cc0c5f040f209e63e9b6df71ff3c928784db81706c264b41d05e4f`.
The source map for the pre-equality `cache-js01` assembly maps the target to the
bridge definition at source line 487, separate from its law. The derivation
matches that exact native02 function against the frozen baseline plus the
existing equality adaptation; it does not substitute a whole reordered module.
Only that function and the two new helper definitions change. Exact lexical
`String.eq` calls in the new definitions use native02's existing `p88_string_eq`.
Reversing this one replacement reproduces the entire parent source byte-for-byte,
including prepared-Base/cache entry, equality helpers, imports and IO permissions.
The old source map is provenance only, not a new line map for the derivative.

Recommended decision sequence: pass the small gate, inspect generated ownership
operations, pass actual-lowering/Map/non-Map exact C, then compare native requests
with identical prepared Base and consuming-equality adaptation. Reject if body
retention merely moves or clean whole-request timing stays neutral. The 11.58%
sampled direct-site budget is a ceiling on removing those sites, not a predicted
end-to-end gain. Body destruction can move into append; affected work may already
be shared elsewhere. Do not add this budget to append samples as guaranteed
savings, or infer a cure for repeated-request growth without new measurements.

The baseline module is SHA256
`d2165a184703a0e2c9355f6cf1081b5582c9f34dd0cb22757495e8bc8fd30358`;
the candidate is
`e2b2d65ee07ef953a7d5736cd6c2e344a1f38bad0114583b47cd8e033fbee260`.
The exact patch and source receipt are retained beside the controls. The active
manifest and all other modules are read without modification.

## Full candidate screen

The frozen candidate is fully checked and emitted in
`selfhost/build/phase89/owned01/report.json`; its native executable is
`48c852be89d311d0740e74957e1eaa7f0acbcff36e8c4b29dcf9c02a4277c594`.
Acquisition took 78.32 seconds and Clang O2 took 175.92 seconds, peaking at
4.00 GiB under the separate full-build guard. Live Small/Map/Unicode checks
passed before the experimental cached comparison. Public cache admission is
unchanged; this candidate remains separate from the qualified native02 image.

Two rotated/reversed cold rounds preserve all 24 complete C outputs, plus the
three live gates. Median request milliseconds (baseline → candidate):

| Case | Baseline | Candidate | Time reduction |
| --- | ---: | ---: | ---: |
| Small | 58.5 | 59.5 | -1.7% |
| Numeric | 104.5 | 107.0 | -2.4% |
| Lexer | 479.0 | 460.5 | 3.9% |
| Map | 2096.0 | 1685.5 | 19.6% |
| Functions65 | 225.5 | 229.0 | -1.6% |
| Unicode | 55.5 | 56.5 | -1.8% |

The single five-call screen preserves all 60 C outputs. Map first/fifth changes
2086/2795 → 1850/2058 ms; the fifth-call reduction is 26.4%. Lexer fifth changes
561 → 535 ms (4.6%). Small fifth is 56 → 65 ms in this one process, so do not
claim a universal win or ignore small-case variation. These clean measurements
are separate from the instrumented operation counters. The median cold Map
process reduction is 18.9%; no TypeScript denominator change is included.

The 19.6% Map request reduction exceeds the old direct-drop sample bucket,
which was never a complete additive forecast. Reduced sharing can affect work
in other callees. Dynamic attribution of the candidate's total savings has not
yet been measured. The candidate still copies bodies and repeated Map time
still grows. The next isolated experiment is deferred body composition, compared
against both this image and the unchanged native02 baseline. Broad integration
and production promotion remain pending.
