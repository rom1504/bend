# Budgeted composition: separate native chain

`prepare-budget-native.py` reuses the eight frozen Phase193 qualification argv
files, requiring equality with their original `qualification-argv01.json` entries.
Only path tokens and outer wrapper job names change. The original selected source,
images and receipts remain immutable; this preparation changes no maintained
compiler source and runs no target.

The fresh outputs are `budget-native-image01`, `budget-native45-01`,
`budget-native-self01`, `budget-native64-01`, `budget-runtime10-01`,
`budget-native-reproduction01`, `budget-native45-02`, and
`budget-native-generations-compare01`. All source requests require the future
`selected-source02/compiler.bend`. Seed acquisition retains the identical
Phase186 QBE N2 and byte-identical assets. Stage flags, exact-object reproduction,
independent program-output gates, catalogs, machine/runtime checks, CPU and
resource limits are unchanged.

| Job suffix (all prefixed `budget-`) | Guard seconds | Disk MiB | RSS MiB |
|---|---:|---:|---:|
| native-image01 | 520 | 192 | 3072 |
| native45-01 | 450 | 128 | 2048 |
| native-self01 | 650 | 192 | 3072 |
| native64-01 | 600 | 160 | 2048 |
| runtime10-01 | 180 | 64 | 2048 |
| native-reproduction01 | 700 | 192 | 3072 |
| native45-02 | 450 | 128 | 2048 |
| native-generations-compare01 | 180 | 16 | 2048 |

Budgets are ceilings, not measured consumption or a new aggregate allocation.
Each command keeps its individual outer disk guard and retention close; never
wrap the entire chain in another guard. The comparison is offline product
analysis, not target timing. Preserve the normal disk reserve and fresh roots.

The pending plan is
[`budget-qualification-plan01/plan.json`](../../selfhost/build/phase193/budget-qualification-plan01/plan.json).
Because selected-source02 does not yet exist at preparation time, it records
`readyToStart:false`, `selectedSource:null`, and `runnerCommand:null`.
Its argv files describe future work; absence of the source is not substituted
with selected-source01 and no hypothetical source hash is supplied.

After root freezes and independently accepts selected-source02, prepare a fresh
bound plan:

```sh
python3 -B selfhost/tests/phase193/prepare-budget-native.py \
  --out selfhost/build/phase193/budget-qualification-plan02
```

The bound plan records exact source and argv pins and an invocation of existing
`run-steps.py`, which checks the source hash before every step. Verify the plan's
input/argv pins before using it. Root can pass selected argv files to that same
runner to pause after N1 acquisition/products for the cost gate, and again after
N2 for its net cost gate. The existence of an all-step command is not an admission
decision to skip those gates or proceed directly to N3.

`compiler-cost-plan-v2.py` preserves the earlier four-request, two-balanced-round
authenticators while adding explicit `--candidate-source`. Its default remains
selected-source01 for exact old comparisons. Budget-source invocation:

```sh
python3 -B selfhost/tests/phase193/compiler-cost-plan-v2.py \
  --stage N1 --candidate-build selfhost/build/phase193/budget-native45-01 \
  --candidate-source selfhost/build/phase193/selected-source02/compiler.bend \
  --out selfhost/build/phase193/budget-cost-n1-plan01
```

Use N2 and `budget-native45-02` for the later separate net-cost comparison.
The supplied candidate source must exactly equal the candidate image binding;
it does not weaken source, request, independent output, Base, runtime, stage or
common-QBE-producer checks. Both baseline stages validated all four requests
offline with v2; future candidate metadata remains pending its actual products.
No new benchmark runner or native execution was added.
