# Phase112: two broad workloads expose missing complete regions

The main common difference is **where ordinary computation remains**. Frozen
upstream C represents these first-order workloads as typed local loops, ordinary
helper calls and flat results. The direct word compiler still routes their hot
loops through generic ownership, boxed carriers and runtime continuations.
Neither example requires higher-order specialization to expose this gap.

This is a source/QBE audit of `local-pair` and `scalar-region-8192`, prompted by
large ratios in an unfinished broad measurement. It establishes no new runtime
ratio or aggregate. No targets were executed. The sources and upstream C were
checked against the frozen [45-point manifest](../../selfhost/tools/performance/phase112/benchmark45/manifest01.json).

## Local pair: temporary products survive the entire call chain

Despite its short name, `local-pair` executes one complete 256×256 edit-distance
grid. The [source](../../selfhost/build/phase93/fixtures01/local-pair.bend:76)
passes four array handles in `Dp` and obtains `(array, word)` pairs from four
`Array.get` calls per cell.

Upstream already removes those carrier objects across function boundaries:

- [`spin_8`, the cell worker](../../selfhost/build/phase93/pilot02/local-pair/upstream.1.c:1452), receives four separate array handles and returns four words through its output buffer. Array access uses `blk_loc`, `blk_at` and `blk_read` directly.
- [`spin_2`, the final cell stage](../../selfhost/build/phase93/pilot02/local-pair/upstream.1.c:1294), computes the minimum, updates the array, and returns the four handles individually. It constructs neither the returned `Dp` nor an array-read tuple.
- [`spin_10`, the row worker](../../selfhost/build/phase93/pilot02/local-pair/upstream.1.c:1490), carries these handles and scalar indices around a local `WL_AGAIN` loop. The helper calls are ordinary inline C calls, making the complete region available to the machine optimizer.

Our [cell QBE](../../selfhost/build/phase111/p112-word-broad01-local-pair/program.ssa:6790)
instead consumes a boxed `Dp`, invokes runtime primitive72 for an array read,
and jumps through `cell.f1 → cell.f2 → cell.f3 → cell.f4`. The
[primitive](../../selfhost/tools/performance/phase111/runtime/primitives.inc.c:322)
returns `p111_tuple(array, value)`; that helper allocates and seals two children.
The final [continuation](../../selfhost/build/phase111/p112-word-broad01-local-pair/program.ssa:5912)
calls array-set primitive73 and reconstructs `Dp` with `p111_rt_ctor`.

The source path therefore creates **four array-read tuple objects plus one Dp
object per cell**: 327,680 carrier constructions over the 65,536-cell grid,
before any extra reference-count wrappers. This is a call-path identity, not a
new measured allocation counter. Upstream's flat interfaces omit these objects.
The row additionally saves a continuation for each cell, and the arithmetic
stages contain further returning frames. Current word QBE has private `umin`
and `umin.go`, but no private `cell`, `cell.f1`–`cell.f4`, `row` or `dp`.

The major opportunity is a checked, ownership-aware **multiple-result product
ABI across ordinary regions**, together with direct array-result lowering.
Canceling one adjacent constructor/take pair cannot remove products that cross
these call boundaries. General call fusion can reduce transport first, but it
does not by itself prove the tuples and state record can disappear.

## Scalar region: even a scalar loop is not a complete native loop yet

The [source `mit`](../../selfhost/build/phase93/fixtures01/scalar-region-8192.bend:26)
is a first-order tail-recursive Mandelbrot iteration with one Nat counter and
six U32 values. Upstream's
[`spin_12`](../../selfhost/build/phase93/broad01/scalar-region-8192/upstream.1.c:1443)
keeps these in typed locals, invokes scalar helpers directly, and loops with
`WL_AGAIN`. It has no per-iteration heap constructor or scheduler frame in this
worker. This is visible in generated C before making any claim about Clang's
machine optimizations.

Our [mit QBE](../../selfhost/build/phase111/p112-word-broad01-scalar-region-8192/program.ssa:5955)
is still a public segment. At line6017 it saves seven captured values, performs
`p111_rt_keep(zr)`, computes `zr*zr`, then jumps to `asr8`. The subsequent
arithmetic proceeds through continuations. Scalar retain operations and register
transport remain even though the source type identifies these values as U32.

The [asr8 worker](../../selfhost/build/phase111/p112-word-broad01-scalar-region-8192/program.ssa:5707)
is itself blocked by a structured pure `If` for checked shifting between its
saved frame and already-private `sel`. Extending gap recognition to pure branches
can help this dependency. It cannot cross `mit`'s post-frame `keep` without a
separate proof that the value is an immediate scalar. There is no higher-order
call or data-product allocation needed by the main mathematical loop.

## Consequence for the next experiment

The [ray/string gap fixes](hot-call-boundaries.md) are useful general admission
repairs, but the broad results expose two larger missing capabilities: preserve
scalar ownership facts until direct calls are formed, and flatten nonescaping
products across those calls. A small decisive test should show one complete
ordinary loop with zero generic per-iteration continuation traffic; the product
variant should additionally show zero tuple/Dp carrier allocations. Retain the
existing unknown/escaping-owner fallback and independent output/lifetime gates.

These source differences justify investigating those capabilities. They do not
establish how much of the observed time gap each explains. Frozen counter profiles
and matched uninstrumented timings must quantify the actual effect.

## Artifact pins

| Artifact, relative to repository | Bytes | SHA256 |
|---|---:|---|
| `selfhost/build/phase111/p112-word-broad01-local-pair/program.ssa` | 437,732 | `500744b0786040147d476923a65d9e7ff8de4d242e1bf60da8eb3bf2064717fc` |
| `selfhost/build/phase93/pilot02/local-pair/upstream.1.c` | 136,409 | `0205c68209f228364c3cfa22bd87297918a9a13c557fb0ca8a3d98124c8a2513` |
| `selfhost/build/phase111/p112-word-broad01-scalar-region-8192/program.ssa` | 352,940 | `15ef0ddf65554ea7395af476a1ae827e1982ddf3fc6d967507bdafd4ac30528c` |
| `selfhost/build/phase93/broad01/scalar-region-8192/upstream.1.c` | 128,493 | `3c4a755182d442714aa96a77f617c354741c6f3f62cd27b1c05efec6fcbba031` |
| `selfhost/tools/performance/phase112/benchmark45/manifest01.json` | 229,972 | `80b07bdc76528bf58ae322ffed470eaa8ccdc8fa3d5cea73aa6d652d66cc6adc` |
