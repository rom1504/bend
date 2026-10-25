# Existing template specialization as a traversal-sharing mechanism

Status: source investigation and isolated candidate preparation only. No target
was checked, compiled or timed by this investigation. The coordinator owns those
gates. No selected compiler source was modified.

**The mechanism exists already.** A closed `~same` function argument can be
substituted into one maintained list traversal before native lowering. Runtime
state must be a separate ordinary argument. This is a credible way to avoid
choosing between handwritten traversal clones and a runtime callback. It is not
evidence that all compiler visitors can be unified economically.

## Existing language and implementation evidence

Upstream `bend2/base.bend` already uses this form:

- `List.map`, line 888: `~A`, `~B`, `~f`.
- `List.filter`, 1033, and `List.contains`, 1086: a static `Data` element type
  and predicate/comparator, with ordinary list/value arguments.
- `List.foldl`/`foldr`, 1040/1049: static function and types, ordinary accumulator.
- `Array.map`, 2517: static types and function.

The selected Phase137 source SHA256 is
`2620d59a3a20fa5d5d27bbf3b12ceb7304439b27093fff1c0f383da03e4ecf38`.
Its implementation supports the same frontend operation:

1. `infer_template` (9227) invokes `sp_live_checked` for demanded live calls.
2. `template_arg_head` (9237) checks each template argument in an **empty runtime
   context**. An arbitrary runtime closure is not accepted as a static callback.
3. `sp_live_key` (10127) and `sp_live_memo` (10137) key and reuse instances by
   template name plus closed argument terms.
4. `sp_live_fresh` (10149) fills the instantiated type and calls
   `sp_apply_template` (10079), which applies the template body to its static
   arguments. Callback substitution therefore precedes backend lowering.
5. `sp_live_body` (10156) constructs a definition with zero remaining template
   binders and reduced ordinary arity, then checks the instance body.
   `sp_live_done` (10163) publishes its checked output.

The source suggests that a named callback becomes a known function reference in
the instantiated loop. It does **not** establish which native optimization will
admit that loop. Generated QBE must confirm the ordinary runtime arguments and
actual callback transfer.

Existing tests make the admission boundaries concrete:
`tests/comptime/fold.bend` passes a closed curried lambda and a named function;
`err_capture.bend` rejects a runtime variable captured by a template argument;
`tests/spec/comp_generic_dedupe.bend` rejects a template binder after ordinary
binders; `tests/comptime/unsafe.bend` covers unsafe template instances.
`err_grow.bend` reaches the 64-level specialization limit when the static
argument grows. The current implementation also rejects a key over 32,768
bytes and nondecreasing cross-instance recursion. These restrictions must not
be weakened to make a generic traversal compile.

## Why this differs from Phase7 A03

[A03](../../implementation/phase7/architecture-evidence/binding-schema/report.md)
implemented a runtime mode/shape interpreter and one enlarged worklist frame.
It replaced six frame variants with a record admitting more invalid states.
The candidate grew by 22 physical lines; freshening slowed 18.6–22.6% and
template shifting slowed 81.2–81.7% on the retained microbenchmark.

A03 did **not** test this static callback scheme. Its report explicitly leaves
generated specialization open. However, specializing an operation does not
automatically eliminate A03's scope classification, enlarged frame, reconstruction
or allocation costs. A `~mode` might remove one dispatch; the remaining costs
need their own evidence. This proposal does not overturn that rejection.

The stronger immediate evidence is
[Phase140's actual comparison QBE](../phase140/typed-comparison-machine.md).
`p134v_list` retains a comparator closure, starts two continuation frames and
uses `p111_rt_apply`; the handwritten typed helpers remove that callback
application and use a known two-argument transfer. Some typed helpers qualify
for local continuation workers, while the recursive scalar/statement helpers
still use the scheduler. The static-template candidate should match the typed
boundary without maintaining ten separate list loops.

## Complete small candidate

Files are under
`selfhost/tools/performance/phase141/static-traversal/`:

- `core-v01.bend`: one pair-list traversal with `~A: Data` and
  `~same: A -> A -> Bool`; a second optional control keeps state explicit.
- `wrappers-v01.bend`: the ten Phase140 typed-list interfaces routed through
  that template, under new names so both old implementations remain oracles.
- `fixtures-v01.bend`: exact finite fixture declarations extracted from
  Phase140's qualified controls, with span hashes in `manifest-v01.json`.
- `controls-v01.bend`: 15 source-defined rows comparing 50 list-pair cases and
  five state cases. Compare empty, equal, reversed and unequal-length inputs
  over actual scalar/statement/argument/value/binding/header types.

The generic `p134v_list` and independently handwritten `p140e_*` traversals are
both comparison references. This is finite differential evidence when run, not
a proof. The candidate preserves the original `same(x,y) && recurse(...)`
expression; it does not introduce lazy short-circuit semantics or a new
stack-safety strategy.

The ten original typed list bodies occupy 60 nonblank declaration lines,
including their `@unsafe` markers. One shared body plus ten three-line wrappers
occupies 36: a **40% source reduction in this small family**, if it qualifies.
The optional state control adds another six implementation lines and is not
needed for those ten replacements. Directly rewriting callers could also
retire the wrappers, but call-site size and compatibility changes must then be
counted. These are source counts, not a validated compiler simplification.

More importantly, changing the existing `p134v_list` to a static comparator and
updating its closed call sites could make the duplicated Phase140 `p140e_*`
field-comparison family unnecessary. That is a possible larger replacement,
not implemented here. The selected Phase137 source predates that experimental
typed family: avoiding its future duplication is not deletion credit against
Phase137's current line count.

## Native falsifier prepared for the coordinator

`native-v01.bend` is a standalone 174-line proxy, not the compiler. It contains
exact `N111Type`/`N111Value`/`N111Arg` declarations and exact comparison helper
bodies, followed by a small workload. Its source and individual span identities
are in `native-source-v01.json`. `cases-native-v01.json` and
`expected-native-v01.json` fit the existing integrated emitter's ordinary gate.

One binary selects three implementations using a runtime argument: runtime
callback, handwritten typed loop, or static template. Lists are built from
runtime size in different orders, then retained for repeated comparisons.
Equal values, a final-element mismatch, unequal lengths, empty lists and aliases
have an independent weighted Boolean digest of 25. Python tuple/list equality
derives the oracle without using any Bend comparator.

The cheapest decisive sequence is:

1. Check the module and finite controls through the existing checked API.
2. Check and emit the small standalone proxy; require the six-line ordinary
   oracle on QBE and the independent upstream compiler.
3. Inspect the actual instantiated list helper: callback/type parameters should
   be absent from the runtime signature, and callback application machinery
   should disappear. Inspect the real worker as well as its adapter.
4. Compare the three runtime modes in serial paired order, keeping the same
   binary, flags, runtime, size and repetitions. Match the handwritten loop,
   rather than claiming success solely by beating the slower generic callback.
5. Only then replace one real compiler call family and measure complete
   preparation/request cost, emitted size and retained specialization count.

No full compiler self-build is required for steps 1–4. Reject the idea promptly
if existing specialization cannot admit the concrete recursive instance or if
QBE still retains runtime callback application. Preserve that negative result
rather than adding a new optimizer just to rescue the abstraction.

## Costs and remaining limits

- A distinct type/comparator pair creates a distinct checked instance. This
  trades maintained source duplication for generated specialization, not for
  smaller machine code. Count instance creation and compiler time explicitly.
- Runtime environments, offsets and evolving traversal state must remain
  ordinary parameters. Specializing on them would multiply instances or fail
  closed-argument checks. Thread existing state; do not invent a newly boxed
  context record at every node merely to fit a generic interface.
- Existing template APIs require leading static parameters. Preserve wrappers
  where callers need a non-template runtime function value or export ABI.
- Semantic scope differences remain. A substitution visitor, freshener and
  matcher cannot share one traversal solely because all recurse over `KTerm`.
  Parallel Let RHS scope, binder freshness, reconstruction and beta-reduction
  remain explicit obligations.
- Static dispatch alone does not remove reference counting, tree traversal or
  continuation traffic. Performance and code-size expectations must come from
  the actual specialized code, not the source-level word “static”.

The architectural opportunity is selective: express invariant operations as
closed language-level parameters and keep varying data explicit. The existing
frontend may already supply the specialization previously assumed to require a
new compiler pass. Whether that supports a substantially smaller compiler is
still a hypothesis, to be tested one complete family at a time.
