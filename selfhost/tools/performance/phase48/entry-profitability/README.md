# Entry guard and native String controls

Root alone executes these commands through the serial resource guard. This
owner prepared tools/source fixtures and ran static syntax checks only.

The allocation-free fragment has independent static review approval within the
fresh-array-host-proof boundary. It does not authorize changing other scalarGuard
callers or caching success. Source integration and measured outcome remain open.

```sh
python3 selfhost/tools/performance/phase48/entry-profitability/derive-v1.py \
  selfhost/build/phase47/array06-full/modules/local-fold.mjs \
  selfhost/build/phase48/entry-profitability01

python3 selfhost/tools/performance/phase48/entry-profitability/measure-v1.py \
  selfhost/build/phase48/entry-profitability01 \
  selfhost/build/phase48/entry-profitability01-audit --mode audit

python3 selfhost/tools/performance/phase48/entry-profitability/measure-v1.py \
  selfhost/build/phase48/entry-profitability01 \
  selfhost/build/phase48/entry-profitability01-timing --mode timing
```

Audit: 30-second deadline; 12 ordinary rows, 192 dependency mutations, four
Error/reentry rows. Timing: default points `128-0,4096-17,8192-123`, five rotated
rounds, three variants, 45 fresh jobs; each 1,000-ms warmup, 50-ms calibration,
200-ms target. Rotations use actual point/variant lengths. CPU 3, 1,024-MiB heap,
2,048-MiB process-tree RSS, 4,096-MiB available floor, 15 seconds per job and
240 seconds campaign. `--points` can select one through six prepared configs;
larger sets may hit the unchanged campaign bound and must retain the failure.

Only `original` and `allocation-free` are semantic candidate comparisons;
`unsafe-admission-bypass` supplies an unsafe upper bound. Audit modules contain
counters and never enter timing. A saved-output pass is not a checked-source
qualification. Run maintained Phase47 semantic suites again after source
integration, then measure the actual selected source image.

## Actual native String.append fixture

The root-owned `ir/native-values.bend` contract recognizes only exactly two
already-proved String operands in JWNative String.append, emits `left+right`
with `/* private String.append */`, and preserves other native fallback bytes.
Operand evaluation/order and existing entry host/source guards must stay intact.

Independent files are in `../controls`: `native-values-v1.bend`,
`native-values-catalog-v1.json`, and `native-values-v1.mjs`. The source has renamed
Nat recursion, ordered append helper calls, ASCII/accent/non-BMP literals, two
String consumers, a pair and a custom record. Catalog acquisition uses
`bench(3,17)` → `α🙂α🙂α🙂17é17é17é`; source hash and byte size are explicit.
Runtime cases additionally cover empty strings, combining marks, NULs and lone
surrogates without putting malformed Unicode into the Bend source file.

Set `ATTEMPT` to the checked candidate containing the native-values integration.
Both acquisition directories must be new. The baseline uses selected Phase47
`checked-array06`, which predates the JWNative String.append lowering.

```sh
NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node
CATALOG=selfhost/tools/performance/phase48/controls/native-values-catalog-v1.json
python3 selfhost/tools/performance/programs/prepare.py \
  --attempt selfhost/build/phase47/checked-array06 --role baseline \
  --catalog "$CATALOG" --set full \
  --out selfhost/build/phase48/native-values01-baseline \
  --node "$NODE" --cpu 3 --heap-mib 1024 --rss-mib 2048 \
  --available-mib 4096 --timeout 180
python3 selfhost/tools/performance/programs/prepare.py \
  --attempt "$ATTEMPT" --role candidate --catalog "$CATALOG" --set full \
  --out selfhost/build/phase48/native-values01-candidate \
  --node "$NODE" --cpu 3 --heap-mib 1024 --rss-mib 2048 \
  --available-mib 4096 --timeout 180

# Root schedules this with the same bounded serial execution guard.
"$NODE" --stack-size=4096 --max-old-space-size=1024 \
  selfhost/tools/performance/phase48/controls/native-values-v1.mjs \
  selfhost/build/phase48/native-values01-baseline/modules/native-values-v1.mjs \
  selfhost/build/phase48/native-values01-candidate/modules/native-values-v1.mjs \
  selfhost/build/phase48/native-values01-controls
```

The controller binds checked receipts, API/runtime/Base/source and tool hashes;
writes separate counted modules; requires seven ordinary full-string rows,
1,372 Unicode/consumer complete-value rows, and 18 host/native/ABI boundaries.
Positive ordinary recursion must execute the new private concat marker;
post-import G binding/code/getter/env/bound/arity/call and String/prototype changes
must retain generic behavior, event/error order and proof cleanup. Error reentry
restores the dependency before an independent nested ordinary call; raw/forged
code calls and coercing object input retain old demand behavior. The pair/custom
record checks include every field and compare public constructor representations.

This source has not been parsed/typechecked yet. A failed acquisition or missing
ordinary activation must be preserved and diagnosed; static marker presence is
insufficient. Neither counted modules nor saved guard derivatives can qualify
the real compiler's performance or substitute for maintained semantic gates.

## Current outcome

The first raw guard diagnostic is complete and deferred from production.
The guarded audit passed; 45 clean timing samples show only 1.039× at 128 steps,
0.993× at 4096 and 1.002× at 8192. See
[the measured outcome](../../../../../implementation/phase48/entry-profitability.md)
for ranges and the adverse midpoint. The unsafe bypass remains an upper bound.
No runtime/source patch was promoted. The unexecuted fresh-region v2 derivative
is also deferred pending a reason to expect material improvement.

The independent checked-source String.append controls passed 7 ordinary points,
1372 complete values and 18 boundary controls. The
[native outcome](../../../../../implementation/phase48/native-values.md)
keeps actual Unicode acquisition/execution/timing qualification separate.
`../controls/native-corpus-probe-v1.mjs` is the new root-only three-case probe;
it checks full acquired catalog results and actual ordinary Unicode concat
execution while retaining Morning as a neutral control. It does not time output.

The separate real corpus probe and clean native screen are now complete:
Unicode16/64 execute 178/706 private concats and improve 1.215×/1.520× against
array06; Morning executes zero and is a neutral mechanism control. Full values,
fresh sample ranges and drift remain in the native outcome and its hash-bound
screen summary. Broad integrated release qualification remains pending.
