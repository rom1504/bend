# Phase102 TRMC destination-field policy

The final experimental source is `projection-cold-source01/compiler.bend`,
SHA256 `b3927732f2250c19a7a8988dab7cbf30726359c18b5305f73c28cadddb902d1f`.
A nine-line correction makes iterative constructor reconstruction preserve the
ordinary native emitter's field-storage policy. This report records the reason
and focused validation; final native qualification and runtime measurements
remain separate gates.

The broad runtime screen of the earlier, otherwise qualified depth candidate
found a list-pipeline regression. TRMC linked every next node with `rfc_seal`,
although ordinary cold constructors store that field directly. Each new link
therefore could add work absent from the original generated loop. A saved-C
ablation removed those seals only in the two list workers whose constructors
were all proven cold. Six balanced rounds measured 128/512 cases at approximately
0.648/0.662 times Phase98 runtime. The initial 512-point slowdown of 2.54 times
Phase98 did not reproduce at that magnitude: the diagnostic comparison was
about 1.34 times before the fix. The diagnostic is in
`selfhost/build/phase102/list-cold-link-screen01/report.json`; its narrow C
rewrite does not establish the general fix's performance.

The general rule belongs to the pending destination field. When a new node
arrives, it must be stored according to the previous node's constructor; only
then may the loop record the new node's policy for its final recursive field.
The terminal result must obey that same pending policy. The private TRMC state
therefore grows from four words to five. Slot four records whether publication
needs sealing, while the existing root, hole, and two private cell-cache slots
keep their roles. Recursive and terminal publication both select exactly one
of the sealed/direct expressions. Argument order, owned arguments, cleanup,
public constructor layout and the admission predicate are unchanged.

The new `ntr_hole_policy` mirrors the unchanged `ne_ctor_node(..., True, ...)`
logic, including `DEVICE`, `NATIVE_COLD_CTORS`, the individual constructor's
`NATIVE_HOT_*` flag and `NATIVE_COLD_USER_CTORS`. This is a storage-policy
correction, not a new permission to treat shared fields as cold. The reversible
[preparation method](../../selfhost/tools/performance/phase102/trmc-cold/prepare.py)
accepts an explicit parent recipe and retains all prior recipe edits.

The final checked API and the 29-case focused manifest pass: 171 complete
exit/stdout/stderr observations across baseline, candidate and upstream roles.
Two added sources exercise alternating two- and four-field constructors, a
terminal constructor, retained shared Unicode payloads, and a separately shared
root. A diagnostic matrix on the unique-chain source then passes five policies
at one, two and four workers: all-hot, all-cold, and each individual constructor
hot. These are 15 additional exact-output observations. Forcing an arbitrary
shared chain cold would violate the ordinary emitter's assumptions; the shared
root source is tested only with its natural/all-hot policy.

The matrix also checks actual preprocessed policy assignments and the order of
hole publication. Output equality alone would not detect unnecessary sealing.
Its final receipt is `trmc-cold-matrix-run02/report.json`; the first runner's
parser failed to recognize preprocessed `_Bool` and remains preserved as
`trmc-cold-matrix-run01`. The successor changes only that lexical signature
match. These diagnostic macro variants are not selected compiler products.

Independent source review and the consumed `authority-source-audit05` verify
that the seven local recipe edits reconstruct and invert exactly, the ordinary
constructor policy is unchanged, and recursive/terminal publication uses the
previous destination before updating it. Original safe proofs retain their
original source identities; there is no new universal native ownership proof.
The final native B1/B2 chain and its complete semantic gates must still succeed
before selecting this candidate.
