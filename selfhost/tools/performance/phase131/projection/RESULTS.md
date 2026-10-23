# Verified product projection and late worker readiness

The experiment now removes real runtime work on both the existing String
comparison and an unrelated retained-root U32-list comparison. The final
prototype is **projection-source06**, using `candidate-v02.bend`,
`controls-v02.bend` and `late-workers-v03.bend`. It is an experimental overlay,
not a new qualified or installed compiler. [results01.json](results01.json)
contains the exact derived measurements and input hashes.

## What was learned

A valid scalar observer plan was insufficient: its immediate consumer had no
ordinary direct worker to retain as an owning fallback. The existing pipeline
could create that worker only *after* borrowed-call retries had already run.
For String.order, the qualified compiler retained a local recursive region
calling String.cmp and Pair.snd, rather than an ordinary worker suitable for
the verified borrowed-call adapter.

The final experiment closes the already retained raw candidate catalogue after
verified helpers become ready and **before** retrying scalar consumers. It
reuses the existing `p113d_passes`, `p128br_apply`, alias guard, owning fallback
and final `p126bp_complete` verification. It does not regenerate the catalogue
or rerun source preparation. The semantic product summary then allows the
existing evaluator to project a virtual product directly into a scalar result.
The original reader's traversal and loop remain byte-identical QBE.

These are two distinct gains. A closure-only control performs the same worker
readiness step but removes product summaries from retry. This control is
essential: most of the total short-input speedup comes from removing scheduler
transitions; product projection supplies a smaller, independently measured
additional improvement.

## Clean runtime measurements

All roles compile exactly the same frozen source, with the same runtime object,
QBE compiler, assembler alignment flags and linker. Root ran the clean
measurements on CPU3, alternating roles for five rounds after a separate pilot.
Values below are median whole-child milliseconds. Size is the common prefix
length; the repetitions are calibrated separately for each row and are identical
between its three roles. Rows cannot be compared as equal fixed work.

| Workload | Qualified parent | Closure only | Product projection | Projection / parent | Projection / closure |
|---|---:|---:|---:|---:|---:|
| String, size8 | 443.744 | 256.343 | 229.472 | 0.5171 | 0.8952 |
| U32 list, size8 | 388.235 | 241.055 | 214.149 | 0.5516 | 0.8884 |
| String, size128 | 368.590 | 328.741 | 327.260 | 0.8879 | 0.9955 |
| U32 list, size128 | 363.806 | 329.433 | 322.818 | 0.8873 | 0.9799 |

Product projection therefore reduces short-input runtime by a further
**10.5–11.2% over closure alone**, transferring to the unrelated list observer.
At length128 it adds little: the String difference is only0.45%, and the list
difference2.01%; these small differences are descriptive, not statistical
significance claims. Long comparisons remain dominated by their unchanged
traversal. Consumed in-program elapsed milliseconds agree with the direction
of the whole-child measurements. All60 timed output oracles passed.

The separate4096-prefix stack/correctness check passed all six role/program
combinations. Ordinary native outputs also passed for all roles, including
shared roots, equal aliases, shared suffixes, unique roots, Unicode and NUL
String elements. This is bounded qualification of these workloads, not broad
compiler conformance or full self-reproduction.

## Work removed

Event-only diagnostic relinks reuse each exact retained program object and the
existing reversible Phase131 diagnostic runtime. There is no runtime source
change. All six diagnostic output oracles pass, with no counter overflow or
invalid context events. The requests use size8,2048 repetitions and two warmups;
counts include setup and output. They count hooked runtime calls, not every
possible inline ownership operation.

| Counter | String parent | String closure | String projection | List parent | List closure | List projection |
|---|---:|---:|---:|---:|---:|---:|
| Dispatcher entries | 110,938 | 183 | 183 | 90,439 | 192 | 192 |
| Allocations | 41,401 | 41,398 | 4,476 | 41,413 | 41,410 | 4,486 |
| Requested words | 82,635 | 82,630 | 8,786 | 82,658 | 82,653 | 8,805 |
| Constructor takes | 61,678 | 61,676 | 43,215 | 61,679 | 61,677 | 43,215 |
| Sinks | 20,527 | 20,527 | 38,986 | 20,530 | 20,530 | 38,990 |
| Drops | 61,621 | 61,621 | 80,080 | 61,623 | 61,623 | 80,082 |

Closure removes almost all dispatch and register transport. Projection then
removes roughly89.2% of allocations and29.9% of takes **without further
dispatch reduction**. Sink/drop entry counts increase because the scalar
adapter consumes held roots directly; lower allocation counts do not mean
every ownership counter decreases. The normal distinct/shared-root admission
guard is unchanged, and unique or equal-alias inputs retain the exact owning
fallback. Counter totals do not directly measure guard branch frequencies.

The source-level independent audit is
[projection-review.md](../../../../../research/phase131/projection-review.md).
It verifies exact fallback-body equality against the closure-only public
consumer, excluding only the renamed declaration. Static audits also verify
the original String and list reader bodies remain byte-identical. The emitted
scalar readers call those original readers eagerly and contain no product
construction. Semantic legality, actual execution, runtime improvement and
full native qualification are kept separate.

## Cost and applicability to the compiler

The isolated source grows from57,018 to57,158 physical lines: **140 lines net**,
eight explicit overrides and15 new declarations. The shared helper summary
gains two fields, exact product wrapper and scalar-result binder. The module
does not introduce a runtime ABI, new IR node, backend or comparison algorithm.

The complete two-program integrated emission took22.46s for projection and
22.87s for closure-only in the bounded CPU6 correctness lane. These are single
observations with other work active, so they are not compilation-speed results.
The baseline emission was also acquired earlier. Paired same-source compiler
requests and full-scale memory behavior must be measured before adoption.
The final clean runtime campaign cost19.14 child-seconds; its pilot0.21s and
long-prefix gate0.034s. Diagnostic relinking cost0.50 guarded seconds and event
execution0.061 child-seconds. These exclude API acquisition, all source checking,
independent emission, failures and agent effort; no research-throughput gain
is claimed.

The qualified full compiler's QBE contains the same missing ordinary
String.order boundary. Its String.eq entry still goes through the scheduler.
The Bend compiler source has942 lexical String.eq call sites across362
declarations. In contrast, `p88_string_eq` and its recursive loop already have
borrowed readers and are not a new direct opportunity for this transformation.
Static call counts are not runtime importance. Prior clean profiles attribute
an overlapping10.08% of lexer and12.56% of Map active context to String.order
plus String.eq. These bound the entire family, not the projection savings.
The kernel's48% total gain must not be extrapolated to the whole compiler.

The strongest next test is the integrated compiler request screen with the
other verified Phase131 changes, followed by native qualification if that
screen is promising. The cheap shallow-record observer can compose with this
interface. Its expensive late-inlining experiment should remain separate:
raw closure admits previously blocked workers but does not rebuild an already
present caller whose body was expanded by earlier inlining.

## Negative results and reproducibility

Earlier fixture revisions exposed real source-checking errors; they remain
preserved. The first String fixture reused an already-rejected historical
Phase130 revision with missing local annotations. The final String fixture is
the qualified Phase130 baseline-v05, and the final list fixture uses checked
structural recursion with a Cmp/thunk selector. Frontend-only checking was
added before repeating integrated emission.

Source03 had a valid semantic projection plan but produced byte-identical QBE
for both programs. Source04's first worker-closure helper failed an affine
check; source05 corrected it but hooked the legacy `p128br_scanned`, which the
current raw-candidate entry bypasses. Its QBE was again byte-identical. No
runtime campaign was wasted on those identical outputs. Source06 hooks the
actual `p128raw_br_scanned` and reuses its raw candidates; this is the first
integrated positive result. This history shows why diagnostic eligibility and
successful checking cannot substitute for inspecting actual emitted code.

Current reproduction tools and evidence:

- `prepare-late-v03.py`: compose source06 or `--closure-only`, no targets.
- `cases-v05.json`: frozen current String/list fixtures and independent outputs.
- `timing-v01.py`: seal three-role pilot and calibrated clean manifests.
- `events-v01.py`: relink retained objects with the existing diagnostic runtime;
  event mode only, never a clean timing baseline.
- `selfhost/build/phase131/projection-source06/manifest.json` and
  `projection-closure-source03/manifest.json`: exact compiler identities.
- `selfhost/build/phase111/p131-projection-api06/report.json`,
  `p131-projection-closure-api03/report.json`: checked APIs.
- `selfhost/build/phase131/projection-finite06/report.json` and
  `projection-closure-finite03/report.json`:28 finite controls each.
- `selfhost/build/phase118/p131-projection-emit06/report.json` and
  `p131-projection-closure-emit03/report.json`: actual request-bound emission.
- `selfhost/build/phase131/projection-{string,list}-inspect06.json`: original
  reader preservation and actual consumer/fallback presence.
- `selfhost/build/phase131/projection-timed01/report.json`,
  `projection-long01/report.json`, `projection-events01/run/report.json`:
  clean timing, independent long-prefix gate and diagnostic counts.
- `selfhost/build/phase131/projection-compiler-applicability01.json`: static
  inspection of the actual qualified102MB compiler QBE, not a hypothetical
  observer plan.
