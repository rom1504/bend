# Preserve unrelated local-word facts across calls

This optional experiment preserves existing copy aliases and zero-upper-word
facts across a call, killing every explicit result with `known=False`. It does
not remember loads, infer return widths, move calls, propagate through `Again`,
or relax the existing expression/memory CSE pass. It composes with branch-facts
v2 through one replacement, `x190_v_plain`. Source acceptance and machine
observations are pending; no speedup is claimed.

## Why the transfer is sound within the existing IR contract

The frozen Phase194 source `selected-source02/compiler.bend` defines
`N111Value` at line 20093 and `N111Stmt` at line 20103. Values are machine words:
locals, literals, symbol addresses and IDs. There is no operation taking the
address of a scalar local's compiler home. `N111Alloca` denotes a separate
buffer, and its local value is the buffer address. A callee may change valid
pointed-to memory; that does not change the caller's saved pointer word or any
previously loaded word. This relies on the existing valid-IR and ABI contracts,
including bounded buffer accesses and preservation of caller-owned homes.

The implementation agrees with those semantics. `x181_frame` (line 34828)
allocates local homes, scratch, outgoing result storage and tail staging
separately. `x181_call_text` (line 35346) passes evaluated values. The ordinary
scalar call path in `x185_float_call` (line 35069) stores its return only into
the explicit destination. `x181_call` and `x181_load_results` (lines 39990 and
40002) use separate result storage and copy returned words only into the
listed destinations. The existing `p113l_base_scalar`/`p113k` fact transfer
also preserves facts for other locals across calls; that is corroboration,
not a substitute for the memory/address argument.

`X190Values` contains only flattened copy aliases and zero32 facts. For a call
with result names D, the new transfer applies `x190_v_written(d,False{},...)`
for every d in D. This removes the alias named d, aliases whose source is d,
and any positive width fact for d. All other represented values are unchanged.
An old snapshot may still be canonical even when its source is overwritten;
keeping the snapshot's own width fact is valid. Call arguments are substituted
using the incoming state, before results are killed. Original snapshot
assignments and effects remain, and the existing dead-assignment pass may
remove assignments only after their uses have been rewritten.

No conclusion about memory equality follows: a subsequent `N111Load` still
executes and establishes its destination through the original transfer.
`x186_expression_body` is unchanged. The branch-v2 join scanner still clears
all incoming facts for a call in either arm, so this version deliberately does
not recover facts through such a join. `Result`, `Return`, and `Again` retain
their existing resets. Register allocation runs after substitution and must
handle any extended source lifetime and call clobbers normally.

## Files and acquisition

The new files are in `selfhost/tests/phase195/call-facts/`:

- `call-facts-v1.bend`: call-result kill helper and scalar-call wrapper.
- `hook-v1.bend`: branch-composed `x190_v_plain`, intercepting scalar and
  multiple-result calls only.
- `controls-v1.bend`, `controls-v1.c`, `driver-v1.mjs`: focused checked-API
  controls and the existing guarded direct/rendered machine transport.

Prepare metadata with the existing extractor; this command has not been run:

```sh
python3 selfhost/tests/phase190/prepare-api.py \
  --parent-source selfhost/build/phase194/selected-source02/compiler.bend \
  --module selfhost/tests/phase195/branch-facts/branch-facts-v2.bend \
  --module selfhost/tests/phase195/call-facts/call-facts-v1.bend \
  --module selfhost/tests/phase195/call-facts/hook-v1.bend \
  --module selfhost/tests/phase195/call-facts/controls-v1.bend \
  --replace x190_v_plain \
  --export p195cf_controls --export p195cf_emit \
  --out selfhost/build/phase195/call-facts-api-source01
```

The two explicit exports append to the seven default API roots. Do not also
include the branch-only `hook.bend`, which defines the same replacement.
Root must perform fresh ordinary source checking and checked API acquisition,
then invoke `driver-v1.mjs` with the usual `--api`, `--assets`,
`--source-manifest`, fresh `--out`, and bounded `--seconds` under the existing
CPU3 guard. The driver preserves all authority, pin and independent output
checks from the branch-v3 transport. It requires 12 exact structural rows and
`phase195 call facts controls: checks=1458 failures=0` from each route.

## Adversarial controls and audit

The structural controls cover unrelated aliases and widths, result-source
invalidation, result-destination invalidation, arguments substituted before
result writes, multiple result names, flattened shared aliases, and refusal
to infer zero32 even for a scalar call annotated `N111U32`.

Nine machine callers exercise an opaque C helper that mutates two memory
cells and returns a full-width word. Cases overwrite the ultimate source,
an intermediate alias, or a known-zero32 local; preserve unrelated shared
aliases; retain an unknown-high-word U32 snapshot; conditionally call inside a
branch; and consume two results from a generated callee. That callee uses the
normal multiple-result ABI and calls the same opaque memory-writing helper.
Every caller reloads memory after the call. The independent C arithmetic oracle
checks the return value and all ten state cells for nine-by-nine edge inputs,
both conditions and all nine cases: 1,458 observations per route. Thus both
old local snapshots and fresh memory observations must be correct. Direct and
rendered routes share typed selection and are not independent compilers.

Offline checks passed: strict C syntax (`gcc -fsyntax-only -std=c11 -Wall
-Wextra -Werror`), balanced Bend delimiters, parameter-only match scrutinees,
no local binding before a match, explicit local types, and agreement of all
12 labels, fixture paths and expected check counts with the driver. These are
not Bend acceptance or target execution.

All new closure captures were audited. `x195cf_after_call` captures `names`
and `state` once, only in its enabled closure; the fallback captures neither.
`p195cf_row` captures nothing in either closure. `p195cf_emit_at` uses `mode`
in its guard and recursive closure, and marks it reusable. The scalar wrapper
marks `state` reusable for argument substitution and transfer, and call-result
`name` reusable for reconstruction and killing. The hook marks multiple-result
`names` reusable for the same reason. `p195cf_body` marks its twice-used mode
reusable; the shared control state has an explicit reusable binding. The
branch-v2 closure audit continues to apply unchanged.

## Cheap falsifier and limits on likely benefit

First pass source acceptance and the independent observer. Then compare
ordinary emissions from the identical branch-only and branch-plus-call
compiler variants, including exact output oracles. Inspect the hot ray
`$product.nearest` call-crossing copy before timing. A change in alias facts
without fewer executed copies/loads is not evidence of a runtime benefit;
longer live ranges can increase register pressure. Use the existing small dev
screen before considering any native compiler build.

`static-corridors-v1.json` retains exact frozen preselection pins and first
witnesses per function from a conservative straight-line scan. It finds zero
full-word call-crossing alias-use sites in tree; two in lexer's cold
`$direct.step.at`; one in edit's `$direct.row`, not its hot product row; 46
across five ray functions; and 32 across eight map-churn functions. Map-churn
is a different workload from the sampled map-set case. These are static
opportunities, not dynamic call counts, gate admissions or saved instructions.
The scan omits width facts and incoming branch facts and resets at joins.

Even ray needs caution: the first hot nearest witness crosses `p111_rt_op`
primitive 25, so eliminating that call in another experiment can overlap this
opportunity. Product trace's capture has 592 placement rows, while the value
pass retains its existing 512-row bound at an earlier stage. Pixel's first
witness contains a later `p194fv_*` name. Neither is proof of admission at this
pass. These observations favor a bounded falsification experiment and do not
establish a broad parity-scale optimization.
