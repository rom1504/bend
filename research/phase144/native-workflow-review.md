# Independent native qualification workflow review

This is a source/receipt-contract review, not an execution result. The reviewer
ran no compiler, target program, profile or native build.

The consumed `workflow-v03.py` source has SHA256
`74a6e953c4a9951b7a1d34479cbd2872f337d5cb62bf65fca68c6a26e145a373`.
Its checked-source replay, exact serial runtime, streamed native acquisition,
N1→N2 lineage, complete Q2=Q3 fixed-point requirement, and reused independent
focused/ordinary coverage authorities had no identified blocker to acquisition.
The initial final-seal path needed stronger smoke evidence and an uncached final
input recheck; those findings did not invalidate the native build recipe.

The reviewed successors are:

| Source | SHA256 |
| --- | --- |
| `host-smokes-v02.py` | `15063dfd5522c753587fceb688da7f1484a7b054ca069acafd6b14ef64d31d89` |
| `seal-v01.py` | `d38633209662f941e7c20d6a7d4544b08118c035b8cec5bc2c4c2ecaa0b95585` |

No new material blocker was found in these successors. The smoke contract binds
the actual final N2 executable, its source/runtime build receipt, the emitted
provider fixture and exact complete observations: both path modes, Unicode
publication, existing-file refusal without replacing content, and readback.
The fixture uses the actual NativeHost foreign signatures. Current-policy A/B
oracles come from the independently checked hosted API, retaining logical-path
and physical revision identities. Batch/session observations bind their actual
executable and linked runtime and compare the complete QBE payloads.

The sealer additionally requires the prior61-program/122-execution/three-CLI
runtime gate and all nine successful word-control observations against the
actual candidate runtime source. It authenticates the smoke methods and child
reports, rather than accepting only four gate booleans. Its final uncached
hash pass catches changes after the earlier cached input checks. The smoke
runner's local final check remains cached, but the qualification sealer repeats
the complete closure without that cache before acceptance.

The review approves this bounded evidence protocol, not an already-completed
qualification. Actual success still requires the native receipts and smoke
outputs to exist and pass. Q2=Q3 establishes complete emitted-QBE reproduction;
it does not claim an N3 ELF fixed point. Provider smokes cover finite success,
existing-file refusal and cleanup observations, not all provider failure modes,
arbitrary C embeddings, parallel heap access or a race-freedom theorem. Installed
and default selection are separate decisions and remain outside this protocol.

## Corrected IO-return process oracle

The first smoke execution exposed an error that the initial source review
missed: its existing-file branch prints the provider's error code and returns
`IO.pure(U32,1)`. That returned value is not a process exit status. The test
incorrectly expected exit1, although the observed complete stdout was`17\n`
with exit0 and empty stderr. The failed `final03-host-smokes01` receipt is kept.

Independent inspection of unchanged Base and runtime establishes the expected
behavior: `IO.pure` calls its continuation; `io_spawn` supplies `FID_IO_EMIT`,
which constructs `CID_EMIT`. The event loop consumes that emitted value and
returns0 when no activations remain. `IO.die` constructs `Halt`; that distinct
runtime branch reads the actual process exit code. This explanation follows
the source contract rather than treating the observed result as its own oracle.

The exact successor derivations and all bound input hashes were replayed
offline successfully:

| Source | SHA256 |
| --- | --- |
| `host-smokes-v03.py` | `a404364ca7587942df6411f310f2dc4df29858e2853e43717e0c6a5fc9aac4f5` |
| `seal-v02.py` | `3d43afe9da5a389b4506568719189a1d1deb24d5d66785c5f0cdcb0c7be6a5a8` |

Only the mistaken expected process status changes1→0, together with the sealer's
runner identity and corresponding status check. The Bend fixture, compiler and
runtime are unchanged. Exact error17 output, preserved original file bytes,
absence of temporary leftovers and subsequent readback remain mandatory. This
is a justified oracle correction, not acceptance of arbitrary exit behavior.
The reviewer performed no new target execution.
