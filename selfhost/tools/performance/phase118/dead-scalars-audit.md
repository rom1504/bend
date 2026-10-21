# Bounded scalar dead-definition prototype

Source-only implementation; no API check, compiler execution, target execution,
or performance measurement was performed by this author. The root owns those
gates. `dead-scalars.bend` and `dead-scalars-controls.bend` are frozen drafts;
repairs after manifest creation must use new versioned filenames.

## Why this experiment

The exact diagnostic object
`selfhost/build/phase118/inspect-mandel01/functions.json` confirms the preceding
[Boolean-path audit](boolean-path-audit.md). `$direct.mit` contains two Bool-to-U32
diamonds whose arms have two versus ten statements. The first assignment in the
short arm is a dead intermediate result. The long arm additionally contains
dead constants and one integer OR that computes packed-constructor metadata.
The eventual output assignments are already literal0/1. No new Boolean theorem
or unsafe branch speculation is needed to remove those dead definitions.

Three sign-mask choices have the same structure but different constants. Their
cleanup does not make them eligible for the existing0/1-only matcher. Two
coordinate choices still need their live two-assignment copy chains; this
prototype deliberately leaves those chains intact.

QBE already removes dead assignments. The hypothesis is **exposing existing
structured selection recognition**, not that fewer QBE lines directly mean a
faster executable. Measure the isolated Mandelbrot and unrelated lexer products
before any broad or native integration.

## Exact scope and safety argument

`p118d_body` and `p118d_scalars` walk statement lists backward, using the existing
`nt_reverse` helper and forward-order output accumulation. String sets reuse
`nb_contains`; their small local add/kill/union helpers preserve unique entries.
No suitable existing machine-local use-set helper was found: the source-use
analysis tracks a different representation. These helpers only inspect IR values;
they do not analyze emitted code.

Only the following definitions can be deleted when their destination is dead:

* `N111Set` of U32/U64.
* `N111Bin` of U32/U64 with exactly `add`, `sub`, `mul`, `and`, `or`, `xor`,
  `eq`, `ne`, `ult`, `ule`, `ugt`, or `uge`.

These are total machine integer definitions. Source checked arithmetic may have
additional runtime checks; calls implementing those checks remain. All calls,
loads, stores, offsets, allocations, returns, direct calls, direct results and
tail edges remain. Shifts and signed comparisons are conservatively retained;
division/remainder and any unrecognized operator are retained. Floating work is
represented by calls in this IR and remains untouched.

For each retained assignment, liveness is
`(live_after − destination) ∪ inputs`. Deleted definitions add no input uses.
This handles mutable names and source/destination overlap. Both If forms receive
the same suffix live-out at entry to each arm; their live-ins are unioned and
then the condition is added. Terminal vectors discard suffix liveness and add
all actual input values. Direct-call destinations are killed **together before**
all argument uses are added. Thus argument/result overlap and parallel Again
transfer do not lose required definitions. The transformation does not rewrite
the actual vectors or their execution order.

Allocas are always retained because emitter hoisting and memory verification
depend on their declarations. Empty branches are retained too. Memory effects
and calls preserve source order. This is local dead-definition elimination,
not dead-store elimination, copy propagation, value numbering, or if-conversion.

## Admission and integration

The sole override is `p114s_ranges`. It first performs the existing range pass
and existing `p114s_commit`, then applies `p118d_boundary` and commits the cleaned
function list using **the same original image and verifier IDs**. A failed
candidate verification returns the already verified range-pass body. An invalid
original boundary remains unchanged. Structural verification is an additional
gate, not a substitute for the liveness argument above.

`p118d_function` reuses `p113i_size(body) < 4096`, exactly the existing range-pass
budget. No names or benchmark identifiers affect the decision. Diagnostic raw
helpers are not a trusted production entry: normal use runs through the valid
boundary and commit. No new runtime ABI or authority is added.

Cost is an extra body traversal, live-set operations and structural verification.
List sets can become quadratic in the number of simultaneously live names; the
4096-statement bound limits scope but does not establish low cost. Measure hosted
request cost before promoting this additional pass. If useful selection exposure
does not appear, do not retain it solely for smaller generated text.

## Finite controls and root invocation

Export `p118d_controls`, `p118d_policy_controls`, and, for exact before/after IR
inspection, `p118d_body` or `p118d_function`. The15 returned `P118DControl` records
have an actual body, an independently written expected body, a live-in set and
an expected live-in set. Compare bodies structurally and live-in names as sets.
The nine policy-control Booleans must all be true.

The cases cover dead chains, overwritten locals, self-updates, partial/all-arm
definitions, terminal-arm joins, mutable branch conditions, parallel tail and
call transfers, the scalar If form, retained ownership and float calls, retained
allocation/store/load, high64-bit payloads and exact Boolean-diamond exposure.
These are finite data transformations, not synthetic native fault probes. The
root should also retain the existing independent scalar-fact controls and
ordinary complete-output checks. No control has been claimed to pass yet.

Read the cleaned `$direct.mit` data through the existing inspection interface,
then confirm `p113bq` actually recognizes the two clean0/1 diamonds and inspect
the changed machine branches. Unchanged machine code or neutral timings are
legitimate negative findings. Do not infer a runtime gain from `.ssa` reduction.
