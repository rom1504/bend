# One traversal, three execution shapes

The maintained `f_pattern_sub` / `f_pattern_value` in
`selfhost/src/front/elaborate.bend` recursively rebuild children and their parent.
They run during pattern-row elaboration. Earlier profiles establish execution,
but the 39 historical contexts and three nearest frames do **not** bound their
inclusive share of current frontend time. This was a capability experiment, not
a forecast of a large whole-compiler gain.

## Hypothesis 1: explicit continuation frames remove scheduler work

The first source overlay preserves constructor variants, child order, removed
names, quantity-presence, spans, and aliases. A matching variable discards its
children and traverses the replacement in span-only mode. Returning to a sibling
restores the original mode and span state. A zero occurrence begin preserves all
replacement spans; binder IDs do not stop this particular substitution.

Frames hold a childless parent shell, pending siblings and reversed completed
children. Visit/rebuild/children/return functions call each other in tail position.
All 57 complete-value observations pass against unchanged checked Bend, including
the independent literal expectation. The native whole-workload digest agrees
with independent upstream-checked execution.

**Negative result:** native workload time grows 0.866154→0.909438s, 4.997%.
Only the reverse helper gets a `p113d` worker; the traversal still uses `p111`
scheduler functions. This adds shells/frames/reversal without removing the desired
execution category. QBE grows 437,041→513,066 bytes. Do not promote it.

## Hypothesis 2: make the traversal one private recursive owner

After that failure, a separate overlay expresses the same frames with a single
tail-recursive function and an explicit state tag. This tests the lost boundary:
the ordinary direct lowerer converts **self** tail calls to `P113DAgain`, while
other calls become dependency-bearing calls. Its readiness pass requires those
dependencies already to be ready. Existing SCC machinery did not close the first
prototype. This is evidence about the emitted candidates, not a claim that every
mutual recursion is unsupported by the compiler.

The single loop gains a `p113d` worker, as do its entry and `f_pattern_sub` wrapper.
Its loop has jumps and no direct recursive native call. The same 57 complete-value
controls and native observations pass. Whole workload time becomes
0.863975→0.669874s, **22.47% less**, across six alternating pairs. QBE decreases
to 416,732 bytes. See `machine-inspection.json` for exact products and symbols.

Both measurements construct varied 8,223-node inputs, retain aliases, exercise
hit/miss IDs, traverse all result fields and perform destruction. They are
compiler-shaped workload measurements, not frontend latency or an independent
semantic proof. No unrestricted deep-stack qualification has been performed.

The candidate then improves complete native parse/load by 3.44% and 3.83% on
356,626- and 656,302-byte real compiler sources in balanced two-round comparisons.
The final report records the full-source follow-up and complete parser-value gate.

## What this changes

Source-level defunctionalization alone is insufficient. A useful specialized
machine must survive direct-worker admission; otherwise it just changes how
continuations are allocated. Preserving a verified recursive region as one owner
is a stronger next hypothesis than adding more source frames.

Do not hand-rewrite every semantic walk based on this one case. First select a
larger measured inclusive frontend cost, extract an honest workload and repeat
the admission/whole-value/complete-component test. Only then consider automatic
fusion of legal recursive regions, retaining ownership, evaluation order and
stack-safety checks. The current experiment changes no runtime, verifier or
production source.
