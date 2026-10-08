# Phase68: share native bodies before pruning entries

Status: source-only investigation and uncompiled prototype, 2026-10-08. No
production files were changed and no compiler/C/runtime target was executed by
this lane. All source/data commands ran on CPU0. Root owns target validation.

**Recommended next candidate:** keep ordinary named entries as curried eta
adapters ending in a call to the full direct worker. Lower the actual body only
once. This removes duplication even when both entries are live and can save
compiler lowering time. Use-directed pruning is a later, smaller cleanup.

## Why ordinary/direct duplication exists

[`nc_compile_def`](../../selfhost/src/back/native/book.bend) currently calls
`nc_lower` on the whole erased body, then `nd_extend` lowers it again with
direct-entry arguments. The first result supplies the ordinary zero-argument
entry and its chain of closure bodies. The second supplies `$direct.<name>`.
Phase68 match-aware arity expands the shared semantic opportunity: a function
can have full direct arity extending past a matcher.

The current source is no longer adequately described by “leading lambdas”.
[`nd_arity`](../../selfhost/src/back/native/direct.bend) combines native/foreign
special cases with the larger of the leading live lambda count and shared JS
source/live-arity analysis. `nd_entry_params` creates fresh word bindings;
`nd_extend` applies the erased source body to those parameters. The proposed
adapter uses precisely that arity, not a new competing arity analysis.

## Eta adapter candidate

The isolated
[v2 patch](../../selfhost/tools/performance/phase68/entry-liveness/eta-adapter-v2/candidate.patch),
[identity manifest](../../selfhost/tools/performance/phase68/entry-liveness/eta-adapter-v2/manifest.json),
and complete base/candidate copies are under
`selfhost/tools/performance/phase68/entry-liveness/eta-adapter-v2/`.
They are an uncompiled source proposal, not qualification evidence. The patch
adds 36 net lines in `direct.bend` and replaces one call in `book.bend`.
V1 remains preserved; v2 adds the review-requested typed-arity guard:

```text
original user definition f, full runtime arity n > 0

ordinary f entry:
  return lambda a0. lambda a1. ... lambda an-1.
    NCall $direct.f(a0, a1, ..., an-1)

direct f entry:
  lower the actual erased f body applied to n fresh parameters
```

`nd_eta_body` constructs the ordinary lambda telescope; `nd_eta_entry` lowers
it with fresh binder IDs, then calls extracted `nd_extend_arity`;
`nd_compile_entry` selects the domain and `nd_user_entry` computes the typed
arity once. The worker/body implementation, `NCall`, runtime closure
allocation/application and continuation mechanisms are unchanged.

Initial admission is deliberately small and general: positive arity, non-native
user definition, not Foreign/Absent, and the definition does not occur in the
book's bang list. Arity-zero, intrinsic, foreign and bang definitions use the
previous lowering path. Additionally, typed live arity must equal the full
native arity, preserving ordinary-body lowering when only a malformed raw
definition's leading lambdas supply positive arity. This avoids changing the native primitive
and foreign action conventions while investigating ordinary function sharing.

### Demand and ownership contract

Upstream [`call_eta`](../../bend2/comp.ts) (lines 707–715 at the active pin)
eta-expands an underapplied named definition to its full live arity. Thus a
named partial call whose source body first matches and then returns another
lambda delays that matcher until the remaining argument arrives. The old
selfhost ordinary body can execute the matcher earlier. The adapter aligns
this inherited boundary with upstream; it is not byte-for-byte preservation of
the old partially applied implementation. Saturated and explicitly staged
matcher uses remain separate controls.

Each adapter argument is evaluated by the existing caller and held once in the
ordinary closure environment. The final closure passes each owned word once to
the existing direct worker. Fresh IDs are allocated before lowering the
adapter; the worker obtains its separate parameter IDs from the adapter's final
fresh counter. There is no new C argument-order dependency or parallel register
assignment operation.

An adapter retains every argument until full saturation, including a parameter
that the old body could discard earlier. This can increase lifetime/allocation
for partial applications. It also adds one tail segment hop to fully applying
an ordinary closure, while saturated named calls still use their direct entry.
Measure higher-order controls, not only direct-call workloads.

The current `nc_mark_code` applies original body references and fork summary to
both adapter and worker segments. These summaries stay unchanged. The ordinary
named entry still exists with its current entry ABI. Bang-marked definitions
are excluded, avoiding an accidental scheduling bypass through the adapter.
References arriving through foreign `FID(name)` still name the ordinary entry.

### Validation required before integration

Root should apply only after checking the manifest's base hashes, or explicitly
rebase onto the selected shared-arity snapshot. The original source files are
not modified by creating these copies.

1. Build a checked B1 and run the existing arity-fast controls: common/unequal
   matcher branches, erased fields, erased partial closure, overapplication,
   uncalled absurd tail, and shared scrutinee/residual ownership.
2. Reuse unchanged `controls/error-order-v1/{saturated,partial,staged}.bend`.
   Their paired upstream observations own the oracle; the partial case is an
   expected inherited difference that the adapter may fix.
3. Run Phase67 raw ten controls. Omitting the first actual-body lowering can
   change which malformed raw-core diagnostic wins, even when checked programs
   are equivalent. Preserve exact public raw diagnostic requirements.
4. Cover `bang_intrinsic_closure`, primitive override, foreign runtime callback,
   higher-order captures containing arrays/trees, and one/four-thread execution.
5. On the small native families, compare emitted C bytes, segment count,
   emission time, Clang time and execution time separately. The main hypotheses
   are less duplicate lowering/C; no runtime multiplier is predicted.

## Why existing `refs` cannot establish entry liveness

`N_Segment.refs` currently feeds `nb_fork_close`; it is a conservative
definition-level effect summary. `nc_mark_segments` copies the original body's
references, mapped to ordinary names, onto most generated segments. It omits
generated closure, continuation and task targets and does not distinguish
`$direct.f` from `f` according to the emitted call site.

Therefore pruning using this field would both retain dead ordinary entries
and risk dropping live local segments. Reinterpreting it as a call graph would
also change scheduler classification. A separate set of actual emitted edges
or a precise entry-mode plan is required.

## Source-only reachability discriminator

[`census.py`](../../selfhost/tools/performance/phase68/entry-liveness/census.py)
reads the existing Phase68 instrumented C outputs, verifies generated-ID/table
and segment structure, and follows literal generated `FID_<codes>` references.
It roots `main`, any literal generated ID outside segment/table sections, and
all bang-marked entries. The script only reads C and prints JSON: it does not
rewrite, compile or execute a target.

[`census01.json`](../../selfhost/tools/performance/phase68/entry-liveness/census01.json)
binds exact input hashes. The inputs are the previously root-produced
`native-counts01/{array,numeric,lexer}-selfhost/program.c` files; these are not
new eta-adapter outputs.

| Input | Generated segments | Literal-graph live | Unreached segments | Unreached segment text | Fraction of full C |
| --- | ---: | ---: | ---: | ---: | ---: |
| Array | 1,860 | 1,591 | 269 | 163,953 bytes | 9.40% |
| Numeric | 1,831 | 1,570 | 261 | 153,254 bytes | 8.94% |
| Lexer | 2,192 | 1,864 | 328 | 204,024 bytes | 9.91% |

These counts include dead direct intrinsic entries as well as dead ordinary
entries and local segments. They are static opportunities, not dynamic costs or
proof of whole-program deadness under arbitrary foreign C. Table/ID reductions
are not included in the removable-text column. Pruning alone cannot explain
away most of the current large C output; sharing live bodies is the stronger
next candidate.

Replay from repository root, with no target execution:

```sh
taskset -c 0 python3 selfhost/tools/performance/phase68/entry-liveness/census.py \
  selfhost/build/phase68/native-counts01/array-selfhost/program.c \
  selfhost/build/phase68/native-counts01/numeric-selfhost/program.c \
  selfhost/build/phase68/native-counts01/lexer-selfhost/program.c
```

## If entry pruning is still useful after adapters

### Option A: classify ordinary/direct demand before lowering

Track demand for `(definition, ordinary/direct)` from `main` and foreign roots.
An exactly saturated non-bang reference admitted by the same call planner can
demand only the direct entry. A value reference or underapplication demands the
ordinary entry. Conservatively treat overapplication as ordinary too, unless
the planner explicitly decomposes the saturated prefix and residual call.
Unknown variable calls require all possible closure producers to remain; merely
seeing one direct caller is insufficient. Recursion requires a fixed point.

This can avoid lowering unused bodies, but duplicates call-plan decisions unless
it consumes a shared plan. It changes fresh-ID allocation, diagnostic traversal
and potentially foreign reachability. After eta adapters, the saved ordinary
code is only a small closure telescope, making a new analysis less attractive.

### Option B: prune after lowering from explicit emitted targets

Every compiler-owned target is currently named explicitly at creation/use:

| Source of edge/root | Emission site |
| --- | --- |
| Named or direct jump | `ne_jump`, from `Ref` or `NCall` |
| Closure target | `ne_closure` / `ne_closure_wrap`, `term_clo(FID, ...)` |
| Sequential return continuation | `ne_frame`, FID stored in `STK` |
| Asynchronous continuation | `nc_cut_task` / `ne_task`, `term_tsk` and `task_node` |
| Fork children and joiner | `nc_children`, `nc_child_task`, `nc_parallel_finish` |
| Main entry | `MAIN_FID` and `io_loop` |
| External callback entry | resolved `FID(name)` in `KF_Source` / `nc_foreign_parts` |

A conservative lexical scan of compiler-owned body text can collect identifier
tokens, including false-positive mentions in comments/strings. A structured
edge list emitted alongside the strings is cleaner long term. Dynamic closure
application and `WL_DYN` do not require rooting every segment when all possible
closures/tasks were created at the listed sites and none can enter externally.
That last condition is essential.

Foreign code can synthesize IDs with token concatenation, integer arithmetic,
static term literals, or direct runtime-table access. The public `nc_compile`
also receives runtime/request text, not an explicit external-root contract.
Literal scanning is therefore not a proof for arbitrary embedded C. A first
sound pruning scope must either exclude opaque external code or consume an
explicit validated list of externally callable entries and forbid dynamic ID
construction within that admitted scope. The census intentionally makes neither
claim. Treat all entries as live when that contract is unavailable.

### Metadata and validation must not change accidentally

Filtering the segment list also renumbers FIDs and rebuilds `FID_ARITY_T`,
`FID_RESW_T`, `FID_FLAG_T`, `WL_TABLE`, `WL_RESW`, register width and `BANGS`.
Recompute table shapes consistently, but preserve each retained segment's old
fork/bang classification. In particular, computing `nb_fork_close` only after
ordinary effect-summary nodes disappear can incorrectly classify a retained
direct entry as fork-free. Compute/freeze the original fork closure first;
do not infer it from the liveness graph during the same experiment.

The global zero/nonzero `BANGS` test influences sequential scheduling and GPU
selection. Rooting all bang-marked segments preserves it in the narrow initial
approach. Keep fixed runtime entries `FID_ENTER`, `FID_EXIT`, `FID_IO_EMIT` and
`BEND_CLO_APPLY`, which are not ordinary generated definitions.

Perform current full-source native diagnostics/ID validation before filtering
so dead malformed raw segments do not silently change accepted input. A
diagnostic-preserving first experiment could replace unreachable bodies with
small trap stubs while retaining IDs and all metadata, but it still requires
the same external-entry proof and saves no lowering work.

## Decision

Advance the eta-adapter source candidate first. Its guarded v2 scope is 36 new
source lines and one call-site change, keeps all entry identities/conventions,
and can remove duplicate live implementation bodies. Validate the changed
partial-call demand boundary explicitly. Defer production liveness pruning
until the adapter's residual code-size census and external-root contract justify
the additional machinery.
