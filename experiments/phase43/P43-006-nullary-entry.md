# P43-006 — Make an ordinary nullary entry reach its private graph

Status: proposed from final-image static evidence; no prototype executed.

The final checked14 application comparison leaves morning at 210 µs versus
3.38 µs for TypeScript, and RLE at 40.5 µs versus 0.587 µs. These are execution
measurements, with imports and first calls recorded separately. The
[inspection](../../implementation/phase43/application-gap.md) retains exact
modules, receipts, drift and emitted-code locations.

Both ordinary entries remain generic zero-argument functions. RLE contains
private structural workers, but their call sites need an enclosing proof that
this module never opens. TypeScript uses saturated calls and direct matches.
Worker presence is therefore insufficient evidence of useful optimization.

First falsifier: count ordinary entry, generic application/forcing and private
RLE/expand execution without granting any new proof. A positive private count
would refute the predicted disconnected entry. This should precede any source
change or broad compiler build.

If the prediction holds, compare unchanged output, removal of entry dispatch
alone, and one guarded complete operation. Preserve fresh input construction,
compression/reversal/expansion/digest, exact results, dependency and host mutation,
errors and reentry. Keep representation and Nat changes as separate experiments.
Do not cache the result or constant-fold the fixture. Generalization to other
nullary entries must come from a typed source proof with explicit refusal cases.

No causal speedup or universal-parity estimate follows from this inspection.
