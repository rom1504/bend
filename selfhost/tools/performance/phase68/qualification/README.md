# Phase68 selected-image qualification

These are source/data successors to the closed Phase67 methods. Preparation
and receipt joins run on CPU0. Root alone executes compiler and native targets,
serially on CPU3 under the existing single guard: 1 GiB Node heap, 4 MiB stack,
2 GiB tree RSS, and 4 GiB available-memory floor. Preserve every old method and
raw attempt. Every output below must be fresh.

`unchanged-js.py` compares actual checked snapshots and named generated B1 APIs.
It retains the original scanner and requires exact runtime/public wrapper bytes
and every generated dependency of all 98 public roots other than `nc_compile`.
Changed generated functions must be outside that actual reachable closure.
The frontend check separately derives the unchanged driver's conservative API
root set. No native-module allowlist substitutes for either closure.

Assembler module membership may change. Every source declaration that moves
between modules must retain its exact annotation, signature and body. The
native fixture manifest may name only modules in the corresponding assembler
manifest. Host, Base, runtime/provider and other snapshot files remain exact.
The report enumerates changed input pins, moved declarations and changed
unreachable generated functions. This transfers only finite non-native semantic
evidence; actual B2, native output and timing require their own receipts.

The stronger 98-root gate fails for Templates05 because native public APIs
reach the changed intrinsic lookup. Its versioned successor
`unchanged-js-routes-v2.py` derives roots from the exact unchanged typed driver,
excluding only its two hash-pinned `mode==='native'` guarded arms. Every other
static API reference stays in the root set; all five dynamic references must
remain presence checks. The complete generated closure of those roots, runtime
and wrappers must still match exactly. The result records excluded public roots
and the stronger gate's separate outcome. It supports JS/frontend driver-route
observations only; excluded native and unused public-API controls do not transfer.
Templates05 passed 85 driver roots / 2,988 functions and the 1,403-function
frontend closure. The stronger gate remained visibly false.

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase68/qualification/prepare-final-methods-v2.py \
  --attempt selfhost/build/phase68/SELECTED-BUILD \
  --out selfhost/build/phase68/qualification-method-SELECTED
```

The selected attempt must already exist and be checked with `strictExact`.
V2 selects and pins the route-specific closure method. V1 and every consumed
preflight/prototype method remain unchanged.
`--baseline-attempt` and `--baseline-js-manifest` default to the immutable
Phase67 selected scalars attempt and its JS acquisition. The factory records
the actual selected attempt and every changed snapshot input. Its five emitted
gate files are exact, counted output-boundary relocations of the consumed
Phase67 derivatives; older diagnostic kind names in those files retain their
historical meaning.

Review `methods.json` and execute its seven commands in order:

1. Source-only non-native closure admission.
2. Data-only genuine B2 construction plan preparation.
3. Existing tiny/full emission, driver comparison and B2 image-pin sequence.
4. Fresh actual B2 own-source type check, retaining the expected unsafe proof verdict.
5. Actual B2-to-B3 complete byte reproduction.
6. Fresh checked B1 JS emission for all 23 sources / 45 points.
7. Fresh actual B2 checking/emission against those complete B1 bytes.

Each target command already owns its guard; do not nest another. The B2
construction script uses the maintained per-step guards. Preparing commands
does not pass a gate or authorize installation. The preflight directory
`qualification-method-preflight01` demonstrates the data/schema path on eta02;
none of its target commands has run in this lane.

The compilation lane owns
`../compilation/prepare-selected-v2.py`, which binds actual `--attempt`,
`--image-pins`, and qualified acquisition receipts before producing separate
import, preparation, native-request and diagnostic-profile jobs. Select the
current version explicitly. Its optional `--oracle-attempt` separately identifies
the actual checked compiler that supplied an identical C oracle, and the fresh
B1/B2 workers must earn complete C equality; never relabel that oracle.

After those jobs close, join the selected receipts:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase68/qualification/collect-final-v2.py \
  --methods selfhost/build/phase68/qualification-method-SELECTED/methods.json \
  --native-compilation selfhost/build/phase68/NATIVE-REQUEST-SELECTED/summary.json \
  --out selfhost/build/phase68/selected-image-qualification01.json
```

The join checks strict36, unchanged JS/frontend driver-route closure, genuine selected B2,
own-source/fixed-point receipts, 23/45 fresh JS equality, retained Phase67 JS
bytes, and selected B1/B2 native-request identities and full C equality. It
does not replace native control/runtime selection receipts, installation checks,
or broad conformance. Clean request clocks, diagnostic profiles, original Clang
clocks and executable runtime measurements remain separate observations.
