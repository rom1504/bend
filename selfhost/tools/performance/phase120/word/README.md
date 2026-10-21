# Phase120 signed-word identity pilot

Isolated experiment on the immutable Phase118 safe03 source. No production
selection change. `model.bend` is frozen once handed to root; repairs require a
new version file. Root owns checked API acquisition, emissions and executions.

## Hypothesis and integration

Recover a general identity already visible in the structured IR:

`(low32(x) >> k) | (signbit(x) ? (0xffffffff << (32-k)) : 0)`

for literal `1 <= k < 31`. The existing `P113DStmt`/`N111Stmt` representation
can express the replacement; no backend, runtime helper or source-name rule is
added. Shift31 and variable/out-of-range counts remain unchanged in this pilot.

The sole override is `p114s_ranges`. It first performs the unchanged original
range transformation and independent commit. Then it transforms functions below
1024 existing structured statements and commits their bodies using the same
verified original image/IDs. A failed candidate verification falls back to the
already verified range result. This size limit bounds transformation scope; the
existing recursive size routine is not a guarantee about host stack use.

The output uses existing instructions:

```
out = (source << 32)
out = arithmetic_shift_right_64(out, 32 + k)
out = out & 0xffffffff
```

This is exactly a signed32 shift followed by U32 zero-extension. It deliberately
does not assume that reading a QBE `w` temporary as `l` initializes upper bits.
The current backend already supports `sar`. Inspect the machine result: if it
does not reduce useful hot work, reject this implementation regardless of IR
size. Root may later isolate a narrow word-width projection if needed.

## Facts and correctness boundary

Each local has a low32 value identity, width bound and one small symbolic shape:
opaque, constant, logical shift, canonical sign predicate, or sign-selected mask.
Copies preserve identities. Every newly computed nontrivial value gets a fresh
identity; separate masks of the same original value preserve low32 identity but
establish a separate upper-bit bound. Constants have no eligible source identity.
No fact comes from `N_W32` ownership classification alone.

Forward environments have one current binding per name. At a rewrite the pass
searches for an initialized, still-live low32 representative of the original
value identity. If the source has been overwritten and no such copy remains,
the rule refuses. Consequently there are no added snapshot locals or reserved
name namespace obligations. The destination may equal that representative:
the first shift reads it before assignment.

Both branch environments are analyzed with disjoint fresh-identity ranges and
joined conservatively. Identical facts survive; differing constant arms yield
a sign-related fact only when the original condition already proves the exact
canonical sign predicate. Unknown joins lose information. Boolean equality with
0/1 and XOR1 track polarity; arbitrary conditions are not treated as sign facts.
All calls, stores, pointer operations and terminal/backedge transitions discard
the current environment. Loads establish only fresh value identities and their
machine width. Nothing is propagated across a loop backedge.

The pass changes only the final matching integer OR. Original branch structure,
assignments, calls and effects remain in order. QBE may subsequently remove
unused pure calculations. Scalar `N111If` bodies are analyzed but retained
verbatim; direct `P113DIf` bodies carry their transformed contents. This avoids
the previous broad dead-scalar cleanup that regressed the hot loop. Analysis hit
counts inside an unchanged scalar If are conservative diagnostics and must not
be mistaken for emitted rewrites; ordinary machine inspection is decisive.

## Checks and decision

`controls.bend` exports `p120w_controls(Unit)`. Fourteen pure analysis records
contain literal expected hit counts and the resulting structured bodies. They
cover shifts1/8/16, commuted OR, wrong masks, differing/overwritten origins,
preserved aliases, partial joins, inverse polarity, call/memory invalidation and
unchanged31/32 cases. These synthetic analysis bodies are never native runtime
failure probes.

`boundaries.bend` is ordinary checked Bend with argv-derived values and twelve
literal expected output lines. It covers zero, small/neighboring values, both
sides of the signed boundary and all-ones values at shifts1/8/16/31. A separate
complemented-division expression independently checks shift8. Its expected
numbers use signed-integer arithmetic, not the optimizer or generated code.

First acquire the checked candidate API and compare every control's actual and
expected count. Then verify ordinary boundary outputs and actual activation in
the existing scalar/Mandelbrot products. Compare exact hot machine instructions
and clean complete-workload timings against the unchanged parent. Require
transfer beyond related Mandelbrot variants before claiming general coverage.
Measure extra request cost; list-based fact tables can be quadratic, so a
profitable pilot is not yet a reason to apply it to all large compiler functions.

No check, speedup or selection has been claimed by this source-only work.

`controls.mjs CHECKED_API_REPORT FRESH_OUTPUT_DIRECTORY` authenticates the
checked API and all declared inputs, reflects the fourteen literal expectations,
and independently evaluates the five admitted finite bodies at twelve boundary
values, including full64 values with the same low32 bits. Its BigInt interpreter
is a test oracle for existing integer instructions, not a host optimizer or
compiler. It never executes the synthetic unknown-call/memory controls natively.
`manifest01.json` and `boundaries.expected.json` use the existing ordinary
complete-output observation format.

Initial source-check failures remain separate evidence: `model.bend` matched an
earlier statement binder after a later scan binder; `model02.bend` repaired that
ordering. `model03.bend` additionally marks the seed counter as duplicated. No
original module was overwritten, and these are source-language check failures,
not successful transformations or semantic benchmark results.
