The native backend now normalizes each unchanged telescope once per nonempty step and indexes the selected annotated definitions once before merging them into the full type context. These changes are in Bend. They preserve the existing native C output; they do not change the generated program's runtime or claim a measured whole-compiler speedup.

`nc_tele_fill`, `nc_live_count`, and `nc_erase_args` reuse the same weak-head-normalized telescope for quantity, binder, and body access. Argument erasure and telescope substitution remain in their original evaluation order. The context merge retains the first matching annotation, including an `Absent` definition that shadows later duplicates, and performs one lookup per original definition. The final context still uses the original maximum-binder calculation and cache construction.

The isolated gate passed **165 exact helper/context comparisons** and **three checked source-to-C byte comparisons**. Cases cover empty and partial telescopes, reference aliases, mixed erased/live quantities, dependent substitution, duplicate and empty names, cached inputs, and cache markers after a raw prefix. The three source fixtures cover identity, an erased dependent type argument, and a two-field constructor match. They pass loading, type checking, ownership, TODO, specialization, and emission gates before comparison. Test APIs expose existing generated workers; instrumentation runs on separate copies and does not affect timing samples.

One first-overlay bug was caught before promotion. Re-indexing an annotation list containing a `BookCache` marker after a raw prefix could expose the reserved `$kernel.cache` name as an ordinary definition. The corrected implementation scans for a marker anywhere and retains legacy lookup for such lists. [The rejected attempt](evidence/native-context-rejected-overlay.json) remains explicit; its passing ordinary cases are not substituted for the final edge gate.

On CPU 2 with Node 24.18.0, 4 MiB stack and 4 GiB heap, a 16-argument telescope reduced `wnf` calls from 32 to 16 for fill/live-count and from 58 to 26 for erasure, including nested argument work. Three alternating clean-API samples of synthetic reversed annotation lists produced:

| Definitions | Recursive lookup calls, before → after | Median merge time, before → after |
| --- | --- | --- |
| 64 | 4,160 → 64 | 12.33 → 9.99 ms |
| 256 | 65,792 → 256 | 123.15 → 40.35 ms |
| 1,024 | 1,049,600 → 1,024 | 1,692.69 → 85.78 ms |

These are synthetic context-merge measurements, including index construction, and not full checked compilation workloads. The synthetic definition records isolate lookup scaling; the independent three source fixtures supply checked native-output correctness evidence. Remaining normalization, substitution, indexing and emission work is not eliminated. No native executable runtime improvement is inferred from these measurements.

[The differential evidence](evidence/native-context.json) records every case, output hash, raw timing sample, counter, tool/API/Node identity, and unchanged-input verification. [Overlay provenance](evidence/native-context-overlay.json) records the two changed modules and unchanged declaration relocation: the checked baseline had moved `FLoadTrace` into its dependency module, while the isolated overlay retained its identical earlier declaration. The production integration uses the relocated declaration.

To repeat the gate from `selfhost`, provide two checked upstream-emitted compiler APIs exposing the generated workers, and a fresh output directory:

```sh
taskset -c 2 /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --stack-size=4096 --max-old-space-size=4096 \
  tools/performance/rapid/native-context.test.mjs \
  BASELINE_API.mjs CANDIDATE_API.mjs NEW_OUTPUT_DIRECTORY --measure
```

The test reads the current native runtime source and hashes it with both APIs and its own source. Reproduction on another machine should choose an available isolated core and record its resource settings. Full compiler and native executable coverage remain separate integration gates.

The production integration was rebuilt from a fresh frozen assembly and passed the same 165 comparisons and three exact C outputs. Its checked API SHA-256 is `8787894920cc8959ab0abec28ddae0ea0dc05ad7665dc6f4d43f845445e60923`. [The integration build report](evidence/native-context-integration-build.json) records clean pinned upstream inputs and unchanged consumed hashes. The ordinary bootstrap child launch returned `spawnSync node EPERM`; the equivalent load/type/ownership/closed-book/library gates were therefore invoked explicitly in one process. This is a distinct checked-build report, not a fabricated bootstrap sidecar. [Integration validation](evidence/native-context-integration-validation.json) confirms the final assembled API retains the native outputs.

The integration builder reads the prior bootstrap metadata for its module list
and export names. That metadata file itself was not included among its
before/after drift-checked inputs; the report does record the actual module
hashes and export list. Do not interpret the report as stronger provenance than
that. The archived builder is a snapshot from its original build directory,
not a standalone launcher at its archive path.
