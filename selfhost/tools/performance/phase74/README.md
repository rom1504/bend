# Compilation-parity investigation methods

These tools analyze Phase73; they do not implement or install an optimization.
Read [the report](../../../../implementation/phase74/README.md) and its limits.

- `prepare-compilation.py` derives the immutable-image/oracle plan using the
  Phase73 preparer with a new Phase74 output root; `derivation.json` records it.
- Phase70 `methods/compilation/run.py --group prepare` owns Base preparation.
- `run.py --plan PLAN --out NEW_DIRECTORY` executes54 first/warm requests,
  one guarded CPU3 process at a time. `request-warm-v1.mjs` preserves the actual
  warm method; `request.mjs` adds the later diagnostic-start hook.
- `counters-v2.py --plan PLAN --out NEW_DIRECTORY` derives an unshipped counter
  image and isolated driver/cache project. Prepare its plan with the same
  Phase70 runner; run `run.py --plan DERIVED_PLAN --out NEW_DIRECTORY --override
  DERIVED_API` for three exact-output requests. Original `counters.py` remains
  as an unmeasured rejected ABI-reader attempt.
- `analyze.py` reads retained reports and emits the committed measurements.
  Its C graph scan is diagnostic and cannot authorize deletion of code.

[Evidence manifest](evidence/manifest.json) verifies all297 raw files in
`evidence/investigation.zip` (SHA256
`746314eda298709ef5338577388328362016d67deeff7865203c32d048c22b29`).
Extract at the repository root to reconstruct the Phase74 raw paths. Absolute
paths in receipts describe this machine; a new machine needs a freshly prepared
plan and the separately preserved parent Phase73/upstream inputs. The archive
contains both diagnostic image derivatives and every prepared project/cache,
guard log, plan and request report. The images are measurement instruments,
not compiler releases. Original raw paths are closed after this archive.

The source compiler was never changed. All57 requests reproduce complete C;
all prepared cache hashes and all original warm-method hashes were audited.
No Clang or generated-program timing was needed because no new C was produced.
