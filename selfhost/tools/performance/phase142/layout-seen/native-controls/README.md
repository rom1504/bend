# Focused native layout refusal/acceptance plan

No targets have been run for this plan. `method.py` only creates commands or
checks existing receipts; it never launches a compiler.

The three `.bend` files are byte copies of the retained earlier
`selfhost/build/js-layout` cases. The copied prior report records:

| Fixture | Existing checked-layout observation |
|---|---|
| `constructor.bend` | Source checks; emission refuses `Error: an open Array element type` |
| `dead.bend` | Source checks and emission accepts the unused generic constructor |
| `erased.bend` | Source checks and emission accepts its erased use |

`fixtures.json` pins each original/copy, the old report and generator. That old
report did **not** contain fixture hashes, so it cannot authenticate historical
source bytes retrospectively. The native plan therefore re-establishes all three
observations with the qualified Phase141 N2 before comparing the candidate.
The native `compile:` prefix comes from the selected P86 adapter; candidate
stderr must match the actual parent stderr byte-for-byte. No runtime stdout
expectation has been invented for the two positive programs.

## Existing runner and refusal handling

`phase125/native/native-emit.py` records expected refusals as transport exit 1,
`failedStage=emission`, native child exit 1, empty `program.ssa` and raw
`emit.stderr`. The existing `phase125/native/coverage.py` shows the refusal
contract, but its fixed manifest/policy supports only type/affine/foreign cases.
Do not modify that historical policy or substitute these fixtures into it.
`phase130/native-request.py` requires successful nonempty QBE and is unsuitable
as a passing refusal aggregator.

After the candidate image exists, create a metadata plan from repository root:

```sh
python3 -B selfhost/tools/performance/phase142/layout-seen/native-controls/method.py plan \
  --candidate /absolute/path/to/candidate/program \
  --directory selfhost/build/phase111/p142-layout-native-controls01 \
  --out selfhost/build/phase142/layout-native-controls-plan01.json
```

Run the six `jobs[].command` arrays in their listed order under the existing
root-owned serial CPU3/resource guard. The constructor jobs intentionally return
1; this is not itself a passing gate. Do not use a generic stop-on-nonzero job
executor without its expected-exit facility. The positive candidate commands use
the original transport's `--reference` to demand complete parent QBE equality.
No QBE build or program execution is requested for this narrow frontend test.

Then authenticate and compare existing results:

```sh
python3 -B selfhost/tools/performance/phase142/layout-seen/native-controls/method.py observe \
  --plan selfhost/build/phase142/layout-native-controls-plan01.json \
  --out selfhost/build/phase142/layout-native-controls01.json
```

The observer requires the exact expected refusal payload, exit 1, empty QBE,
no timeout/build, and matching parent/candidate stdout/stderr/exit. Positives
require exit 0, complete successful emission, empty stderr and exact full QBE.
If the historical fixture no longer passes current source admission, the gate
fails; do not treat a different error as successful refusal or silently edit the
fixture. Use a new version with independently established expectations instead.
