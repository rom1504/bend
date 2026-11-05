# Phase163: direct-first boxed-Term QBE audit

Source and retained-machine inspection at `a8b5989`, 2026-11-05. No compiler,
target, profile capture or production edit was performed. The proposal is an
execution/call-boundary experiment, keeping the current Term representation and
ownership runtime. It does not replace the checker, weaken final admission or
assume that GC/direct calls are automatically faster.

## Main conclusion

**The desired single-result ABI already exists.** `P113DFunction` can represent
an ordinary QBE function taking borrowed runtime state and word arguments,
returning one owning boxed Term. `P113DCall`, `P113DResult`, `P113DAgain` and their
emission/verification machinery already supply direct calls, return and
snapshot-safe self tail loops. The architectural opportunity is to make this
the first representation for an admitted pure call graph, instead of deriving
selected direct workers while also retaining all generic continuations.

The important missing coverage is not simply “boxed results”: it is non-tail
recursion, mutually dependent callees, escaping/indirect functions, plus the
bridge to scheduled/effectful execution. These are real contracts. Merely
predeclaring all signatures or deleting dependency checks admits programs whose
native stack or scheduler state no longer obeys the old behavior.

Phase162 supplies two cautions. Publication bookkeeping has a separate measured
algorithmic cost; a direct ABI does not remove its12.02million recorded book-pass
visits. Likewise an application still allocates the generic KTerm plus two child
list cells (three objects/15 requested words) unless representation changes too.
Keep those hypotheses separate so this experiment attributes a real mechanism.

## Reuse these existing interfaces

All source paths in this section start at `selfhost/src/`.

| Existing component | Concrete use in the prototype |
| --- | --- |
| `back/qbe/model.bend:243–264` | Reuse `P113DStmt`, `P113DFunction`, `P113DCandidate`; a one-word result is already supported. No new general IR is needed for the first owned direct experiment. |
| `back/qbe/direct-lower.bend:117–140` | Existing let/liveness lowering partitions owned environments, retains values required by both computations and sequences evaluation. Reuse these operations rather than inventing host-side ownership inference. |
| `back/qbe/lower.bend:370–387` | `p111_partition` drops unused owning bindings; `p111_keep` emits retains only for owning kinds. Keep its nonowning/scalar distinctions. |
| `back/qbe/verify-direct.bend:221–285` | Word formals, direct calls and returns; multi-result output pointers exist but are optional for a boxed-first prototype. |
| `back/qbe/verify-direct.bend:235–250` | Tail recurrence snapshots every new argument before overwriting any old formal. Required for swaps, aliasing and ownership transfer. |
| `back/qbe/verify-direct.bend:334–367` | Private worker emission and existing scheduled-to-direct public adapter. Preserve public/closure names and table metadata at the compatibility boundary. |
| `back/qbe/helper-resume.bend:16–110` | Existing admitted single-result callable lookup and helper-resume composition. It validates full argument stores before direct calls and loads all arguments before scratch/capture reuse. Current bridge admission caps arity at8; do not silently generalize it. |
| `back/qbe/product-composition.bend:550–625` | Tail-only two-function SCC checking and merged tagged-loop rewrite. Reuse for admitted tail cycles; its whole residual-block check is necessary. |
| `back/qbe/verify-compact.bend:510–547`, `retained-context.bend` | Existing initial verification plus independent original/final verification. A new recursive contract needs an explicit corresponding verifier change, not a forged old ready table. |

Minimal owned signature, already emitted by `p113e_call_emit`:

```text
function l $worker(l %state, l %argument0, l %argument1, ...) -> l
```

`state` is borrowed. Each owning Term argument transfers one ownership obligation
to the callee; the result transfers one obligation back. Scalar words use their
existing authenticated kind, not a guessed owning-pointer interpretation. An
unused owning argument is sunk. If a caller retains a value across a consuming
call, it must use the **returned word** from `p111_rt_keep`; that helper can alter
the reference/forwarding representation. A retain is not merely a counter side
effect whose result can be ignored.

Keep constructors, takes, closures, primitive imports and readback on the current
runtime ABI. `runtime/qbe/runtime.c:3932–3961` implements keep/sink/ctor/take;
constructors consume field ownership, and take consumes/destructures the shell.
Do not add compensating drops to transferred fields. The current reference-count
runtime does not require treating every machine local as a tracing-GC root.
That fact would not survive an unrelated moving/tracing-runtime change without
a new contract.

## What the scheduler work actually is

`runtime/qbe/runtime.h:12–19` defines the2088-byte `P111State`: environment,
continuation stack pointer, sequence/result/next fields, and256 word registers.
The generated program currently declares its actual smaller live transport width.

`runtime/qbe/runtime.c:3984–4005` shows that a jump copies arguments to the
register bank, resets result count and writes `next`. A return copies results,
writes the count and pops a continuation FID. `work_loop:1433–1452` selects the
segment function, calls it indirectly, reads the next transition and repeats.
Some argument loads/frame operations are already inlined into generated QBE,
and live-bank transport avoids clearing the whole256-word array. Describe the
actual copies/dispatches, not an obsolete claim of unconditional256-word copying.

A direct call removes intermediate scheduler transitions and gives QBE ordinary
argument/result liveness. It does **not** inherently remove keep/sink, constructor
allocation, reference-wrapper checks, generic term fields or repeated analyses.
It also moves pending call state from the explicit runtime stack to the machine
stack unless tail loops or another stack-safe lowering preserve it.

## Actual hot owners still scheduled

Evidence: `selfhost/build/phase161/profile-full01/stages.json`, its complete
exact-output capture, and `profile-prep01/owners.json`. The capture has7452
samples,99.43% main-thread coverage and zero loss. Owner samples name the active
dispatch context, **not exclusive function CPU**; calls into helpers/ownership
operations may occur underneath it. Small slices remain descriptive.

| Owner / maintained source | Retained dispatcher segments | Relevant active-owner samples | Why direct coverage is difficult |
| --- | ---: | --- | --- |
| `p131i_insert`, `core/index-queries.bend:9` |16|100/1051 checking|Recursive tree reconstruction performs work after the recursive result. Legacy KDef and malformed/split-zero fallbacks coexist with typed index nodes. |
| `index_remove`, `core/index.bend:186`; `index_remove_step:198` |8 for `index_remove`|53/1051 checking|Mutual recursion, with `Con{h,index_remove(...)}` on one branch. An arbitrary collision bucket has no32-element bound. |
| `nc_uses_term`, `back/native/bridge.bend:167` |8|43/360 generic production;80/835 candidate production|Tail transfer into the mutually dependent list walker; raw Var must remain a leaf even if malformed children exist. |
| `nc_uses_list`, `back/native/bridge.bend:173` |7|19/360 generic;28/835 candidate|`nc_uses_list(rest,nc_uses_term(h,uses))` retains sibling state across nested traversal. AST nesting is not statically bounded. |
| `f_grow_base`, `front/parser.bend:538` |71|48/920 parse/load|Many closure/branch continuations and dependencies back into recursive parsing. Large initial candidate; useful later transfer target. |

The same owner map contains `p113d_` direct workers for `f_find`, `f_eq`,
`f_prec`, `book_final_filter`, `book_final_seen`, `kt`, `app`, `k_rebuild`,
`nt_append`, `p111v_get` and `p144e_body_tail`. High samples for one of these
do not establish missing direct lowering. `terms_len` and `p113d_deps` also have
`p114r_` region workers: absence of `p113d_` alone is not proof of scheduling.
Inspect all admitted worker/adapter kinds before choosing a target.

## Retained machine evidence

Inspected exact diagnostic ELF
`selfhost/build/phase161/profile-build03/runtime/program` (19,008,664bytes),
which relinks the existing retained program object. The authenticated owner map
names QBE SHA256
`1032c6a6495ca86bb26ad2bcd7ae639ed49dc987765dfe567dce7ac6224bf7bb`.
The report's owner binding checks all73926 function symbols and56649 FIDs.
No debug image was rebuilt and no machine target was run.

The following are selected `p111_` **entry bodies only**, not whole owner groups.
Decoded names below have a `$direct.` prefix, but that spelling does not make
them ordinary direct workers. Their symbols still take only `P111State*`.

| Entry | QBE line | Machine bytes | Static instructions | Initial stack subtraction | Selected retained runtime call sites |
| --- | ---: | ---: | ---: | --- | --- |
| `index_remove` |2782084|386|88|`0x1008`|2 keep,1 jump,1 return,1 take2,1 sink|
| `p131i_insert` |2782859|2231|505|`0x1838`|7 jump,5 keep,19 sink plus constructor/take sites|
| `nc_uses_term` |1749732|288|74|`0x1008`|2 jump,1 keep,2 sink|
| `nc_uses_list` |1748500|275|60|`0x800`|1 jump,1 return,1 take2|
| `f_grow_base` |995504|309|69|`0x1008`|1 jump,1 keep,1 take2|

Method: `nm -S --defined-only` plus
`objdump -d --no-show-raw-insn --disassemble=SYMBOL`; count addressed instruction
rows and `call`/`callq` mnemonics. Decimal character codes after `_FID_` recover
the names. Counts include cold/failure branches and alignment instructions.
They are static sites, not executed operations or speed estimates. Diagnostic
runtime hooks make this an architecture trace, not a clean timing result.

Scratch is part of the risk for recursive direct calls: `p113e_private:334`
currently reserves2048bytes per direct function before local scratch, and
`p111_segment:400` starts generic segments with the same default. A direct-first
emitter should compute the required scratch capacity from admitted operations
and pass it consistently to both verifier seed and emitted alloca. Reducing only
the alloca text while the verifier still assumes2048bytes is unsound. Reusing one
global scratch across recursive callees clobbers caller-live data.

## Prototype interfaces and sequence

**First interface: closed owned direct region.** Keep ordinary boxed values,
existing runtime imports, same source algorithms and public wrappers. Classify
the actual call graph before lowering. Emit direct bodies for acyclic calls,
self tail loops and already-admitted tail SCCs; retain generic entry adapters
only at the boundary. Produce an explicit refusal for unsupported callees,
effects, bangs, foreign calls and indirect applications. This can expose the
cost of producing/transporting generic continuations without introducing GC,
new term layout, speculative purity or unrelated optimizations.

For a first substantial **scheduled** hot region, `nc_uses_term/list` is a good
semantic target but needs its pending siblings represented explicitly. A small
owned work stack plus a tagged loop can represent the mutually recursive walk;
the stack holds the exact pending sibling list and accumulator obligations.
That should be a general structural/SCC transform, not a name-specific rewrite
marketed as direct-first coverage. Include stack construction, snapshots,
result consumption and destruction in its lifetime measurement. A shallow
handpicked tree is insufficient. `index_remove` is the corresponding
tail-modulo-constructor case: destination passing or an explicit reconstruction
stack is required to avoid unbounded native recursion.

`p131i_insert` may be a useful bounded-depth prototype **only if** the admitted
domain establishes the32-bit Patricia-mask depth invariant. The generic source
type and current fallback paths do not establish that automatically. Do not
assume every `KIndexNode` supplied to a generic compiled function has a valid
monotone mask, or silently replace its legacy KDef fallback.

**Second interface, only if coverage requires it: synchronous generic bridge.**
There is no such boxed-return helper in the inspected runtime. `p111_rt_jump`
and `p111_rt_apply` return scheduling status0; they do not evaluate a callee and
return its value. Calling either as an ordinary expression is wrong. A real
bridge must isolate/save caller transport state, provide a sentinel continuation,
run the scheduled region to an exact one-result return, and restore its frame
without duplicating/dropping owned arguments. Effects, asynchronous work,
exceptions/fail-stop and reentrancy need explicit policies. Preserve the existing
scheduled-to-direct adapter first; defer the reverse bridge until its contract
is required and independently tested. Per-call bridge copies could erase gains.

Do not force arbitrary recursion through the old verifier: both
`p113e_functions:188` and `p147d_functions:523` check a function before inserting
its signature, deliberately enforcing ready dependencies. `direct-lower:82`
rejects non-tail self calls. `p126sc_safe` admits internal SCC calls only when
their entire residual block is the corresponding result. Preseeded signatures
alone remove these stack/call restrictions without replacing their guarantees.
A genuinely new recursive ABI needs a separately stated verifier/admission
contract; reusing an old “passed” label is not sufficient.

## Fast falsification and transfer gates

1. Metadata/source-only: report actual admitted owners and refusal reasons,
   dependency/SCC shape, generic segments avoided, scratch maxima and exact
   wrapper identities. Do not infer coverage from a `$direct` name.
2. Small independent controls: aliasing/repeated parameters, dropped fields,
   shared constructors, tail-argument swap, all return branches, closure escape,
   invalid constructor fallback, error propagation, deep lists/trees and mutual
   recursion. Fail-stop is not an ordinary zero-valued result (`p111_rt_fail`
   posts an error and returns0). Test both fresh and shared ownership.
3. One captured real-owner workload with complete unchanged result, changing
   inputs and full setup/teardown; retain existing fallback and final verifier.
   Reuse Phase154/157 capture/oracle infrastructure rather than inventing another
   benchmark. Include compiler cost to produce the direct body, not runtime only.
4. Transfer an admitted compiled compiler image to a small real request, then
   one complete full-source request with the existing independent output oracle.
   Separately measure self-acquisition/output size: generic body production alone
   was only11.59s/239.79s in Phase161. A large whole-build gain must include its
   downstream optimization/registry/emission/reclamation consequences.

Rank the work by measured boundary eliminated, not by the promise of a new ABI.
Direct-first is a credible architectural direction because it can simplify both
generated execution and compiler production. The audit establishes reusable
components and remaining obligations; it establishes no speedup yet.
