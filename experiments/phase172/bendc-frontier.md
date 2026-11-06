# Phase172: the remaining bendc lesson is a cheaper execution boundary

Read-only source/evidence audit at `fbdf8a0`, 2026-11-06. No compiler, benchmark,
profile or machine-build target ran. Current bendc source is the retained
`56edcc65b3527a75838011682c231072d5b46097`, not an upstream update. The parent
owns implementation selection and the single execution lane.

## What still explains the gap

Bendc is not simply a smaller, single-pass compiler that omits all checking.
Its current `Gen.program` calls `Lo.program`, runs parameter/sum unboxing and
other representation passes, rebuilds `G`, computes destination-passing groups,
and renders Docs. `Lo.program` lowers **all loaded runtime definitions**, applies
several passes, then raises the core IR again. Its checker and emitter even have
separate parsers. Repeating a proposal to add body caches, reachability or output
streaming does not follow from this source: our prepared body reuse and bounded
output cursor already exist.

The useful contrast is **how ordinary computations reach the machine**:

- Bendc's C generator produces ordinary calls, local variables, field access and
  control flow. Clang sees allocator/ownership helpers in the same translation
  unit and can inline fast paths and keep values in registers.
- Our QBE code has separately compiled C runtime calls at constructor/take
  boundaries. Its current `p125_rt_ctorN`/`takeN` interfaces remove some redundant
  checks, but these remain machine calls. Call-clobbered registers, input/output
  scratch buffers and repeated state/allocator loads survive that boundary.
- For blocked non-tail recursive functions, our compiler also constructs direct
  candidates, scheduled families and later callable regions. Bendc's ordinary
  C route does not require those parallel execution representations. But its
  ordinary non-tail native recursion is not our unbounded stack-safety contract;
  copying native calls blindly would change supported behavior.

The two differences interact. Eliminating helper call boundaries may improve the
execution of the compiler across several semantic stages. A common semantic
function graph instead removes repeated compiler work. Neither is demonstrated
to close the entire current180.7→100s gap on its own.

## Controlled history rules out several shortcuts

| Retained experiment | What it established | What it does not establish |
|---|---|---|
| Phase160 same complete compiler through QBE and bendc/C |223.237→167.602s source-to-QBE; GC-factor variant138.383s, exact118MB output |Not current cold source-to-executable; C used a different memory policy and up to5.06GB RSS.|
| Phase160 C profile |55.62% tracing/collection samples; increasing GC headroom helped |Replacing RC with tracing is not free or a few-second route.|
| Phase161 source closure |44.97% fewer input bytes gave14.32% less request time; emitted function count unchanged |Raw source lines do not explain100×; changing the benchmark input does not meet the fixed-source goal.|
| Phase164 mixed direct-first |10.44% fewer continuations,4.68% fewer QBE bytes, near-neutral full acquisition |Body omission for already admitted workers did not eliminate the retained downstream work.|
| Phase165 memo/equality cuts |Native memo removal and our equality transplant barely changed bendc's complete checking request |More memoization or replacing the already borrowed equality algorithm is not the missing large win.|
| Phase169 runtime shared-take/warm helper |About2.15% less small native compiler request time |This was runtime-C optimization, not QBE call-site inlining.|
| Phase169 consuming projection |Only about1.46% on the actual checker |Combining take/drop for a selector is not general allocator/take inlining.|
| Phase171 borrowed descendant |99.535% promotion coverage but1.25% verifier gain; lookup neutral |Further selector admission work is not justified by the earlier lookup aggregate gap.|

The exact implementations and comparison boundaries remain in
[Phase160](../../implementation/phase160/README.md),
[Phase161](../../implementation/phase161/README.md),
[Phase164](../phase164/compiler-generic-audit.md),
[Phase165](../../implementation/phase165/README.md),
[Phase169 runtime boundary](../phase169/runtime-boundary.md), and
[Phase171 follow-up](../../implementation/phase171/followup.md).

## A distinct untested execution hypothesis: inline verified fast paths

I found no retained implementation/measurement of **general QBE call-site
inlining of the ordinary unique constructor/take allocator paths** in the
inspected Phase110–129 and160–171 records. Phase125 specializes calls; Phase128
already inlines borrowed field reads; Phase169 changes C helpers or fuses a
consuming projection. Those are distinct. This absence claim is bounded by the
searched records, not a proof that no older abandoned prototype ever existed.

The actual Phase166 full-result consumer is a concrete witness: its QBE scanner
has91 constructor helper sites and19 take sites, a2,632-byte frame subtraction,
and separate scalar calls. Mature C retains ownership behavior but inlines
allocation paths, with120-byte subtraction; bendc/C has72-byte subtraction and
GC-refill slow paths. The complete lookup/digest timings were0.54148s QBE,
0.35772s mature C and0.15649s bendc/C. These static counts are not dynamic calls,
and the mature C/bendc differences also include representation and memory policy.
See [exact machine inspection](../phase166/code-shapes.md).

The latest Phase171 full capture has5,429 samples. Summing disjoint physical leaf
locations from its `callerMatrix` gives:

| Runtime leaf family, cold clones included | Samples | Share |
|---|---:|---:|
| `p125_rt_ctorN` |79|1.46%|
| `p125_rt_takeN` |435|8.01%|
| `ctr_take` |159|2.93%|
| `heap_alloc` / miss |100|1.84%|
| `rfc_wrap` |51|0.94%|
| `span_fade` |353|6.50%|
| `term_drop` |550|10.13%|

Constructor/take/`ctr_take` alone occupy12.40% of physical samples. That is not
removable time: actual payload access, reference counts and freeing remain.
Conversely, caller-side spills/scratch traffic is outside these leaves, so the
leaf total is not a strict ceiling for a transformation that allows machine
optimization across the old boundary. A reasonable experiment must inspect both
sides. There is **no evidence for a44.7% whole-build gain from inlining alone**.
Helper shares measured in isolated kernels must not be scaled onto the full
compiler. [Latest source capture](../phase171/runtime-callers.md).

### Smallest useful implementation

Start after the unchanged independent final verifier, at the same trusted
Bend emitter boundary already used by `p128bf_*` borrowed-field templates. Match
an authenticated constant-arity constructor/take call, emit a bounded fast path,
and retain the exact existing call for every refusal. Do not hand-edit generated
machine code or weaken the N111 body verifier to admit arbitrary heap writes.
The lowering from a verified runtime operation to QBE needs an explicit pinned
ABI/runtime contract and its own finite equivalence controls.

**Cold constructor, arities1–4:** use only a literal constructor whose existing
source-derived table says cold and whose descriptor enables capability8. The
ordinary runtime then stores fields directly, without sealing them. If its
class free-list head is nonzero, pop that head, decrement the existing length,
write the fields in their original order and return the same tagged constructor.
If the head is zero, call the unchanged helper **before any mutation**. This
exposes allocation/payload stores to QBE while leaving refill/growth untouched.
An unknown/hot constructor always uses the old helper. Do not silently remove
`rfc_seal` for hot constructors.

**Raw unique take, arities1–4:** retain constructor identity/arity/type checking,
require non-RFC ordinary `TAG_CTR`, a heap payload and enough remaining free-list
headroom to avoid `heap_hand`. Copy all fields before modifying the node, then
perform the same class free-list push. Packed, static, shared/RFC, mismatched or
hand-off cases go through the original helper without preliminary mutation.
RFC-unique support is a later separate delta because it frees both wrapper and
payload and must preserve their order.

Pinned layout facts in the current host ABI:

- `P111State.e.mem` at byte0, `.alc` at byte8 (`runtime.h`).
- Host `LANE_STEP=1`, `NCLS_ALL=32`; class heads at `alc[cls]`, lengths at
  `alc[32+cls]`. `corpus_setup` sets host `KEEP_WORDS=CAP_WORDS=32768`;
  device retention uses `CHUNK=256`. A conservative initial fast-path guard of
  `old_length + class_size < 256` is safe but misses some host opportunities.
  Merely checking `old_length < threshold` is insufficient when adding a
  multiword class can reach the hand-off threshold (`runtime.c`).
- Heap base is **not a universal constant**: `HEAP_OFF = STAT_OFF +
  PAGE_UP(program.static_words)`, page size128 words. The descriptor stores
  `static_words` at byte64. Use the actual authenticated program value.
- `term_ctr(cid,loc)` and the RFC/tag/location masks must match the pinned runtime.
- Admit only the existing audited sequential host runtime. Atomic/device/future
  provider changes do not inherit the template automatically.

These facts are source observations, not a permission to bypass malformed-state
or error obligations. Valid-state controls cover raw/shared/static/packed values,
retained aliases, pool-hit and pool-miss paths, and free-list near-hand-off cases.
Do not execute malformed heaps or custom failure probes. Review refusal/error
ordering structurally and keep the original runtime as the fallback authority.

### Cheap falsifier and transfer

1. Use the frozen complete Phase166 lookup/digest program **and** the nonempty
   real-verifier fixture. Retain their independent full-value/diagnostic oracles.
2. Compare original and candidate complete native processes in balanced pairs.
   Record fast-path opportunity/coverage separately from clean timing. If almost
   all observed takes are shared, do not attribute the shared `span_fade` cost to
   a raw-only fast path.
3. Inspect one actual caller's machine code: removed helper calls, fewer spills,
   scratch elimination, code growth and unchanged slow paths. Fewer calls alone
   is insufficient; branch pressure may lose.
4. Require transfer to the real verifier before rebuilding a compiler image.
   After a meaningful win, transform/employ the actual retained compiler and
   compare the same full source. Include larger QBE/machine-build cost: inlining
   can make the compiler faster to run but slower to acquire.

This is a fast execution falsifier with an existing independent oracle. It is
not a general runtime rewrite, collector experiment or giant new IR project.
If it is neutral, stop; do not expand the arity/ownership cases indefinitely.

## The broader architectural alternative remains larger and less certain

One semantic function graph shared by direct and scheduled lowering remains the
largest concrete work-elimination candidate. Current `p168_selected` prepares
private candidates; nonadmitted demand later invokes `p167l_family`; region
analysis then reconstructs callable local computations. Interfaces, local values,
branches, ownership facts and suspension sites could be produced once, with
calling-convention realization deferred. Ordinary admitted calls become native
calls; actual resumable/fallback sites become frames only when required.

The first slice must replace those producers for one real function family and
preserve complete final products. Packing the already-built bodies into another
record merely adds work. Current generic production is only8.508s; the larger
potential comes from avoiding failed private production and downstream
reconstruction, and eventually reducing the generated compiler's own execution
work. These effects must be measured separately, not added twice.

Bendc's borrowed-parameter analysis is relevant to that interface design, but is
not a missing universal magic pass. Its `Bor.ev`/`Bor.fix` tracks parameters and
field provenance, propagates known borrowed call arguments, and rejects parallel
lets, arrays and many owned-result uses. Our scalar/product readers already
cover part of this space. Phase171 shows why another isolated selector contract
is weak. General allocating functions with borrowed context parameters would
require owned-result/pointer-escape obligations, not just extending a result bit.

**Recommendation:** execute the bounded inline-runtime fast-path comparison as
the cheapest genuinely different bendc-informed test, while selecting one actual
repeated-lowering family for the common-graph alternative. Do not market either
as a proven100s path. If the call boundary has little complete-consumer leverage,
spend the next implementation budget on work elimination rather than another
ownership-helper variant.

## Exact source anchors

Pinned bendc files under `selfhost/build/phase158/current`:

- `bendc.bend` SHA256 `72be729fb5a27c528acc4d232314ac44c4595a86dc67d9dde47197956edabb99`:
  `Gen.stmt`9381, `RC.wrap`5733, `Gen.def`9922, `Lo.program`25746,
  `Gen.program.fin`25944, `Gen.program`26462; borrowed-parameter contract13303,
  `Bor.call.name`13656, `Bor.ev`13703, `Bor.fix`14180, `Dps.build`14201.
- `core.bend` SHA256 `776ec5d81269d74ab3e8da0ad0f748e0f0e48695aae667a5d57ed033c433a1b7`:
  typed surface `Expr`2034 and lower/raise section2026.
- `check.bend` SHA256 `786514afc1804c00371356943ac6790c16c04c04551e7ab8e0d8f6468e22bf41`:
  typed terms222 and `Book`278; native memoization is not presumed absent.

Maintained source:
[`runtime.c`](../../selfhost/src/runtime/qbe/runtime.c#L776) allocator/free,
[ordinary take](../../selfhost/src/runtime/qbe/runtime.c#L1073),
[verified sized helpers](../../selfhost/src/runtime/qbe/runtime.c#L4751),
[`runtime.h`](../../selfhost/src/runtime/qbe/runtime.h#L11),
[emitter descriptor](../../selfhost/src/back/qbe/emit.bend#L343),
[existing borrowed inliner](../../selfhost/src/back/qbe/borrowed-regions.bend#L970),
[early private candidates](../../selfhost/src/back/qbe/early-observers.bend#L340),
[demanded generic family](../../selfhost/src/back/qbe/early-demand.bend#L288).
