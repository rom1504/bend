# Phase153 evidence and replay

`phase153.tar.gz` is 2,036,531 bytes, SHA256
`e2f2cc58b16b537b4fd5328ea0ac6dae21785d57f800849f66670a736ff384e6`.
`capsule.json` pins all 96 stored payloads and 39 identical aliases. Every member
was decompressed and its exact size/hash verified after packaging.

The capsule retains the frozen compiler source/map, fresh owner and stage maps,
raw physical samples/contexts/callers, full and pilot stage reports, event counts,
complete-output receipts, exact guarded commands, runtime preparation, original
controller/summary methods, and derived attribution. It omits large QBE products,
native objects/binaries and external toolchain/Base assets. Those remain in their
qualified locations and verified local retention under
`selfhost/build-retention/phase153/`; no artifact was pruned.

Restore into empty scratch, verify every payload, and copy needed aliases from
their recorded payload paths. Never extract over live/frozen run roots. Replaying
requires the pinned external assets or separately qualified reacquisition; this
is not a standalone toolchain distribution.

The unmodified controller is
`experiments/phase147/tools/profile-candidate.py` at starting Git `0a16bb7`.
Exact argv and resource limits are in each `*-guard/process.json`. The five jobs:

1. `prep01`: authenticate the Phase152 N2 receipt, object, QBE and exact assembled
   source; derive fresh FIDs, source ownership, ELF bindings, libc CFI and the
   existing 23-stage contract plus optional nested verification marker.
2. `profile-build01`: build only the diagnostic runtime/sampler and relink the
   retained program object. No Bend compiler is recompiled.
3. `pilot01`: compare a small clean request with its instrumented counterpart;
   complete output and stage ordering must agree. Its 64 samples are below the
   quantitative threshold and are not used for hotspot percentages.
4. `full01`: execute the current exact compiler source through the diagnostic
   image at 32ms sampling. Compare every emitted byte against qualified
   `selfhost/build/phase152/native-n3/program.ssa`. The quality gates admit the
   7,406 samples. `analysis01` and `attribution01` are offline derivations.
5. `events01`: use the pilot's same frozen manifest in event-only mode. Stage
   sampling is off, the counter output is complete and independently matched
   to the exact linked FIDs. `events-attribution01` is offline. This is event
   volume, not a clean clock or a proxy percentage for the full compiler.

The exact full-request source is 3,085,157 bytes, SHA256
`027e15041035522ed7e40ef971eff75f24a09ef6a00e3f8fe335839f94bcb8a8`.
The full expected QBE is 118,227,421 bytes, SHA256
`1032c6a6495ca86bb26ad2bcd7ae639ed49dc987765dfe567dce7ac6224bf7bb`.
Diagnostic and clean images have different runtime support; their clocks are
not interchangeable. No FID/address mapping is copied from another compiler.

`experiments/phase153/summarize.py` regenerates the committed headroom metrics
from these reports and ordered samples. Its conditional half-region arithmetic
is explicitly a screening scenario, not an implemented optimization. The report's
publication count uses the complete ordered sample slice, not only the stage
summary's top 12 owners. Source audits did not execute additional targets.

A rejected first event-command attempt supplied a 32 MiB file cap, below the
guard CLI's supported minimum. It created no run or target; the actual retained
command uses 64 MiB. All five executed guards succeeded and were closed through
maintained retention. [Costs](../cost.json) and [retention](../retention.json)
separate these jobs from agent, source-analysis and documentation effort.
