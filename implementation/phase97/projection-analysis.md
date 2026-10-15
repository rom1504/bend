# Consume-once lookup candidate

The isolated consume-once lookup passes its finite contracts and takes
0.318–0.345 times baseline time in six native helper shapes. The complete
compiler screen is nearly neutral: request time ratio 0.9903 and process time
ratio 0.9917. This is insufficient evidence to promote the added complexity.
Production, default images and historical methods are unchanged. Root executed
the guarded targets; this report's author prepared sources and inspected evidence
offline. Methods are in `selfhost/tools/performance/phase97/projection/`.

Phase95 showed that native shared constructor projections retain selected
fields, drop the parent, and sink unselected fields. `f_find` currently retains
the complete head definition across `dn(d)`, compares its name, then chooses
between returning that retained row and dropping it before recursion. The
candidate opens the definition once and reconstructs ordinary rows only on the
selected branch. It removes one `dn` per visited row. The original
`f_find_next` call on ordinary rows is replaced by a typed `f_find_fields` call;
index variants still use `f_find_next` after reconstruction. Those
counts describe source syntax, not measured native instruction/allocation cost.

The exact isolated patch changes `front/declarations.bend:f_find` (line 242
in canonical production) and adds its typed branch helper: 10 source lines
become 27, a net addition of 17 lines. The full candidate is derived from D04 SHA256
`d04ad79cf08c019b509cfbbd4be2b16ae9e4af189767715d12e0645b9eee8097`.
The preparer checks canonical equality, authenticates all extracted helper/type
bodies, and records both patches, byte offsets, full old/new text, hashes and
forward replay. The D04 `f_eq` uses its existing `p88_string_eq`; canonical
`f_eq` uses `String.eq`. That known equality adaptation is recorded explicitly;
the optimization does not alter either equality implementation.

The cost hypothesis is strongest for misses and late hits in shared books,
where many whole-row projections disappear. Head-hit reconstruction was a
prospective regression risk, although the measured head case improved.
Unshared books may behave differently. The benchmark therefore
keeps the original list alive, checks full aliases after timing, and separates
head/middle/tail/miss cases. A repeated-helper result cannot establish the
request mix or real compiler speed. Phase95 attributed physical cleanup owners,
not removable logical-call cost, so its percentages must not be multiplied by
this microbenchmark speedup.

The alternative twelve-call `tg(t)` chain in `infer_node` remains promising,
but its full isolated semantics require much more checker state/dependency
closure. This candidate was selected because a small extraction can execute the
entire actual operation, with no stubbed callees or simplified dispatch model.

The semantic obligation is full first-match row equality and missing-name
retention, including complete metadata and surviving aliases. The 24 new
contracts cover ordinary definitions with distinct payloads and duplicates,
empty and Unicode names, misses, colliding string hashes, and both index
constructors. `dn` exposes the neutral empty name on index constructors, so
empty-name hits must retain those exact index values. Nonempty names must skip
indexes without searching their buckets/children. This intentionally preserves
the helper's complete defined algebraic behavior rather than assuming every
caller passes only ordinary definitions.

The Phase96 executable suite constrains related `lookup` and projections but
does not extract this `f_find` caller. Its passing laws alone therefore cannot
accept this optimization. Five source mutations illustrate the gap while
leaving every old helper body intact: compare the query to itself, swap returned
type/value, erase the unsafe flag, skip an empty-name index hit, or erase a
missing query name. Newly frozen exact-value contracts must detect those
mutations after successful compilation. Formal source laws, caller contracts,
native alias controls and performance observations answer different questions.

The completed [contract campaign](../../selfhost/build/phase97/projection-contracts02/report.json)
accepted 24 complete JS results and 24 generated-C results for each role. All five
caller mutants compiled and produced their named semantic mismatches. The actual
B2 check reports still identify the trusted `@unsafe` boundary; these results
are finite executable constraints, not independently checked universal proofs.
The complete output/alias oracles were frozen before execution and unchanged
between versions. The full candidate build and balanced six-source request
screen subsequently completed; their weak result does not justify broadening.

Frozen01 baseline passed 24 JS contracts; its candidate executed no cases because
frontend loading returned a stack overflow. Offline inspection found computed
match scrutinees (`match f_eq(...)`) prohibited by `guide/GUIDE.md:123–126`.
Pinned upstream subsequently supplied the exact computed-scrutinee rejection in
[candidate01 acquisition stderr](../../selfhost/build/phase97/projection-micro-candidate01-acquire/stderr.log).
The actual frontend also describes parameter/field-only matching in
`front/flatten.bend:117`. This confirms a source-shape failure with a poor B2 diagnostic,
not an observed semantic counterexample or proof of a recursive-checker limit.
Frozen02 follows the documented helper pattern: `f_find_fields` matches a Bool
parameter and reconstructs the ordinary row only on a hit. The micro's computed
Nat comparison match uses the same repair. Cases and complete expected values
remain identical; frozen01 and its failed evidence remain untouched.

The B2-generated contract C is separately pinned in
[native-code-evidence.json](../../selfhost/tools/performance/phase97/projection/native-code-evidence.json).
The baseline product is SHA256 `20026c85c43a9815bdd5d9c4b841612c0355618c36be034920579f86112372ba`;
candidate is `2e22136a243015de31fffd53d837852438b85ad3f7ee512dfcf2f4a7a2ea42e8`.
In baseline `laws.c:6267`, `$direct.f_find` takes a list cell, retains the complete
head, and saves four plus two continuation cells before calling `dn`. Its `dn`
implementation at 2332 takes all nine fields (`ctr_take` at 2339), sinks eight
unselected fields, and returns the name. `f_find_next` at 6589 returns the retained
row on a hit and sinks it on a miss.

In candidate `laws.c:6284`, `f_find` takes the same list cell and directly takes
the nine definition fields at 6341. It retains the name for equality and saves
twelve continuation cells, then calls `f_find_fields` at 6961. The hit branch
allocates a nine-field record at 7022 and seals its fields. The miss branch sinks
all nine fields before recursion. These are emitted C sites, including scalar
no-ops, not counts of optimized machine instructions. The `dn` call and extra
whole-row alias are gone, but field retention and disposal are moved, not erased.
The shared `ctr_take` path still invokes `span_fade` (candidate 1817/1805), which
retains children before dropping the shared parent. Both contract products set
`NATIVE_READONLY_OBSERVERS=1`; their calling shape must not be treated as the
calling shape of the separately upstream-compiled timing products.

Those actual timing products are pinned in
[upstream-code-evidence.json](../../selfhost/tools/performance/phase97/projection/upstream-code-evidence.json).
Baseline C SHA256 is `a8ef5beb857e9f5b7c4c7d6e3d5373bbc9568c97aa5371e6d9710e8d7156b78a`;
candidate is `d9ba964049176b765a11b16af668eb8be77a751ee99961f5de62a9ac94c8ce2f`.
The [baseline lookup](../../selfhost/build/phase97/projection-micro-baseline02/program.c)
at 5865 retains the entire head and calls `spin_15`, the name projection at 1677.
That projection takes nine fields and sinks the four unused boxed fields; U32
fields need no sink. The [candidate lookup](../../selfhost/build/phase97/projection-micro-candidate02/program.c)
at 5840 takes the nine fields directly at 5866. Upstream inlines `f_find_fields`
into this loop, so the twelve-cell B2 continuation is absent here. Its miss path
sinks five boxed fields, releases spare storage, and jumps to the next row.
Its hit path at 5885 reuses the taken row block when unique or allocates another
block when shared, seals all fields, and returns the complete reconstructed row.
The shared-child retention implementation itself has identical bytes in both
upstream products. This is ordinary field-consumption code, not a new borrowing
primitive or a change to the native runtime.

The accepted [timing02 report](../../selfhost/build/phase97/projection-timing02/report.json)
contains 81 serial guarded executions, independent calibration, three alternating
samples per role/shape, and unchanged inputs. Medians below are microseconds per
lookup plus its arity consumer; candidate/baseline is a time ratio.

| Shared book / query | Baseline µs | Candidate µs | Candidate / baseline |
| --- | ---: | ---: | ---: |
| 128 / head | 0.610 | 0.210 | 0.344 |
| 128 / middle | 31.130 | 10.246 | 0.329 |
| 128 / miss | 61.603 | 20.667 | 0.335 |
| 128 / tail | 62.883 | 20.266 | 0.322 |
| 8 / miss | 3.852 | 1.328 | 0.345 |
| 1024 / miss | 518.000 | 164.817 | 0.318 |

Every non-timing line matches the frozen independent reference: first complete
result, success count, final complete result, and the complete surviving book.
Accepted samples lie between 200 and 800 ms. Doubling gives 1.984× baseline time and
2.231× candidate time, both within the declared 1.5–2.5 interval. Timing01 is
preserved as incomplete because its two-million repetition cap blocked the
candidate doubling sample. Root's `measure-v2.py` changes only that cap to four
million; timing windows, sampling and scaling criteria remain unchanged.

The measured composition includes the consuming `p97.token` observer. A baseline
hit returns the original shared record, while the candidate returns a
reconstructed record whose parent can be consumed uniquely; that downstream
ownership difference is part of this benchmark. Misses still scan the actual
production helper, and both roles retain the entire original book. Neither
the table nor the static source counts establish the real compiler's lookup
mix or overall speed. Each snapshot and failed attempt remains separate.

The [complete compiler screen](../../selfhost/build/phase97/compiler-screen01/report.json)
used the upstream-built native B1 baseline and the isolated candidate, with
identical request assets/Base cache and Clang O2 settings. Six frozen sources,
four balanced rounds, and two roles produced 48 byte-identical complete C
outputs and 48 exact diagnostics. Diagnostic comparison removes only the three
clock lines; stdout remains empty. Request time excludes preparation; process
wall time includes startup, preparation, output writes, and teardown. This gate
does not compile or execute those generated user programs.

| Compiler input | Baseline request ms | Candidate request ms | Candidate / baseline |
| --- | ---: | ---: | ---: |
| small | 58.0 | 58.0 | 1.0000 |
| numeric_closed | 99.0 | 98.5 | 0.9949 |
| lexer_original | 354.5 | 354.0 | 0.9986 |
| map_closed | 1405.5 | 1394.0 | 0.9918 |
| functions65 | 234.0 | 226.0 | 0.9658 |
| unicode | 57.0 | 56.5 | 0.9912 |

The equal-case geometric ratio of request medians is 0.990332487; the process
wall ratio is 0.991747900. The apparent largest gain, `functions65`, has baseline
samples from 226 to 255 ms and candidate samples from 224 to 227 ms. Their
overlap and the small four-round sample limit confidence in the median shift.
Most inputs move by fractions of a millisecond or roughly one percent. The
roughly threefold extracted-helper improvement therefore does not establish a
useful compiler speedup.

The [pinned caller inventory](../../selfhost/tools/performance/phase97/projection/caller-inventory.json)
helps define scope without estimating runtime frequency. It finds 13 textual
calls, including the one recursive call in `f_find_next`. They occur in parser
declaration/validation, contextual elaboration, syntax sugar, and import-fill
paths. Four calls deliberately supply `Nil{}` to construct a missing record
without scanning. `f_decl_local` at `front/declarations.bend:741` supplies the
book only when an indexed lookup has not proved absence. Other calls inspect
prior definitions or constructor lists, and import filling reverses its scope
before searching. Thus the repeated shared-book micro workload is not a measured
request mixture. These static sites do not reveal call counts, typical list
lengths, hit positions, or the fraction of compiler time affected.

Keep the candidate as an unpromoted law-usefulness experiment. Its new caller
contracts accept the legitimate transformation and reject five payload/selection
faults that unchanged helper laws do not cover; native alias controls preserve
the ownership boundary. The performance result adds a separate constraint:
correctness and a large helper win do not justify 17 extra production lines when
the real request screen is nearly neutral. No full-self benchmark, candidate B2
qualification, or 45-case rerun was performed after this screen. Production and
default images remain unchanged, and no further target work is justified here.
