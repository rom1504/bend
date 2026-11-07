# Phase175 full candidate: parser lookahead plus report-name membership

This is a **source-only proposal**, pending the combined frontend screen. The
installed Phase171 compiler and maintained source are unchanged. Use the separate
[`full-prepare.py`](../../selfhost/tests/phase175/full-prepare.py); the active
frontend composer is not modified.

The fixed composition replaces only `f_grow_base`, `f_grow_existing` and
`dr_own_names`, adding their measured lookahead/report helpers and forward laws.
It excludes precedence, publication, field-erasure experiments and diagnostic
frontend mains. The original native QBE main and every canonical declaration
remain present. There is no source pruning or declaration-closure selection.

Metadata inspection at `selfhost/build/phase175/full-source-inspection01` yields:

- Source: 3,163,584 bytes, SHA256
  `a0e953a84de73aa22403dde7ec2144540197633857a0f7b5b9784f9e66f5ad04`.
- 8,461 declarations: 8,442 original declarations, three replacements and 19 new
  helper declarations. Zero original declarations removed.
- All 112 protected normalized declarations unchanged; original native main exact.
- The recorded inverse of actual output spans reconstructs the complete
  3,161,409-byte `74cd7de3…` parent exactly.
- Replacement signatures preserve all lexical type/quantity tokens. Whitespace
  and the original optional trailing parameter comma are ignored by that check;
  measured overlay text is retained verbatim. The first stricter metadata attempt
  rejected those harmless formatting differences before creating output.

The output includes source/export pins, exact input pins, operation spans and
original replacement blocks. It is not a source-check or native qualification.

```sh
python3 -B selfhost/tests/phase175/full-prepare.py \
  --out selfhost/build/phase175/full-source01
```

Default exports are `main`; explicit `--export` roots may be recorded for later
checking, but never prune the full source or replace its main.

## Minimum native-first qualification

Use the existing bounded execution lane and fresh paths. No maintained source,
assets, installed selection or release metadata needs changing for these tests.
Only proceed beyond the existing small exact-value gates if the combined
frontend screen supports a full image.

1. **Independent full source check without JS emission.** Use
   [`full-check.mjs`](../../selfhost/tests/phase175/full-check.mjs), which calls the
   same unmodified upstream `book_load`, `book_valid` and zero-hole gates used by
   maintained `stage0-library.mjs`, then stops before compiler emission. It pins
   the exact candidate and composition receipt, Bun, clean upstream revision,
   language/Base files and actual import closure, and verifies inputs again at
   completion. It does not import `comp.ts` or run the candidate.

   The initial CLI `main.ts --check-only` recipe was wrong for this purpose. Its
   retained 7.936s run reached `cli_verdict` and refused 7,195 declarations relying
   on unsafe/foreign code. In this upstream version `--check-only` combines source
   validation with a **proof-safety** requirement. That verdict is distinct from
   a type error; keep the failed CLI receipt at
   `selfhost/build/phase175/full-source-check01-guard`. Do not suppress that verdict
   or present unsafe code as proved. The explicit adapter reports source acceptance
   under existing assumptions, `proofSafetyAssessed:false` and `kernelChecked:false`.

   The failed CLI peaked at 1,069,711,360 bytes (~1.00GiB); historical full B1 API
   acquisition took 14.443s and ~2.12GiB including emission. Retain the 90s, 3GiB
   RSS, 16GiB available-memory floor and 32MiB disk bound for the corrected gate.
   No B1 API or JS self-bootstrap is needed.

   ```text
   selfhost/.assets/bin/bun selfhost/tests/phase175/full-check.mjs --source selfhost/build/phase175/full-source01/compiler.bend --out selfhost/build/phase175/full-source-check02
   ```

2. **Installed native → N1.** Existing assets authenticate the qualified parent
   (`qbe-n2`, actual stage N2), prepared Base, provider/runtime and machine tools.
   The maintained builder emits a fresh N1 binding in its report. Retain QBE for
   actual-generation comparison; budget about 256MiB artifacts and 300s guarded.

   ```sh
   python3 -B selfhost/tools/build/native.py \
     --assets selfhost/manifests/assets-native.json \
     --image-key qbe-n2 --host native --stage N2 --target qbe --mode cache \
     --source selfhost/build/phase175/full-source01/compiler.bend \
     --out selfhost/build/phase175/full-native-n1 --seconds 280 \
     --retain-ir --output-stage N1
   ```

3. **N1 → N2 on that same source, with an exact QBE oracle.** This is also a
   useful controlled compiler-speed comparison: the N1 and N2 acquisition jobs
   use identical candidate input/source paths and tools, but different executing
   compiler versions. Keep this changing-source self-build experiment separate
   from the historical frozen-source metric.

   ```sh
   python3 -B selfhost/tools/build/native.py \
     --assets selfhost/manifests/assets-native.json \
     --image selfhost/build/phase175/full-native-n1/program \
     --image-receipt selfhost/build/phase175/full-native-n1/report.json \
     --host native --stage N1 --target qbe --mode cache \
     --source selfhost/build/phase175/full-source01/compiler.bend \
     --expected selfhost/build/phase175/full-native-n1/program.ssa \
     --out selfhost/build/phase175/full-native-n2 --seconds 280 \
     --retain-ir --output-stage N2
   ```

4. **Execute N2 to produce Q3, without another machine build.** The maintained
   `request.py` command uses the same source, explicit N2 image/report, native
   stage N2 and cache mode; set `--expected full-native-n2/program.ssa` and a fresh
   `--out full-native-q3`. Require the complete request's exact QBE, unchanged
   input pins and successful process. Do not infer this execution from N1/N2
   product equality. Compare assembly/object separately; final ELF differences
   require precise metadata audit, never broad normalization.

5. **Native64 and unchanged generated programs.** The existing catalog already
   includes independent output and refusal oracles. Phase174 native64 took
   66.81s; use a 180s outer guard and at least 64MiB disk budget initially.

   ```sh
   python3 -B selfhost/tools/build/qualification.py \
     --assets selfhost/manifests/assets-native.json \
     --image selfhost/build/phase175/full-native-n2/program \
     --image-receipt selfhost/build/phase175/full-native-n2/report.json \
     --host native --stage N2 --target qbe --mode cache --suite all \
     --seconds 30 --build-seconds 30 --execute-seconds 10 \
     --out selfhost/build/phase175/full-native64
   ```

   If an early acquisition is doubtful, focused19 on N1 is an optional cheap
   rejection gate before N2; it does not replace final native64. Reuse the
   existing `selfhost/tests/phase170/reemit-products.py` on N2 with the Phase169
   six/remaining timed-product receipts. It verifies all45 exact wrapper QBE
   products against their independent frozen outputs, with unchanged runtime and
   machine policy. Exact products justify carrying the existing runtime result
   for those products; they are not a fresh speed measurement. Rebuild/time only
   changed products or a deliberately selected independent performance screen.

## Preserve the frozen complete-cold comparison

The historical fixed input is **not** the 74cd current source or this new
candidate. It is:

- `selfhost/build/phase170/source-final/compiler.bend`, 3,150,535 bytes,
  SHA256 `434edd1d56128f9480800573abf8a0ae21d910a547837af089f25cd1d0e89b71`.
- Exact QBE oracle `selfhost/build/phase170/native-chain-final/n2/program.ssa`,
  97,488,970 bytes, SHA256
  `661b62664acdac83d12bc3192b5f9113a2bb946dd331433e64ca0452f6f83850`.

Run `native.py` twice on that exact input/path: installed `qbe-n2` versus the
explicit new N2/report, both `--host native --stage N2 --target qbe --mode cache`,
both with that exact `--expected` oracle, separate fresh output roots and the
same CPU3/runtime/toolchain. Retained IR is unnecessary for this pair because
`--expected` checks the full streamed output; this keeps each disk budget near
128MiB. The complete build includes the compiler/QBE overlap plus assembly/link.
Use the actual new pair for a speed claim. Phase174's historical 188.395s is
context, not a fresh control. No filesystem-cache flush or hidden cache reuse.

The minimum complete evidence is therefore an independent source check, actual
native generations, exact frozen QBE and finite native correctness. Expensive
JS B2/B3, hosted45 and C45 are not automatically required for this experimental
native image. A later public multi-target promotion remains a separate decision
with the relevant interface/target gates; these frontend changes are shared.
