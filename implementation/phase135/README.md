# Phase135 — Incremental compiler rebuilds, measured at full scale

Work in progress from `17a9e43`; [design](../../design/phase135/README.md) and
[edit contract](../../design/phase135/edit-contract.md). The qualified Phase134
compiler and installed selection remain unchanged. The experimental compiler
source and its native image are separate from that qualified selection.

## First result: cache hits are not the objective

The existing Phase134 native session successfully compiles two complete compiler
revisions and reproduces both independently retained 107 MB QBE products exactly.
The real edit changes `p111q_main`'s local output spelling from `%result` to
`%answer`, with every other source byte unchanged. These are the historical
Phase131/132 compiler sources, not a claim that the newest compiler has completed
incremental self-hosting.

| Native session | Time | Prior inline hits | Inline misses |
|---|---:|---:|---:|
| A, acquire semantic cache | 362.510 s | 0 | 1,507 |
| B, actual compiler edit | 374.922 s | 1,387 | 120 |
| Ordinary B, same executable, no semantic cache | 364.183 s | — | — |

Base/session preparation took 318 ms. The native process took 737.793 s; the
outer guard took 741.526 s with a 1.105 GB sampled process-tree peak. Both products
are byte-identical to their independent references. All execution used CPU3 with
no concurrent target checks.

The 92.0% hit rate does **not** establish faster compiler development. A and B
have different inputs and preparation boundaries; their times are not a valid
warm/cold speed comparison. The separate same-executable ordinary B baseline
also matches the independent product. Its complete native process takes
364.183 s; warm B's interval is 2.95% longer despite excluding shared startup and
Base preparation. These are single observations with different clock boundaries,
not a stable regression estimate, but they provide no adoption benefit for this
cache on compiler rebuilds. The current session still checks and prepares the
source, lowers candidates, verifies the result and renders the complete output.

Evidence: `selfhost/build/phase135/full-session01/report.json` and its frozen
plan; compact archival receipts will accompany the final report.

## A compiler-owned boundary for machine reuse

The experimental Bend emitter announces complete function bundles, data and
main through a narrow comment-framing protocol. Its sealed cursor supplies the
boundaries; the host does not rediscover functions by parsing the complete QBE.
Groups contain up to 1,000 complete bundles. A bundle may contain several QBE
functions. Data remains current and is never treated as an unchanged fallback.

The host hashes one bounded unit, reuses or builds its object under exact
payload/tool/runtime identities, and links the ordered current objects. This
removes the previous whole-file boundary-discovery scan. It does not yet skip
frontend work, lowering or rendering. Generated internal definitions are made
link-visible in a closed executable using `objcopy`; allocated bytes and
relocations must remain exact. This is not a shared-library ABI change.

The small test passed on Lexer, closures and Map: cold builds, all-hit reuse and
independent empty-cache builds produce matching loaded machine images, with
outputs matching independent monolithic programs. This exercises the checked
Bend frame view and host object pipeline; the actual native FIFO writer and
complete edited compiler are subsequent gates, not established by this test.

Source checking, 121 finite controls and a pure stage-orchestration comparison
also pass. The latter compares complete outputs, cache state, counters and
refusals before acquiring the instrumented native image. Stage clocks distinguish
frontend, raw lowering, optimization/verification, and rendering/writing. When
writing to the machine pipeline, rendering time includes consumer backpressure.

## Preparation reuse: retain the narrower claim

The private-candidate preparation audit rejects a body-only or Ref-only cache
key. Its consumed facts also include signatures, constructors, ownership, type
normalization, readiness, prepared bodies and cross-function transformations.
Omitting these dependencies would make a cheap cache unsound.

An isolated constructor-ownership summary passes source checking and 29 finite
controls against the original query, including ordering, absence, duplicate
names, hash collisions and cached-child refusals. It has not demonstrated a
performance improvement and is not included in the framed native image. Its
late insertion misses earlier ownership queries, while its fallback wrapper
adds lookup work. Do not promote it on the strength of correctness alone.

## Remaining measurements

- Same-executable uncached B versus the observed warm B, with clock boundaries
  explicitly identified.
- Native frame emission, producer-success joining, actual edited compiler object
  reuse, and an independently rebuilt current machine image.
- Small compiler-request and ordinary-program gates against the monolithic
  reference, including partitioning's effect on compiler execution speed.
- Complete acquisition/update cost, stage attribution, peak memory, retained
  artifacts and source/tool complexity. No new broad runtime or N1/N2 score is
  implied by bounded experimental qualification.
