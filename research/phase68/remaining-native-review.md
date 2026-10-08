# Remaining native mechanisms after the first ordinary workers

Source/data review only. Products are owned by the separate P68-007 lane; this
note does not propose a competing product implementation. Observed C comes from
`native-flat06` and `native-flat06-rest`, produced by actual checked flat06.
Reference source is pinned upstream `0592662`, `bend2/comp.ts`.

## Do not remove checks by guessing from source types

The numeric worker already has a direct self loop. Its body contains generic
`term_keep` on F32 state and ordinary temporary joins, but no per-iteration Nat
arithmetic overflow check: the Nat countdown uses a nonzero test and subtraction.
The local join/error text mostly vanishes on CPU because `err_seen` is false on
host. Counting these C statements would exaggerate their machine-code cost.
Removing Nat guards indiscriminately therefore targets neither an established
hot cost nor a valid general semantic rule.

A narrow later scalar fact can recognize values *produced* by guaranteed immediate
operations (for example F32 rewrap and wrapping U32 arithmetic) and omit their
retain/drop checks. Keep arbitrary incoming words opaque. Some U32 template
zero-divisor branches return an argument without a fresh cast, so a blanket
"U32 intrinsic implies a normalized word" assertion is unsafe for raw inputs.
Estimate: 0–15% on scalar-heavy affected code, around 1–2 hours for a bounded
prototype/controls; no expected geometric-mean claim. Inspect optimized code
first to see whether Clang already removed those branches.

## A concrete runtime difference worth a small isolated test

Our `runtime.c::term_peek` uses `rfc_view`: two atomic 32-bit reads and, when the
count equals one, an acquire operation. Upstream's `term_peek` uses one relaxed
64-bit load on CPU; its comment states that redirect target-location bits never
change while only the low 24-bit count changes. Upstream `ctr_take` copies fields
first, then acquires only on the unique-owner destruction path.

A host-only adaptation of this narrow read path is more justified than deleting
runtime validation generally. Retain the existing acquire in `ctr_take` before
reusing/freeing unique storage, and retain release/acquire destruction ordering.
Do not silently port device ordering or change count-overflow diagnostics. The
rule relies on immutable redirect location bits, no concurrent last-owner
release while a retained owner reads, and immutable shared-node fields. It is
not justified merely by matching function names across runtime revisions.

Estimate: 0–20% on shared-box-heavy affected programs, about one hour for a
prototype, disassembly, and CPU threads1/4 sharing controls. Products may remove
many affected dereferences, so measure after that selection. A counts reduction
is not a timing result; concurrency controls are required even for a serial
benchmark improvement.

## Larger opportunities remain outside a cheap check-removal patch

Actual06 worker coverage reaches all named array/numeric workload functions,
16 lexer workload functions, eight tree helpers, two Map helpers, and none of
the authored closure workload functions. These are syntax/admission counts,
not time percentages. The absent paths include dynamic/escaping closure
construction, non-tail recursion and calls depending on those paths.

Upstream `collect` and `flat_of` also exclude direct non-tail self recursion,
parallel/bang bodies, and cyclic nonself flat dependencies. Simply permitting
ordinary recursive C calls is neither an upstream parity technique nor a safe
way to preserve our bounded-stack contract. Tail-SCC state machines or explicit
local continuation stacks are separate designs; first establish their hot
coverage before paying that cost.

The strongest next allocation technique beyond products is local constructor
storage reuse. Upstream `node_fields` keeps eligible consumed storage in a
scope spare list; ours immediately calls `spare_free` after `ctr_take`. A private
spare can satisfy a later same-size constructor allocation, falling back when
`ctr_take` reports shared storage. This needs explicit branch/call/escape and
unused-spare cleanup rules, not C-text rewriting. Estimate: 1.1–2x in genuinely
allocation-dominated affected code, roughly 2–4 hours for a bounded prototype
and alias/branch controls. It is premature to promise the six-family gain before
new allocation profiles identify the remaining dominant work.
