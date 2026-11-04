# P160-006 — does repeated tracing explain the scaling loss?

The accepted100ms full-request profile has1,672 samples,99.94% sampled CPU
coverage and zero loss/overruns. Physical gc_mark+gc_collect_locked accounts
for54.01%, with gc_rescan_items another1.61%; gc_refill is5.86%.
The initial8ms capture is rejected for36 overruns and is not pooled.

Test one existing runtime policy on the **same** C02 executable and full input:
BEND_GC_FACTOR=1 instead of0.5. The runtime's next collection budget is
max(factor*live_bytes, minimum*growth). This independently varies collection
frequency; the earlier free-block search cap remains fixed. Do not change
MIN_MB, MINOR, STATS, source, output, optimizer, checking or machine build.
The existing request runner clears BEND_*; the separate pinned ablation runner
explicitly admits/records this one override.

Require all118,227,421 independent QBE bytes and ordinary diagnostic/status
gates. KeepCPU3,6GiB RSS,16GiB availability,5GiB disk reserve and300s deadline.
More allocation headroom may increase peak RSS; a resource refusal is a negative,
not a reason to silently raise the cap. A time win establishes cadence
sensitivity, not the safety or value of region allocation or production GC.

The compiler already streams QBE output. Future lifetime separation concerns
durable admitted IR/catalogues and temporary emission/analysis objects, not a
fictional single retained118MB String. Do not drop original/legacy graphs until
their remaining verifier, fallback and public consumers are accounted for.
