# P87-002: minimize the observer continuation fail-stop

Status: mechanism confirmed by eight minimal controls; full observer repair designed.

Map reaches `rfc_wrap` from `NOA_EVAL_K8169`, rejecting a closure/task value in
ordinary reference counting. Test whether type erasure or eager creation of two
branch closures duplicates an affine continuation. Compare typed/untyped small
programs and direct pattern-match branching, with C and JS behavior recorded.
Use checked sources; unsafe annotations are part of the hypothesis, not proof
that native runtime representation use is valid. Preserve the runtime guard.

Law/inline signatures generate identical C/JS. Eager/double reuse fails natively;
direct branching, affine threading and Data continuations pass. The safe checker
rejects duplicate capture.29 guarded jobs,15.84s summed execution,23s elapsed.

Results and proposed repair: [Phase87 report](../../implementation/phase87/README.md).
