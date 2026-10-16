# P102-005: preserve cold constructor destinations

**Question:** why did newly admitted constructor loops regress list pipelines?

The candidate02 broad runtime screen finds1.330× installed time for128 nodes
and2.536× for512. Static inspection shows all18 old NF inline hints remain.
New `p37.list` and `dbl` loops unconditionally call `rfc_seal` when publishing
into a pending constructor field; ordinary constructor emission respects the
checked cold/HOT policy.

A saved-C experiment changes only these two stores for homogeneous cold Con
lists. Six balanced rounds compare installed, candidate02 and the intervention:

| Size | Installed median ms | Candidate02 ms | Cold stores ms | Cold / installed |
|---|---:|---:|---:|---:|
|128|270|355|175|0.648|
|512|270.5|362.5|179|0.662|

All complete outputs pass. The512 observations are bimodal: the candidate02
samples are702,360,693,362,362,363ms; installed403,267,401,270,271,267ms.
The initial2.536× magnitude is not reproduced as a median here. Both datasets
remain intact; the matched intervention has a consistent benefit.

**General integration:** a private fifth state word records the previous
constructor destination's policy. Both recursive and terminal publication use
it before the next hole changes it. Derive the policy from the exact ordinary
emitter conditional, including DEVICE, COLD_CTORS, HOT_CID and COLD_USER_CTORS;
the current child constructor is not the owner of the pending field.

Final source `b3927732…902d1f` passes checked acquisition and171 focused outputs,
including an alternating2-/4-field recursive sum and a separate shared-root
control. An independently prepared unique-chain matrix forces all-hot,
all-cold, short-hot, wide-hot and end-hot policies. The actual preprocessor
assignments and15 full-output runs pass. Arbitrary cold policy is never applied
to the shared-root fixture. These diagnostic macro variants are not natural
compiler outputs or a whole ownership proof.

The first matrix runner failed because Clang expands `bool` to `_Bool` before
its function-signature parser. The versioned successor normalizes only that
signature for inspection; compiled C is unchanged. The failure is preserved.

Raw evidence: `list-cold-link01`, `list-cold-link-screen01`,
`trmc-cold-controls01`, `final-controls03`, `trmc-cold-matrix01`, and
`trmc-cold-matrix-run01/02`, all under `selfhost/build/phase102`.
Native-chain and45-program final measurements are separate release gates.
