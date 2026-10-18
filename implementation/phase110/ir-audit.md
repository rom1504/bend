# Phase110: constant facts and typed pair calls

This audit covers the source boundary and the additive IR implementation. Target
compilation, execution, laws and timings run serially under the root campaign;
their receipts and promotion decisions belong to the integration report. The
Phase106/107/109 model, walkers, emitters and evidence remain unchanged.

## What the existing IR already supports

Phase106 Nx already represents full-width values, typed parameters, scalar
direct calls, mutable locals, branches and loops. Phase109 `NxLibrary` adds
external signatures and an opaque context while refusing raw allocation,
free, loads, stores, offsets, function pointers and indirect calls. Scalar
imports are lookup declarations rather than empty implementations available
to inlining. Every call remains an effect barrier and arguments must be pure.

This is sufficient for ordinary first-order calls between ownership workers;
the missing general-source boundary is checked dependency/signature admission
and ownership-aware call lowering. It does not require another scalar IR or
an SSA rewrite. Existing Nx U64 is still a machine carrier, not a distinct
owned-Term type: arbitrary U64 arithmetic is not prevented by Nx typing.
The structured ownership layer and authenticated lowering remain responsible
for restricting Term observations and ownership transfers.

Phase110 keeps ownership operations in the original verified `NxoOp` graph.
Only subsequent machine lowering exposes the authenticated `term_aux` shift
40 and mask 65535, and the already known constructor/retained-field constants.
This avoids passing constants through a generic out-of-line helper where the
runtime compiler cannot recover them. It grants no permission to treat a Term
as an address. See [the ABI audit](abi-audit.md) for runtime authentication and
the exact unique/shared/static rules.

## Additive typed pair boundary

The new modules under `selfhost/tools/performance/phase110/nx/` add:

```text
Nx110ImportPair { name, params, first: NxType, second: NxType }
Nx110CallPair   { first: local-name, second: local-name, name, args }
Nx110Stmt      = scalar NxSet/NxReturn | if | while | pair-call
Nx110Function  = existing scalar signature/locals + Nx110Stmt body
Nx110Library   = scalar imports + pair imports + functions + exports

nx110_pair_library(specialized NxLibrary) -> Nx110Library
nx110_take_pair_library(specialized NxLibrary) -> Nx110Library
nx110_verify / nx110_qbe / nx110_c
```

This small statement facade reuses the existing scalar expression/type
representation, expression verifier, QBE expression generation, C expression
generation, local initialization and declaration conventions. The facade is
experimental overhead, not a claim that maintaining two control-flow walkers
is the final architecture. It permits a measured additive extension without
changing every historical Nx matcher or allowing old optimizers to silently
drop an unknown statement. No old optimizer receives the facade.

The pair import signature is explicit. Admission currently requires exactly
two U64 results, distinct declared U64 destinations, exact argument widths and
arity, pure arguments, valid unique names and no collision with scalar imports
or definitions. A pair cannot be called as a scalar expression or exported as
a scalar worker. Pair statements cannot be nested inside an argument or an
arithmetic operand. All call arguments are evaluated before either output
is assigned. The existing scalar worker export ABI remains
`(opaque context, owning Terms...) -> owning Term`.

This verifies structure and widths. It does not establish ownership credits,
context validity, initialized scratch fields, correct runtime refcounts or
that an arbitrary caller's import declaration describes a real implementation.
The source-owned graph must pass the existing ownership verifier first.

## Two independent transport transformations

`pair.bend` replaces only the immediately adjacent specialized reconstruction
and remaining-field transfer:

```text
first  = rt_rebuild2_cC_kK(ctx, parent, other)
second = rt_fast_field(ctx, 0)
  ->
(first, second) = rt_pair_rebuild2_cC_kK(ctx, parent, other)
```

The four admitted names encode C in {1,3} and K in {0,1}. Contexts must match,
the field index must be U32 zero, and destinations must be distinct. No source
function name participates and no intervening effect is crossed. The transform
recurses through branch and loop bodies and preserves unmatched scalar code.
It adds explicit pair declarations while retaining the original scalar import
list, so fallback paths remain typed.

`take.bend` is a separate optional ablation, leaving the reconstruction-only
transform unchanged. It first applies that transform and then replaces:

```text
status = rt_fast_take2(ctx, parent)
first  = rt_fast_field(ctx, 0)
second = rt_fast_field(ctx, 1)
  ->
(first, second) = rt_pair_take2(ctx, parent)
status = U32(0)
```

All three contexts, both field indices, adjacency and distinct destinations
are checked. Restoring zero preserves the original status value even when
the caller reads it later. The runtime returns both child owners after the
same production take/free behavior. This operation applies to ordinary takes
in tail/last/discard/duplication workers; it does not require reconstruction.

Both transformations depend on the structured layer's immediate, complete
scratch-transfer discipline. They are not equivalence claims for arbitrary
malformed scalar libraries that later inspect stale scratch state.

## Actual QBE and C consumers

The C consumer declares `struct NxRtPair { uint64_t first, second; }`, calls
the exact imported prototype once into a block-local temporary, then assigns
both outputs. The QBE consumer declares `type :nx110_pair = { l, l }`, makes
one aggregate call, loads its two components, and assigns the typed locals.
The aggregate pointer and its offset 8 exist only in the QBE machine consumer;
neither is represented as a user-visible Term pointer in the semantic graph.

The local pinned QBE 1.3 source establishes the ABI mechanism:

- `doc/abi.txt`, Classification and Returning: two aligned integer eightbytes
  use RAX and RDX on amd64 SysV, while larger/unaligned results use memory.
- `doc/il.txt`, Call: aggregate values in QBE IL are represented by pointers.
- `amd64/sysv.c`, `selcall`: aggregate-return lowering creates a private return
  pad and stores the selected return registers into it.
- `amd64/targ.c` sets `abi0=elimsb` and `abi1=amd64_sysv_abi`; `main.c` performs
  promote, SSA and load optimization before `abi1` inserts these pad stores.

The first root-built products confirm this mechanism. In
`selfhost/build/phase110/build01/pair-qbe.s`, each reverse-loop pair call is
followed by stores at `-16(%rbp)` and `-8(%rbp)` and two reloads into the next
loop arguments. Read-only disassembly of the same build's `pair-clang.o` and
`pair-gcc.o` shows direct use of RAX/RDX with no aggregate stores. All three
use the identical runtime object. The paired call removes the scratch helper
but QBE retains its private return-pad traffic. Matched-runtime timing decides
the practical gain; this source/machine finding is not a speed ratio. No custom
QBE calling convention or toolchain modification is part of this candidate.

## Controls and execution boundary

`nx110_control_report()` prepares 22 structural admission/refusal cases and
seven reconstruction-upgrade boundaries. They cover pair signature collision,
unknown imports, wrong argument/result/destination widths, duplicate outputs,
nested effects, raw context loads, scalar invocation of a pair, export misuse,
fallthrough, branch/loop placement, exact adjacency/context/index and invalid
source-library refusal. `nx110_take_control_report()` adds nine take-protocol
boundaries, including preserved zero status and verification of the resulting
typed graph. `nx110_alias_control_report()` adds six explicit alias boundaries.
The entry transformations verify the original scalar library before rewriting:
a U64 result cannot overwrite an opaque pointer context, and the U32 take
status cannot alias a U64 child. Both consumers evaluate inputs before writes,
so overwriting an already evaluated U64 input is permitted. The first 29
controls passed in `build01/emit-pair/pair-controls.txt`; additional reports
belong to later root-run receipts. These synthetic structural controls do not claim
that their sample Term values have valid semantic ownership.

Actual emitted workers and runtime contracts must separately check exact
outputs, full-width Terms, unique/shared/static inputs, retained aliases and
allocation cleanup. Reusing one machine runtime object for both consumers
holds the runtime denominator constant. Source size, source/API acquisition,
ordinary worker build and execution time remain different measurements.

## Ordinary owned-call extension

The additive `phase110/calls/` candidate extends the existing semantic graph
with `NxoCall{dest,symbol,words}` and reuses ordinary scalar Nx calls. Its
`overrides.json` authenticates four exact historical declarations before
`prepare.py` replaces them in a composed candidate source: `NxoOp`,
`nxo_v_ops`, `nxo_nx_op` and `nxo_p_op`. The historical files remain unchanged.
The new recursive source traversals carry an explicit callee catalogue and
reuse the old constructor checks, occurrence budgets, credit operations,
branch assembly, tail moves and machine consumers.

`nxc_lower_library(sources,ctors,exports,policy)` derives the catalogue from
the exact list of `NxcSource{fact,symbol}` entries it will compile. Every source
must pass the existing erased-body shape/descriptor admission; source names
and machine symbols must be unique. Every direct call must resolve in this
catalogue with exact live arity. All definitions enter the final Nx library,
which independently rejects unresolved calls, incorrect machine signatures,
runtime-symbol collisions and invalid exports. There are no declaration-only
ordinary callees silently supplied by an unrelated runtime object.

The credit checker consumes one token per owning argument occurrence and adds
one token at the result destination after those consumptions. It rejects a
missing retain, repeated consumption, overwritten live result or leaked result.
The result's constructor identity is unknown until refined. A separate pass
checks the call catalogue; the old ownership checker alone does not establish
callee identity/arity. The full closed-library entry is the intended boundary.

Nested arguments are lowered left to right while threading the occurrence
budget computed over the entire terminal expression. Calls in constructor
fields and matched branches use the same staging. An ordinary call invalidates
the machine tag cache and remains an effect barrier. Final self calls retain
the existing tail-loop lowering; a non-self call emits a scalar call followed
by subsequent computation or return. The actual `nt_append` composition thus
stages a nullary list, calls reverse, calls reverse again with the returned
owner and second argument, then returns that owner. No append-specific
algorithm or source-name rewrite is present.

The 27 call controls separate credit failures from closed-catalogue,
symbol, export, policy, dynamic-call and arity failures. The root's initial
ordinary-call gate passed all 27, together with six pair alias controls. The
actual unchanged `nt_append` and `nt_reverse` closure passed six frozen training
graphs for fused, specialized and pair-take profiles with both QBE and Clang;
these include retained physical aliases into both inputs. The emitted ownership
graph has two ordinary reverse calls and no specialized append operation.
Held-out, depth and broader shape witnesses remain separate campaign gates.
Ordinary recursion uses the native call stack; only the existing self-tail
case has an explicit bounded-stack loop. No arbitrary recursion-depth claim
is made. The source contract still authenticates all parameters/results as
owning Terms; a fabricated `NativeErasedBody` label is not general ABI evidence.

## Private runtime templates and native source integration

`calls/runtime-library.bend` applies the same closed source catalogue to the
separate runtime-template worker boundary. `nx110rt_lower_library` lowers each
fact with `nxc_apply`, checks its credit and callee rules, preserves `NxoCode.next`
when constructing the worker, and validates the complete library after all
definitions are present. The exact replacement in `runtime-overrides.json`
strengthens `nx110rt_verify`: every `NxoCall` must resolve against a catalogue
derived from the actual workers, including calls inside branches. Canonical
machine regeneration and full library signature checks remain in place.

This additional check matters even when a graph has valid credits and machine
types. A forged owning call to `rt_fast_keep(ctx,p0)` has the same scalar machine
signature as an owning identity function, but its runtime operation retains a
credit. It cannot serve as an owning ordinary callee. The prepared 15 runtime
call controls include that counterexample, missing workers, wrong arity, bad
credits, nested source calls and branch-local import forgery. The source tool
applies this guard whenever it composes ordinary calls with runtime templates;
the original runtime-template source and prior source snapshots stay intact.

`phase110/native/prepare.py` now assembles the unchanged mature checked frontend
with these experimental modules and an exact entry adaptation. Requests still
require the frozen reverse/discard/duplicate/tail/last/append source contracts;
the real frontend checks and erases that source before selecting facts and
lowering the whole worker closure. Append's reverse worker is private. Scalar,
typed-pair and runtime-template policies share the owning-call rule. The source
preparation records every input and exact override and does not execute a
compiler. Its separate small entry-check source uses explicit frontend mocks
only for type checking and must never be executed as correctness evidence.
Image acquisition and ordinary native requests have separate root-run receipts.

`calls/emit-shapes.mjs` provides a separate actual-source transport for the
coverage agent's frozen eight-definition catalogue and six exports. It verifies
the complete capture binds the exact source bytes, selects unchanged checked
facts with the declared live arities, and delegates the complete closure to the
Bend lowerer. It serializes every ownership and machine graph and emits matched
QBE/C. The additional `p110_reverse_via_call` source is explicitly synthetic:
its branch performs take, build, ordinary call and return, permitting the generic
continuation template to be tested without a source-name optimization. This
transport contains no list algorithm or ownership lowering. Its emission and
source-refusal checks are distinct from the prepared 18 training and 10 held-out
native harness cases.

## Scope required beyond the bounded catalogue

The mature frontend already retains the facts needed for a bounded typed entry
boundary; the `NativeErasedBody` record intentionally does not retain them:

| Existing API | Relevant fact or limitation |
| --- | --- |
| `p86_plan_checked` / `p86_plan_annotated` in Phase86 `entry.bend` | Typechecks the original book, checks owned annotation, then creates a native request. |
| `NR_Request.source` and `.book` in `src/back/native/request.bend` | Original typed definitions and the attached erased native facts coexist in one request. |
| `nr_visit` | Produces `NativeErasedBody` with `typ=Absent`; erased arity alone has no entry representation evidence. |
| `ns_body(book,name)` and original `lookup(source,name)` / `dt` | Retrieve corresponding erased body and original checked telescope. |
| `nd_arity_plain` in `direct.bend` | Can include a returned function's leading lambdas; it must not replace declared source arity when classifying an owning result. |
| `nc_ctor_identity` in `identity.bend` | Grants Base identity from the enclosing ADT's provenance; non-Base constructors are encoded distinctly. |
| `f_path_defs` / `f_seed_matches` in `src/load` | Base metadata comes from loaded module identity; the prepared seed gate binds that identity to the exact canonical path and complete source text. |
| `nq_layout_type`, `nq_layout_specialize`, `nq_layout_dep`, `nol_ctor_fields` | Existing bounded syntax queries support aliases and field specialization, but the observer schema as a whole has different ownership/result requirements. |

The small `phase110/admission/` prototype uses direct canonical syntax rather
than importing those larger schema passes. It reads exactly the original
definition's declared parameter count, admits only live `String` and
`List<&2,String>` parameters/results, and checks the actual Base
String/List/Char constructor telescopes with alpha-bound references. It emits
structured ordered roles plus the exact typed definition and erased fact.
No erased parameter, alias, dependent type, higher-order role or generic
specialization is silently inferred. The independent coverage fixture includes
a function returning a function: its declared arity is one even when its
erased direct entry has arity two. That is the cheapest concrete falsifier for
an arity-only admission policy.

`nxe_entry` is a structural factory, not an authenticity oracle for arbitrary
KDefs. Its host probe binds both books to products of one actual checked
capture and requires the pinned driver Base path and bytes. The unintegrated
native `nxe_plan` adapter validates the prepared Base with `f_seed_matches`,
creates the checked request through `p86_plan`, and selects the two facts from
that resulting request. Its seed and expected Base path/text must still come
from the trusted native preparation/assets boundary. These requirements cannot
be replaced by a caller asserting `native=True` or supplying a serialized
certificate. Reflected malformed-data tests are distinct from reachable source
programs that the mature checker actually accepted or refused.

A concrete wrapper that calls polymorphic `nt_reverse` can receive an entry
certificate, while its closed library must still refuse without a certificate
for that dependency. Generalizing that step needs checked type-argument
substitution from the original typed call before erasure, with per-instance
identity when one generic definition has multiple representations. Reusing its
erased body and guessing `String` from the root entry is insufficient. The
initial prototype remains separate from native selected-source admission until
the independent source and mutation gates qualify it.

A general descriptor boundary should transport constructor identity, runtime
arity, erased/runtime field mapping and child representation facts directly
from the authenticated checked book, with exact binding to the runtime's
descriptor table. Unsupported layouts must refuse explicitly. More binary
constructor names in a hand-maintained whitelist do not establish general
descriptor support. Generic semantic take/build operations can retain field
lists; machine lowering can then choose scalar, pair or larger-result ABIs.

The call candidate closes an explicitly supplied checked source set. General
source integration still needs automatic dependency extraction and checked
parameter/result representation facts; borrowed arguments need separate
contracts. List.tail, List.last.go and the real `nt_append` composition expand
the finite evidence. Scanner and continuation-heavy work should follow once
descriptor/call admission can express their actual bodies and independent
full-output oracles are frozen. Neither inlining nor whole-program SSA
conversion is required merely to admit that next coverage.

The prior fused reverse worker was only 1.39 times production Clang time in
its stated screen, so eliminating its remaining overhead cannot demonstrate
a tenfold advantage over that already optimized production loop. Larger
whole-compiler claims require measured coverage of the dominant real work.
For work fraction f improved by s, total speedup is
`1 / ((1-f) + f/s)`; helper or toy-kernel gains alone provide no such bound on
the full compiler. This phase supplies a cleaner transport experiment and a
coverage path, not a general tenfold or recursive-acceleration result.


### Checked entry closure and native factory boundary

The parent campaign has executed the initial typed admission against fourteen
actual checked source cases and nine distinct reflected-data corruptions. The
next additive `nxe_close` pass discovers each requested root's erased `Ref`
closure in Bend, certifies all private callees from the same original typed
book, preserves unchanged erased facts, and assigns deterministic machine
names. Unsupported generic and Char callees refuse even behind a canonical
String/List<String> root. The independent closure oracle has four positive
roots and two such negative roots. This source audit does not count their
pending emitted-worker runs as completed evidence.

The source-only `native/general.bend` factory closes the raw-seed trust gap:
it reads Base from the compiled path, compares the full bytes with a compiled
literal, creates `p86_prepare` internally, and feeds the resulting seed directly
to `p86_plan`. Original source types and erased bodies are extracted only from
that same checked request. Its command accepts an input source path and entry
name, not a serialized seed, KDef, certificate, or provenance flag. The initial
mode is live-only, with one exported `nx_entry`; roots/callees must already be
reachable from checked main. The fixed source03 remains independent while the
general factory awaits qualification and image acquisition.

A separate private-template namespace audit found that a forged ownership word
such as `ir_old1` could collide with a generated private temporary despite exact
machine regeneration. The additive namespace guard restricts all ownership
words to the declared `p0..arity-1` and `v0..next-1` slots. It applies to every
runtime profile, including ordinary calls; captured frontend graphs already use
that namespace and retain identical machine output. This is a certificate
boundary fix, not a measured runtime optimization.

### Owning-call lifetime review of the qualified closure corpus

The actual `closure-check03` graphs contain nine definitions. List and String
chains each transfer `p0` into one call, receive `v0`, and return it; the leaf
returns its sole input. The mixed constructor root evaluates its String call
first, keeps that returned owner in `v0` while evaluating the List call, then
consumes both owners in `NxoBuild{cid=1}`. The diamond root obtains two independent
returned credits and passes both into `choose`; that callee sinks its first
parameter and returns the second. An identity callee may return the same
physical word it received: the new result credit represents a transfer, not an
extra reference. No caller retains a consumed credit accidentally.

`NxoCall` verification spends one credit for every argument occurrence, then
creates one result credit in a destination with zero remaining credits. Repeated
source arguments require `NxoKeep` before that spending, as exercised by the
separate ordinary-call controls. Calls are bound to actual checked worker
signatures and cannot target a runtime import with an invented owning contract.
The machine arguments are materialized plain words and the result assignment
occurs after the call; a caller's other live owners remain in ordinary locals.
Every lowering path clears cached discriminant facts at an intervening call.
Take/rebuild helpers materialize their scratch results in adjacent statements,
so scratch ownership never spans an ordinary call. The private runtime path
also checks its generated `p`/`v` namespace before regenerating machine code.

These four positive general roots have an acyclic call graph with at most
three simultaneous worker frames, independent of graph size. They do not test
recursive ordinary calls. The separate unchanged `nt_append` case calls
`nt_reverse` twice sequentially; reverse's source self-tail recursion becomes
the existing loop, so its call depth is also bounded. The gate permits other
closed recursion if its body/credits verify, but a non-tail recursive call
uses the native stack and arbitrary depth is not qualified. The frozen general
semantic harness supplies overlapping physical arguments, external aliases,
static values, both release orders, pending-scratch checks and final heap
balance; executing those native-produced worker products remains a distinct
parent-owned gate after this source review.

### Native image acquisition literal-size failure

The first general-live image source04 did not emit within its 300-second guard;
its receipt records about 600 MB peak RSS and no generated C. Only Base/runtime
preparation timing markers appeared, so that run alone does not identify a
specific subsequent compiler stage. The parent then isolated the exact new
Base literal: a 1,024-character prefix emitted in 0.718 seconds; the full 75,064-character
literal exceeded 45 seconds in a minimal otherwise equivalent source.

Source inspection supplies a mechanism consistent with that measured cliff.
`nc_compact_plain` expands String literals into nested SCon syntax, and
`ns_intern` caps the entire static image at 65,536 words. The 75,064-character Base
needs 150,128 constructor words, so a substantial part must remain a dynamic
constructor body even in isolation. Changing the runtime/static cap is outside
this experiment. A literal cache stamp is also insufficient: the existing
p88 cache entry explicitly assumes external authentication of the complete
carrier, producer, Base, path and image.

The `native-base-chunks01` candidate kept exact full-text authentication:
74 separate helpers each contain at most 1,024 original characters; a streaming
prefix consumer compares each character and forwards the remainder. A bounded
length pass requires exactly 75,064 characters, and the final chunk requires an
empty suffix. Preparation authenticates the Base pin, each chunk and the exact
concatenation inverse. Eleven Bend API controls passed exact/prefix/truncation/
suffix/content/chunk-boundary mismatches, but minimal native emission still
exceeded 45 seconds. Splitting functions alone did not solve the total static
image pressure; both failed receipts remain intact.

The next candidate, `native-base-packed01`, represents the same 75,064 ASCII
bytes as 18,766 U32 values, four bytes per value in little-endian order. Its 74
bounded helpers contain at most 256 values each. Preparation requires the
inverse byte stream to equal the original authenticated Base exactly. The Bend
consumer compares each full `Char.to_u32` value with the next expected byte,
then advances by one character; it does not truncate incoming Unicode values.
The explicit length pass and final empty-suffix check remain. This is an exact
representation, without probabilistic hashing or weaker cache authentication.

All 11 hosted controls passed. The minimal native emission completed in about
4.8 seconds, and its machine image passed 14 native controls, adding Unicode
characters with identical low eight bits at the first, chunk-boundary and last
positions. The packed List representation needs 37,532 constructor words,
below the existing static cap in isolation. No static cap, compiler, runtime,
or ABI was changed. Fresh `native-source05` replaces only the source04 literal
and equality call with this qualified comparator, and binds both control
receipts plus the minimal emission. The full compiler then emitted successfully
in 148.73 seconds and its QBE image built in 87.64 seconds. The separate
`native-general-qualify01` gate then passed eight exact QBE/C products and four
refusals. `native-general-semantics02` passed 36 independent observations per
backend; the earlier semantics01 failed during Clang tool discovery before
running a target. `native-string-append01` passed 20 observations per backend
for actual Base `String.append`, with first-input recursion bounded to 1,024
cells. `native-fixed-qualify01` preserved eight exact products across reverse,
tail, last and append. The parent also ran the unchanged old 13-case reverse
harness successfully against both native-produced backends. These are semantic
and product-preservation results, not performance measurements.

The final native tooling review found no remaining source/IR trust change. The
general path constructs its own checked seed from the exact compiled Base; the
production bridge expected emitter uses actual captured typed/erased facts;
qualification binds source, emitted C, portable metadata and built image. Worker
runners consume the actual native stdout files and link one pinned runtime
object. Clang must be present on PATH for the original semantic runners; the
old-13 runner also accepts its path explicitly. All target execution remains
serial under the parent's process guard. The isolated packed comparator's
14 native mismatch cases do not constitute an injected full-image Base mutation.
The retained `io_str` decoder also matters for the byte claim: it rejects
overlong UTF-8 and invalid lead/continuation ranges by emitting U+FFFD. Because
the authenticated expected Base is entirely ASCII, no different valid or
invalid byte sequence decodes to that same expected sequence. Sized reads plus
the existing EOF check retain all input, so exact character comparison here
implies exact Base-byte identity.

### Frozen performance transfer and context-call feasibility

The fixed transfer experiment reused the actual qualified native products and
compared QBE `fused` against selected `runtime-ir-single`, with no selection
change. Three predeclared deep `nt_append` graphs had median selected/baseline
worker-time ratios of approximately 0.921, 0.718 and 0.625. The bounded actual
Base `String.append` cases instead measured approximately 1.158 (shared left,
512 cells) and 1.052 (unique left, 1,024 cells), slower in every paired round.
All original oracles passed, including full String observations on every
repetition; only the worker call was timed. One list round was noisy, so raw
paired results remain part of the receipt. These five cases do not establish
universal transfer or application-level speedups.

Actual selected String.append assembly still calls `nx_rt_ir_heap` and
`nx_rt_ir_alc` on each non-tail recursive frame. Reverse loops amortize those
entry calls. That observation motivates a separate bounded context-threading
ablation, but does not establish the cause of the measured regression. The
selected native source05 image stays frozen.

The runtime source supports passing the two borrowed base addresses through a
closed synchronous worker tree: `nx_rt_open` assigns `env={CORPUS,ALC[0]}` once;
`corpus_grow` accepts only an adjacent extension and never relocates the base;
the allocator array has static storage; only close unmaps the corpus. Open and
close are absent from the admitted owning call catalogue. Mutable heap and
allocator contents must still be loaded normally. The exported wrapper must
retain the original context/pending-scratch checks, and exact generated lowering
must materialize all take/rebuild scratch fields before any internal call.
An additive facade may therefore regenerate private functions with
`(ctx,heap,alc,owned...)` parameters and original public wrappers, while keeping
the original ownership/callee verifier and requiring exact full machine graph
equality plus signature/name checks. Private C pointer parameters need
`uintptr_t` declarations rather than the public opaque-context parameter rule.
Machine qualification of this separate prototype is recorded below and remains
distinct from the frozen native selection.

### Context diagnostic capture boundary

The separate context-call API compiled from `context-source04`. Its first
String.append transport attempt was correctly refused by canonical layout
admission: the mature hosted driver captures selected annotated definitions,
and the String-only wrapper's 14-definition graph omitted unused `List`.
The native general factory receives the full same-request source book, so the
previous native qualification did not have this sparse transport limitation.

`context-capture-source01` preserves the original driver and an exact diff.
Its only semantic transport change is to retain annotation roots `main`,
`List`, `String`, and `Char`; remaining edits relocate module paths into the
fresh artifact directory. The actual wrapper source, checked compiler and Base
bytes remain unchanged and pinned. Mature Bend performs checking, reachability,
annotation and erasure; no host supplies constructor facts. The fresh capture
succeeded. An ensuing transport failure was an output-shape assumption: the
Bend control API returns named PASS lines, not a `{passed,cases}` object.
The failure receipt retains all 25 passing lines. `emit-v3.mjs` validates their
exact names and count before proceeding, and still requires original QBE and C
to equal the qualified native products byte-for-byte.

`emit-v3` then completed all three String.append products and its 18 malformed
certificate refusals, but the larger reverse facade overflowed the hosted
stack during exact whole-library String equality. The generated upstream
`String.cmp` retains non-tail recursion and reconstructs borrowed strings.
The first comparator source05 was rejected by the checker for matching a local
Boolean scrutinee; source06 then violated the checker's parameter-match ordering
rule. Fresh `context-source07` puts that Boolean first in the explicit parameter
list, consumes both serialization strings, compares full Unicode codepoints and
recurs directly in tail position. It preserves
complete graph equality, including length; it does not replace equality with a
hash. Six focused controls cover empty/equal Unicode, first/last mismatch,
length and different scalars with identical low bytes. The new `emit-v4`
expects all 31 named controls. Earlier source, API and transport failures remain
separate receipts; no selected native source was rebuilt for this diagnostic.

`context-api07` compiled successfully in 2.862 seconds. Its generated
`nx110ctx_exact_go` is a `for (;;)` loop that updates the Boolean and both tails
before `continue`; it contains no recursive call. The completed
`context-emit04` passed all 31 named controls, emitted all nine
algorithm/mode products, and rejected all 54 malformed certificates. For
String.append, reverse and nt_append, the baseline QBE and C remained exactly
equal to the qualified native products. This completes hosted facade
qualification; actual worker execution and paired timings are a separate gate.

The assertion-only context runtime capsule compiled successfully, and its
31,456-byte object is byte-identical to the original general runtime object.
The machine runner requires that source/object/process receipt, matches the
source to the exact admitted context capsule, and pins the full chain. Thus
runtime machine-code changes are excluded from this specific ablation.

The first machine runner stopped while compiling threaded C because the pinned
Lean Clang installation could not find `stddef.h` through `string.h`. Earlier
QBE/Clang baseline and threaded QBE semantic jobs in that run were preserved;
the partial run is not a complete machine qualification. `run-v2.py` and the
wide runner's v2 explicitly pin GCC's `stddef.h` and add the same `-isystem`
header path to every Clang mode. They leave all emitted programs and admitted
runtime source unchanged.

The fresh `context-machine02` completed all 18 workers and 234 original
semantic observations: three modes and two backends across String.append's
20 observations, nt_append's six graphs and reverse's 13 cases. Its 60 timed
jobs reuse only the two frozen bounded String.append cases, with five paired
rounds per backend. Median variant/current-compact-baseline ratios were:

| Backend | Case | Threaded pointers | Direct context loads |
| --- | --- | ---: | ---: |
| QBE | Shared left, 512 cells | 0.9040 | 0.8841 |
| QBE | Unique left, 1,024 cells | 0.8501 | 0.8571 |
| Clang | Shared left, 512 cells | 0.8821 | 0.9072 |
| Clang | Unique left, 1,024 cells | 0.8340 | 0.8426 |

Every individual paired ratio was below one. A Clang unique-case round was
unusually low (about 0.61/0.63), so the raw paired values and ranges remain
necessary context. The same runtime object and original semantic oracles were
used throughout. These matched results support per-frame context access and
call boundaries as a useful optimization target for this recursive
computation; they do not isolate every consequence of the wrapper/private-call
change. They are not a fresh comparison with fused, and ratios from separate
runs should not be multiplied to claim one. The selected native image and
original heldout choice remain unchanged. The actual-source machine corpus
here uses one or two owning arguments; wider stack-argument ABI checks are a
separate data-graph experiment.

### Additive source size

Physical line counts below include blank lines and comments, and count each
listed source once. Generated assembly snapshots and packed Base data are
excluded. The mature frontend already existed and is composed unchanged into
the image; its full source size is not new Phase110 implementation.

| Role | Files | Lines |
| --- | ---: | ---: |
| Canonical admission and closure, active Bend | 4 | 325 |
| Ordinary-call model/verifier/lowering/library, active Bend | 5 | 277 |
| Exact old declaration replacements for ordinary calls | 2 | 65 |
| Ordinary-call Bend controls | 2 | 113 |
| Native entry/factory/comparator handwritten Bend | 4 | 263 |
| Admission checks and source preparation | 3 | 242 |
| Ordinary-call orchestration | 4 | 276 |
| Native source preparation and isolated diagnostic preparations | 10 | 759 |
| Native qualification and timing transport | 8 | 425 |
| Native comparator diagnostic controls | 2 | 50 |

The raw-seed admission prototype is a separate 20-line unselected module. The
native handwritten count includes the superseded chunk prefix helper; only its
length/dispatch definitions are reused by the packed comparator. The packed
comparator's generated 219,521-byte module encodes the exact Base constant plus
bounded helper calls; it does not add a new source language or ownership rule.
