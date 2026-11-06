# Phase171 checked API experiments

These files add private experiments to the fixed Phase170 compiler source.
`prepare-api.py` only assembles source and records provenance. It never runs a
compiler. The root execution lane owns checking, measurement and resource guards.
Use fresh output directories for every attempt, including source-check failures.

The assembler verifies the exact 3,150,535-byte parent, checks the maintained
protected declaration hashes, then selects the conservative declaration closure
of the explicit API roots. This smaller API is an experiment harness, not the
full-source compilation benchmark. `--replace NAME` authorizes only that original
definition; unknown or unused names fail. New modules are additive. `--prelude`
inserts new helper laws immediately before their first lexical use, retaining
original type declaration order. The emitted manifest records the original source
map, selected declaration identities, replacement hashes and the authenticated Base
binding. All generated Bend source still requires the normal checker.

For a callable-import source snapshot:

```sh
python3 -B selfhost/tests/phase171/prepare-api.py \
  --module selfhost/tests/phase171/checked-imports.bend \
  --module selfhost/tests/phase171/checked-import-emission.bend \
  --module selfhost/tests/phase171/checked-import-controls.bend \
  --export p171_plan --export p171e_next --export p171_controls \
  --export p171_request --export p171c_summary \
  --out selfhost/build/phase171/import-sourceNN
```

The defaults also export `p88_cache_prepare`, `p86_prepare`, `p86_plan`,
`p169np_plan` and `p134e_next`. A single acquired image can therefore execute
both baseline and additive-import roles. The whole image includes the additive
modules in both roles; neither role changes the original definitions.

Under one root-owned disk/RSS/time guard, the standard checked acquisition is:

```sh
selfhost/.assets/bin/bun selfhost/tools/build/hosted.mjs acquire \
  --source selfhost/build/phase171/import-sourceNN/compiler.bend \
  --exports selfhost/build/phase171/import-sourceNN/exports.json \
  --upstream selfhost/.bootstrap/upstream-phase66 \
  --engine selfhost/.assets/bin/bun \
  --out selfhost/build/phase171/import-apiNN
```

Then run each request in a fresh process under the root's guard:

```sh
selfhost/.assets/bin/bun selfhost/tests/phase171/request.mjs \
  --receipt selfhost/build/phase171/import-apiNN/report.json \
  --assembly selfhost/build/phase171/import-sourceNN/manifest.json \
  --source selfhost/build/phase167/verifier-source03/compiler.bend \
  --mode baseline --out selfhost/build/phase171/verifier-baselineNN
```

`--mode imports` runs the candidate with its own checked cursor intercept;
`--mode import-controls` executes the nine independently expected admission
controls. The latter requires a real imported recursive family: `coverage gap:`
is a failure, never a pass. `recursive-tree.bend` is a small positive workload
with independently derived value `[127, 8128, 8128, 127]` and repeated use of the
original shared tree. Its native printed representation must be checked against
the existing printer convention, not inferred by this transport script.

Two fixed transfer inputs are already available:

| Input | Independent execution gate |
| --- | --- |
| `selfhost/build/phase167/verifier-source03/compiler.bend` (39,333 bytes; SHA256 `ff6b4083aa2f3e034f3b4f8e43dfb25d93a4f524685934e0ee13845278033ef3`) | Exact complete stdout `768\n`: captured real verifier checks valid arithmetic/branch segments and two malformed variants. |
| `selfhost/tools/bench/catalogs/native45/fixtures/coverage-map-churn-128.bend` (3,659 bytes; SHA256 `cd22c831c180c0de12d84aeb80debf4881d08cbd18fcf8f6d634153fba2feb03`) | Native45 full semantic observation via `experiments/phase167/tools/map-oracle.py`; timing fields vary. |

The verifier is a frozen real compiler slice, not a claim that every retained
declaration is the current implementation. The request adapter records these
oracles only when the exact fixture bytes match. It **does not execute** the
generated program. Build the QBE using the maintained native build workflow and
apply the independent output oracle separately. Callable imports may change QBE
bytes; source checking or a successful final verifier alone does not qualify
generated execution or performance.

For fail-fast/lazy-admission/publication overlays, acquire two images with the
same explicit exports and control modules. Add only the selected overlay and
its exact replacement list to the candidate. Keep each experiment separate:

| Overlay | Replacements | Controls/extra options |
| --- | --- | --- |
| `fail-fast.bend` | `p113d_let`, `p113dl_let`, `p113pl_bind_flat`, `p113pl_bind_boxed`, `p113px_boxed`, `p113dm_more`, `p113pm_more`, `p113dm_original_match`, `p113pm_original_match` | Both images: `fail-fast-controls.bend`, exports `p171ff_cases`, `p171ff_scc_controls`. Candidate: `--prelude fail-fast-laws.bend`. |
| `lazy-admission.bend` | `p114r_plan`, `p114g_plan`, `p114h_plan`, `p112c_plan_index` | Both images: `lazy-admission-controls.bend`, export `p171l_case`. |
| `publication-history.bend` | `p156cp_start`, `p156cp_continue` | Both images: `publication-controls.bend`, export `p171s_controls`. |

Paths in the last table are relative to this directory; pass repository-relative
paths to the assembler. Invoke `request.mjs --mode baseline` for each overlay's
normal maintained entry. On the candidate request, add
`--reference BASELINE_REQUEST/report.json` to require **complete byte equality**
of QBE, exact workload path/content and the same prepared Base. This is the cheap
first transfer gate for unchanged-output hypotheses. It is not a standalone
proof for all inputs.

`fail-fast-controls.mjs` and `lazy-admission-controls.mjs` consume the two actual
checked acquisition receipts. Their complete successful records and independent
failure expectations are additional gates; do not replace them with QBE equality
on a single valid program. Request timing is explicitly hosted B1 timing and
includes fresh API/Base/front-end preparation; it is not the qualified native
full-build target. The final native experiment and promotion decisions remain
separate.

For a native candidate compiler, use the separate `prepare-native.py` with the
same `--module`, `--replace` and `--prelude` options. It retains **every** canonical
declaration and the exact original native `main`; it never extracts an API
closure. `--export` only configures the optional checking manifest (default
`main`) and does not affect source selection. The output `report.json` records
every kept/replaced/inserted byte span. Together with `inverse-originals.json`,
these spans recover the original source byte for byte; assembly verifies that
inverse before reporting success. Original replacement signatures and protected
declarations are checked separately. Helper definitions are appended, and helper
laws are inserted immediately before their first lexical use. The ordinary
checker still validates those declaration-order and type assumptions.

Use the installed qualified native compiler to build that full candidate source
only after the smaller checked API gates justify it. Compare the resulting
candidate compiler against the baseline on the **fixed original** source input;
compiling the changed candidate source is a distinct self-build measurement.
The older `prepare-api.py` stays frozen for its already recorded receipts.


The subsequent borrowed-selector and cleanup experiments are closed without
integration. See the [follow-up report](../../../implementation/phase171/followup.md)
and [compact reproduction package](../../../experiments/phase171/descendant-history/README.md).
The root borrowed-selector modules are the original experimental baseline;
`descendant-v15/` is its final tested successor. Intermediate revisions are
reconstructed from authenticated deltas, not additional maintained compilers.
