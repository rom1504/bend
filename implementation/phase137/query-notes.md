# Phase137: complete scalar observers across real compiler query boundaries

Status: native kernel experiments now establish a composition win; full-compiler
integration source03 is frozen for independent checking and qualification. The
coordinator executed all targets. The kernel result is not a full-compiler speed
result or a promotion decision.

The qualified Phase134 compiler's actual `lookup` non-cache loop projects a
kept nine-field `KDef` twice: kind, then name. `f_find` projects its name once;
`nc_ctor_owned` projects kind before visiting an ADT's children. Phase136's
[exact-QBE audit](../phase136/profiling/query-mechanics.md) shows shared `take9`
field-reference transfers followed by unwanted-field sinks. These loops already
have local tail backedges. This experiment targets the projection boundary,
not another loop optimization and not destruction of the entire unused graph.

## Small, independently controllable source experiment

[Manifest](../../selfhost/tools/performance/phase137/queries/manifest-v01.json)
and [cases](../../selfhost/tools/performance/phase137/queries/cases-v01.json)
freeze four small programs. The original side contains 43 exact declarations
from qualified source `a0001924…fa19fb57`, including the real `KDef`,
`f_find`, `lookup`, `nc_ctor_owned`, Patricia index, equality and projections.
The extraction is packaging; source checking remains an independent gate.

The changed side replaces five expressions in three real compiler declarations:

| Location | Original computation | Complete scalar observer |
|---|---|---|
| `f_find` | `f_eq(name, dn(d))` | key-first `p137q_key_eq(name,d)` |
| `lookup` | `p88_string_eq(dk(d),"BookCache")` | `p137q_kind_eq(d,"BookCache")` |
| `lookup` | `p88_string_eq(dn(d),name)` | field-first `p137q_name_eq(d,name)` |
| `nc_ctor_owned` | `p88_string_eq(dk(d),"ADT")` | `p137q_kind_eq(d,"ADT")` |
| `nc_ctor_owned` | kind equality on the child lookup result | `p137q_kind_eq(lookup(...),"Ctr")` |

Each observer directly matches all three actual `KDef` variants and performs the
same String comparison inside that match. Index variants preserve their exact
name/kind projection constants. The original operand order remains intact.
Unknown native inputs must retain the producer's existing checked fallback; no
raw pointers, layout assumptions, runtime changes or verifier changes appear in
these source transformations.

This gives the existing optimizer a whole Boolean computation to borrow. A
linear source parameter is sufficient; `+` would permit reuse, not request a
borrowed ABI. Whether the current producer actually emits a borrowed worker is
an empirical admission question. Inspect the selected worker and its caller
before treating a faster timing as evidence of the proposed mechanism.

The intended two-by-two comparison crosses original/complete-observer source
with unchanged Phase134/width16 producer. Width16 is a separate four-bound
admission change; do not conflate its effect with the source transformation.
The unrelated transfer is an ordinary nine-field record's label equality. It
uses its own type and query, with held opaque payload/list fields. There is no
benchmark-name admission rule.

## Workload and correctness boundaries

The timed compiler workload builds 64 rows named after actual declarations in
the qualified source, then one owned ADT with one constructor. It invokes each
actual query on a late hit and a missing key. This preserves repeated raw visits
and the ownership-heavy row shape, but the constructed records are **not the
compiler's actual checked book or a sampled query distribution**. There is no
claim of a full-compiler speedup from this kernel.

The input book and unrelated record remain shared across iterations. Setup and
final reclamation sit outside the inner `IO.now` interval; report whole-process
cost separately. Each compiler iteration returns `63 + 63 + 1 = 127`, and each
unrelated-record iteration returns `1`. The numeric repeat argument gives three
stdout lines: one-iteration checksum, repeated checksum modulo 2^32, elapsed
milliseconds. All producers/compositions use the same source path and outputs.

Ordinary execution, with no numeric argument, has 23 independently specified
true controls. They cover distinct missing conventions (`Missing` retains the
requested name, `Absent` does not), first duplicate, cached duplicate, cache
sentinel dispatch before ordinary name comparison, first false-owned matching
ADT, non-constructor child shadow, cached children, non-ADT exclusion, missing
constructor, Unicode, both index variants, retained opaque value/arity, and
aliased unrelated record fields. Expected stdout was written from those
constructions, never copied from a candidate run. The index semantics remain the
actual compiler implementation rather than a replacement test index.

## Decision and limits

A successful source ceiling should remove shared nine-field projection transfers
inside the measured queries, survive the unrelated record case, and improve
runtime without losing the fixed outputs. The source rewrites are directly
transferable to the three compiler functions; an automatic general
projection-plus-scalar-consumer transformation is a later possibility, not
required for this test.

If width16 alone wins, prefer its smaller source change after checking actual
compiler scalability. If the combined variant wins substantially more, preserve
the complete-observer boundary and investigate whether that composition is
already expressible through existing preparation. If neither removes the
expected native work, reject this form before spending on a full self-build.

Phase136 placed these three active query contexts at 18.16% of full-request
samples. Their overlapping drop/fade intersection was 9.21% of all samples.
These are attribution views, not additive speed predictions. Even removing
all measured query time cannot make a 376-second cold build take 60 seconds.
The experiment is a cheap transferable first category removal; indexing or
reuse must additionally eliminate visits, and the large parsing/checking,
lowering, verification and rendering costs still need separate evidence.

Independent source review by the runtime-audit agent found no semantic or obvious
quantity blocker and checked all23 expected predicates and both checksums. This
is not source-check or native validation. Two explicit remaining coverage limits
are a key that is the exact stored-name allocation (rather than merely equal
text) and every unique-root public-adapter fallback. The held-record fixtures
exercise lifetime preservation but do not prove every native ownership path.
Also, `kind_eq(lookup(...))` still receives an owned returned child: this first
rewrite does not eliminate the entire selector or all tree/list ownership work.


## What the native experiment established

The initial two-by-two experiment exposed an optimization-order problem. The
width16 producer emitted several correct borrowed readers, but early inlining
had already copied their original owning bodies into timed callers. Only the
`f_find` call to the key-first name predicate survived and used its new reader.
The unrelated record loop retained two `take9` sites. Eligibility was real;
usefulness at the hot callsite was missing. The
[code01 audit](audit/code01.json) records this negative result.

The source-only v02 attempt specialized the three fixed kind predicates and
changed two helper signatures to key-first without changing comparison operand
order. It admitted additional kind readers, but still did not restore the
already inlined callsites. Lookup retained three `take9` sites, constructor
ownership four, and the record loop two. See
[code02](audit/code02.json). Source argument order alone was not the fix.

The decisive bounded policy preserves a function containing an exact
9–16-field consuming runtime extraction from the existing early inlining
eligibility walk. It neither grants new borrowed permission nor changes runtime
or verifier contracts. It uses the existing return-shape traversal, avoiding a
second function-body analysis. The old return-shape queries remain unchanged;
the policy is implemented by the separate `p137qi_returns` walk selected only
by `p113i_eligible`. Once the later borrow pass installs a reader, the surviving
caller reaches it. Unknown count/shape and nonmatching imports retain the old
profitability decision. Fifteen initial controls were expanded to20, including
actual inlining eligibility and malformed-IR policy-only cases.

Five fresh interleaved CPU3 rounds used the same native programs and independent
outputs. These are **complete process wall medians**, including startup and
construction, not just the printed inner-loop clock:

| Producer/source composition | Actual-query kernel | Relative | Unrelated record | Relative |
|---|---:|---:|---:|---:|
| Qualified width8 / original | 190.288 ms | 1.0000 | 227.974 ms | 1.0000 |
| Qualified width8 / fused v01 | 193.815 ms | 1.0185 | 227.691 ms | 0.9988 |
| Width16 / original | 192.402 ms | 1.0111 | 232.726 ms | 1.0208 |
| Width16 / fused v01 | 173.799 ms | 0.9133 | 229.546 ms | 1.0069 |
| Width16 / fused v02 | 173.155 ms | 0.9100 | 229.509 ms | 1.0067 |
| Width16 + retained wide consumers / fused v02 | **130.863 ms** | **0.6877** | **80.059 ms** | **0.3512** |

The actual-query loop used2,000 iterations; the record loop262,143. All observed
outputs passed. The decisive pair reduces wall time31.23% and64.88%, respectively.
The exact receipt is
[query-timing03](../../selfhost/build/phase137/query-timing03/report.json), SHA256
`45367e35e7a03cc8adf8f11add09f979dc01c29360a1aa9fd8de5f74c16f2e6b`.
Earlier campaigns remain retained rather than selecting their best samples.
No new frozen45-program score, upstream ratio or full-compiler throughput
measurement follows from these numbers.

This is useful composability evidence: preserving a profitable semantic boundary
can matter more than adding another reader. The narrow early-inlining policy
may still regress computations whose wide owning helper has no useful borrowed
replacement. Native integration must measure that tradeoff; the kernel cannot
qualify it away.

## Frozen integration for qualification

[Replay tool](../../selfhost/tools/performance/phase137/queries/prepare-integration-v01.py)
composes source03 at
`selfhost/build/phase137/integrated-source03/compiler.bend`, SHA256
`2620d59a3a20fa5d5d27bbf3b12ceb7304439b27093fff1c0f383da03e4ecf38`.
It carries exactly the three actual compiler query rewrites and five required
scalar helpers from v02 onto frozen width16 plus retention source02. It excludes
the unused generic kind predicate and all workload-specific source. The old
width9-refusal control becomes a width17-refusal control; the safety predicates
and remaining controls remain intact.

The manifest inventories nine changed qualified declarations: four field-width
bounds, one inlining eligibility choice, three query definitions, and the
explicit width-policy control. All protected verifier declarations, eleven proof
declarations, native entry and runtime are unchanged. Controls remain17 width,
20 retention and13 existing private-region cases. Source composition alone does
not establish checked-source success, native reproduction, conformance or an
acceptable broad speed/complexity tradeoff.
