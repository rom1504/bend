# P45-025: compose native String equality with Number-Nat lowering

Status: **retained, unselected prototype; experiment closed**. Candidate25 passes
its checked build, eight maintained suites and focused controls. Number-Nat
activates but supplies no additional gain in the short24→25 isolation. A longer
installed23→25 confirmation passes 30 samples and observes 1.37766× Map/Set speedup,
still 41.336× TypeScript and with substantial within-sample drift. One source
benefits while emitted size grows 56.4%; no controlled candidate25 compiler-cost comparison
or full candidate25 qualification ran. Worker23 remains the installed fully qualified
release. The [final report](../../implementation/phase45/native-string-equality.md)
records the decision and exact evidence. No further candidate is part of this phase.

The following proposal and queue describe the scope fixed before execution;
no-execution statements below refer to that preserved planning stage.

## Hypothesis and representation proof

Candidate24 admits exact native `String.eq`, but the private Number-Nat pass's
separate unchanged-layout native whitelist does not include it. Entire equality
containing graphs therefore retain BigInt Nat, including the newly admitted
Map/Set roots. This is a compositional proof omission, not a new equality algorithm.

The [one-line patch](../../selfhost/tools/performance/phase45/string-equality-numbernat-frozen24-v1.patch)
adds `String.eq` beside the already admitted `String.append`, `Bool.and`,
`Bool.xor`, `U32.cmp` and `F32.to_u32` in `jw_nat_value_valid`. It changes no
constructor, arithmetic, emitter, root selection or runtime code. Unknown natives
continue to refuse the entire Number-Nat rewrite.

The prerequisite is the completed candidate24 native proof: exact native
definition/source identity, quantity-one canonical String inputs, canonical Bool
result and unchanged public descriptor dependencies. Neither input nor result
contains a Nat representation. `jw_nat_value` therefore keeps the operation as
`JWNative` and preserves its argument order and ordinary `callOwned` ABI. Any Nat
computations producing surrounding values receive the existing whole-graph
rewrite; immutable String and primitive Bool values are unchanged.

The runtime's well-formedness/code-point equality and errors remain intact.
Private Char construction still checks U32 code points; this patch changes no
Char representation or error. `bad()` still suspends the proof for supported
Error hooks and reentry. Post-import String and Bool protocol mutations remain
guarded boundaries, not permissions to reuse proof across callbacks.

This reasoning does not assume every typed native is safe. Only the operation
whose two input/result representations were just proved is added. A future
native accepting or returning Nat-containing data needs its own representation
analysis.

## Independent falsifiers and efficient acquisition

The [controller successor v2](../../selfhost/tools/performance/phase45/string-equality-native-controls-v2.mjs)
retains the original source, catalog and all 135 value, six activation, 19
boundary and eight error checks. It pins the preserved v1 controller. Both
baseline24 and candidate25 must retain each admitted root; the candidate must
add Number-Nat emission for `bench` and `scalar`, while baseline24 lacks it.
This updates the causal mechanism expectation without weakening any oracle.
Two additional post-import Boolean-prototype `bounce`/`build` getters compare
exact observations and require private refusal. Existing String getter/method,
native descriptor, public malformed Unicode, source Char error, Error reentry and
clean replay controls remain.

Reuse exact candidate24 and pinned TypeScript fixture acquisitions, and acquire
only candidate25's emission of the unchanged catalog. After a checked build and
eight maintained suites, run:

```sh
node selfhost/tools/performance/phase45/string-equality-native-controls-v2.mjs \
  selfhost/build/phase45/equality24-candidate/modules/string-equality-native-v1.mjs \
  CANDIDATE25_MODULE \
  selfhost/build/phase45/equality24-typescript/modules/string-equality-native-v1.mjs \
  NEW_OUTPUT_DIRECTORY
```

Compare newly emitted Map/Set roots and unchanged-code canaries before timing.
Use candidate24 as the causal timing baseline for this isolated representation
comparison; worker23 remains the selected compiler, whose full-corpus metrics
are not replaced by this two-point screen. A short clean screen can reject the
idea, but cannot establish steady-state gains or promote a compiler. In
candidate24 the nominally clean Map/Set screen still had substantial
within-sample drift; a surviving candidate needs a longer settled comparison.
No further coverage extension or benchmark-specific rule is part of this probe.

## Preserved identity

Patch SHA-256:
`045824d7ac9a0022879ed5a541c8c04b6a440e33b40c3b6ce5dbd1da92cbe76d`.
Exact before/after and patch receipt are in
`selfhost/build/phase45/string-equality25-v1/`. The tracked patch applies to the
frozen candidate24 clone, not maintained production source. Node syntax checking
and `git apply --check` pass. No compiler or generated program has been executed
for candidate25 by this proposal's author or reviewer.


## Frozen bounded queue

The root may execute the reviewed isolated queue:

```sh
python3 selfhost/build/phase45/string-equality25-v1/serial-queue.py \
  --execute-isolated25
```

It verifies worker23's exact installed API and 42 smoke checks, pins 25 inputs,
clones frozen24 to fresh25, applies only the Number-Nat whitelist patch, verifies
source isolation, builds a checked compiler and runs the eight maintained suites.
It acquires only the new candidate fixture, reusing the hash-bound24 and pinned
TypeScript acquisitions; all controls pass before further work proceeds.

It then acquires five corpus sources (six modules with the complete-row adapter),
requires the five canary points and Unicode module to retain their prior bytes,
and verifies that only the two existing Map/Set entries switch Number-Nat mode.
Byte-identical canaries are not timed again. A single clean two-case 60-second
budget screen compares24 with25 and pinned TypeScript, with no concurrent heavy
work. Failure stops the queue and preserves all jobs. No installation, additional
transformation or automatic longer run occurs. The root may request longer
confirmation only if that screen is useful; a modest gain or negative result is
sufficient to close this proposal.

Independent actual-file review confirms the patch, controller and serial queue.
All 25 frozen queue input hashes match; no target execution is claimed here.
