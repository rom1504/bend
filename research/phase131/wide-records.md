# Wider borrowed records: bounded compiler-query falsifier

Frozen final Phase131 source `1bc5930e…` remains unchanged. This experiment
copies it and raises exactly four field-count bounds from 8 to 16: `nol_fields`,
`nol_ctor_fields`, `p131rg_width`, and the derived-import contract in
`p118b_project_borrow`. All 91 protected verifier declarations are byte-identical.
Runtime, native calling conventions, buffer verification and the late inline
field template remain unchanged. Wider field reads use the existing runtime
helper, which checks the actual constructor and exact field count.

The width audit established that 8 was an admission limit, not a physical ABI
limit: the existing scratch buffer holds 2,048 bytes and 16 fields require 128.
Constructor-count, parameter-count, continuation and packed single-field limits
are separate and are not widened. See
`selfhost/tools/performance/phase131/regions/identity-width-audit.md`.

Two small programs share independent ordinary controls. The first copies the
actual selected KTerm/KDef representation and `dn`/`da` declarations, then asks
the whole scalar query `String.eq(dn(record),key)`. KDef's main constructor has
nine fields; its index constructors remain present. The second uses an unrelated
nine-field record with opaque lists and a KTerm payload. A sixteen-field record
is an additional ordinary positive control. Timed queries retain the records,
perform one name hit and one miss, and return one per iteration. Ordinary
controls also check retained arity, opaque list length, empty-name index leaves,
separately spelled equal names and Unicode. Expected outputs are derived from
the fixture constructors rather than target outputs.
The source bridge in `selfhost/build/phase131/wide-source-bridge01/report.json`
authenticates all seven copied compiler declarations against the frozen final
source, ignoring comments and whitespace only.

The initial finite test accidentally used **emitter** constructor IDs as the
independent verifier catalogue. Even its existing eight-field positive failed,
revealing the test mistake before native execution. The failed API/finite
receipts and `controls.bend` are retained. `controls-v02.bend` uses the actual
`p111v_put` verifier metadata; compiler overrides did not change. It passes all 17
predicates, including 8/9/16 acceptance,17 and packed refusal, mismatched/unknown
constructor refusal, state/result type refusal, insufficient/unknown buffer
refusal, 128-byte buffer acceptance, and continued refusal of the wider late
inline template. Malformed/dependent telescope rules remain unchanged; this is
not an exhaustive proof over all possible record declarations.

Candidate source `5b889d04…` checks through the independent upstream-built API
in 14.87 guarded seconds, peak 2.20GB. Baseline and candidate both emit the two
programs with original parent verification and final independent verification.
All four aligned native products pass the same 11-line ordinary oracle; their
combined build/output check takes 0.96 seconds. Exact receipts:

- `selfhost/build/phase111/p131-wide-api02/report.json`
- `selfhost/build/phase131/wide-finite02/report.json`
- `selfhost/build/phase118/p131-wide-{baseline,candidate}-emit01/report.json`
- `selfhost/build/phase131/wide-builds01/report.json`

Actual candidate QBE contains new borrowed readers for all three scalar queries.
The KDef reader has 292 lines with five static fallback read sites covering its
constructor branches; the unrelated nine-field reader has 48 lines/one import,
and the sixteen-field reader 62 lines/one import. These readers contain no root
sinks or destructive takes. Their public adapters retain the original guarded
owning fallback and two root sinks. The timed caller still calls the selected
public query directly, so this experiment does not suffer the earlier inlining
bypass. The compiler-kdef QBE grows 567,614→593,474 bytes; code size is a cost.

Root-owned timing completed all 20 observations in 3.00 guarded seconds: five
rotating paired rounds, two families, 262,143 iterations. Every exact checksum
and output check passes.

| Whole scalar query | Baseline median | Candidate median | Time reduction | Internal timer medians |
|---|---:|---:|---:|---:|
| Actual KDef name query | 0.124640s | 0.084157s | **32.48%** | 123→82ms |
| Unrelated nine-field record | 0.137857s | 0.081294s | **41.03%** | 136→79ms |

Every pair improves. Candidate/baseline pair ratios range 0.618–0.679 for KDef
and 0.574–0.601 for the unrelated record. Internal timers stay at least 79ms;
startup and integer-millisecond quantization do not explain the differences.
These five observations are a bounded screen, not a confidence interval or
large-program generalization. Summary and actual generated callsite evidence:
`selfhost/build/phase131/wide-results01/report.json`, reproduced by
`selfhost/tools/performance/phase131/identity/wide/analyze.py`.

The demonstrated capability is wider scalar observation under existing root
ownership. Destructive field extraction/reclamation inside these queries is
replaced by a checked borrowed read, and it transfers beyond the compiler's
record type without a named-record recognizer. The old owning fallback remains.

There is **no measured whole-compiler benefit** or native self-hosting
qualification for the wider source. Merely supporting KDef layout does not
remove the owned-result boundary in `p111v_get`/`index_find`; a complete scalar
lookup consumer remains a separate hypothesis. Preserve this promising four-
bound candidate for the next controlled integration, without replacing the
qualified compiler or launching another broad campaign solely for these wins.

## Composition with the proved scalar bucket selector

A final bounded test composes the two existing capabilities, without adding an
optimizer or changing source algorithms. The exact already checked
`selector-ceiling/fused-v03.bend` and `fused-short-v03.bend` programs are compiled
again with the wider producer. Their controls remain the existing final-producer
binaries of those **same fused sources**, not the older unfused algorithms.
Both new binaries pass the independent 34-line oracle and both emissions pass
the original and final verifiers. The new emission/build screen takes 35.85 plus
0.81 guarded seconds; no full compiler image is acquired.

| Same fused scalar selector | Final producer | Wider producer | Time reduction |
|---|---:|---:|---:|
| Ordinary one-entry leaf | 0.107089s | 0.052844s | **50.65%** |
| Forced 64-entry collision bucket | 0.465811s | 0.177247s | **61.95%** |

All 12 exact-output timing observations pass. Three paired ratios lie within
0.493–0.498 for the one-entry case and 0.380–0.381 for the collision stress case.
Internal timer medians 105→51ms and 464→175ms support the complete-child result.
The fastest one-entry internal observation is 50ms, so this remains above the
timer floor. Do not multiply this block's ratios by the separate source-fusion,
wide-name-query or owning-identity results; they measure overlapping work in
different programs and observation windows.
The collision workload is intentionally adversarial and is reported separately;
neither number is a whole-compiler estimate. Evidence:
`selfhost/build/phase131/wide-selector-results01/report.json` and
`wide-selector-timing01/timing/report.json`.

The useful boundary is now explicit. The owned `p131sc_bucket` body had 290 QBE
lines, two static destructive-take sites and 32 static sink sites. The existing
observer pipeline can now derive an 816-line private reader with no takes or
sinks; it retains 15 generic borrowed-read fallback sites and a 17-line public
guarded adapter. Actual callers continue to target that adapter. Code growth
and the copies performed by those generic reads remain costs, not erased work.
The complete collision-program QBE grows 949,672→991,504 bytes (4.40%).

Scalar continuation fusion by itself had mostly moved owning projection into
the bucket worker. Wider layout admission lets the existing borrower preserve
the entire scalar computation over the held list and record descendants. This
is concrete evidence for **composing semantic capabilities**, and it identifies
a better next optimization boundary than another isolated getter tweak.
Automatic preservation of scalar consumers through real `index_find` callers,
including all malformed finite/tree/cache semantics, still needs a separately
checked transformation. Protected verifier source and the qualified compiler
remain untouched.
