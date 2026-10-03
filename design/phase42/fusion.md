# Phase42 scalar pipeline work elimination

Hypothesis: removing all three private intermediate lists in an already direct
producer/filter/map/fold component improves the current Phase41 list output
substantially. Compare exact original output, fused BigInt countdown, fused
Number countdown and pinned TypeScript. Number countdown is an independent
ablation; it must not be credited as allocation elimination.

Saved-output prototype: `selfhost/tools/performance/phase42/fusion/derive.py`.
It binds the current manifest/API/module hashes and changes only the existing
private scalar root try body. Existing exact-entry authorization, canonical U32
argument checks, dependency/host guards, proof opening/finally restoration and
public fallback stay byte-for-byte. No worker is renamed or changed. The loop
performs every producer step and seed update, then filter/map/fold once per head;
no low-bit cycle arithmetic or benchmark-algorithm rewrite is used.

A future compiler admission must recognize source shape, never definition names:
Nat countdown producer of a closed grounded one-child ADT, scalar head/state
updates, one structural map/filter chain, then a tail scalar fold. Every
intermediate must have exactly one private consumer and no returned identity or
shared binding; rejecting ambiguity is acceptable. Existing closed component
proof and host guards remain prerequisites. The scalar subexpressions need a
new totality whitelist (bounded U32 add/sub/mul/bit/comparison and bounded Nat
countdown) rather than JPure. Division, descriptor/native hooks, callbacks,
String/Char/Sigma, early termination, zip, nested streams and arbitrary closures
are refused initially. Effectful/deferred heads, error-producing callbacks and
retained intermediate aliases stay on the original route before extra work.

Demand rationale: original producer and map evaluate heads forward; filter
predicates execute backward after the tail. Fusion reorders those predicates
with seed updates and mapping. Closed U32 operations cannot throw under the
unchanged host guard; the complete pipeline is total for canonical finite
inputs. Only this proof permits the reordered scalar computation. Fold head
order and U32 wrap at each operation remain exact. Purity alone is insufficient.
The Number role relies additionally on the existing bounded U32-to-Nat scalar
countdown argument: integer 0..4294967295 is represented exactly.

Controls compare complete produced/filtered/mapped tagged values and ordinary
exports at empty/singleton/noncycle sizes and hostile seed values; an independent
BigInt oracle supplies expected values. Diagnostic arbitrary heads and initial
accumulators cover multiplication/addition overflow, all/none/mixed selectivity
and unchanged retained sources. Public dependency/getter/native mutation and
foreign deferred errors must refuse the fused root and preserve exact event
order. A counter inside the actual private root proves entry and refusal.
Explicit predicate and later map failures challenge strict stage demand.

Status: saved-output v2 controls and short screen pass; general source patch is
prospective and uncompiled. Root owns source integration and execution/timing.
Promote only a measured winner after independent review and a second renamed
source-shape fixture; otherwise reject/defer without widening admission.

The first source grammar supports exactly one producer, one filter and one map
feeding a tail scalar fold, with two-constructor owners whose nonempty node has
U32 head and same-owner tail. It refuses all root lets (including harmless
single aliases) as a conservative ownership bound, and admits no alternate
stage ordering initially. Literal values and definition names are unrestricted.
U32.mod remains allowed because the existing intrinsic emitter defines total
zero-divisor behavior; existing emission is reused without arithmetic rewrite.
