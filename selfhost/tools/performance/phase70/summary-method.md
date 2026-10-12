# Final release summary

`summarize-release.py` reads closed evidence and writes one fresh summary. It
does not execute Node, Clang, a compiler, a benchmark, installation or sealing.
Run on CPU0 **after** compiler03 qualification and installed release verification
finish, and before the Phase70 artifact seal:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase70/summarize-release.py \
  --out implementation/phase70/evidence/summary.json
```

The defaults bind source commit `d6d6049`, checked API `386ae358…`, flattened
source `d583e187…` and genuine B2 `d069204f…`. `--source-commit`, `--identity`
and `--compilation` accept explicit overrides of evidence locations; source/API
hash expectations remain fixed to compiler03. Existing outputs are refused.
Missing or inconsistent evidence fails before writing the summary.

The collector checks:

- Frozen source files against the selected checkout, checked B1 validation,
  exact source/API/B2 identities and final installed API/source.
- Candidate native100 goldens, raw31 outcomes and the unchanged JS closure.
  The native paired workflow remains false because seven upstream outcomes
  differ; the summary preserves this separately from candidate100/100.
- All 24 checked C emissions and supporting host/runtime equality that bind
  compiler03 B1 and B2 to the already measured compiler02 executables. Source,
  complete C and actual timed binary identities must join exactly.
- Original six and expanded six runtime cohorts separately; three qualified
  samples per role/family, fixed work and independently recomputed medians.
- Final 27 clean TS/B1/B2 requests plus two Base preparations, complete C
  equality, guarded completion and independently recomputed medians.
- Fresh B2 own-source type acceptance, expected unsafe proof-trust refusal,
  exact B2/B3 reproduction and release42/24/5 plus six successful guarded jobs.

Final receipt locations default to `compiler03-C-identity12-v2-summary.json`,
`compiler03-compilation01-summary.json`, `compiler03-release-qualification/`
and `release-compiler03/` under `selfhost/build/phase70/`. Both runtime reports
retain their original compiler02 paths and attribution. This is not a new
runtime measurement or a full-language conformance claim.

The JSON uses repository-relative evidence paths and SHA-256/size pins. Every
verified input is rehashed before the only output write. Raw input files remain
unchanged. On replay, restore the Phase70 capsule and referenced earlier
capsules first; toolchain files and Git source history remain external inputs.
