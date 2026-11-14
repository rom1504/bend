# Maintained integration plan — no edits or jobs applied

Scope: frozen branch-facts v2 plus table-calls v3; sqrt is optional and separately qualified. Pool, physical select and cycle copies remain separate decisions. Keep all experimental originals and failed versions as evidence.

## Exact source mapping

| Input | Maintained destination | Action |
| --- | --- | --- |
| `tests/phase195/branch-facts/branch-facts-v2.bend` | `src/back/x86/expression-reuse.bend` | Insert all 48 lines after `x190_v_if`, before `x190_v_plain`; required `X190Values`, write-kill helpers and `x190_v_body` law are already in scope. |
| `tests/phase195/branch-facts/hook.bend` | same | Replace only `x190_v_plain` with its exact frozen declaration. |
| `tests/phase195/float/table-calls-v3.bend` | new `src/back/x86/constant-tables.bend` | Copy only the `x195t_*` declarations. This is exactly the 136-line v2 payload; omit the seven prefixed canonical helper declarations from v3. |
| `tests/phase195/float/table-hook.bend` | `src/back/x86/program.bend` | Replace only `x181_program_private`. |
| manifest | `src/compiler.json` | Add `src/back/x86/constant-tables.bend` immediately before `src/back/x86/program.bend` in `profiles.x86.modules` only. |

The new table module needs this forward interface before its definitions, because the data renderer is defined later in `program.bend`:

```bend
law x181_program_data:
  for data: P111QData
  for +available: KDef
  X181Output
```

Profile-only modules explicitly support laws/definitions in separate additive modules. Do not put the new file in canonical top-level `modules`, and do not append duplicate canonical definitions. `p126i_lookup`, `p126i_present`, `p126i_recognized`, `p126i_calls_walk`, `p126i_calls` and `p126i_table_name` already belong to `src/back/qbe/product-composition.bend`; `p126s_data` belongs to `src/back/qbe/typed-regions.bend`. Existing canonical inventory contains all seven. The x86 dependency closure will now retain them because the x195t declarations reference them.

This route adds about 194 source lines plus one manifest path: 48 branch helpers, approximately two net branch-hook lines, 136 table helpers, four forward-law lines, four net private-hook lines. No whole-program canonical inventory refresh is necessary: only existing profile-module bodies and the explicit profile-module list change. `source.py refresh` concerns the canonical `modules/order` inventory and must not be used to manufacture duplicate table entries. An even smaller file-count alternative is to put table helpers in `program.bend` after `x181_program_data` and move the unchanged private-renderer declaration below them, leaving the manifest unchanged; choose one ownership layout, not both.

Optional sqrt exact integration:

- In `floating.bend`, replace the final `x185_float_call` declaration with all definitions from frozen `sqrt-call.bend`, followed by checked `sqrt-hook-v2.bend`. The copied `x195s_previous` body is the original fallback; do not retain a second `x185_float_call`. Existing F32 publication and probe helpers precede this insertion.
- Add a forward `law x181_label` to `model.bend` with `for n: U32`, `for frame: X181Frame`, result `String`, since the helper body is later in `function.bend`.
- Replace only `x187_encode` in `object-encode.bend` from `sqrt-encoding-hook.bend`.
- No opcode36 admission to `x186_inline_op`, FloatValues, scratch effects or call metadata. No parser override. The experiment covers typed ELF emission and rendered GNU-as routes.

Optional sqrt adds approximately 65 net source lines across three existing files; no additional manifest entry. Preserve exact checked definition bodies; forward-law additions are explicit interface-only differences in the transport audit.

## Metadata and source acceptance

Before changing source, assemble/hash all five non-x86 profiles (`qbe`, `native-c`, `js-api`, `qbe-policy`, `qbe-policy-test`) using `source.maintained_assemble`; retain the full compiler manifest pin. These profiles contain no x86 additive modules and should remain byte-identical. Verify this by assembly after integration, not by assuming isolation. The new x86 reference to existing QBE helpers changes only the x86 closure.

Canonical native source command, from repository root:

```sh
python3 -B selfhost/tools/build/source.py assemble \
  --manifest selfhost/src/compiler.json --root selfhost --profile x86 \
  --out selfhost/build/phase195/selected-source01/compiler.bend \
  --map selfhost/build/phase195/selected-source01/compiler.bend.map.json
```

Create an audit-only manifest copy with `profiles.x86.omitMain=true` and these seven roots: `p88_cache_prepare`, `p86_plan`, `p169np_plan`, `x181_prepared`, `x188_many`, `x188_render`, `x188_assemble`. Assemble its closure and compare normalized declaration bodies against the final checked combined experimental API, excluding controls. Require identical executable definition/type sets and bodies; allow only the explicitly added forward laws above. Each imported canonical table helper must match its original canonical declaration exactly. Reuse the metadata approach in `research/phase194/commutative-integration-audit.py`; do not run that old script unmodified because its paths are fixed to Phase194.

Source acceptance command, root lane only:

```sh
python3 -B selfhost/tests/phase195/job.py --cpu 3 --rss-mib 3072 \
  selected-source-check01 120 48 \
  selfhost/.assets/bin/bun selfhost/tools/build/check-source.mjs \
  --source selfhost/build/phase195/selected-source01/compiler.bend \
  --out selfhost/build/phase195/selected-source-check01
```

Freeze maintained files and compiler.json once source identity is accepted. Fresh checked API preparation must bind this exact source/manifest: a previous API binding may correctly refuse after manifest changes. Do not weaken that check. `source.py verify` only checks historical extraction identity and is not acceptance for intentional edits.

## Qualification path and concrete command templates

`research/phase195/integration-qualification-templates.json` contains eight explicit argv arrays transported from the successful Phase194 plan, with fresh Phase195 output paths and selected-source01. They are **not ready to execute** before final selection/source/assets pins are authenticated. The original pinned Phase194 assets and Phase186 QBE N2 seed remain explicit; no implicit latest image is used.

Sequence: checked combined finite controls and exact hosted development products; N1 image from the pinned QBE N2 compiler; 45 N1 products; N1-to-N2 x86 self-build; N2-to-N3 exact object reproduction; 45 N2 products; exact N1/N2 object and linked-section comparison; native64 and runtime10 finite controls. Preserve hosted-selected versus native development-object identity as in Phase194, compiler request cost checks at both generations, and balanced runtime transfer against frozen Phase194/C/QBE references. Existing Phase194 producer argv and receipts are templates, not new qualification evidence.

`native.py --expected-object N2/program.o` is mandatory for reproduction. Both native45 generations must cover all 45 admitted cases; comparison must retain all 45 objects/135 linked sections. Runtime summary keeps regressions and reference provenance. All target steps use one outer Phase195 guard, unchanged disk reserve and CPU3 admission; no nested guards, deployment or installed-image change is part of this plan.
