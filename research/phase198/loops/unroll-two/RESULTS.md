# Two-cell source fold: lowering gate refused

The frozen native compiler accepted the local-fold source and emitted an ELF
object in 1.017 seconds. The whole guarded trial closed in 1.375 seconds with
exit 1 at the planned machine activation gate. This source rewrite does not
preserve the fused scalar-product loop, so it cannot test the proposed loop
throughput improvement economically in this trial.

The actual object has no `$product.fold.loop`. Its `$direct.fold.loop` spans
0x3946–0x3a8c (326 bytes). The two-cell recurrence calls `$direct.fold.cell` at
0x3a48 and 0x3a79, with stack argument staging around both calls, before jumping
from 0x3a87 to the loop header at 0x397d. The single-cell fallback has a separate
call at 0x39e3. Thus this is more than a worker-symbol rename: the intended
call-free fused recurrence was lost. The exact instruction and relocation
witness is in [refusal-witness.txt](refusal-witness.txt); [result.json](result.json)
pins the actual object and the reproducible objdump command. The unchanged
ordinary object and mature C comparison remain in [the offline study](../final-fold/NOTE.md).

No executable was linked; no ordinary C, baseline or candidate correctness
observations were run; no timings were collected; the 8192-size source was not
compiled; and neither optional LLVM-MCA model ran. The prepared odd/even and
0/1 edge oracle remains an unexecuted method, not a correctness result. Source
emission alone does not establish the rewrite's complete-program correctness.
The result rejects this source proxy under the current lowering. It does not
measure or falsify the speedup possible from a fused two-cell implementation.

The root launched the frozen [argv](argv.json), and no retry was made. The
guard's failure closure remains sealed and unchanged. An 18-member, 46,150-byte
local capsule preserves the exact object, logs, receipts and frozen source
method; every archived member was checked byte-for-byte against its original.
[archive.json](archive.json) records the capsule and member hashes. Hot originals
remain available; nothing was pruned. This same-filesystem capsule is not an
independent backup. No compiler source or installed selection changed.
