# Current compiler laws and finite controls

These tools take explicit current source and operational assets. They never
substitute a historical compiler when a helper is missing or its representation
changes. Frozen references, statements, independent case oracles and challenge
witnesses live in `selfhost/proofs/compiler-laws/` and `selfhost/tests/laws/`.

There are three separate claims:

* `prepare.py` extracts exact declarations from the requested assembled source.
  `check.py --binding` authenticates that extraction and frozen contracts, checks
  every body, elaborates it, checks nonopaque laws with BendTT/Lean, and requires
  the independent kernel to reject a known false equality. Only those safe value
  contracts are proved; callers, runtime ownership and the whole compiler are not.
* `check.py` without a binding checks a standalone closure. The algebra and
  ownership models remain models, even when independently checked. `--source-only`
  performs frontend admission only; `--prepare-only` executes nothing.
* `prepare-finite.py` and `finite.py` execute complete values from an independent
  oracle over exact production helper declarations. This is finite coverage,
  not a universal proof. A type/syntax/resource failure is never a semantic
  mutation detection.

Prepare a source-bound proof package offline:

```sh
python3 -B selfhost/tools/laws/prepare.py \
  --candidate /path/to/current-assembled-compiler.bend \
  --kind tag --out selfhost/build/my-laws/tag-source
```

Packages are `representation`, `held-simple`, `tag`, `scalars`, `permission`.
The current consolidated source prepares all except `scalars`: its retired
`p98_term_scalar_finish` helper is absent. The scalar proof fixture remains
preserved, but requires an explicit new bridge before it can cover today's
implementation. Missing-helper refusal is intentional. Source extraction removes
only a leading `@unsafe` annotation; it does not rewrite the function body.

Execute under **one outer** `build-retention/guard.py` invocation, with explicit
disk/run-root and CPU/RSS/time limits. Workers below do not acquire another lock:

```sh
python3 -B selfhost/tools/laws/check.py \
  --assets /path/to/law-assets.json \
  --source selfhost/build/my-laws/tag-source/tag.bend \
  --binding selfhost/build/my-laws/tag-source/manifest.json \
  --out selfhost/build/my-laws/tag-check
```

For standalone suites use `selfhost/proofs/compiler-laws/algebra/all.bend` or
`ownership/composition.bend` and omit `--binding`. Actual execution receipts,
not preparation alone, establish checking success. A proof failure after a valid
refactor may require support-proof maintenance; do not call every rejection a
compiler defect.

Prepare and execute finite controls:

```sh
python3 -B selfhost/tools/laws/prepare-finite.py \
  --source /path/to/current-assembled-compiler.bend \
  --assets /path/to/law-assets.json --out selfhost/build/my-laws/finite-source
python3 -B selfhost/tools/laws/finite.py \
  --assets /path/to/law-assets.json \
  --manifest selfhost/build/my-laws/finite-source/manifest.json \
  --out selfhost/build/my-laws/finite-js
```

The unchanged baseline has 226 cases in 16 families and 32 native representatives.
The default `--serializer word-kind-v2` uses an explicit test-observer successor:
`N_Imm64` has distinct wire tag `3`; original `N_W32`/`N_W64`/`N_Box` tags remain
`0`/`1`/`2`. The frozen original serializer remains byte-identical and is selectable
with `--serializer frozen`. The current profile checks the exact four-constructor
declaration and refuses unknown variants. This repairs exhaustive observation;
it changes no production body, case or expected value, and adds no coverage count.
`--supplements` adds the two independently frozen Phase97 gap witnesses, giving
228/34 with separate IDs. `--families` and `--cases` select explicitly; they never
stand for the full score. `finite.py --native` emits C, builds it with declared
Clang `-O3`, and compares complete stdout/stderr. It does not time workloads.
`prepare-finite.py --mutant ID`, followed by `finite.py --expect-mutation`,
requires checked source and a complete wrong value at the frozen witness.
The worker disables the shared Base cache and retains full frontend diagnostics
in both its report and failure summary. Serializer admission failures are not
compiler semantic mismatches.

Use the bounded `bend-build-assets` v1 manifest from `tools/build/assets.py`.
No asset is discovered through historical receipts. Required keys:

| Command | Named assets |
| --- | --- |
| `check.py` | `law-bun`, `law-upstream-main`, `law-upstream-bend`, `law-upstream-safe`, `law-base` |
| Independent check | also `law-lean`, `law-lean-shared`, `law-kernel-source`, `law-kernel-olean`, `law-kernel-runner` |
| Finite prepare/JS | `law-api`, `law-driver`, `law-runtime`, `law-base`, `law-directRuntime`, `law-node` |
| Finite native | also `law-clang` |

Frontend main/bend/safe/Base must share one coherent declared directory. Lean's
library and the BendTT module/runner must match their explicit installation
layout. Finite worker verifies the driver's actual exported API/runtime/Base
paths against its manifest. Toolchain key pins are not a whole-installation
audit. Asset acquisition and provenance are separate from law results.

The [migration map](migration.json) and [fixture map](fixtures-migration.json)
preserve exact origins. Historical Phase96/97/98 campaign/challenge runners are
restoration-only, not current supported commands: they bind their original
images, APIs, source and outcomes. Frozen independent challenge recipes/witnesses
remain under `tests/laws/challenges`; applying them to a changed helper requires
an explicit exact-source recipe and admission step. Do not silently normalize
them, reuse old positive receipts, or add model, proof and finite counts together.

Offline controls (no Bend/JS/C/Lean execution):

```sh
taskset -c 0 timeout 60s python3 -B -m unittest discover \
  -s selfhost/tools/laws -p 'test_*.py'
```
