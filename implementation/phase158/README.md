# Phase158 — reproducing bendc’s published self-compilation

We reproduced the historical compiler emitting its own C **byte-for-byte**.
On this Xeon, emission takes **4.48s best / 4.50s median** without checking,
and **8.76s best / 8.81s median** with checking. This supports the reported
few-second compiler-execution result. It does not reproduce the absolute M4 Pro
times or the AArch64 native-build result.

[Metrics](metrics.json) · [Cost](cost.json) ·
[Reproduction](../../experiments/phase158/README.md) ·
[Published-method audit](../../experiments/phase158/published-method.md) ·
[Independent audit](../../experiments/phase158/independent-plan.md) ·
[Design](../../design/phase158/README.md) · [Evidence](evidence/capsule.json).

## Comparable operation, different hardware

The table first appeared in [bendc 9c54842e](https://github.com/Lulzx/bendc/blob/9c54842eb5756803af599583ca49870d1e09186a/README.md).
We use that exact source, committed C seed and runtime, with its installer’s
Bend2.0.32 Base/effects. No source normalization or ABI adapter is needed.
The newer October source used in Phase157 is substantially larger; it is not
substituted for this historical workload.

| Operation | Published M4 Pro | Local Xeon, one worker, best / median | Samples |
|---|---:|---:|---:|
| C-built compiler emits its own C | 2.13s; checking flag unspecified | 4.484 / 4.499s **without checking** | 9 |
| C-built compiler checks its source | 1.95s | 5.023 / 5.044s | 5 |
| C-built compiler checks then emits C | No unambiguous separate figure | 8.764 / 8.810s | 9 |
| AArch64-built compiler emits its own C | 2.55s | Not measured | — |
| AArch64-built compiler checks its source | 2.54s | Not measured | — |

Local hardware is Intel Xeon E3-1245 V2 @3.40GHz, four physical cores/eight
logical CPUs. Serial runs use CPU3; GPU is disabled. Each sample starts a fresh
process, uses the same executable and inputs, writes the complete result to a
regular file, then compares it outside the timed interval. Modes alternate
order. Filesystem caches are not flushed. These are process times, not an
uncached source-to-machine build. All individual times, CPU use and RSS are
retained; no hardware-normalized ratio or confidence interval is claimed.

The publication uses best-of-nine emission and best-of-five checking under
shared M4 load8–21, but supplies no complete command, executable hash or raw
sample receipt. Its Makefile and bootstrap explicitly use `--no-check` and
`BEND_NO_FREE=1`; the table itself does not specify that flag. We therefore
measure both boundaries rather than assert that its 2.13s omitted checking.

## Checking and self-reproduction evidence

Every emission in the two pilots and both measured cohorts matches the entire
2,802,777-byte committed seed, SHA256
`039673e7cd0a3f8534b30b44af6256b1e957e473814a6337b43e4ba687e90db2`.
That is 25 complete C comparisons. No output normalization is used. All 33
measured calls pass their stated gates; two pilots also pass.

An independent upstream2.0.32 checker, run from authenticated TypeScript source
with pinned Bun, reports the same 24 definitions relying on foreign or unsafe
code as bendc. Both check-only routes return1 and produce exactly the same
392-byte diagnostic; ordinary checked emission succeeds. The expected
foreign/unsafe report is retained and explicitly admitted as a differential
checker result. It is **not** a proof that all definitions are safe, an
independent BendTT acceptance, or full compiler correctness.

The seed executable is acquired from the public C with Clang `-O2 -w`. That
one-time construction takes60.642s and is outside the emission measurements.
We do not build another identical C copy merely to retest these timings.
Exact C reproduction is narrower than a complete independently bootstrapped
compiler qualification or diverse double-compilation.

## More workers did not help here

The published command leaves worker selection unspecified. bendc’s runtime
default is the host CPU count, so a second cohort explicitly uses eight workers
and all eight logical CPUs. It remains a separate five-round observation:

| Operation | Best / median wall | Median total CPU | Max RSS |
|---|---:|---:|---:|
| One-worker check | 5.023 / 5.044s | 5.043s | 632MiB |
| Eight-worker check | 5.018 / 5.062s | 22.837s | 671MiB |
| One-worker checked emission | 8.764 / 8.810s | 8.809s | 685MiB |
| Eight-worker checked emission | 9.517 / 9.635s | 36.471s | 729MiB |

Checking has a real fork in `Chk.VJob.all.go`, while no-check emission bypasses
it. In this cohort eight workers consume substantially more CPU without reducing
wall time; checked emission is9.36% slower by median. The worker pool remains
alive after checking, but we have not isolated whether scheduler activity,
atomic/runtime state, hardware contention or another effect causes the loss.
Do not generalize this result to M4 hardware or all parallel Bend computations.

## What remains unreplicated

bendc’s direct native backend emits AArch64 and cannot run this benchmark on our
x86 host. Thus we do not reproduce its2.55s native-built self-emission, or the
3.5s native source-to-executable claim. The latter and its20s C/Clang comparison
originated in an earlier revision, with a different source size. We also have
not measured the matching full `bendc -o` C build. That command uses reusable
split-runtime objects; our60.642s monolithic seed acquisition is not its20s
measurement and must not be presented as a failed reproduction of it.

No ratio against our approximately250s full QBE self-build is valid here:
compiler source, generated product, checking and machine-construction scopes
all differ. The useful new evidence is that the historical self-emission
operation is reproducible without compatibility patches and genuinely takes
only seconds on this machine. Phase157’s same-workload comparison still matters:
this does not establish that bendc’s architecture wins every compiler workload.

## Cost, failures and next step

Six guarded jobs total301.10s, including seed acquisition, pilots, independent
checking and repeated measurements. One setup attempt mistakenly looked for
TypeScript entry sources in the binary release; it exits in0.065s without
executing the checker. The corrected acquisition uses the exact release-tag
Git sources. Both attempts are preserved. No OOM, timeout or broad self-hosting
campaign occurred. Two bounded agents audited publication history and evidence;
root controlled target execution. All six runs are closed and archived.

To retain the5GiB execution reserve, five previously sealed Phase157 roots were
pruned only through their authenticated archive plans; their evidence remains
restorable. Qualified compilers and seed/vendor inputs remain intact. Phase158
raw outputs and exact inputs are retained in the verified evidence capsule.

The highest-value follow-up is a same-source, same-host comparison of bendc and
upstream emission on this historical compiler, with checking and machine-build
costs separate. An AArch64 machine is needed for its direct-native claim.
Production source and qualified Phase152 selection are unchanged.
