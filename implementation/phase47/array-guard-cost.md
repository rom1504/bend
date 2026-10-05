# Array guard cost: bounded ablation

Status: root completed the diagnostic timing; this note recomputes saved data
only. It does not execute targets, alter consumed tools, qualify a compiler,
or claim an installed release. The [compact evidence](evidence/array-guard-cost.json)
records source-report hashes, all 45 samples and their recomputed summaries.

## Experiment and results

Source report: `selfhost/build/phase47/array04-guard-timing01/report.json`.
All 45 results are complete/pass, with five balanced rotated fresh-process
rounds for three variants at three inputs. CPU 3, Node 24.18.0, 1000-ms warmup,
50-ms calibration, 200-ms target; wall time 69.153 s. Each call is checked by the
maintained execute driver against independently produced local-fold oracles:
(128,0)→0, (4096,17)→2339999928, (8192,123)→805701512.

The parent is the checked array04 full local-fold module, SHA256
`939da9e9644487fcc8cef3b34436a529a796adbab352403c4bd2a7af002a5387`.
The producer closes its checked-emission receipt and input identities. The
manifest and timing report record each derivative separately. All variants
retain the public canonical-input checks, localGuard, raw body and old fallback.
Only the array host guard changes.

| Input | Original median us (range) | Integer-only median us (range) | Bypass median us (range) |
| --- | ---: | ---: | ---: |
| 128,0 | 15.879 (15.811–17.494) | 14.075 (13.892–16.101) | 6.235 (6.022–6.385) |
| 4096,17 | 62.061 (61.606–62.583) | 60.348 (59.971–63.534) | 53.055 (52.895–54.200) |
| 8192,123 | 112.390 (112.153–121.384) | 110.355 (109.989–114.777) | 100.829 (99.065–113.168) |

Integer-only saves median 1.805, 1.713, 2.036 us per call respectively. Bypass
saves 9.645, 9.006, 11.561 us. These differences between medians are scoped
ablation observations, not precise exclusive instruction costs or confidence
intervals. The near-constant integer-only saving supports a fixed-entry-cost
component; it does not identify a JIT transformation.

The separate full-corpus batch1 report,
`selfhost/build/phase47/corpus-array04/runtime-1/report.json`, measured
128,0 at 7.705 us baseline versus 16.362 us array04, a 2.124x slowdown and an
8.657 us gap. On 8192,123 it measured 173.065→110.662 us, a 1.564x gain.
The modest roughly 2 us guard narrowing cannot eliminate the short-input loss.
The unsafe complete bypass demonstrates a larger guard-cost opportunity,
but removing admission safety is not a solution. These are separate runs;
do not pool their samples or subtract them as if they were paired measurements.

## Diagnostic safety versus forthcoming implementation

`integer-only` replaces the array guard's full regionHostGuard() with the
existing regionHostGuard(true). This skips unused floating checks on these
specific local-fold programs, but is unsafe as a general admitted-root rule:

- It supplies no complete no-F32 proof. Even an unused F32 public input has a
  canonical-input check calling Math.fround and Number.isNaN.
- The existing integer-fusion hook list excludes Math.floor, while
  j_primitive_u32 emits U32.div using Math.floor. Mutation/reentry through that
  omitted hook would invalidate the closed no-callback proof.

`bypass-array-host` skips the entire array host proof. Public localGuard and
input checks do not establish fill/isSafeInteger or backing-allocation safety.
This derivative is diagnostic only and cannot ship, regardless of its values.

The forthcoming array06 proposal must prove no F32 across canonicalized public
signatures, both relevant planned arms, and collected helper signatures/bodies;
retain Math.floor as well as imul and the remaining integer hooks; and preserve
fresh host admission, allocation/protocol/prototype checks, active-proof refusal,
full source dependencies and the unchanged fallback. A safe hook set is not
identical to this measured unsafe integer-only set, so its time is unmeasured.
At writing, shared runtime source still uses the full guard; no frozen array06
checked artifact or performance result is asserted here. There is no workload
name or iteration threshold proposal.

See [V8/path analysis](v8-analysis.md) for the exact entry branches and
[private-array documentation](../../docs/self_hosted/private-array-regions.md)
for ownership, demand and representation boundaries. Runtime profitability,
semantic safety, compiler cost and release selection remain separate gates.
