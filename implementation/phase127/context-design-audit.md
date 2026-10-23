# Generic native profiling context: bounded design audit

Date: 2026-10-23. Read-only investigation against Phase126 source32 and its
retained native artifacts. No target program was executed, no production file
was changed, and no performance or profiling-accuracy improvement is claimed by
this document. Root owns implementation and experimental validation.

## Recommendation

Start with **physical samples plus the active dispatcher segment**, retain both
dimensions in every report, and map anonymous segments to their lexical lowered
definition. Add counters for actual runtime operations under that segment.

This is a generic Bend mechanism: no compiler phase names are needed in the
collector. N1 is one workload. It can be implemented by rebuilding only the
diagnostic runtime and relinking the exact existing program object, without
regenerating the 99.5 MB compiler QBE or bootstrapping another compiler.

Do not call this an inclusive logical call stack. True selected-scope ancestry
across native private calls, trampoline continuations and task boundaries is a
larger step. A correct, explicit partial attribution is more useful immediately
than an attractive but misleading inferred call tree.

## Existing evidence and the important correction

`selfhost/tools/performance/phase88/ownership/README.md` explicitly describes
**physical caller recovery**, not a logical Bend stack. Its sampler uses
precomputed, exact-image `.eh_frame` rows for `term_drop`, `span_fade` and
`rfc_wrap`, with up to three bounded native return addresses. Tail transfers erase
many logical frames. Its phase marks are interceptions of actual `IO.now`
runtime calls, checked against the entry's emitted timings.

Phase116 samples an unchanged native compiler but primarily reports physical
instruction-address leaves. Neither mechanism currently establishes which
logical compiler pass caused all reclamation observed in a runtime helper.

The existing Phase88 restrictions remain appropriate: no heuristic stack
scanning, no allocator or general unwinder from the signal handler, exact image
binding, supported-CFI coverage reported, and losses/overruns retained.

## Exact inexpensive attachment point

The qualified runtime is
`selfhost/build/phase126/runtime-divmod01/runtime.c`, SHA256
`2125198f0a44bac52de957754190d759161a289c5d6f8c802248ae24b41bfc52`.

At approximately line 1393 its ordinary-ABI dispatcher has:

```c
WlState state = {0};
/* ... */
for (;;) {
  Fid next = state.next;
  state.next = P111_STOP;
  /* select run from program segment table or four runtime segments */
  Reply reply = run(&state);
  if (state.next == P111_STOP) return reply;
}
```

Immediately before `run(&state)`, the runtime knows the exact active program
segment. A diagnostic runtime can publish this ID to per-thread profiling state
and increment a dispatch counter. It should restore previous context on exit
from `work_loop`, including nested invocations; clear/reset context at task
boundaries. The sampler records this ID alongside the sampled PC.

Use a separate profiling state, not an ABI change to `P111State`. Its layout is
asserted at 2,088 bytes and generated QBE directly accesses offsets, including the
register bank at offset 40. Existing program descriptors are similarly fixed at
192 bytes. A profiling context sidecar avoids invalidating either ABI.

The existing object is
`selfhost/build/phase111/p126-native32-n1/program.o` (21,504,144 bytes). The
Phase126 runtime receipt records only 1.82 seconds for its previous runtime
compilation. That is evidence that runtime-only acquisition is cheap, not an
estimate of profiler overhead. `phase111/relink.py` demonstrates authenticated
object reuse, although its historical receipt-kind check needs explicit handling
for Phase123 aligned build receipts. Do not silently bypass identity checks.

For signal-safe access, use a previously resolved, leaf TLS accessor or a bound
per-thread context pointer. Do not call `dlsym`, allocate memory, or initialize TLS
from the handler. A dynamically exported getter must have a documented ABI and
the executable must explicitly export it. Keep all-thread registration separate
from claims of semantic attribution: initial qualification can be sequential.

## Why named-function sampling alone is insufficient

Source32 includes named compiler functions whose public/private named entries
are only **curried closure factories**. For example, the generated named entry
for `p126bp_close` calls `p111_rt_closure(..., 42686, ..., 0)` then returns that
closure. Two anonymous `$p111.k.*` functions capture later arguments, and a
subsequent anonymous segment jumps to the actual `$direct.p126bp_close` body.

The named private worker `p112s_prepare` is likewise a zero-argument closure
factory. Counting entry time or recognizing only named symbols would miss the
actual computation and could incorrectly conclude the analyses are cheap.

The exact source still provides a useful structural invariant:

- `p111_compile_step` prepends the named factory to that definition's complete
  generated-segment list.
- `p111_compile_defs` preserves definition order after reversing its accumulator.
- Each definition's anonymous closure and continuation segments are contiguous
  in this semantic list; explicit `$direct.name` entries identify the same owner.
- Public segment emission preserves the semantic segment order. The final QBE
  contains an explicit `$p111_segments` FID-to-symbol table.

These facts permit a **qualified lowered-definition owner map** for the current
emitter: decode FID symbol bytes, start a definition group at a named factory,
associate its generated continuation/factory/direct entries until the next
named factory, and reject unsupported or ambiguous forms. Bind the map to the
exact source, emitted QBE, object and executable. Validate actual table order and
direct-name agreement rather than trusting arbitrary ELF address adjacency.

This is not original source-line provenance or proof of logical ancestry.
Inlining may place another definition's computation inside the current lowered
definition. Optimized product/observer workers can encode multiple origins.
Where the owner cannot be established, retain the generated identity and mark
origin unknown instead of assigning a plausible human name.

The robust future representation is an emitter-produced sidecar:

```text
program identity
segment id -> generated symbol, lowered definition, role
private symbol -> lowered definition or explicit composite origin
optional source span and inlining chain
```

That sidecar would avoid reconstructing provenance from names. It is not
necessary to acquire useful profiles of the already-qualified N1 now.

## What the first diagnostic context can and cannot mean

Keep the report dimensions distinct:

| Dimension | Honest interpretation |
| --- | --- |
| Physical PC / native caller | Actual executing machine location and supported physical return sites |
| Active dispatch FID | Segment through which this current native execution entered the dispatcher |
| Lowered-definition owner | Lexical owner of that segment under the qualified emission invariant |
| Runtime-operation counter | Number of calls or events observed at the instrumented runtime boundary |
| Selected logical scope | Not available merely from these dimensions |

A private worker called synchronously inside a segment does not reenter the
dispatcher. Its samples retain the outer dispatch FID while the physical PC
identifies the worker. This is expected, useful information, not permission to
charge all nested work to the worker's source function or to call the outer
segment an inclusive source frame.

Allocation/reclamation counters are similarly **execution-site attribution**.
The scope doing destruction may not be the scope that allocated the object.
Reference-count sharing, retained values and final teardown can separate these
events in time. An allocation-origin profiler requires additional object-lifetime
metadata and should remain a distinct feature.

Inlined keep/sink operations bypass public helpers, so helper counts do not
represent every language-level ownership operation. Compiler transformations
can eliminate an operation entirely. Report the specific instrumented runtime
entry set and coverage, rather than naming the total “all allocations” unless
the actual low-level allocator boundary is instrumented too.

## Small runtime counters worth adding

First count events that correspond to a falsifiable optimization question:

- Dispatcher entries and target transitions.
- Continuation frame pushes and captured words.
- Runtime constructor/take calls, optionally separated by shape/arity.
- Closure creation and capture words.
- Actual heap allocation requests by size class, reuse/fresh distinction if the
  runtime exposes it cheaply.
- Sink/drop entry calls separately from nodes actually visited or reclaimed.
- Copied words at runtime register-transfer boundaries.

Use bounded per-thread arrays keyed by active FID or a compact owner ID. For
example, 44,000 IDs times eight 64-bit counters is about 2.7 MiB per thread;
allocation should be explicit and capped, especially before enabling 32 threads.
Do not create unbounded maps or heap allocations on each event. Counter-only,
sampling-only and combined runs should be distinguishable. Do not interpret a
counter reduction as a runtime saving without clean timings.

Avoid `clock_gettime` per segment: millions of transitions would turn timing
into the workload. Sample the active context. Record clean uninstrumented
performance separately and measure instrumentation overhead on both N1 and an
unrelated ordinary Bend program.

## Why true logical scopes need more than one TLS variable

`p111_rt_frame` (around runtime line 3932) writes captures followed by the next
FID and advances `state->sp`. `p111_rt_return` pops that FID and schedules it.
A logical scope entered in one segment can therefore outlive that segment's
native return. Clearing a scope whenever a segment returns is incorrect.

Conversely, leaving one global scope active until the next named function is
also incorrect: it leaks attribution across resumed parents, closures and tasks.

A later opt-in selected-scope design can keep a shadow entry for a real Bend
continuation frame, keyed to its exact stack boundary, saving/restoring scope
tokens when that continuation is pushed/resumed. It must handle:

1. Frame captures and `p111_rt_stack_pop` consistently, without treating captured
   values as frame headers.
2. Tail transitions: replacing the active function is different from returning
   to an enclosing selected scope.
3. Private synchronous calls and explicit local continuation regions that bypass
   public frame hooks.
4. Closure invocation context versus closure allocation origin.
5. Task entry/exit, scheduler transfer and eventually parallel propagation.
6. Unsupported transitions: explicit unknown attribution, not stale scope IDs.

The three-hour campaign should not depend on implementing all of this. First
test whether active-segment/physical-owner cross-tabs explain the compiler
regression. Add selected-scope instrumentation only where that result identifies
a concrete remaining attribution hole.

QBE text instrumentation of ordinary private-function entry and return is a
possible bounded diagnostic, but it changes register allocation, code size and
layout and does not automatically handle trampoline scopes. It requires a new
machine build and exact output comparisons. A full compiler-source rebuild to
introduce scopes is the most expensive first option and is unnecessary for
current-segment attribution.

## Acceptance and falsification

The initial mechanism should pass controls on a generic ordinary Bend program
with a called helper, non-tail continuation, tail recursion and nested closure.
Use known literal output or an independent executable as the semantic oracle.
Verify no profiling data leaks into ordinary stdout.

For current-segment attribution, compare a few selected sample PCs with the
actual program dispatch table and known helper call sites. For any claimed
logical-scope extension, test a child returning to a parent, an escaped closure,
and a private worker; reject the feature if any keeps a stale scope.

The N1 practical acceptance test is finer attribution of its preparation,
lowering and cleanup cost than the existing physical-leaf table, with explicit
unknown/low-coverage buckets. A successful profile should explain where to make
one small compiler experiment; profiler feature count is not the objective.

Expected engineering scope, not measured performance claims: current-FID
runtime attachment and reporting is a bounded sub-hour implementation when
reusing the collector and object; correct inclusive scope recovery is plausibly
multi-hour and should be deferred unless the first profiles need it. Existing
CFI physical caller recovery can be delivered independently of runtime changes.

## Exact files inspected

- `implementation/phase126/candidate.json` and the pinned source32 source/QBE/runtime.
- `selfhost/tools/performance/phase88/ownership/{README.md,sample-ownership.c,make-table.py}`.
- `selfhost/tools/performance/phase108/profile.py`.
- `selfhost/tools/performance/phase116/compiler-profile.py`.
- `selfhost/tools/performance/phase111/segment/{lower-book.bend,lower-control.bend,lower-helpers.bend}`.
- `selfhost/tools/performance/phase111/relink.py`.
- `selfhost/tools/performance/phase123/build-aligned.py`.

This audit records implementable designs and verified static facts only. Root's
later implementation and experiment receipts determine which capabilities
actually exist and what they measured.
