# Phase102: ambitious native campaign

Status: execution started 2026-10-16 20:09 UTC; planned window approximately
three hours. [Design](../../design/phase102/ambitious-native-campaign.md).

Baseline is commit `41f758c3`, installed Phase98 native B2 and pinned upstream
`059266225b77c8ca256ac6b25ee5c21449bab151`. Phase101's chunk representation remains
an uninstalled generated-C experiment. This report will retain tested variants,
results, failures, source integration and qualification boundaries separately.

Three offline preparation lanes cover linked-storage iterative append,
whole-function typed lowering, and fusion/build work. The leader owns the serial
guarded target queue and integration. All numbers below are early screens;
installed releases remain unchanged.

## First mechanism screens

The existing linked String representation can retain a substantial part of the
Phase101 renderer gain. Iterative append with exclusive-cell reuse reduces
complete rendering time by 26.4% at one worker and 22.3% at four workers in four
alternating rounds (`linked-append01`). Indexing is neutral (`linked-index01`),
and DAG800 is neutral/slightly faster. RSS falls from about81MB to53MB, compared
with26MB for Phase101 chunks. Copy/free instead of cell reuse still improves
rendering by19–22% (`linked-copy01`), separating continuation elimination from
the additional reuse benefit. Independent String controls pass90 executions
(`linked-controls01`), including shared tails, arrays and parallel use.

A general saved-C transformation composes existing admitted one-result NF
workers into scheduler parents, retaining original argument and ownership
operations. The first screen improves indexing by27.0% on generated10000 and
37.8% on the frozen compiler text (`typed-index01`). This is source indexing,
not compiler request latency. There is no application-name selection.

Combined linked append and call composition (`linked-typed01`) gives:

| Complete application | Candidate / installed B2 | Candidate / upstream |
|---|---:|---:|
| generated10000 source index |0.738|1.139|
| compiler-text source index |0.621|1.336|
| renderer, one worker |0.723|0.951|
| renderer, four workers |0.723|1.074|
| DAG800 |1.000|0.337|
| chain1000 |1.040|0.347|

The chain difference needs confirmation. The corresponding chunk combination
(`chunk-typed01`) retains a DAG regression (~8.4%), so changing the global String
ABI is still not justified. One generated-input screen also has unusually slow
times in all three roles; retain those samples rather than treating small ratio
changes across independent runs as established gains.

## Source integration and rejected paths

The first23-line Bend direct-call implementation checks successfully, but its
three emitted applications are byte-identical to baseline (`typed-api01`,
`typed-emission01`). Its host-plan permission is stronger than the File-provider
permission used by source-index. This is a failed activation experiment, not a
successful compiler optimization. The tiny differences in `typed-bend-screen01`
measure noise between identical C products. A revised narrow local-call plan is
being checked separately, preserving existing packing/sharing permissions.

The build lane found that per-program tables and generated segments dominate
application C; the common runtime is only~84KB of555–748KB. A two-round renderer
screen (`build-screen01`) finds compact reversible identifiers reduce Clang time
by only3.0%; a shared-prefix PCH is neutral for warm builds and adds preparation
to clean builds. This does not justify runtime object extraction or a build-speed
claim. The lane is now pursuing generic tail recursion through constructors and
reusing the already-tested Phase99 branch specialization.

All named runs are under `selfhost/build/phase102/`. The final report will bind
their exact receipts and preserve failed/inactive candidates, source derivatives,
control boundaries and measured time/resource accounting.

## Actual Bend compiler implementations, first hour

The scoped local-call plan activates in the actual native request path without
granting the stronger representation/packing permissions. `typed-bend-source02`
reduces compiler-text indexing to128.9ms versus211.9ms installed and97.2ms
upstream (`typed-bend-screen02`, four alternating rounds). This is compiler
logic written in Bend, acquired as a checked JS testing API; it is not yet a
native B1/B2 image qualification. Source03 also fixes device-source visibility:
only the already-proved no-bang scope marks these segments host-only.

Unchanged-ELF sampling of source02 (`typed-profile01`,641 candidate and451
upstream pooled samples, two periods) confirms that the three formerly hot
continuations disappear. The next bottleneck is the index loop itself (39.6%
of candidate physical leaves), followed by `term_drop` (19.8%). Admission
diagnostics show that this loop lowers successfully but cannot be admitted
because its dependencies include a mutual String-comparison cycle. The next
experiment reuses an existing proved owning observer adapter to break that
admission barrier; it does not permit arbitrary recursive C calls.

Generic tail recursion modulo a final constructor field (`trmc-source04`) now
replaces the special-case append idea with a structural transformation. It
also activates in graph constructors `dp_push` and `dp_roots`. With scoped
direct calls and the reused Phase99 branch specialization, its first screen is:

| Complete application | Candidate / installed B2 | Candidate / upstream |
|---|---:|---:|
| generated10000 source index |0.613|1.054|
| compiler-text source index |0.574|1.242|
| renderer, one worker |0.796|1.066|
| renderer, four workers |0.727|1.163|
| DAG800 |0.882|0.297|
| chain1000 |0.892|0.324|

`trmc-screen01` compares all complete output bytes in four alternating rounds.
Renderer RSS falls from81MB to53MB. These are promising application results;
dedicated ownership/refusal/error controls and native image gates are pending.
The candidate adds338 physical lines over the installed source before observer
forwarding. No global String representation change is needed.

Failed experiments remain recorded: TRMC source03 initially failed checking
because two helper matches were nested under local binders; source04 corrects
the syntax. The first construction witness needed explicit String annotations.
The three successful application emissions in that otherwise-incomplete run
are bound by an explicit subset receipt, not by relabeling the parent run.
Observer source02 likewise failed checking on a local match and is being fixed
in a new version. The early canonical append matcher also missed normalized
application annotations; its correction is retained but generic construction
is the preferred integration if it passes the broader gates.

## Composition and the next measured bottleneck

Owning-observer forwarding now admits `index_lines`, `String.eq` and
`String.order` without allowing a recursive C call cycle. The exact emitted
indexer has64 NF functions, no missing NF targets and no recursive NF SCCs.
Its loops use local jumps. `observer-screen01` improves compiler-text indexing
to111.8ms (0.546× installed,1.183× upstream) and generated indexing to63.35ms
(0.582× installed,1.014× upstream). The corresponding unchanged-ELF profile
(`observer-profile01`) puts44.7% of candidate leaves in the direct index loop
and7.8% in `next_mode`.

That helper just misses the existing4KiB forced-inlining cutoff. A global8KiB
cutoff experiment (`inline-screen01`) reduces compiler-text indexing to101.3ms
versus203.2ms installed and93.85ms upstream; generated indexing takes59.23ms
versus62.64ms upstream. The other applications remain broadly neutral relative
to the previous candidate. The one-line Bend implementation (`inline-source01`)
emits all three applications **byte-identically** to the generated-C experiment.
The old compiler self-C audit predicts24 additionally hinted workers; final
compiler-image build time and transitive growth are still separate gates.

A private one-cell reuse experiment avoids returning a uniquely taken cell to
the allocation pool only to allocate it again. A direct alternating comparison
against the same TRMC parent (`reuse-pair01`, six rounds) measures5.6% less
renderer time at one worker and7.4% at four workers; DAG/chain are neutral.
The first independent screen had a noisy DAG point, so it is not used to
attribute the mechanism. Static cells below `HEAP_OFF` are explicitly excluded.
The Bend integration is in progress; it will retain ordinary allocation for
unmatched classes and dispose of an unused private cell on return/failure.

## Faster experiment loop

The new batch emitter prepares pinned Base once and retains independent request
plans, effect checks and complete per-program receipts. Its first three
applications exactly match separate-process C (`batch-consistency01`). That
batch takes about21s, compared with about40s for the three independent requests.
This is a faster test harness, not a claim about cold compiler-request speed.
The shared preparation is immutable and the batch stops at the first failure.

The first combined control batches exposed witness-source problems before
execution: an unrestricted recursive argument, explicit String annotations,
and mutual forward-reference rules. Their failed receipts and all witness
versions remain recorded. They do not count as passed controls or as compiler
regressions. The final controls will also exercise retained aliases, arbitrary
three-field constructors, argument swapping, late failure and unchanged bang
fallback; the installed release remains unchanged while these gates run.

## Frozen compiler candidate and broad application results

The retained source is `trmc-reuse-source02/compiler.bend`, SHA256
`8b895aec2dc9eac2eaee0036239367f83b53910c309ba26ebab4c9a47fa5affa`.
It integrates the mechanisms in Bend and adds425 physical lines to the installed
standalone source. Its compact, replayable source profile is
[`phase102-lowering01`](../../selfhost/tools/native/profiles/phase102-lowering01/profile.json);
the forward replay and inverse recovery both pass. The linked String ABI and
ordinary scheduler fallback remain in place. See the
[compiler guide](../../docs/self_hosted/phase102-native-lowering.md).

The actual Bend emitter passes all50 application inputs /165 executions
(`reuse-bend-broad01`). These include the complete image output, source-index
records and graph results against the frozen independent oracles. This wider
one-round run is a semantic check, not the source of precise speed estimates.
The final helper-gating correction emits all three applications byte-identically
to those products (`reuse-emission02`). It avoids adding unused TRMC helpers to
bang fallback programs.

Focused controls pass144 complete-output executions (`reuse-controls03`):
arbitrary three-field constructors, aliasing, strict argument order, late
failure, full-U32 characters including NUL/surrogates, shared String tails,
parallel work, and fallback refusals. A separate frozen Phase99 branch corpus
is being added to cover the inherited literal-branch specialization explicitly.
These finite controls establish useful boundaries; they are not a whole-compiler
correctness proof.

The upstream-built native B1 now exists (`native-b1-01`). Checked C acquisition
took37.9s; matched O2 native construction took202.8s wall time, including its
guard and authentication. Its ELF is10,584,704bytes. Fresh raw/provider authority
checks pass (`authority-controls02`); a native B1→B2 chain and native semantic
qualification are in progress. Installed Phase98 native and Phase90 JS selections
remain unchanged. The successful checked API and application runs do not stand
in for these native image checks.

## Compiler-scale inlining failure and revised experiment

The first genuine B1 self emission passes with exact independent diagnostics.
For that same final source, installed B2 emits39,356,447bytes of C and candidate
B1 emits30,080,590bytes, a23.6% reduction. Direct NF workers rise508→943;
continuation FIDs fall35,179→15,964. All508 formerly admitted worker bodies remain
byte-identical. The gain comes mainly from extending admission and composing
existing lowering:47 generic TRMC helpers and hundreds of ordinary direct
workers replace scheduler transport. These are static shape facts, not yet
measurements of the candidate native B2.

The first matched O2 B2 build **fails its420s deadline** (`native-chain01/b2-build`).
Peak process-tree RSS is2,577,940,480bytes, below the6GiB bound; this is not an OOM.
The failed build is retained and no B2 binding or self result is manufactured.
The historical installed B2 build took260.8s, on its older source; that is context,
not a fresh matched-build ratio.

The prior per-function8KiB inline hint is insufficient at compiler scale. A
static NF call-graph expansion audit estimates115.12MB of forced expansion at
outside call sites versus1.38MB in the independent reference. This is a source
size proxy, not measured LLVM IR or a causal timing proof. Nonetheless, it
identifies a concrete composition problem: small forced-inline workers contain
calls to more forced-inline workers. Removing the force hint globally keeps
renderer/graph gains but slows the large indexer to1.229× upstream in a four-round
screen (`auto-inline-screen01`).

The next bounded policy retains the8KiB local limit and permits at most two
levels of forced NF dependencies. It uses three immutable admission passes,
then carries the selected names through emission. This targets transitive
expansion while retaining the measured scanner helper. It changes inline hints,
not worker legality, ownership or semantics. It is being tested as a new source
successor; the original candidate and failed build remain immutable.
