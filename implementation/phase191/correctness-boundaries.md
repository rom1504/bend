# What the Phase191 checks establish

The compiler algorithms remain Bend. Source checking uses unmodified pinned
upstream loading/checking and rejects unresolved holes. The scalar/native plan
verifier, ownership admission and register-interference validator remain intact.
No new BendTT theorem or whole-compiler equivalence proof is claimed.

Indexed-address selection removes an adjacent address temporary only when its
whole-function read/write facts establish the required single use. Parameter
and setup identities remain protected. Full-width arithmetic is preserved;
a U32 intermediate cannot silently become a64-bit effective-address multiply.
Unknown or large unsigned displacements retain ordinary lowering. Allocation
sees selected inputs/outputs; original verified rows determine source semantics
and are emitted using the same matcher. Selected emissions cannot silently fall
back after dropping an allocation dependency.

Conditional selection accepts only matched one-to-four-copy chains with the
same destination sequence and width, or two empty arms. Inputs and condition
are snapshotted before publication; every original destination remains written.
No user-memory operation, call, effect, ownership transition or terminal control
flow is speculated. Machine CMOV uses register sources. U32 truncation and low32
condition interpretation are explicit.

Frame forwarding retains the original store. It recognizes only an immediately
following equal-width64-bit load of the same aligned negative RBP slot, with
ordinary GPRs. Every other item—including labels, directives, calls, clobbers,
unknown writes and partial stores—clears the fact. It changes neither frame
layout nor original liveness/ABI decisions.

Loop-use weighting changes profitability only. It does not remove interference
edges, call-crossing restrictions, incoming-register restrictions, pool bounds,
or independent post-allocation validation. Static repetition classification is
not a dynamic frequency or hotness proof.

Focused fixtures compare direct ELF, assembly rendered from the same typed
sequence, and separately handwritten assembly where specified, against independent
C observers. Literal machine-byte cases cover encoding independently from the
renderer. Exact native45 outputs are an independent finite semantic oracle.
Native self-reproduction and cross-host product equality, when reported, are
separate evidence; two generations can share a bug.

The argument-move prototype additionally preserves original call-slot/capacity
admission, stores outgoing arguments before modifying ABI registers, orders
register writes after all pending readers, and breaks cycles with a reserved
64-bit snapshot. U32 identities still clear upper bits after other full-width
readers. Its bounded refusal discards every tentative instruction before the
complete original fallback. It passed focused controls and eight exact program
oracles, but its small measured runtime change did not justify selection. The
prototype and integration patch are retained under tests, outside production.

Final independent static review found no correctness or ABI blocker. All 892
x86 declarations across 35 modules match the frozen source-map spans. The call
prototype and alignment attempt are absent from selected source. Two stale
comments remain deliberately untouched after freezing: CMOV's old “Proposal
only” label, and frame forwarding's “memory effects unchanged” wording (the
intended claim is unchanged observable behavior, since a reload disappears).
Finite controls, native qualification and exact product comparisons are recorded
separately in the implementation report; static review does not replace them.
