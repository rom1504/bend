# Phase108 production runtime boundary

This is a source audit and an unqualified portable-runtime implementation. The existing production
allocator, reference counts, constructor layouts, closure consumption and IO
scheduler can be retained behind an ordinary C ABI. The missing work is an
explicit program descriptor and segment transition ABI, plus structured lowering
before the existing C text boundary. No replacement collector is needed.

The implementation chosen after this audit reuses the entire existing Bend C
emitter with a portable C-to-QBE frontend. That allows full-language semantic
lowering to stay in Bend while the object builder changes. The descriptor and
direct QBE import discussion below remains a subsequent reusable-runtime split;
it is not required to compile this existing full C product through QBE.

## Implemented transport

`runtime/runtime-recipes.json` materializes v1 from the selected
runtime from `selfhost/build/phase90/runtime-accessor-transport02/runtime.c`,
SHA-256 `9e1c59078878be94052cb4d2d63a713e19e29b41ed3f94b034f2175a50efd0a9`.
This is the active native runtime with its accessor transport adaptations; the
canonical vendored source is not silently substituted for it.

With `WL_PORTABLE=1`, individual segment functions use the ordinary C ABI with
the original `WL_SIG` arguments plus a pointer to an invocation-local `WlState`.
The explicit stack, registers, sequence flag and result count move through this
frame on `WL_JMP`, `WL_DYN` and `WL_AGAIN`. Those macros set `next` and return
zero. Before each call the dispatcher resets `next` to `UINT32_MAX`; an unchanged
sentinel means the original C return is a scheduler Reply and must leave
`work_loop`. Raw segment returns are untouched. The entry segment is handled
separately because it is absent from `WL_TABLE`.

`tables.bend:nb_bank` now emits `WL_WIDTH`, `WL_INIT_BANK`, `WL_WRITE_STATE(V)`
and `WL_READ_STATE(V)`. Every portable fresh bank is zeroed before its body,
including the `rp` padding word when present; each resumed input is restored
from initialized state. Serialization excludes `rp`. This avoids copying
uninitialized dead registers and preserves the incoming/outgoing scopes around
`WL_OPEN`. Legacy CPU/device branches retain their original protocol; the new
macros alone do not select portable mode. `PRESERVE` attributes are disabled in
portable mode, while ownership/scheduler atomics remain unchanged.

Under `BEND_CPROC=1`, the allocator cache array uses standard `_Alignas(128)`
instead of the GNU aligned attribute. The CPROC build needs both
`-DWL_PORTABLE=1` and `-DBEND_CPROC=1`. This source task did not change effect
registration: constructor attributes still need toolchain support and must not
be silently erased.

The selected CPU runtime's GNU atomic operations all address `u32`; the only
64-bit C11 atomic is `pool_tick`. All accesses to the three `_Atomic` globals
use atomic wrappers. The proposed GCC shim keeps compare-exchange's expected
pointer updates and all requested orders. Its dynamic order arguments may be
implemented as stronger sequential consistency, which preserves semantics but
can cost time. The reviewed representation boundary is Linux x86-64 with natural
32/64-bit alignment; it does not admit device execution or arbitrary external
volatile/atomic code. The runtime's active host code and six compiler effects
contain no `volatile` qualifiers; those occurrences are device-only.

For the initial compiler bootstrap only,
`selfhost/tools/performance/phase108/runtime/bridge-metadata.py` adds the same
four transport macros to an old image. It accepts one exact `WL_SIG` grammar,
cross-checks the redundant `WL_BANK`/`WL_ALL`, verifies canonical contiguous
register numbers and padding, and refuses pre-existing metadata. It changes
no body, expression or semantic lowering. Its receipt records input/output
hashes. A new image compiled from the changed Bend source emits the metadata
itself; normal requests and subsequent self-emission use that source path.

A source-only control applied the bridge in memory to the retained 29 MiB
Phase103 image, found width 17, and reproduced the exact original bytes after
removing the four inserted macro lines. A reordered `WL_ALL` declaration was
rejected. Python syntax and the additive Bend diff's whitespace checks passed.
These checks do not substitute for compiled trampoline/ownership controls.

```
python3 selfhost/tools/performance/phase108/runtime/bridge-metadata.py \
  FIRST-PORTABLE.c FIRST-PORTABLE-METADATA.c --receipt METADATA.json
```

The runtime template must first have been supplied to Bend emission and portable
mode must be enabled for the C build. This bridge does not replace the runtime
inside an already-generated image. No target execution evidence is claimed here.

### Pointer-only segment candidate

The materialized v2 runtime changes only portable transport: every segment accepts
one `WlState*`, and the dispatcher calls it directly without first reconstructing
the old wide C argument list. `WL_CASE` now opens the function and loads the
incoming register bank. The existing emitted block captures arguments before
`WL_OPEN` resets the bank, and the existing two closing braces still balance.
The four builtin segments likewise save their inputs/results before the reset.
All scheduler returns, next-FID discrimination, ownership operations and explicit
stack updates retain their v1 behavior. Legacy mode is unchanged.

This removes one layer of lexical nesting around the generated body. A separate
source audit of the frozen full compiler counted 21,183 segment definitions and
53,000 captured arguments including conditional scalar declarations, finding no
captured-name redeclarations anywhere in their bodies or collisions with the
register/environment names. That establishes
the required scope condition for this compiler image; it is not a proof for
arbitrary manually injected segment text.

The candidate changes 12 lines and removes 14 relative to v1, with no Bend
emitter or generated segment-body changes. Its exact patch and four authenticated
replacement blocks are `runtime-v1-to-v2.patch` and
`runtime-v1-to-v2-replacements.json`. Source-only replay against
`selfhost/build/phase108/full-emit01/portable.c` matches each block once and
predicts 30,395,885 output bytes, SHA-256
`a20a95f1a12d7e556b6dfb17ae795318af6250c249c224437c99aec254aef06b`.
The candidate runtime itself hashes to
`17cece2e0cf301472cb7f9b131337ebaa2cb0eb870f67af73566c8cb6c29eec3`.
No target build or execution was performed by this source task for v2.

### Pure accessor candidate

The materialized v3 runtime starts from v2 and adds 13 conditional lines for
`term_tag`, `term_rfc`, `term_aux`, `term_loc`, and `blk_cls`. Under `BEND_CPROC`,
these pure extractions are function-like macros because this toolchain does not
inline the retained C helper functions. Each macro evaluates its argument once,
casts it to the original `Term` parameter type, and casts the result to the
original `u64`, `bool`, `Loc`, or `Cls` return type. The original functions remain
unchanged in the other branch. Ownership, allocation, reference counts, atomics
and scheduler transitions are untouched.

No other helper was converted: notably `term_triv`, `blk_span`, and `cls_fit`
use their parameters more than once or have branching semantics. The frozen
compiler and its effects use the five selected accessors only in call syntax,
with no address-taking or other function-value use. Arbitrary external C taking
their addresses is outside this macro candidate's admission.

The runtime hashes to
`bffb4258ac362a338b18bb7a6ece1c816a46e6f3112a3cb594d65ae79cdde0dc`.
`runtime-v2-to-v3.patch` and `runtime-v2-to-v3-replacements.json` retain the exact
delta. Source-only replay of its three hunks after the v2 delta produces
30,396,376 bytes, SHA-256
`24b697abc934fe6c006b7f6e1964cb2bd6249a2eb3b249dac4f30f5a5252fe48`.
No target build or execution was performed by this source task for v3.

## Concrete full compiler scope

The retained Phase103 compiler image at
`selfhost/build/phase103/cli06/image.1.c` is a useful bounded integration target.
Its generated metadata says:

| Property | Value |
| --- | --- |
| Program segments | 21,037 |
| Runtime segment IDs | IO emit 21,037; closure apply 21,038; exit 21,039; enter 21,040 |
| Constructor IDs | 405, numbered 0 through 404 |
| Register bank | 17 Term words, plus the C transport's `rp` padding word |
| Maximum result width | 1 |
| Bang functions | 0 |
| Static image | 41,761 words |
| Registered effects | `IO.print_err`, `IO.print`, `IO.args`, `NativeHost.read`, `NativeHost.path`, `NativeHost.publish` |

These are inspected facts about that image, not promises about every compiler
revision. Its existing launcher already chooses one CPU worker and disables GPU
execution. Full compiler coverage therefore need not first qualify GPU execution
or every external C effect. General user-program coverage is a separate gate.

## Template and program dependencies

`back/native/emit.bend:ne_program_runtime` fills exactly four runtime sections:

| Template section | Generated material | Reusable-object replacement |
| --- | --- | --- |
| Tables | IDs, arities, flags, result widths, register macros, main metadata, show metadata | Versioned immutable program descriptor |
| Spins | `STAT_IMG`, direct/observer declarations and definitions | Static data and generated program objects; do not mistake these helpers for stable runtime |
| Segments | Program-specific `WL_CASE` bodies | QBE functions with the versioned segment ABI |
| Requests | Selected foreign C definitions and registrations | Cached host-effect objects plus explicit descriptor-bound registration |

The stable runtime directly uses `FID_ARITY_T`, `FID_FLAG_T`, `FID_RESW_T`,
`CID_ARITY_T`, `CID_HOT_T`, `STAT_IMG`, `STAT_LEN`, `SHOW_DESC`, `SHOW_NAMES`,
`MAIN_FID`, `MAIN_PURE`, `BANGS`, `WL_RESW`, and the four runtime segment IDs.
The ordinary core constructor bindings are `SNil`, `SCon`, `WCon`, `Nil`, `Con`,
`Tuple`, `Unit`, `Some`, `None`, `Done`, `Fail`, `Emit`, and `Halt`. Optional
unavailable-effect diagnostics add `Chan.try_*`, `TCP.try_*` and `UDP.*` IDs.
The compiler's foreign helper also needs its three `NativeHost` IDs.

The only `NATIVE_*` policy flags directly read by runtime.c are
`NATIVE_SCALAR_ARRAYS` and `NATIVE_UNSHARED_ARRAYS`. Generated code additionally
depends on packing, cold-constructor, field-width and observer policies. The first
QBE ABI should use conservative boxed constructors and ordinary Term arrays;
later certified layouts require their own descriptor version or explicit flags.

The retained runtime is process-global: `CORPUS`, `ALC`, `KEEP_WORDS`, banks,
pool state, static IO queues, handles and effect registration tables are globals.
An opaque context pointer is a useful API boundary but does not make those
globals support concurrent independent runtimes. Admit one live context first.

## Ownership imports

Use machine `uint64_t` for the physical Term word, but retain a distinct owned
Term role in IR. A heap `Loc` is a word index into `Env.mem`; it is neither a
process pointer nor an ordinary integer value available for arbitrary rewriting.

| Import | Ownership contract |
| --- | --- |
| `keep(ctx, term) -> term` | Replaces one owned handle with the returned shared handle. The caller may then use that returned handle for both ownership claims. It must not keep using the old unredirected word. |
| `sink(ctx, term)` | Consumes one owned value using `term_sink`; static/immediate values are trivial. |
| `build(ctx, cid, fields, count) -> term` | Validates descriptor arity, consumes the field values, allocates through `heap_alloc`, and uses conservative `rfc_seal` on children. A zero-field node is `term_pak(cid, 0)`. |
| `take(ctx, term, fields, capacity)` | Consumes the constructor and transfers all live fields. Uses `ctr_take` and then `spare_free` on the consumed shell. For permitted packed one-field nodes the payload is `term_loc(term)`. |
| `peek_tag/peek_id` | Borrows the value and does not change ownership. |
| `peek_field(ctx, term, index)` | Borrows a child only while the owned parent remains alive. This is a test observer, not an owned-field extraction operation. |

The output buffer belongs to the caller and is valid only for that call's
transfer. No helper retains its pointer. `take` must not expose `ctr_take`'s
returned shell location as a new owner: it is either a reusable shell, an
immortal static location, or zero in the shared case. All runtime calls that
may allocate, retain, take, or release are optimizer barriers initially.

The important source contracts are `runtime.c:term_keep`, `ctr_take`,
`span_fade`, `term_drop`, and `spare_free`; generated matching in
`bridge.bend:nc_destructure` already composes the last two. A shared parent can
only transfer children safely when its nontrivial children have been sealed.
Disabling constructor sealing without reusing a checked sharing certificate
would break that invariant.

Closures and tasks are affine: `rfc_wrap` rejects their tags. Closure creation
transfers capture ownership into a heap shell without sealing. Applying one
copies captures, releases only the shell, appends the argument, then enters its
function. A generic constructor helper must not replace these distinct rules.

## Ordinary segment transitions

Use a C ABI entry equivalent to
`uint32_t segment(Context *ctx, Frame *frame)`. A returned ordinary FID selects
the next segment. A reserved `UINT32_MAX` means leave the trampoline and return
the 64-bit scheduler `Reply` stored in the frame. This discriminator is required:
existing `return 0` and `return term_tsk(...)` are scheduler exits, while
`WL_JMP`, `WL_DYN` and `WL_AGAIN` continue the current computation.

The persistent frame must carry the explicit Bend stack pointer, `seq`, `rn`,
the register bank and yielded `Reply`. The opaque context reconstructs `Env`
with the same allocator lane. Generated segments may use fixed documented
frame offsets; do not pass the C `Env` struct by value through QBE. The C
trampoline performs an ordinary call and then loops, bounding native stack
growth across self and mutual tail calls. No optimizer tail-call promise is
required. Independent validation must cover explicit Bend stack growth too.

Preserve these exact transitions:

1. `FID_ENTER` installs a task's continuation/index/exit frame, places captured
   continuation arguments on the explicit stack and its results in registers,
   frees the task shell, and enters the selected segment.
2. `WL_RETN(n)` writes `rn`, pops one continuation FID and dispatches. Ordinary
   register input and continuation stack input remain distinct.
3. `FID_EXIT` saves incoming `rn` and result registers before its local bank is
   refreshed. A ready sequential continuation is resumed directly; otherwise
   `task_deliver` owns the returned result words and produces a scheduler Reply.
4. Closure apply loads captures before freeing their shell; argument position
   is `fid_arity(fid) - 1`. Zero-capture closures have location zero and are
   trivial. `rp` is C ABI padding and carries no semantic register value.
5. A segment that creates outstanding parallel work yields a task Reply rather
   than continuing the dispatch loop. First compiler admission may reject bang
   and fork metadata, but must not silently reinterpret such a Reply.

The current host macros deliberately shadow register variables at `WL_OPEN`.
Their incoming parameters are read before that point; outgoing values are
assigned afterwards. A state-memory ABI has to model this boundary explicitly
instead of accidentally reading stale values. Unused register slots are not
roots and must not be automatically dropped.

## Descriptor and static image

A versioned descriptor should carry byte size/version, maximum parameter and
result widths, segment table/count, constructor arities/hot flags/count,
function arities/flags/result widths, entry ID, runtime builtin IDs, semantic
constructor/effect IDs, static image and show metadata. Runtime initialization
validates counts, enum bindings, non-null required callbacks and supported
capabilities before entering generated code. IDs stored in Terms have 16 bits;
the current arity/result tables store bytes. Reject overflow explicitly.

`STAT_OFF` depends on `WL_RESW` through `H_BANK`; the existing static image
contains tagged words with `STAT_OFF + offset`, not linker pointers. A cached
runtime object must choose a stable ABI result-bank capacity or apply explicit
static-location relocations. Merely turning `WL_RESW` into a descriptor load
leaves existing static words wrong. Fixing the capacity makes `STAT_OFF` stable;
`HEAP_OFF` can remain derived from descriptor image length, and generated static
words must use the same ABI-defined offset. A first fixed-table adapter can
keep the existing exact capacities and avoid this full-program split.

Use cache keys bound to runtime source/object hash, ABI/header hash, target
architecture, scalar layout policy, effect-object hashes and descriptor data.
No cache lookup should treat arbitrary generated C or an unverified runtime
template as equivalent to the canonical runtime.

## Smallest real reverse adapter

Retain `runtime.c` verbatim except the same four authenticated template
insertions used by the current backend and rename its `main` at inclusion.
Provide a fixed test constructor table, runtime builtins only, fixed empty or
small immutable static image, and an exported ownership adapter. Compile this
test runtime object once with the existing Clang acquisition toolchain. The
actual unchanged checked `nt_reverse<String>` body must be lowered by Bend and
compiled by QBE; a handwritten reverse in the adapter would not qualify.

The adapter initializes the production corpus and allocator; it does not run
the event loop. One context lives until all test-owned roots have been dropped,
then unmaps the corpus. Tests should cover empty/singleton/deep lists, empty and
Unicode String heads, shared roots, shared tails, repeated String heads,
immutable static roots, nonempty accumulator, and drop paths. `keep` tests must
replace the original handle with its returned redirect before duplicating it.
Observe inputs through borrowed fields and use the same owned transfers on the
C and QBE paths. The first adapter need not expose closure/scheduler entry.

Follow with unchanged Base `String.reverse.go`; then qualify the ordinary
segment trampoline on mutual recursion, closure calls, nested continuations,
array ownership and the six compiler host effects. Only then attempt complete
compiler emission and a real B1/B2 self-reproduction gate. The fixed-table
reverse adapter establishes a heap bridge, not a full compiler.

No production runtime was edited. The canonical Bend table emitter received
additive metadata only; the experimental runtime lives under Phase108. No target
build or execution was performed by this source-audit task.
