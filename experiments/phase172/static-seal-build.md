# Private static-seal runtime adapter

`tools/static-seal-runtime.py` performs mechanical source preparation, runtime
object construction and paired relinking. Compiler policy and controls remain
in Bend. It never runs a generated program or changes production files.

The exact runtime source is pinned to `aa95d2c0…`, GCC10 to `693abcb4…`, and the
installed runtime object to `2d078323…`. Preparation copies `runtime.h` and
`primitives.h` alongside the private source and records their original and
snapshot hashes. The only source edit is the guarded `rfc_seal` definition.
`P172_STATIC_SEAL` defaults to zero. Enabling it requires the pinned serial host
policy and declines device/parallel configurations at C compilation.

Preparation, which invokes no compiler:

```sh
python3 experiments/phase172/tools/static-seal-runtime.py prepare \
  --out selfhost/build/phase172/static-seal-runtime-source01
```

The coordinating agent runs the following **inside the maintained outer disk
guard**, with fresh distinct artifact and guard roots. Do not nest guards.

```sh
python3 experiments/phase172/tools/static-seal-runtime.py build \
  --plan selfhost/build/phase172/static-seal-runtime-source01/plan.json \
  --out selfhost/build/phase172/static-seal-runtime-build01
```

Both objects use `-O2 -std=gnu11 -ffp-contract=off
-DP144_SINGLE_MUTATOR_RFC=1`, differing only in `-DP172_STATIC_SEAL=0/1`.
The baseline object must match the installed object byte for byte. A mismatch
leaves an incomplete receipt and requires inspection; it is never silently
accepted as a new baseline. The adapter retains exact commands, stderr/stdout,
wall/CPU/RSS job receipts, source/header/tool pins and resulting object hashes.

After the root compiles a valid Bend control once through the installed QBE
compiler, pair it without repeating QBE/assembly:

```sh
python3 experiments/phase172/tools/static-seal-runtime.py link-pair \
  --build selfhost/build/phase172/static-seal-runtime-build01/report.json \
  --program-object /absolute/path/to/program.o \
  --program-ir /absolute/path/to/program.ssa \
  --out selfhost/build/phase172/static-seal-control-pair01
```

`link-pair` runs under the same outer-guard policy, pins the supplied object and
IR, verifies both runtime objects against their complete build receipt, and
links `baseline` and `static-seal` with identical program object, GCC10,
`-no-pie -pthread -lm`. Both artifacts retain that explicit shared program
identity. This pair builder does not itself prove the supplied object was
derived from its IR; retain the existing compiler-build receipt for that
provenance, and require independent complete control outputs before timing.

The same operation can relink a retained compiler program object once valid
static/shared/dynamic Bend controls and the semantic audit pass. Runtime-only
changes do not authorize changing generated QBE, provider identity, static
verification, installed selection, or benchmark definitions. No malformed
runtime probes belong to this experiment.
