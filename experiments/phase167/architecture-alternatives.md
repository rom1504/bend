# Phase167: alternatives to generic-first and direct-worker recovery

Source-only audit at `022a0f0`, against retained bendc
`56edcc65b3527a75838011682c231072d5b46097` under
`selfhost/build/phase158/current`. No target, compiler acquisition, benchmark or
production edit. Phase152 remains qualified. The numerical evidence below is
retained evidence, not a new measurement.

**The genuinely different backend is one canonical expression/control-flow
representation, independently checked and emitted directly to QBE, including
explicit resumable frames for non-tail cycles.** It should not first construct
the old generic program, then recover or certify direct workers from it. That
is a useful architectural prototype; no existing evidence predicts a 10× cold
build from it. A second, independent architecture changes the lifetime of
compiler data so that traversals can borrow stable descendants and discard
temporary regions together. A credible 10× attempt probably needs both fewer
compiler operations and substantially faster execution of the remaining ones.

## The full-build arithmetic

The qualified same-source observation is 249.222s source-to-executable, including
machine construction; 10× means **24.922s**, not a 10× isolated lowerer. Its
242.103s emission/QBE interval overlaps the compiler and external QBE process;
the remaining 7.119s is serial build/orchestration tail, not all machine cost.
See [Phase152 metrics](../../implementation/phase152/metrics.json).

The separate exact-output Phase161 diagnostic has 239.978 process CPU seconds.
Its disjoint intervals give these conditional ceilings:

| Responsibility | Diagnostic CPU seconds | Consequence under unchanged execution |
|---|---:|---|
| Parse/load, checking/publication, proof report |66.520|Even deleting everything else leaves this; the remaining computation itself needs >2.67× acceleration to fit 24.922s.|
| All work before `p134e_plan`, including annotation/erasure/layout |83.223|A free backend gives at most about 2.88× on this diagnostic.|
| Generic segment body production |11.588|Deleting this entire interval alone saves only 4.83%.|
| Private/direct candidate production |26.782|Required direct code and ownership work remains after generic omission.|
| All work from `p134e_plan` through output/teardown |156.571|Large experimental envelope, not removable work or exclusive lowering cost.|

These are not clean wall-clock intervals to subtract from the 249.222s result.
The nested 9.261s conditional verifier is already included in composition and
must not be added again. The
[profile receipt](../../implementation/phase161/profile-metrics.json) fixes the
boundaries. A new backend can accelerate the frontend *in the next generated
compiler*, so this ceiling does not forbid a generational architecture change;
it forbids presenting a same-executor backend cut as a 10× full-build result.

The existing mixed route is the decisive negative: Phase164 removed 10.44% of
continuations but changed same-source complete acquisition only
201.931→201.271s. Its 1.556MB experimental source differs from the qualified
3.085MB source. Its small runtime transfers include a Map regression. Do not
repeat that campaign with a larger omission percentage as the sole success
criterion. [Phase164 report](../../implementation/phase164/README.md).

## What bendc actually avoids

Exact current source points, all in `selfhost/build/phase158/current`:

- `bendc.bend:25746`, `Lo.program`: lowers declarations to `Core.Tm`, erases,
  performs inlining/simplification/specialization/fusion and other transforms,
  then raises to `Core.Expr`. It is not a one-pass or reachable-only optimizer.
- `bendc.bend:26462`, `Gen.program`: further representation, two parameter
  unboxing rounds, optional RC preparation, layout/DPS and flow analysis;
  `Gen.all.go:10220` then emits reachable definitions.
- `Gen.stmt:9381` / `Gen.rec` produces C expressions, branches and statements
  directly from the optimized expression representation. `RC.wrap:5733` emits
  ordinary native calls; self-tail calls become parameter moves and `goto top`.
  It does not create our scheduled reference program and independent private
  candidates for the same owner. It still generates wrappers and flat workers.
- `Gen.shares.if:5299` omits sharing work under tracing/no-local-free policy.
  This is a different memory contract, not a source-level affine exemption.
  `Gen.program.fin:25944` materializes Docs/text; our QBE output already streams.
- `Main.checked.go:30822` calls emission loading after the checker succeeds;
  bendc's checker/emitter use distinct parsers. It does not save work by secretly
  sharing a single checked AST throughout both routes.

Our actual shared prepared body already works:
`back/qbe/static-data.bend:162` publishes `NativeStaticBody`, and
`back/native/book.bend:104` reuses it. The Map census's 76 private queries cause
zero recorded `nc_compact` entries. Independent verifier lookups already use
indexes; borrowed native String comparisons already avoid hosted per-character
Tuple reconstruction. None of those is a new architectural gain.

The same complete compiler implemented in Bend and executed via bendc/C still
took 167.602s, or 138.383s with a larger GC budget, versus 223.237s QBE for the
matched full request. All products matched; memory rose from about 1GiB to
4–5GiB. Its 55.62% physical tracing/collection/rescan share explains why simply
copying tracing does not yield bendc's much smaller self-source timing.
Current bendc's own 5.981s unchecked/11.374s checked observations use a different
1.641MB source and emit C, without Clang construction in those clocks. The C
request-compiler acquisition itself included 93.330s Clang construction.
[Phase160 report](../../implementation/phase160/README.md).

## Alternative A: direct expression-to-QBE with one checked control graph

**Work removed:** generic continuation IR plus independently derived direct IR,
candidate recovery from generic bodies, repeated symbolic-name/fact rebuilding
across those representations, and retaining both whole programs through emission.
Use one per-owner representation with numeric local identities, typed word kinds,
explicit ownership operations and control edges. This is more than Phase154's
numeric field substitution or Phase164's generic-body omission.

Input is the already authenticated `NR_Request` / prepared body. At the current
`back/common/constructor-facts.bend:202` fork, replace *both* `p111_compile_defs`
and `p113pl_candidates` for the experimental request. A complete owner produces
one graph. Scalar, borrowed and product decisions transform that graph before
its final check; unsupported owners are explicit coverage failures in the first
prototype, not empty fabricated originals or hidden acquisition work.

Ordinary acyclic calls use a boxed-Term QBE ABI. Self-tail calls snapshot operands
before moving parameters. Non-tail recursive SCCs use explicit frame records and
a resume loop derived from that same graph, with one public scheduler bridge
where effects/closures require it. This retains input-depth-independent machine
stack use without constructing the old global segment graph. Current
`local-continuations.bend:894,1054` supplies semantic precedents, not a free
implementation: it discovers regions after generic lowering and has shape,
arity and dependency restrictions.

An independent checker validates the **actual final graph and import manifest**:
definitions-before-use, widths and full 64-bit constants, constructor arity/layout,
call/result/closure ABI, branch joins, initialized frame slots, array capacity,
transport namespaces and recursion discipline. It must not accept a producer's
`valid=True`, unchecked original stub, or a merely same-name prior certificate.
Current obligations are grounded in `verify-segments.bend:257–342`,
`verify-direct.bend`, `verify-compact.bend:523`, `checked-boundary.bend:18–59`
and `retained-context.bend:5–44`. The current verifier is a structural/type/ABI
boundary, not a full proof of semantic lowering or ownership correctness; the
new boundary must preserve at least those obligations and independent negative
controls. A temporary exact decoder into existing verifier input is a legitimate
prototype cost, but constructing the complete old program defeats this design.

**Cheapest complete falsifier:** reuse the Phase165 checked request seam and
compile the real Map program and verifier source slice through this entire route,
including all owner analysis, manifest construction, final verification, text,
QBE/assembly/linking and teardown. Compare complete diagnostics where unchanged;
new machine code needs independently specified execution outputs rather than
old-QBE byte equality. The verifier slice's `0\n` main tests an empty-program
verifier and is weak runtime coverage: also execute actual verifier-table/branch
controls and the real checker workload before concluding code quality is kept.
No isolated arithmetic worker or successful helper is a coverage gate.

Stop before a full compiler acquisition if it cannot handle those complete
requests, if new verifier/translation work consumes the saving, or if output
runtime regresses substantially. A next gate compiles and executes the actual
182KB checker closure over fixed valid and invalid source, then the full exact
3.085MB source. Only that tests whether the new architecture accelerates the
large frontend it inherits. A 2× backend-only pilot is useful feasibility evidence,
not evidence that the full 10× target is attainable.

## Alternative B: compiler-specific lifetimes and borrowed analysis data

**Work removed:** repeated retain/take/rebuild/drop of immutable compiler graphs
and transient fact records across a whole compilation phase. Keep checked book
and constructor/schema tables in a durable region; use per-function or bounded
phase regions for temporary work; let lookup consumers borrow descendants while
the root region is alive. Promote/copy precisely the surviving output graph or
fact summary before releasing a region. Keep effects, external resources and
arbitrary user-program objects on their existing runtime policy initially.

This is not `NO_FREE=1`, and is not an allocator replacement. Keeping every
temporary alive would violate the existing memory envelope: Phase162 observes
2.950B logical allocations for a complete C request, including 2.132B outside
parse/check/report. The count does not locate their origins or establish how
many may safely share a lifetime. New arenas must have bounded retained size,
handle error exits, and preserve persistent branch snapshots and retained old
roots. An escaping borrowed field needs promotion or an owning root; a raw
pointer with a plausible constructor tag is not a lifetime certificate.

Exact consumers include `core/index.bend:index_find/index_bucket`,
`core/term.bend:lookup`, `back/native/bridge.bend:nc_word/nc_live_env`, and the
scalar/verification environments in `back/qbe/scalar-facts.bend` and
`verify-compact.bend`. Existing borrowed readers accept restricted scalar/root
results; extending them to a selected descendant requires a lifetime-bearing
interface through its *consumer*, not just a faster getter.

The Phase153 full-request physical ownership/reclamation/allocation/transport
envelope is 42.71%. Even deleting all of it gives only about **1.75×** at fixed
remaining work, and necessary loads/copies survive. Phase166's 46.73% constructor/
take helper share belongs to a tiny complete-record kernel, not the full build.
Its mature-C expected-record control approaches bendc while the actual lookup
case does not: this motivates root-tied consumers, but does not quantify a
full-build multiplier. Hosted 19.27M Tuple events are not native allocations.

**Cheapest complete falsifier:** one real per-function optimizer/verifier pipeline
and its complete output, using actual compiler functions plus unrelated Map
functions, including region setup, promotions, verification and destruction.
Then run one complete request with a hard peak-RSS bound and the final independent
verifier retained. Reject if copying surviving IR or retaining branch roots
consumes the benefit. This can combine with A only after separate effects are
measured; their savings overlap and must not be multiplied from kernel ratios.

## Selection

Build A as the contrasting compiler architecture if the mission is a genuinely
new cold-build prototype. Keep B as the independent whole-pipeline execution
design to test, rather than more local selector/lookup rewrites. Do not spend
another full acquisition merely widening the Phase164 direct-first whitelist.

The prototype's honest success criterion is a complete checked workload with
materially fewer representations and operations, bounded memory and stack,
independent final verification, preserved generated-program behavior, and lower
source-to-ready-executable time. The 10× aspiration remains a hypothesis until
that full accounting fits under 24.922s on the same input and resource policy.
