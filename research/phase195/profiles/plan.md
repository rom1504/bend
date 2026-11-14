# Fresh Phase194 physical profiles for Phase195

Use the maintained `selfhost/tools/profiler/plan-runtime.py` and existing
all-thread sampler, without compiler builds, runtime relinks or privileged
changes. `selfhost/tests/phase195/profiles/prepare.py` only prepares metadata.
Both frozen recipes passed maintained `run.py --check-only`; no targets ran
during preparation.

`candidate` is the qualified Phase194 N2 `native45-02` product. `c` and `qbe`
are exactly the retained products in Phase194 `references01`, not newly built
references. The authoritative merged manifest is Phase194
`runtime-plan01/manifest.json`, calibrated by final `runtime02/report.json`.
Preparation checks selected native acquisition/oracle bindings and exact
reference products, then the maintained planner revalidates all manifest,
calibration, sampler, command and independent output/count identities.

| Batch | Cases, all with candidate/C/QBE | Processes | Expected target CPU | Guard / disk |
| --- | --- | ---: | ---: | ---: |
| priority | active-ray64 (`variation-ray-active-64-2440`), editdist | 18 | 57.61 s | 120 s / 128 MiB |
| remaining, optional | tree-bitonic, test-map-set-ops, lexer | 27 | 86.40 s | 180 s / 128 MiB |

Each case-role has one clean process and two sampled processes, at 8 and 13 ms,
calibrated to 3.2 CPU seconds each and approximately 646 pooled samples. Expected
combined target CPU is 144 seconds; allow roughly three minutes including
analysis, subject to actual load. Combined hard wall limits are five minutes.
Each guard uses CPU3, 2 GiB RSS, 16 GiB available-memory admission, and the default
5 GiB free-disk reserve. Each individual process has a nine-second timeout.
Metadata preparation does not reserve disk. Expected capture files are modest;
128 MiB per batch is the explicit whole-run ceiling, not a measured estimate.

Exact guarded argv, offline compare/render argv and successful retention-close
argv are stored in:

- `selfhost/build/phase195/profile-priority-plan01/execution.json`
- `selfhost/build/phase195/profile-remaining-plan01/execution.json`

Execute `captureCommand` directly on root's lane; do not nest it in another
guard. The execution receipt only shortens the generic planner's outer timeout
to 120/180 seconds; it does not change the frozen workload or quality policy.
Use `closeOnSuccess` only after success; classify failed jobs as failed. Run the
priority batch first and admit the optional batch against current time/disk.
Reproduction preparation, with fresh output paths, uses:

```sh
python3 -B selfhost/tests/phase195/profiles/prepare.py --batch priority
python3 -B selfhost/tests/phase195/profiles/prepare.py --batch remaining
```

The independent stdout contract checks the exact catalog result and exact
warmup/repetition lines, followed by the wrapper's elapsed integer line; stderr
must be empty. Four warmups are preserved. Per-role counts differ intentionally:
active-ray64 candidate/C/QBE 11442/29435/30988; editdist 1357/3720/2948;
tree-bitonic 6092/19286/8064; map/set 104526/307092/126737;
lexer 2938/8221/3926. Each case-role has a distinct workload identity, so the
comparator must produce zero cross-role total-process comparisons.

After capture, the small offline adapter reuses the maintained comparator and
checks each denominator against the frozen command:

```sh
python3 -B selfhost/tests/phase195/profiles/normalize.py --plan selfhost/build/phase195/profile-priority-plan01/plan.json --report selfhost/build/phase195/profile-priority01/report.json --out selfhost/build/phase195/profile-priority-plan01/per-invocation.json
```

Substitute `remaining` for the optional batch. Clean CPU and each admitted
physical leaf/group CPU estimate are divided by that role's repetitions and
reported in microseconds per invocation. This includes startup, warmups and
output. It is descriptive physical attribution, not an independently paired
runtime speedup or inclusive source ownership. `WL_FID_*` can hold generated C
work; generic scheduler-name categories must not be mistaken for overhead.

Retain at least 500 pooled samples, both periods, complete unchanged exact
outputs, zero loss/overruns and adequate thread/whole-child CPU coverage.
Individual 3.2-second captures will usually be below 500 samples: retain those
individual flags while using the maintained pooling policy. Record rejected
captures, unknown weighted shares and sampled/clean ratios; do not lower
thresholds. The comparator retains unknown samples in denominators and does
not enforce zero unknowns. An additional historical zero-unknown rule can fail
even when the generic pool is adequate. No dynamic calls, allocation events,
hardware instructions or confidence intervals are inferred from sample counts.

Prior environment observations in `selfhost/tests/phase185/PROFILE-LOOP.md`
record `/usr/bin/perf`, `perf_event_paranoid=3`, and zero effective capabilities
(no CAP_PERFMON/CAP_SYS_ADMIN). Treat hardware/software perf events as unavailable
on that evidence; no new permission probe or privilege changes were attempted.
The signal sampler remains usable without perf-event access.

## Admission retry

The first priority guard refused disk admission before dispatch: available
headroom above the 5 GiB reserve was below its 128 MiB budget. Preserve that
receipt and original `execution.json`. Fresh `execution02.json` uses
`profile-priority02`/`profile-priority02-guard`, the identical immutable workload
manifest and 120-second ceiling, with a 64 MiB whole-run disk bound. Its offline
outputs are `comparison02.json`/`summary02.md`. This reduced bound is supported
by measured retained footprints: the comparable eighteen-process Phase191
capture occupies 2,158,592 allocated bytes, and the larger-output Phase193
compiler capture 10,690,560 bytes, each with a 16,384-byte guard directory.
These observations support a bounded retry, not a guarantee of future growth.
The free-disk reserve and all output/profile gates are unchanged. For offline
normalization use the original plan with the new `profile-priority02/report.json`.
