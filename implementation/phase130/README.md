# Phase130 — compact prepared Base, qualified native compiler

**Native compiler request time falls11.68% in the controlled three-case block:**
Phase128 N1 is2.0412× pinned upstream; Phase130 N1 is1.8028×. The improvement
comes from removing repeated decimal transport parsing. Both scalar-comparison
rewrites were slower and are excluded.

[Design](../../design/phase130/README.md) · [Contracts](../../design/phase130/contracts.md) ·
[Mode review](../../design/phase130/mode-review.md) · [Candidate](candidate.json) ·
[Native measurements](native-results.json) · [Checks](checks.json) ·
[Output preservation](output-preservation.json) · [Cost](cost.json) ·
[Guide](../../docs/self_hosted/prepared-base-transport.md) ·
[Sealed evidence](evidence/final01/index.json) (2.14MB compressed).

## Results and scope

| Measurement | Result |
|---|---:|
| Native request time, candidate/Phase128 |0.88324×|
| Native request time, candidate/upstream |1.80283×|
| Request + machine-build child sums, candidate/upstream |0.88237×|
| Separate qualified N1/upstream block |1.79493×|
| Separate qualified N2/upstream block |1.79239×|
| Qualified N2/N1 request time |0.99859×|
| Integrated decoder proxy, candidate/old |0.63988×|
| Ordinary45 emitted QBE and allocated machine sections |45/45 identical|

The first block rotates Phase128 N1, Phase130 N1 and upstream for three rounds.
Lexer improves10.27%, closures21.13%, Map2.63%; all27 generated outputs pass.
All18 native QBE observations are identical across the two compilers. The second
block independently compares the actual qualified N1/N2 images with upstream;
do not pool it with the first block or use historical timings as paired controls.

These are **cold native source-to-QBE requests**, versus upstream TypeScript/Bun
source-to-C requests. Native uses authenticated prepared Base; upstream checks
source Base. Machine-build clocks include QBE/as/link with cached runtime versus
Clang including its runtime. Thus ready-executable parity does not imply request
parity. Upstream, source inputs, oracles, tools, CPU3, rotated schedule and machine
build flags remain frozen. No upstream migration occurred.

This is a fixed-cost improvement, most useful on short requests. It does not
establish a similar gain on a large compiler source or all possible programs.
The original45 runtime wrappers were not retimed. Instead, the ordinary45 suite
emits exactly the same QBE, `.text`, allocated data, section addresses and BSS
layout as Phase128. ELF differences are confined to nonallocated `.strtab`
symbol strings. The backend/runtime are unchanged. Phase128's1.6526× runtime
score remains the last historical-wrapper measurement, not a new Phase130 score.

## Work removed and legality

Every request previously repeated roughly325,000 numeric token reads, including
1,087,899 decimal-parser entry segments in Phase129's profiles. The new private
carrier uses two Unicode scalars per U32 instead of decimal accumulation. The
carrier grows from1,100,924 to2,612,691 UTF-8 bytes, but shrinks from1,100,924 to
662,955 runtime Unicode scalars. Fewer String cells and parser transitions win
even when file reading and reclamation are included.

The isolated exact decoder proxy takes0.374401→0.241596s across nine alternating
pairs. The integrated, backward-compatible version takes0.367932→0.235432s,
36.01% less time. Its legacy decimal path takes0.372475s,1.23% above the old
version in that block. No full-compiler percentage is inferred from this proxy.

A cursor retains two fields. Its status becomes a finite numeric mode:
0 failed,1 decimal,2 compact. The entry chooses the mode once using a disjoint
first-token range and the explicit compact stamp namespace. All downstream
reconstruction is shared. Canonical decimal spelling, overflow, Unicode, tag,
field, reference, source-span, bounds and readiness checks remain. Mixed numeric
formats refuse. The stamp is routing metadata, **not authentication**: the host
pins full carrier, producer/cache, Base and source/ABI identities. The transport
recoder has an exact byte inverse and performs no semantic lowering or native
heap injection. Compiler logic remains checked Bend.

Complete cached-preparation comparison covers88,578 object pairs and221,919
primitive comparisons against the old decoder. Fresh preparation comparison
covers125,089 object pairs and318,383 primitive comparisons. Exposed old
world/book sharing identities are preserved. The integrated gates add26 finite
predicates,32 malformed-input checks, and nine complete QBE comparisons: old,
new-decimal and new-compact on lexer, closures and Map. These are concrete
checks, not a mathematical proof of whole compiler correctness.

## Qualification and usable artifacts

The exact source is archived as [compiler-source01.bend.gz](compiler-source01.bend.gz),
SHA256 after decompression
`995d6b4bf14963debb9a810de2ed941c3cd30a71fc34a156d96b1adbd1b06bdd`.
The [candidate](candidate.json) binds source/API/runtime, N1/N2, preferred compact
carrier, legacy carrier and [qualification](native-qualification.json).

Hosted → N1 → N2 reproduces exactly102,432,076 QBE bytes. Focused19 passes on each
image (16 successful outputs,3 expected refusals); N2 passes ordinary45. N1
self-emission uses compact Base; inherited ordinary gates use decimal Base,
exercising backward compatibility. The separate N1/N2 timing block exercises
compact requests on both images. The installed Phase102 CLI is unchanged.

For the faster research route, use the candidate's authenticated **compact**
carrier receipt with `selfhost/tools/performance/phase130/native-request.py`.
The older Phase125 qualification runner intentionally still uses decimal Base;
merely substituting the new binary into that old recipe does not select compact
transport. Follow the [reproduction guide](../../selfhost/tools/performance/phase130/README.md)
and use fresh path-bound receipts when relocating artifacts.

## Rejected attempts

The safe Cmp-result rewrite takes133→149ms (1.1203×); the direct-U32 rewrite takes
525→640ms (1.2190×), each five paired rounds on the retained shared-prefix64
workload. Both pass ordinary independent outputs. Neither changes the compiler.
Cmp borrowing was already admitted: the rewrite changed traversal state and
alias fallback costs as well as product transport. Both readers still used a
generic comparison helper. The U32 rewrite also failed to demonstrate a gain.
These are not clean ceilings for projecting the existing reader's result.
The prepared69-line supplemental scalar controls were not executed after the
performance discriminators rejected the candidates.

Four initial scalar wrappers failed binder ordering, termination, Data/Type
quantity or inferred-binding checks. A later U32 wrapper had an unfilled forward
law; the first native decoder extraction omitted `kc`. All six failed guarded
attempts are retained. The initial scalar runner mislabeled IO.now milliseconds
as nanoseconds; raw outputs and wall times identify the correction, and ratios
are unchanged. Future runs use `scalar-run-v2.py`. No baseline definitions or
correctness gates were relaxed to make a result pass.

## Complexity, cost and what we learned

The frozen compiler has57,018 physical lines versus56,904: +114 (0.20%), including
67 new control lines. The implementation itself adds47 net lines. Seventeen
original declarations change and17 helpers/control declarations are added; no
new optimizer pass, reusable IR or runtime ABI is introduced. Research tools and
retained negative fixtures are separate from this compiler-source count.

Twenty-two serial guards cost1,870.65s (31.18min), including six failed attempts.
Full hosted acquisition dominates at872.50s and6,339,612,672 bytes peak, close to
the6GiB cap. Native self-emission costs399.32 guarded seconds and2.81GB peak.
The previous Phase128 historical hosted acquisition was512s/2.67GiB; this is not
a controlled same-source comparison, so the cause of that difference is not
established. Native request gains must not be sold as cheaper full acquisition.
Bounded agents prepared separate fixtures, audited contracts and inspected code;
only root executed targets. Guard cost excludes agent research and cannot measure
billing/quota. No OOM occurred.

Verified hardlinking recovered538,456,064 allocated bytes from2,596 immutable
artifact paths; full-self QBE equality allowed another102,436,864 bytes to be
shared. Contents, paths, modes/owners/xattrs and original metadata receipts are
preserved. There was one full acquisition and one native self-reproduction,
following cheap proxy experiments; no broad program-runtime rerun was needed.

The largest practical lesson is that transport and repeated materialization can
cost more than useful compiler work on short inputs. Optimizing the exact
producer/consumer boundary produced a general gain with little compiler growth.
Conversely, a superficially simpler scalar computation need not be faster when
its ownership adapter and per-character state change.

There is no demonstrated recursive research acceleration. A better next acquisition
policy is to use the qualified native producer for **byte-preserving** transport
or analysis changes after independent source checking, retaining exact reproduction
and semantic gates. Current same-source native emission is over2× faster than
hosted emission. Code-generation changes may need an extra bootstrap generation,
so the saving must be measured rather than assumed.

For further compiler gains, first profile the remaining prepared-state
materialization and repeated usage/name queries with the existing fast recipes.
A compact non-text or preconstructed-state ceiling is worth a small experiment;
do not bake a huge unchecked native object graph into the image. Complete query
projection should reuse the existing verified reader and traversal, with an
unrelated transfer case. The two negative scalar source rewrites do not justify
adding another pass. Broad parity still requires removing work outside Base
preparation, especially on lexer/Map and large sources.
