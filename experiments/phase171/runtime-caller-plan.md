# Targeted runtime caller capture: prepared, not executed

2026-11-06. Offline CFI preparation found substantial supported coverage in the
retained `candidate-profile-products01/program`. Root owns sampler compilation,
the small Map control and any subsequent full capture. No target ran during this
preparation; no compiler image or runtime is rebuilt or changed.

The existing maintained `unwind.py` admits **378 constant rsp-relative rules**
covering all **16,502 bytes across 30 selected runtime symbols**. No partial mode
was used; zero bytes/rules were skipped. Comparing these exact address ranges
with the prior same-ELF profile finds **2,264/5,358 samples (42.2546%)** eligible
for the new one-frame read. This is an eligibility screen, not recovered callers.

Largest previously sampled ranges: `term_drop`609, `span_fade`362,
`p125_rt_take2`224, `p111_rt_sink`195, `ctr_take`124,
`p111_rt_special_ctor`121, `p118_rt_extend1`106, `p125_rt_take4`96,
`heap_alloc`90, `term_triv`85 and `p111_rt_keep`78. Exact symbols, bounds and
weighted coverage are in `runtime-callers-prep01/coverage.json`. The new table
targets the current executable, replacing the earlier libc-only table; the
earlier 227 libc→`p111_set_regs` observations remain separate evidence.

One physical caller may still be a runtime helper, including a recursive/runtime
intermediate. Tail-erased calls cannot be recovered. Report those categories and
unknowns rather than labeling every caller an inclusive compiler owner. No
second frame or heuristic stack scan is implemented.

## Immutable bindings

- Retained diagnostic ELF SHA256:
  `a61dfe42bfb5e6dd3abd8d16cf96179fbde682e6317eae6ed6f803050b64cfc7`.
- New CFI table ID:
  `35a27bea8c39c130c1612f5ec7d00146ce8eb55c36f91d2d56c83a83214ee5ea`.
- Sampler source is byte-identical to the earlier stage sampler, including
  `bend_sample_delivered_count`; only its compiled CFI header changes.
- The unchanged executable embeds the **original** stage-spec hash. Keep
  `candidate-profile-prep01/spec.json` unchanged. The additive observer binds
  the new caller table separately and reuses unchanged stage/FID/order/ordinal
  validation. It never relabels the embedded stage hash.

Prepared inputs occupy about120KB under
`selfhost/build/phase171/runtime-callers-prep01/`. Products and guard/report roots
remain fresh. The method is
`experiments/phase171/tools/runtime-callers.py`; prior methods are untouched.

## Root-owned execution sequence

All compiler/sampler targets below require the usual serial CPU3 resource guard.
Declare the fresh products and report roots; retain the 5GiB reserve. Suggested
build budget: 60s, 512MiB RSS, 16MiB disk. The existing guarded build wrapper
creates the fresh products directory before invoking the maintained builder.

```sh
python3 -B experiments/phase171/tools/profile-v2.py build \
  --plan selfhost/build/phase171/runtime-callers-prep01/build-plan.json \
  --out selfhost/build/phase171/runtime-callers-build01

python3 -B experiments/phase171/tools/runtime-callers.py manifests \
  --prep selfhost/build/phase171/runtime-callers-prep01 \
  --build-report selfhost/build/phase171/runtime-callers-build01/report.json \
  --out selfhost/build/phase171/runtime-callers-manifests01
```

The second command is metadata-only and requires a successful exact build
receipt. It freezes both pilot and full recipes. Each uses the same retained
candidate executable, unchanged Base/cache/stamp, independent complete QBE
stdout and empty-stderr oracle. Full source is the original Phase170 S0, not a
smaller extracted compiler closure.

Pilot before full:

```sh
python3 -B selfhost/tools/profiler/run.py \
  --manifest selfhost/build/phase171/runtime-callers-manifests01/pilot-manifest.json \
  --modes sample --rounds 1 --periods-us 1000 \
  --out selfhost/build/phase171/runtime-callers-pilot01

python3 -B experiments/phase171/tools/runtime-callers.py observe \
  --prep selfhost/build/phase171/runtime-callers-prep01 \
  --run selfhost/build/phase171/runtime-callers-pilot01/report.json \
  --out selfhost/build/phase171/runtime-callers-pilot-stages01.json
```

Require exact output, stage order/FID/ordinal binding, valid caller-table pairing,
zero loss and plausible one-frame recovery before considering the full sample.
The observer is metadata-only. Caller coverage is explicit; a small pilot's
stage distributions may remain below the per-interval resolution threshold.

If that gate passes, use `full-manifest.json`, sample mode, one round and
`--periods-us 32000`, with a fresh `runtime-callers-full01` root. Its target
deadline is190s; allow guard overhead for symbolization/output verification.
Suggested full guard limits: 2GiB RSS and160MiB disk, with the actual whole-run
deadline selected by root. Run the same observer on the completed full report.
Close each run through the retention workflow. This diagnostic is not a new
clean compiler-speed measurement or a claim of removable runtime cost.
