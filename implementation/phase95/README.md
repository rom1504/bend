# Phase95: native ownership attribution and early-exit membership

Profiles now connect native runtime cleanup to concrete compiler helpers. A
two-line simplification makes selected membership hits dramatically faster, but
the actual compiler screen is neutral and full self-input takes only **1.2%
less time in one pair**. Keep the experiment; **do not promote it**. Production
source, installed images and established performance metrics remain unchanged.

[Design](../../design/phase95/native-ownership-attribution.md) ·
[Profiling experiment](../../experiments/phase95/P95-001-native-ownership.md) ·
[Membership experiment](../../experiments/phase95/P95-002-eager-membership.md) ·
[Methods](../../selfhost/tools/performance/phase95/README.md) ·
[Independent review](method-review.md) ·
[Machine-readable result](../../selfhost/tools/performance/phase95/evidence01/summary.json).

## What the profiles establish

The baseline is unchanged native D04 source, upstream-built B1 `6bb07e94…`,
upstream `0592662`, and the Phase90 installed release. The unchanged Phase88
sampler uses an executable-specific unwind table to recover at most three
physical return addresses from cleanup routines. It requires no compiler rebuild,
frame-pointer change or speculative stack scan. Existing clock marks separate
Base/runtime preparation from compilation requests.

Five Map requests at an 8ms sampling interval produce an accepted capture:
987 total samples, 962 request samples, no overrun or drop, and five exact full C
outputs. Cleanup accounts for **56.44%** of request samples. An earlier 4ms
attempt has one overrun and remains rejected. The wrapper explicitly checks loss
counters; the historical analyzer alone would have accepted it.

One full self-compilation also produces the exact **38,614,882-byte C** oracle.
It has 17,334 samples, including 17,246 request samples, but two timer overruns.
The strict profile is **rejected**; a separate reader labels its descriptive
analysis exploratory. Two unrecorded expirations out of 17,336 are 0.01154%, but
that does not waive the declared quality rule. No retry was run merely to get a
passing capture. Cleanup accounts for 68.10% of the recorded request samples.

| Physical owner | Map cleanup samples / request | Full-self cleanup samples / request, exploratory |
| --- | ---: | ---: |
| String comparison, `p88_string_eq` | 8.52% | 27.08% |
| Boolean branch closure disposal, `nt_choose` | 11.12% | 1.50% |
| Term branch closure disposal, `kc` | 2.39% | 7.87% |
| Term tag projection, `tg` | 8.32% | 2.50% |
| Term children projection, `ks` | 4.68% | 1.14% |
| Membership, `nb_contains` | 0.21% | 2.57% |

Adding each helper's disjoint own-leaf samples gives full-self equality **31.88%**,
membership **3.51%**, `kc` **8.41%** and `tg` **3.22%**. These are not estimates
of removable time. Tail dispatch erases logical callers, so equality costs cannot
all be assigned to membership. Inline allocation has no separate frame: these
profiles do not count allocations or provide a complete Bend call tree.

Generated C explains the ownership work. Shared constructor projection retains
fields and drops the parent; unselected fields are then sunk. `tg` and `ks` take
the eight fields of a term to return one field. `nt_choose` and `kc` discard an
unused closure. String comparison takes both string cells and may release shared
tails. `term_drop` itself uses an explicit heap-threaded walk, not C recursion.
The generated `spin_*` names were mapped against this exact image, rather than
assuming historical numbering still applied.

The qualified native B2 product has the same consuming source patterns, including
`NATIVE_READONLY_OBSERVERS 0`. That is a static observation, not a B2 profile or
permission to enable borrowed observers globally. Full-self temporal bins put
membership mainly between 60 and 110 seconds and closure disposal late in the
request. These bins are not independently instrumented compiler stages.

## The bounded intervention

In `native/tables.bend`, `nb_contains` computes a head comparison OR a recursive
tail membership result. Bend evaluates ordinary Boolean arguments eagerly, so a
head match still traverses the tail. Existing `has_name` branches on the
comparison before recursing. The candidate delegates to it, removing **two
assembled lines / 81 bytes**, without adding a helper, data structure or pass.
It preserves dependency discovery order and every list representation.

Five actual D04 definitions were extracted unchanged. The control source covers
19 membership cases plus final consumption of a surviving shared list: empty
lists/strings, head/middle/tail/missing entries, duplicates, prefixes, Unicode
and non-normalization. All 20 stdout lines match independent expectations.
The same list can be queried repeatedly and then consumed intact.

The intended semantic law is finite-list membership equivalence using the same
pure equality. This phase does **not** claim an independently checked proof of
the existing unsafe, mutually recursive `has_name` pair. Phase94's safe generic
proof method remains available, but its proof cannot be transferred to a different
unsafe implementation by analogy.

Native helper benchmarks construct dynamic names before the clock, retain shared
roots across calls, and check independently expected consumed checksums. Each
role calibrates separately because early-hit costs differ greatly. Three
alternating rounds give 36 measured samples, all at least 237ms; elapsed time is
normalized per invocation. The timed interval includes loop/checksum printing
and the final root release, but excludes construction and process startup.

| List size / query | Baseline µs | Candidate µs | Candidate / baseline |
| --- | ---: | ---: | ---: |
| 8 / head | 0.4368 | 0.0570 | 0.1304× |
| 128 / head | 7.0781 | 0.0612 | 0.00865× |
| 1024 / head | 55.6805 | 0.0649 | 0.00117× |
| 128 / middle | 7.1859 | 3.5996 | 0.5009× |
| 128 / absent | 7.2616 | 7.6898 | **1.0590×** |
| 128 / tail | 7.0098 | 7.1967 | **1.0267×** |

The mechanism is clear, including its tradeoff: early matches avoid work, while
misses and tail hits become modestly slower. Head-hit speedups are not general
compiler speedups. First-case doubled counts take 1.954× and 1.916× time, which
passes the predeclared scaling interval. Both helpers use identical Clang C11/O3
flags; the final evidence separately binds build receipts omitted by the original
micro runner's input list.

## Actual compiler comparison

The isolated candidate source is `84789809…`, created by one exact replayable
replacement in D04. Pinned upstream checks it and emits C; Clang O2 matches the
baseline native B1 build. No generated C, upstream source, production module or
installed image is patched. Acquisition takes 53.28s and Clang takes 175.12s.

The six-source screen swaps only the B1 executable, preserving input, prepared
Base, runtime and providers. Four balanced fresh-process rounds give 24 pairs.
All 48 complete C outputs match their qualified oracles.

| Compilation request | Baseline median ms | Candidate median ms | Candidate / baseline |
| --- | ---: | ---: | ---: |
| Small | 58.0 | 58.5 | 1.009× |
| Numeric | 99.5 | 99.5 | 1.000× |
| Lexer | 357.5 | 357.0 | 0.999× |
| Map | 1396.5 | 1389.0 | 0.995× |
| Functions65 | 228.0 | 225.0 | 0.987× |
| Unicode | 57.5 | 57.0 | 0.991× |

The equal-case means are **0.996642× request** and **0.999952× process wall**:
effectively neutral. All outliers remain, including a 1484ms candidate Map request.
Millisecond request clocks and the guard's process polling limit interpretation
of small changes. This screen is not reported as a general 0.34% improvement.

The full-input pair compiles the **same original D04 source** with both images:
baseline request **138.029s**, candidate **136.418s** (0.9883285×); process
138.778s versus137.146s. Both emit the exact original C and the same existing
3,987-definition unsafe/foreign proof-trust refusal. This is successful source
emission with an expected proof refusal, not whole-compiler verification.
The roughly1.2% difference is one ordered pair, not a confidence interval or a
qualified general speedup. It does not establish candidate-own-source B2 behavior.

All **45 original native benchmark C products** also match exactly. Together
with the screen and full-input pair, there are **95 exact complete C comparisons**.
This preserves the relevant program artifacts; recompiling them with Clang and
rerunning their timing suite would not answer a new question here.

Do not spend another native/JS release cycle on this evidence. The early-exit
mechanism is real, but its beneficial occurrences do not dominate these actual
requests. Profile ownership fractions alone could not predict the hit distribution
or the miss cost. Keep the exact patch available for a later combined simplicity
change; do not claim its tiny measured difference closes the parity gap.

## What remains true of the five metrics

| Metric | Outcome |
| --- | --- |
| Compiled-program speed | Candidate exact-C continuity checked against the original45 corpus; no new runtime timing claim. Installed Phase93 metrics remain1.114840× upstream C over44 measurable points,1.139377× with equal source weighting. |
| Native B1 compilation | Six-source screen neutral; unchanged D04 full-input pair138.029s versus136.418s. No promoted speed change. |
| Native B2 compilation | Not rebuilt or retimed. Qualified historical full-self request remains152.191s, versus48.394s TS/Bun. |
| Conformance | Twenty helper-control output lines and exact complete C comparisons. Existing native69 positives+3 rejections per stage,31 import/provider exclusions and JS B2 diagnostic-fidelity gap remain unchanged. |
| Simplicity | Candidate removes two lines/81bytes, no new production concept. Unpromoted, so maintained production remains132 modules/32,692physical lines. Experiment tools and evidence are separate. |

## Better next experiments

The larger opportunity is **the ownership cost of observing shared values**.
It appears in several unrelated operations, making it more promising than another
membership-only optimization. Reuse the actual native helper pipeline before
paying roughly four minutes for another full compiler image.

1. In `check/kernel.bend:infer_node`, bind `tg(t)` once and reuse it in the twelve
   tag comparisons. Test early/late/unknown tags, every constructor and retained
   child payloads; inspect whether generated C actually removes repeated full
   term projection. This is a small source intervention, with a ceiling bounded
   by only part of the measured `tg` traffic. It is not a parity proposal.
2. In `front/declarations.bend:f_find`, test consuming the definition fields once
   per candidate instead of observing `dn(d)` and later disposing another
   retained definition. Preserve first-match order, duplicate and empty names,
   `Missing`, index variants and surviving shared inputs. Reconstruction on a hit
   may cancel the saving; definition-name traffic is not exclusively this caller.
3. For a larger gain, investigate borrowing or fusing read-only projection and
   comparison in generated native code, and eliminating unused closure captures
   in dispatch. First demonstrate fewer retain/drop operations on exact small
   shapes. The combined equality bucket is large, but source aliases, unsafe
   observer permissions and retained roots are real correctness obligations.
   Changing a global runtime flag is not an acceptable proof of legality.

Prior Phase88/89 Bool-first comparator rearrangements failed checked recursion or
match ordering and did not establish borrowed traversal. Do not repeat them as an
untried shortcut to the31.9% equality bucket. The actual native B1 is generated by
upstream C, whereas native B2 uses our C backend; an emitter-only improvement
must be evaluated on the stage it can change. Keep these host/generation
boundaries explicit when choosing the next intervention.

## Preserved failures and measurement limits

Two small source versions failed before executable generation: a shared natural
number lacked its affine `+` annotation, then a `+` tuple destructuring form
could not be inferred. Frozen01/02 preserve them; frozen03 supplies a separately
annotated helper and is the sole source for the final measurements. An initial
micro campaign reached its repetition cap at the doubled-count check; its
partial results are excluded. V2 changes only that cap and starts a fresh run.

The first full-image build request was rejected before launching Clang because
its 6GiB RSS allowance requires 16GiB available-memory headroom. The corrected
invocation keeps that guard unchanged. Rejected profiles retain raw samples and
their original status; the exploratory self reader does not repair or rescale
them. No PR comment was posted.

## Cost and retained evidence

Two agents handled offline source/method review; root alone ran targets under
the serial execution guard. There were **217 guarded jobs**, **752.47s** total
target occupancy, **4.00GiB** peak process-tree RSS, no overlap, deadline or memory
stop. The interval from first target start to last target finish was33.42minutes;
it includes preparation/reasoning gaps and is not an agent-work or quota estimate.
The two nonzero target exits are the preserved micro-source rejections.

The accepted helper campaign occupies18.60s including calibration; the paired
six-source screen21.99s; broad45 continuity39.26s. The expensive decisions are
full compiler acquisition/build228.40s and the full-input pair275.92s. The full
profile adds138.82s. Future experiments should pass the small native mechanism
test before incurring those full-image costs. Do not spend another275s repeating
a tiny full-input difference merely to polish its percentage.

The [evidence capsule](../../selfhost/tools/performance/phase95/evidence01/archive.json)
preserves and verifies **824 files** by exact byte readback in a24.1MB archive:
raw samples, quality failures, extracted products, candidate source/C/executable,
build receipts, all timings, output C, diagnostics and failed attempts. It stores
Phase95 artifacts; referenced Phase92/93 baselines retain their own authenticated
evidence. CSV tables and execution ledger are alongside it. Production/images
were not changed, and no unqualified candidate was selected as a default.
