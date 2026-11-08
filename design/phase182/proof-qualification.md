# Phase182 proof and qualification gate

Audit of upstream `9a4223d577ba56a0cb53d1fd952d2b481c38930f`, 2026-11-08.
No Bend, Lean, generated program, benchmark, download or installation was run
by this audit. Twelve source/data-only law-tool tests pass. Root owns target jobs.

The smallest useful independent gate is: compile the **new complete kernel**
once, check/elaborate a small existing law closure with the new frontend, require
every named law to have a nonopaque kernel definition, run that exact text through
the new kernel, and require the kernel to reject the frozen false equality.
Then repeat for the actual changed helper package, authenticated by `--binding`.
An algebra or ownership-model result alone does not cover production helpers.

## Toolchain and identities

Lean 4.34.0 already exists at
`selfhost/build/phase94/toolchain/lean-4.34.0-linux/bin/lean`. The executable
SHA256 `e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550`
and matching `lib/lean/libleanshared.so` SHA256
`ab523f803d805db2c08eb755f0fa8189345bf6ae9b408664cdf3cf67fa0112d9`
were recomputed and match `selfhost/manifests/assets-laws.json`. Its pinned Bun
also matches. The default `.elan` installation is 4.32.0; do not select it via
PATH. Toolchain presence/key hashes do not authenticate every installed file.

The new `bend2/bendtt.lean` is 169,051 bytes, SHA256
`3e9b678d00a754fc6f4281584e470f7c677093b03eccfc244085afdee8e020a6`.
The existing `selfhost/.assets/laws/kernel/BendTT.olean` belongs to the old
source and cannot establish a current-kernel result. Preserve it for replay.
The new kernel contains `book_check`, `halts`, `consistent` and `adequate`
theorems (lines 2450, 3834, 3852, 3860); this audit found no `sorry` or `axiom`
declarations. Lean must still check the complete file; copying it is not proof.

## Root commands

Run from the repository root. Names below must be fresh. Preparation copies are
small, reversible file operations; target commands each have one outer guard.
Keep the default 5 GiB reserve. These bounds are initial budgets, not promised
durations: the older kernel build took about 53 seconds and 1.27 GB tree RSS.

```sh
P182_ROOT="$PWD/selfhost/build/phase182/proof01"
P182_UP="$PWD/selfhost/.bootstrap/upstream-phase182"
P182_LEAN="$PWD/selfhost/build/phase94/toolchain/lean-4.34.0-linux/bin/lean"
export P182_ROOT P182_UP
python3 -B selfhost/tools/build/assets.py verify \
  --manifest selfhost/manifests/assets-laws.json \
  --key law-bun --key law-lean --key law-lean-shared
python3 -B - <<'PY'
import os, shutil
from pathlib import Path
p = Path(os.environ['P182_ROOT'])
(p/'kernel').mkdir(parents=True, exist_ok=False)
shutil.copyfile(Path(os.environ['P182_UP'])/'bend2/bendtt.lean', p/'kernel/BendTT.lean')
(p/'kernel/Run.lean').write_text('import BendTT\n')
PY
python3 -B selfhost/tools/build-retention/guard.py \
  --out "$P182_ROOT/kernel-guard" --run-root "$P182_ROOT/kernel" \
  --disk-mib 128 --seconds 180 --rss-mib 2048 --available-mib 4096 --cpu 3 -- \
  env -u LEAN_PATH -u LEAN_SRC_PATH LEAN_STACK_SIZE_KB=4096 \
  "$P182_LEAN" -M1400 -o "$P182_ROOT/kernel/BendTT.olean" \
  "$P182_ROOT/kernel/BendTT.lean"
```

Require guard completion/exit zero, inspect both logs, and retain all module
sidecars inside the kernel root. Prepare a **separate** current proof asset map
only after that successful build; do not repin the operational old law assets:

```sh
python3 -B - <<'PY'
import hashlib, json, os, subprocess
from pathlib import Path
p = Path(os.environ['P182_ROOT']); up = Path(os.environ['P182_UP'])
revision = '9a4223d577ba56a0cb53d1fd952d2b481c38930f'
assert subprocess.check_output(['git','-C',str(up),'rev-parse','HEAD'],text=True).strip() == revision
subprocess.run(['git','-C',str(up),'diff','--exit-code','HEAD','--','bend2'],check=True)
def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())
old = json.loads(Path('selfhost/manifests/assets-laws.json').read_text())['assets']
assets = {k:old[k] for k in ['law-bun','law-lean','law-lean-shared']}
for key, file in [('upstream-main','main.ts'),('upstream-bend','bend.ts'),
                  ('upstream-safe','safe.ts'),('base','base.bend'),('upstream-comp','comp.ts')]:
    assets['law-'+key] = pin(up/'bend2'/file)
for key, file in [('kernel-source','BendTT.lean'),('kernel-olean','BendTT.olean'),('kernel-runner','Run.lean')]:
    assets['law-'+key] = pin(p/'kernel'/file)
assert (p/'kernel/BendTT.lean').read_bytes() == (up/'bend2/bendtt.lean').read_bytes()
build = json.loads((p/'kernel-guard/process.json').read_text())
assert build['complete'] and build['returncode'] == 0
doc = dict(kind='bend-build-assets',version=1,complete=True,upstream=revision,assets=assets,
           kernelOrigin=pin(up/'bend2/bendtt.lean'),kernelBuild=pin(p/'kernel-guard/process.json'))
with (p/'assets.json').open('x') as stream: json.dump(doc,stream,indent=2)
PY
python3 -B selfhost/tools/build/assets.py verify --manifest "$P182_ROOT/assets.json"
python3 -B selfhost/tools/build-retention/guard.py \
  --out "$P182_ROOT/algebra-guard" --run-root "$P182_ROOT/algebra" \
  --disk-mib 32 --seconds 300 --rss-mib 2048 --available-mib 4096 --cpu 3 -- \
  python3 -B selfhost/tools/laws/check.py --assets "$P182_ROOT/assets.json" \
  --source selfhost/proofs/compiler-laws/algebra/all.bend \
  --out "$P182_ROOT/algebra" --seconds 60
python3 -B selfhost/tools/build/assets.py verify --manifest "$P182_ROOT/assets.json"
```

The law runner calls the selected frontend with `--check-only`, emits retained
`laws.bendtt`, then uses `LEAN_PATH=<fresh kernel dir>` and
`lean -M1400 --run Run.lean`. It does **not** invoke automatic `--verdict`
kernel acquisition. Success requires both exact positive diagnostic lines and
the existing `phase67_false` rejection (expected `.left`, observed `.right`).
An out-of-scope elaboration can exit zero; the runner correctly refuses its
stderr and any omitted/opaque law. Do not accept exit zero by itself.

For the migrated compiler source, after assembly has stopped changing:

```sh
python3 -B selfhost/tools/laws/prepare.py \
  --candidate "$P182_SOURCE" --kind held-simple --out "$P182_ROOT/held-source"
python3 -B selfhost/tools/build-retention/guard.py \
  --out "$P182_ROOT/held-guard" --run-root "$P182_ROOT/held" \
  --disk-mib 32 --seconds 300 --rss-mib 2048 --available-mib 4096 --cpu 3 -- \
  python3 -B selfhost/tools/laws/check.py --assets "$P182_ROOT/assets.json" \
  --source "$P182_ROOT/held-source/held-simple.bend" \
  --binding "$P182_ROOT/held-source/manifest.json" --out "$P182_ROOT/held" --seconds 60
```

Set `P182_SOURCE` to the actual freshly assembled migration source. Expand to
`tag`, `representation`, `permission` only where those helpers/contracts are
unchanged and relevant. `scalars` intentionally refuses the retired
`p98_term_scalar_finish`. Missing helpers or changed `KTerm`/`tg` require an
explicit bridge; never substitute old bodies. The ownership composition suite
is an abstract protocol theorem, not concrete native-memory ownership.

## Migration changes and remaining boundaries

* `safe.ts:670` now encodes the **whole canonical key**, including the source
  path/colon, and doubles `_`. `laws/check.py` now selects the exact old/new
  codec by authenticated safe/language/kernel source hashes and records that
  provider. New law bindings use the exact namespace relative to the entry
  directory, not a suffix or import alias. Old-provider replay keeps its old
  matching. Omitted, wrong-namespace and opaque definitions remain refusals.
  This code change has only source/data tests; the commands above establish
  actual elaborator/kernel compatibility.
* `safe_check` changed from boolean to `null` success / failure-reason string
  (`safe.ts:1728`). Main already handles that contract. Its diagnostics now
  group transitive unsafe/foreign dependencies; old negative stdout fixtures
  need explicit current oracles rather than substring normalization.
* `check-source.mjs:30–38` still uses available `book_nil`, `book_load`,
  `book_valid`, `book.hols`. It requires a matching **manifest revision** as
  well as `--upstream`; overriding the directory alone does not override an old
  manifest pin. Its exact two-file closure applies to assembled compiler plus
  Base, not multi-file law suites. It performs no kernel or proof-safety gate.
* The new elaborator changes recursion grouping, eta expansion, quantity/convoy
  handling, and opaque model search. A previously checked law may need support
  proof maintenance or expose a real regression. Preserve the first failure,
  full text and diagnosis. No automatic old elaborator fallback.
* `qualification.py` and its catalog previously fixed upstream `05926622` and
  C execution used legacy runtime arguments. The tooling owner is migrating
  those separately. Preserve old reference identities; new catalog/oracles,
  image lineage, prepared Base and runtime argument convention require explicit
  bindings. Finite JS/C/QBE execution remains separate from this proof gate.
* Source safety, nonopaque value-contract proofs, kernel metatheorems, finite
  output controls and compiler self-reproduction are distinct claims. None
  alone proves backend correctness, runtime ownership or the whole compiler.

The current kernel source and full frontend (`main.ts` imports `comp.ts`) must
stay pinned before/after each campaign. The extra `law-upstream-comp` manifest
key is checked by the explicit asset verification commands above; the current
law worker only consumes its documented keys. Close and seal each target root
with the maintained retention workflow, keeping the fresh module build receipt.

## Completed algebra compatibility update

The actual `proof-algebra03` run independently checked all 23 algebra laws with
the current frontend/kernel and rejected the existing false-law control. Its
unchanged 27,103-byte report is retained at
`implementation/phase182/evidence/proof-algebra03.json`, SHA256
`c1d9b02b2b1cc6b615738f4ed42aba0754b32ba73f3bf2a976c9f866aa8e01ae`.
This is a standalone algebra result; the receipt makes no production compiler
binding, whole-compiler theorem, or native-ownership claim.

Current Base changed `List.contains` from eager `Bool.or` to a deferred tail
through `List.any.if`. The maintained membership proof adds two Boolean case
lemmas, `or_matches_any_if` and `any_if_empty_tail`, and repairs singleton/append
proof terms. All six original membership theorem statements, including their
quantities, remain byte-identical. The singleton helper consumes its affine head
once. The two earlier failed runs remain historical failures.

`selfhost/tools/laws/fixtures-migration.json` retains every original extraction
row unchanged. Its separate `sourceUpdates` version 1 records the original and
current membership identities, original statement hashes, added helper names,
upstream identity, and the exact independently checked receipt. It does not
relabel the original extraction as already containing these later changes.
Metadata tests accept changed maintained bytes only through that explicit update,
verify the pinned receipt's source closure and nonopaque law bindings, and require
both kernel success and rejection of the false law. They need no historical
checkout or executable and cannot substitute for rerunning the kernel after a
future proof change.

```sh
taskset -c 0 python3 -B -m unittest discover \
  -s selfhost/tools/laws -p 'test_*.py'
```
