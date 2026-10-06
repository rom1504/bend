# Direct compiler-image migration: first falsifier

The current driver can already consume a compiler API with named fields and no
`G` export. A direct compiler image therefore appears compatible with its host
data interface without a positional-ADT conversion. The restricted transport image has now passed its independent probes; full
compiler-driver and self-emission compatibility remain separate gates.

The existing [loader](../../selfhost/tools/typed-driver.mjs#L190) checks the term,
span and loader ABI versions, then returns `module.default` directly when `G`
is absent. Only a positional legacy image enters
[createCompilerAbi](../../selfhost/tools/compiler-abi.mjs), which supplies lazy,
read-only named-field proxies. The present checked-B1 image itself comes from
the pinned upstream bootstrap plus reviewed derivatives. Its successful use is
not evidence that the compiler has already reproduced itself through the new
direct Bend emitter.

## Representation and scope

The compiler's public `KTerm`, `KLambda`, `KLiteral`, `KDef`, loader and diagnostic
records contain named fields, lists, strings, booleans and U32 values. The core
explicitly has no function-valued fields. These are the direct backend's native
public representations. Their types require no Nat conversion, so
`jd_host_nat_status`/`jd_marshal` should choose identity conversion. Internal
compiler closures and Nat computations are separate from this boundary.

The additive [adapter](../../selfhost/tools/performance/phase54/bootstrap/adapter.mjs)
verifies the image hash, direct metadata, absence of `G`/`ctor`, requested
exports and ABI versions. It selects the requested public dictionary keys while
preserving the exact function objects. It adds no graph copies, method wrappers,
runtime coercions or compiler semantics. Unchanged driver methods can receive
that dictionary through their existing `api` option. A later facade module can
also expose it to the existing `BEND_TYPED_API` loader.

One export difference must remain explicit: upstream `stage0-library.mjs`
selects an explicit export inventory. `jd_library_selected` emits public wrappers
for all selected non-Base definitions, including reachable helpers. The adapter
hides those extra keys; the probe records both inventories. Selecting roots for
reachability is essential: compiling the whole compiler as an unrestricted
library would root every eligible compiler helper.

The frozen Phase53 assembly has **3,004 textual `def` declarations**, 103 modules
and 1,302,786 bytes; its bootstrap exposes 77 API names. These are source/export
counts, not a measured live call-graph size or dynamic closure count. The initial Phase53
512-definition direct-analysis bound precedes final emitted pruning. The tested
Phase54 graph02 successor raises the checked source/emitted bound to 4,096; that
capacity change alone does not establish full compiler emission speed. The
host type graph also has 1,024-node and marshaller depth-64 bounds. A no-Nat
boundary avoids conversion but must still pass the type-graph analysis.

## Isolated tools and fastest falsifier

The new [selected-root emitter](../../selfhost/tools/performance/phase54/bootstrap/emit-selected.mjs)
loads the exact frozen compiler source through the unchanged generated frontend,
completes TODO/specialization checks and the owned-layout validation, then reuses
`reach_book`, `annotate_selected`, direct emitted reachability and layout validation. It rejects missing roots, foreign effects and explicit
unsupported markers. It emits a new image and receipts in a fresh directory;
it never overwrites the installed API, driver or bootstrap tools.

The first configured lane reuses the exact complete-source upstream bootstrap
check, as explicitly authorized for this transport falsifier. Source, attempt,
Base and API identities are checked before and after. It is labeled
`inherited-exact-bootstrap`, **not a fresh self-check**. A separate `fresh` lane
invokes `check_program_diagnostic` on the loaded source before emission. Its ABI2
result already includes frontend completion; both lanes retain the ordinary
emission ownership check. Inherited checking does not skip current specialization.

`selfhost/build/phase54/bootstrap-plan01/plan.json` preserves the tools and
inputs prepared before execution. Its first plan requests eleven actual compiler roots: four ABI probes,
the two path helpers, `kt`, `tg`, `kid`, `book_cached` and `lookup`. A second plan
adds the real loader header; a third retains the current 77 API roots. The latter
must be rebound to any new scalable-graph attempt rather than relabeling the old
attempt or assuming all helper closures fit its bound.

Root-owned commands, each inside the existing serialized resource supervisor:

```sh
node --max-old-space-size=1024 --stack-size=4096 \
  selfhost/tools/performance/phase54/bootstrap/emit-selected.mjs \
  selfhost/build/phase54/bootstrap-plan01/transport.json \
  selfhost/build/phase54/bootstrap-transport01

node --max-old-space-size=512 --stack-size=984 \
  selfhost/tools/performance/phase54/bootstrap/probe-image.mjs \
  selfhost/build/phase54/bootstrap-transport01/probe.json \
  selfhost/build/phase54/bootstrap-transport-controls01
```

The initial plan used CPU3, a 180-second emission deadline, 1 GiB heap and 2 GiB
process-tree RSS; the probe had a 20-second deadline and 1 GiB RSS ceiling. Its
pre-execution estimate was 30–180 seconds for loading/emitting the restricted
compiler source. Actual root-owned execution results follow below; the estimate
is not a measurement.

The [probe](../../selfhost/tools/performance/phase54/bootstrap/probe-image.mjs)
checks exact versions and string helpers, named constructor fields, a frozen
diamond with shared children, a 20,000-element list at default stack size, and
`book_cached → lookup → kid` without copying or losing aliases. A newly returned
record remains mutable, matching ordinary named-record behavior; legacy proxy
read-only identity is not the comparison contract. The later loader plan adds
a real `FSource → FHeader` observation.

## Gates before retiring the old compiler-image route

1. Pass restricted transport and loader probes; record actual reachable counts,
   import time, peak memory and refusal/error behavior.
2. Emit the full 77-root image, verify the exact public facade, and run the unchanged
   driver's parse/check/diagnostic/emission paths on successful and failing inputs.
   Compare complete observations with the current image, including source ranges,
   declaration order, repeated calls and Base-cache behavior.
3. Run independent semantics, maintained compatibility and emitted-byte/oracle
   comparisons through that image. Exercise long compiler lists and nested terms;
   source-tail stack safety alone does not bound all native non-tail recursion.
4. Only then attempt compiler-source self-check and self-emission with freshly
   recorded resources. Compare successive direct images and the behavior of the
   generated compiler. No fixed-point or throughput claim follows from small
   programs or an unchanged adapter interface.

Remaining risks include unsupported live compiler terms, analysis budgets,
non-tail depth, string-operation cost, repeated module compilation, and accidental
graph copying at a newly introduced Nat-bearing public type. None justifies
silently routing to the old backend. Keep every failure and keep the installed
compiler-image ABI unchanged until these separate gates pass.

## Restricted execution and full-image successor

The root-supervised first transport emission passed: 84 source-reachable
definitions became 73 emitted definitions and a 50,150-byte module. The worker
recorded 23.096 seconds (the enclosing supervised job took 23.226 seconds).
Loading the complete source took 10.979 seconds and specialization 4.430 seconds;
emission of the restricted library took 1.433 seconds. This measures the whole
probe workflow, not isolated compiler throughput. The separate default-stack
transport probe passed all five observation groups in 0.047 seconds, including
the 20,000-element frozen list and shared-graph phase handoff.

Raw receipts: `selfhost/build/phase54/bootstrap-transport01/report.json` and
`selfhost/build/phase54/bootstrap-transport-controls01/report.json`. The produced
module SHA256 is `0f92f25e42289845908ac6da22aaf943af6a2c382014fe1897bfd55e51258871`.

The fresh `bootstrap-plan02/full77.json` binds all 77 public roots to
`checked-graph02`, whose exact assembled source SHA256 is
`32cddcf1a970a9726a9785b30269cdd8a0047f917f769a964995fa6a0633de84`.
It uses the unchanged, consumed selected-root emitter. The inherited complete
source proof remains explicitly distinct from a fresh direct self-check.

The additive [driver probe](../../selfhost/tools/performance/phase54/bootstrap/driver-probe.mjs)
uses the ordinary `loadApi`, `inspect` and `execute` methods without injecting
an API argument. Source and direct roles each receive a private byte-identical
driver/runtime copy so their ordinary Base caches remain keyed by their own
actual API hash and cannot modify the frozen attempt. The source fixtures are
existing parse rejection, type rejection and the U32 result 42. Eight requests
cover successful and failing parse/check, JavaScript emission and execution,
C emission, and successful replay after errors. C execution is not claimed.

The [data-only join](../../selfhost/tools/performance/phase54/bootstrap/compare-driver.mjs)
requires exact returned observations, diagnostics and emitted JS/C byte hashes.
Runtime file paths differ between private role directories; their verified byte
hashes are compared instead. No timing threshold or fallback API is involved.
The serialized commands and bounds are recorded in
`selfhost/build/phase54/bootstrap-plan02/driver-plan.json`. Both roles must pass
before the next gate: fresh checking of the actual compiler source through the
direct image, followed by direct self-emission and another generation.

## Full migration retained as an unfinished gate

The graph02 full 77 attempt reached its **240-second deadline** without producing
a compiler module. The supervisor recorded 240.065 seconds and a peak summed
process-tree RSS of 863,965,184 bytes, below its 2 GiB ceiling. This is a resource
qualification failure, not an observed wrong compiler result. The working
compiler-image route remains required. The prepared ordinary-driver comparison,
fresh compiler self-check, self-emission and fixed-point gates were **not run**.

The unchanged first emitter could not show its interrupted phase. A separately
reviewed progress-only successor retained the same API pipeline and added durable
JSONL phase boundaries. Its bounded, V8-profiled diagnostic also stopped at its
90-second deadline. The surviving progress showed:

| Phase | Diagnostic seconds |
|---|---:|
| Load exact compiler source | 10.383 |
| Specialize loaded book | 5.381 |
| Source reachability | 1.452 |
| Annotate selected definitions | 3.116 |
| Exact emitted reachability | 55.898 |
| Layout proof | 3.327 |
| Final library emission | Started at elapsed 82.290; unfinished |

These durations include profiling and progress IO and are not a clean throughput
comparison. Raw receipts are under
`selfhost/build/phase54/bootstrap-full77-graph02-supervisor/run.json`,
`bootstrap-full77-graph02-diagnostic01-supervisor/run.json` and
`bootstrap-full77-graph02-diagnostic01/progress.jsonl`, relative to the same
Phase54 raw root. Neither deadline justifies a larger unmeasured retry.

The 110,271,475-byte V8 log's **offline processor** exhausted its separately
bounded 512 MiB Node heap. This was distinct from both supervised compiler jobs
and was not a system OOM. The original log and failure stderr remain retained.
A deterministic one-in-ten tick sample kept all mapping records and 7,857 of
78,570 ticks; its 18,177,069-byte log processed successfully. The sample receipt
and summary are `bootstrap-profile01/sample10.json` and
`bootstrap-profile01/processed-sample10.txt`.

That sampled summary identifies a concrete query bottleneck: `j_find_ctor`
accounts for 26.5% of sampled ticks, and `missing` for 11.2%. Of the latter, 98.6%
have `j_find_ctor` as caller. About 80.3% of `j_find_ctor` samples are under
`jd_raise_head`; its parents include `jd_arity` called by ordinary call lowering
and call-graph analysis. These are sampled tick counts from an interrupted mixed
workflow, not unbiased wall-time attribution or a predicted speedup.

The source explains a plausible cause without a new cache hypothesis:
[j_find_ctor](../../selfhost/src/back/common/queries.bend#L91) scans every book
definition's constructor list; empty or unrelated lists repeatedly return a
fresh `missing` record. [jd_raise_head](../../selfhost/src/back/js/direct/model.bend#L101)
performs that search for each matcher while recovering function arity. The
existing persistent book index indexes **top-level definition names**, so simply
replacing this search with `lookup(book, constructorName)` would be unsound.

The smallest next investigation is to reuse
[j_layout_ctor](../../selfhost/src/back/common/queries.bend#L199) wherever the
normalized ADT owner is already known. `j_arm_type` already has the input type;
the dominant `jd_raise` path would need its expected telescope threaded through
lambda and matcher descent before it can make the same query safely. Preserve
constructor precedence, aliases, erased parameters and the original unknown-type
fallback; test shadowed owners and duplicate constructor names independently.
If that typed route is insufficient, a constructor index must be scoped to the
exact immutable checked context and reproduce original first-match selection;
owner updates must rebuild or invalidate it. No such source change was made.

Repeated SCC body emission and emitting host wrappers for every reachable helper
remain source-level opportunities, but this profile does not establish either
as the timeout's main cause. Keep them separate from the measured constructor
lookup evidence. Full legacy retirement is deferred until actual compiler-image
and successive-generation gates complete.
