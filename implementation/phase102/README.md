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
