# Entry profitability: measured allocation removal

The allocation-free raw-array local guard passed its independent audit, but is deferred from production. Five rotated samples per variant and point (45 samples; 69.74 seconds) show a small short-point gain and no broad improvement.

| Point | Original μs (range) | Allocation-free μs (range) | Original / candidate |
| --- | ---: | ---: | ---: |
| 128-0 | 14.1966 (14.0635–15.9010) | 13.6606 (13.0249–15.0192) | 1.0392× |
| 4096-17 | 61.0509 (60.8118–69.1695) | 61.5000 (60.0807–68.2116) | 0.9927× |
| 8192-123 | 111.5230 (111.1002–123.3676) | 111.3387 (110.3731–115.3162) | 1.0017× |

The 4096-step point is adverse: the candidate median is slower. Removing temporary guard vectors does not eliminate the descriptor checks, source dependency checks, or complete host protocol validation. A 44-line runtime specialization is not justified by this screen. The selected compiler and runtime remain unchanged.

The unsafe admission-bypass derivative reaches 1.2046 μs at 128 steps (11.785× relative to the original), but removes mutable source/host checks. It is an upper bound, not a permitted implementation. Its result does not establish that the same speed is available under the mutation contract.

The audit retains ordinary complete values, all eight source dependencies, descriptor/getter/prototype refusals, native Error fallback and reentry with proof cleanup. Timing uses clean derivatives; audit counters are separate. The inherited-proof and unguarded scalar-root routes were not broadened. Generic fresh-region guard allocation removal remains deferred rather than assuming this small result transfers.

Evidence: [timing report](../../selfhost/build/phase48/entry-profitability01-timing/report.json), [audit report](../../selfhost/build/phase48/entry-profitability01-audit/report.json), and [compact hash-bound summary](evidence/entry-profitability.json). The maintained execute driver and selected array06 image are pinned in these reports. These are saved-output diagnostics, not checked source integration or a corpus measurement.
