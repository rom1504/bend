# P68-008: force-inline private C workers, diagnostic only

Registered before transformation or target execution. Root owns all serial CPU3
targets; upstream lane only prepares source/data artifacts.

Hypothesis: the array worker result is limited partly by Clang keeping small
private worker calls out of line. Exact flat06 array C has two Tuple allocations
and two takes per element; its object retains fold.cell and fold.step as ordinary
calls. Forcing all admitted private NF workers inline may reduce call overhead
and expose ownership/constructor simplifications without changing representation.
Numeric provides an independent comparison. This is a diagnostic, not a proposed
production inlining policy or a parity claim.

Transform only `INLINE Term NF_*` prototypes/definitions in frozen flat06 C to
add `__attribute__((always_inline))`. Keep all other source bytes, runtime,
Clang identity/arguments, single CPU/thread, input corpus, independent Phase46
oracle, and saved Phase68 plan02 repetitions/warmups unchanged. Do not regenerate
Bend C. The source-only preparation script records before/after identities,
worker graph closure, exact command arrays and smoke/plan02 expected digests.

Root uses the existing ExecutionGuard: 2GiB process-tree RSS, 4GiB available-memory
floor, 90-second Clang deadline and 45-second target deadline. Record failure or
stop if these bounds are exceeded. Stop before timing if either executable is
larger than eight times its own flat06 baseline. All workers are included even
when cold/large, so Nat.read.trim may make this deliberately broad diagnostic
unprofitable. Do not silently narrow the rule after observing a result.

Qualify both transformed programs against independent smoke and plan02 digests.
Use three alternating baseline/candidate rounds, fresh raw paths, and the existing
phase46 execute.py child timing receipt. Inspect symbol/call disappearance and
binary size alongside runtime, C compilation time and peak RSS. A speedup can
motivate a separate bounded profitability policy; failure or regression rules out
this unrestricted policy. No production source change, correctness result or
measurement is claimed at registration.
