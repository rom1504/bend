# Phase176 — faster experiments and a direct semantic traversal

**The same screening batch runs 2.72× faster with four software workers.**
A new traversal experiment runs 22.47% faster on its complete native workload,
and 2.86% faster on full-source parsing. No maintained compiler or installed
selection changed; there is no new complete-frontend or cold-build score.

[Design](../../design/phase176/README.md) · [Measurements](metrics.json) ·
[Runner](../../selfhost/tests/phase176/README.md) · [Reproduce](reproduce.md) ·
[Evidence index](evidence-index.json).

## What changed in the method

We reused authenticated native images to calibrate actual smaller compiler
sources, then dispatched independent comparisons in software under one aggregate
resource guard. Each job compares both images on the same core, reversing order
in its second round. Final performance screens remain isolated on CPU3.

| Identical four-comparison batch | Wall | Child CPU | Peak tree RSS | Throughput |
|---|---:|---:|---:|---:|
| One worker | 76.504s | 75.707s | 88.0MiB | 1.00× |
| Two physical cores | 38.890s | 76.898s | 161.6MiB | 1.97× |
| Four physical cores | 28.170s | 79.076s | 266.8MiB | 2.72× |

These are one batch per configuration, not confidence intervals or complete
research-throughput results. Four workers spend 4.45% more child CPU. Two longer
jobs limit the four-worker schedule; more workers cannot help this four-job set.
The four-worker pilot remains far below the 2GiB aggregate limit.

The 356,626-byte real compiler closure takes about 2.55s to parse and 5.34s for a
complete frontend request. The 656,302-byte scaling input takes about 5.79s and
13.82s respectively. They recover the historical broad positive/neutral decisions:
lookahead and the combined changes improve; precedence and field reuse remain
small/neutral. Magnitudes drift: the combined small-input gain is smaller than
the historical full-input gain. Treat a few percent as uncertain and advance
survivors to a larger isolated screen. There is no automatic promotion threshold.

Calibration is narrow: four historical variants, two compiler-shaped inputs.
It does not prove predictive validity across future transformations. The earlier
indexed-store regression uses a different interface and was not silently
substituted into this calibration. New representation experiments still need
complete computations with realistic sharing and teardown.

## What the new experiment found

The first work machine replaced the parent/child recursion of `f_pattern_sub`
and replacement-span traversal with explicit frames and mutually tail-calling
functions. It passed complete-value controls but ran **5.00% slower**. Machine
inspection showed the traversal still used generic scheduler functions. It
added frames, shells and reversal without eliminating the intended execution
overhead. We rejected it after an 11-second paired screen.

A second version put those states into **one tail-recursive owner**. This gained
a verified private worker (`p113d`) with loop jumps rather than recursive native
calls. Its wrapper gained a private worker too. This is the important architectural
finding: the information must survive worker admission; source-level stack
conversion by itself is insufficient.

| Complete native traversal workload | Baseline | Candidate | Change |
|---|---:|---:|---:|
| Mutually recursive explicit frames | 0.866154s | 0.909438s | 5.00% slower |
| One tail-recursive state loop | 0.863975s | 0.669874s | 22.47% less time |

Each row has six alternating isolated pairs and its own contemporaneous baseline.
Construction, all-field observation, retained aliases and destruction are included.
The 64 varied iterations use 8,223-node compiler-shaped inputs with hit/miss IDs.
These are extracted workload results, not compiler throughput. QBE changes from
437,041 bytes to 513,066 for the rejected version and 416,732 for the single loop.
See the [mechanistic analysis](../../experiments/phase176/pattern-traversal.md) and
[exact worker census](../../experiments/phase176/machine-inspection.json).

The survivor transferred to real native parse/load:

| Actual input | Baseline parse | Candidate parse | Less time |
|---|---:|---:|---:|
| 356,626-byte compiler closure | 2.1925s | 2.1170s | 3.44% |
| 656,302-byte compiler closure | 5.0540s | 4.8605s | 3.83% |
| Frozen 3,150,535-byte compiler | 23.2385s | 22.5730s | 2.86% |

Two balanced rounds per input, same runtime/toolchain, Phase171 native producer,
prepared Base and CPU3. The historical parser declaration order is preserved in
the candidate source; only the named transformation and its helpers change.
For the full input, whole process time is 24.0336→23.3673s, including Base setup,
digest and teardown. Source paths/bytes and observation contracts are unchanged.

**Do not subtract 0.67s from the old 56.219s frontend or 178.937s build and call
that a measurement.** Annotation/checking/backend costs were not remeasured.
No full compiler image was built for this change. The modest component gain does
not justify a full qualification campaign in this methodology experiment.

## Correctness and limits

- Both variants pass 57 complete-value comparisons each, against unchanged checked
  Bend and independently written literal expectations. Variants, metadata, spans,
  child order and retained aliases are covered.
- Native workload outputs match an independently upstream-checked observation.
  These 32-bit digests supplement complete-value gates; they are not proofs.
- The selected parser passes complete parsed-value/diagnostic comparisons on 14
  cases, including tree-bitonic and RLE. All native proxy/full-input observations
  match their reference.
- Supervisor tests cover timeout termination, preserved nonzero exit, continuing
  independent work, released lanes and refusal of changed input identities.

Forward `law` signatures are type declarations, not mathematical proofs. There
is no new BendTT theorem, unrestricted deep-stack campaign, broad generated-program
runtime campaign or self-hosting qualification. Maintained source and installed
compiler remain unchanged; their existing qualified results remain the frontier.

## Cost, failures and storage

The 31 closed outer runs cost **465.499 target seconds (7.76 minutes)**. Nine
nonzero runs cost 13.516s combined. Metadata preparation, research, the bounded
read-only agent audit, storage work, writing and coordinator effort are outside
that sum; this is not a quota measurement or proof of faster research overall.
One coordinating agent owned execution; a single bounded agent audited semantics
and supervision. The parallel compiler trials were software jobs.

Small native images cost 1.27s, 1.36s and 2.45s to acquire; the last includes extra
unused control declarations, so these are costs, not an isolated compilation
overhead comparison. Actual parser acquisition costs 27.60s. We reused the
existing reference image and avoided a full compiler rebuild/qualification.

Failures are retained: initial disk-budget interruption, unavailable unqualified
`node` command, four Bend source-admission errors, an output-path typo, a hosted
API import-shape mistake and a stale historical manifest identity. Reacquiring
the baseline API fixed the stale identity; the old verifier was not weakened.

The initial threaded prototype was corrected before parallel measurement: the
existing guard discovers children launched by the main OS thread. A further audit
restricted payloads to tools that keep descendants in the job's process group;
native build adapters run directly under the outer guard. Historical failed harness
receipts are retained; the very first threaded harness source revision was not
captured, so that interrupted implementation has no exact replay claim.

To stay within disk limits, 45 previously exact QBE copies were independently
verified and hardlinked to their existing oracle products, recovering 23.49MiB.
Every path and byte remains present; both aliases must stay immutable. Separately,
future small source manifests retain only relevant parent source-map entries:
3,044,736→63,311 bytes with identical generated source and declaration inventory.
This is experimental metadata reduction, **not** emitted compiler IR reduction.
Retained large source manifests are explicitly labeled derived provenance
summaries; measured reports/logs and small source snapshots remain exact.

## Recommendation

Use two to four workers for independent cheap screens and keep final timing
isolated. Inspect actual private-worker admission **before** paying for a larger
transfer test. Keep these small, source-connected probes rather than automatically
running the whole compiler after each idea.

Next, select a more costly semantic traversal using current inclusive evidence,
then test whether a single verified recursive region removes its generic
continuations. The single-loop result justifies that experiment; it does not yet
justify manually rewriting every walker or adding a new global optimization pass.
The 10× direction is automatic fusion of useful recursive regions. The 100×
direction is reusable checked semantic units that avoid repeated reconstruction.
Both need a measured whole-request cost ceiling before implementation.
