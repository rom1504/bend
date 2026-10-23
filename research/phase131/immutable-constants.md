# Immutable compiler constants exposed before static preparation

The useful discovery is a phase-ordering boundary: the compiler already knows
how to share closed immutable constructor trees, but small source helper calls
hide those trees until after static preparation. This experiment changes the
compiler's own source expression shapes; it adds no optimization pass, runtime
helper, cache, ownership rule or backend.

## The decisive small experiment

Selected Phase130 implements `atom(tag)` as `kt(tag,"",0,0,Nil{})`, and `kt`
constructs `KTerm{tag,name,id,quant,kids,Nil{},0,0}`. `missing()` calls
`atom("Absent")` twice inside an otherwise closed KDef constructor. The
ordinary helper calls survive the static-data preparation boundary. They are
inlined later, leaving dynamic allocation of two KTerm nodes and one KDef node.

`identity/missing-static-v01.bend` exposes exactly those closed constructor
trees. The existing static-data verifier and runtime handle the result.
`missing-static-emit01/report.json` records independently checked and verified
emissions; `identity/missing-inspection/report.json` records their code shapes:

| Region | QBE lines before / after | Constructor callsites before / after |
|---|---:|---:|
| `missing` worker | 153 / 7 | 3 / 0 |
| Closed `index_find` worker | 1,563 / 681 | 32 / 14 |
| `index_bucket` worker | 352 / 205 | 5 / 2 |
| Whole extracted index program | 1,228,019 / 1,087,633 bytes | 118 / 71 |

The original QBE is byte-identical to the previous qualified proxy emission.
These counts establish removed code and construction sites, not dynamic speed.

The ordinary all-successful lookup benchmark is an inappropriate primary test
for an absent-result optimization. The frozen mixed discriminator instead
alternates actual present compiler names with guaranteed absent spellings.
It constructs the persistent index and query strings before the timed region.
The independent oracle derives exact U32 checksums from the known replacement
payload sequence and zero arity for missing records; it does not implement the
index or compiler algorithm.

`selfhost/build/phase131/missing-mixed01/timing/report.json` reports median
**316 ms to 285 ms**, **9.81% less timed execution**, with exact ordinary and
timed outputs. This is a real native extracted-computation result, not a
whole-compiler speedup. Source and timing identities are pinned in
`identity/missing-mixed-manifest-v02.json`. The initial unpublished v01 expected
JSON lacked conventional status/stderr fields; v02 corrected the harness schema
without changing either program or the independent checksum.

## Broader source exposure, with exact boundaries

A lexical inventory found 425 actual bare literal `atom` calls in the selected
compiler. Four lie in protected verifier declarations. The remaining 421 calls
are spread across 286 declarations. Raw substring counting was misleading:
it also counted longer helper names such as `noa_atom`.

The source bridge checks the exact selected/current `atom` and `kt` bodies,
skips comments and quoted text, preserves qualified and dynamic calls, and
rejects shadowing of the bare `atom` name. The one dynamic `atom(name)` call is
unchanged. Every selected literal call becomes the identical eight-field
constructor with an erased KTerm type ascription. No existing verifier body or
declaration inventory changes.

The first broad draft omitted that ascription. Checking failed in 4.58 seconds
at `+shape = KTerm{...}` because constructors in inference positions need an
annotation; the original helper signature supplied one. Preserve
`literal-atoms-source01` and `p131-literal-atoms-api01` as that rejected attempt.
The corrected source02 uses `{KTerm{...} : KTerm}` uniformly.

`literal-atoms-source02`, SHA256
`7d1f2bef2a97a579783930e18b5004d9554a0179b30983db6fb810bd8143f56d`,
combines the earlier FAST algorithms with all 421 exposures. It adds 17,261
source bytes and no declarations or physical lines per replacement. Its checked
API completed in 14.73 seconds with 2.18 GB peak process-tree RSS. The following
bounded gates passed:

- 336 whole-tree comparisons and 11,088 exact lookup comparisons.
- 11,088 reads of independently generated trees and 840 malformed-tree reads.
- 2,656 exact catalogue/cache/duplicate-result controls.
- 22 usage controls and 16 actual Base-body usage comparisons.
- Six complete QBE outputs for lexer, closures and Map, each byte-identical to
  its frozen qualified oracle (`literal-atoms-request02`, 44.40 seconds).

Those hosted checks do not establish native compiler speed. Their diagnostic
times also include the other FAST algorithm changes, so they cannot isolate
the contribution of literal exposure.

## Final composition replay

The later combined compiler includes first-order safe usage summaries, closed
lookups, projection/borrow capabilities and the already exposed `missing()`.
Applying the old whole-definition overlay would risk reverting those changes.
Instead, `identity/expose-current-literals.py` patches only literal call spans
inside the current bodies of the original reviewed declaration set.

Its first output is `combined-literals-source01`, SHA256
`1bc5930edcf80cda6c3572645df3c846fa631a83c2b936f20c83b05e0a6728f9`.
The direct parent is `combined-regions-source01`, SHA256
`75a9c4ad4ed01ae7e731bb1167d7a84959c74bab778ecabdcafbb81d305e5929`.
There are 419 remaining replacements across 285 declarations because the two
calls inside `missing()` were already handled. Growth is 17,179 source bytes
(0.65% of that parent), zero declarations. All 91 protected verifier
declarations and 11 selected proof declarations remain byte-identical to the
direct parent. The manifest retains every replacement and source identity.

Full combined checking, native qualification, self-reproduction and complete
request timings remain the coordinating lane's separate admission decision.
The installed compiler is unaffected by these source patches alone.

## Interpretation and limits

This supports exposing immutable construction before a stage that can optimize
it. It does not establish that arbitrary calls can be evaluated at compile time.
Effects, unknown arguments, recursion and error ordering remain excluded.
Source equality also does not prove physical ownership behavior: sharing and
uniqueness guards can change, so the existing static-data/runtime contract and
independent execution checks remain essential.

A future small general constructor-factory exposure rule could remove the
source duplication if profiling and compilation-cost measurements justify it.
That is distinct from the parallel prepared-body reuse investigation, which
addresses a later pass resurrecting raw constructors after static preparation.
Both indicate that making existing optimization results compose may eliminate
more work than adding another independent special-purpose optimization.
