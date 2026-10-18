# Native selected-library entry

`image.json` selects the qualified Phase109 image. After restoring its evidence
and the existing Base/cache assets at their recorded paths, run:

```sh
python3 -B selfhost/tools/performance/phase86/guard.py \
  --out selfhost/build/phase109/my-native-guard --seconds 30 \
  --rss-mib 1024 --available-mib 4096 --cpu 3 -- \
  python3 -B selfhost/tools/performance/phase109/native/emit.py \
  --out selfhost/build/phase109/my-native-output --contract reverse --policy fused
```

It writes QBE to `program.txt`, authenticates image/source/Base/cache and records
the command/output. `--format ir` writes JSON; `--live` disables prepared Base.
Python supervises the native executable; the raw invocation below needs no
Python. This wrapper compiles the selected library, not a complete executable.
The frozen image embeds absolute asset paths; rebuild with `prepare.py` when
moving to a different checkout location.

`prepare.py` assembles a controlled native Bend image source. It reuses the exact
selected compiler's `p86_plan` and `NR_Request` preparation, including checked
annotations, native erasure and ownership preprocessing. It appends the same
Bend-written Nxo/Nx/QBE modules used by the hosted experiment, renames only the
old `main`, and installs `main.bend` as the experimental entry. No production file
or installed image changes.

```sh
python3 -B selfhost/tools/performance/phase109/native/prepare.py \
  --out selfhost/build/phase109/native-source01
```

Preparation executes no compiler. The manifest pins all modules, the trusted
source, Base/cache, portable runtime and exact source contracts. It includes
explicit acquisition commands reusing Phase108's guarded emission/build tools.
Those tools put acquisition receipts under
`selfhost/build/phase108/p109-native-source01/`; root must execute the commands
serially with process-tree guards. The intermediate metadata bridge only inserts
Phase108's four register-transport macros omitted by the historical seed.

A resulting raw native binary accepts its runtime flags followed by a sentinel:

```text
IMAGE --threads 1 --gpu off -- phase109 ABS_INPUT reverse qbe raw cache
IMAGE --threads 1 --gpu off -- phase109 ABS_INPUT duplicate ir fused live
```

Arguments are source path, selected contract (`reverse`, `discard`, `duplicate`),
output (`qbe`, `ir`), lowering policy (`raw`, `trusted`, `fused`) and Base mode
(`cache`, `live`). The QBE library exports `nx_list_reverse` and
`nx_string_reverse`; contract names select the corresponding source definitions,
not handwritten compiler intrinsics. IR output contains both serialized Nx
functions and identifies the contract/policy. Root's launcher must authenticate
image/source/Base/cache and output receipts before qualification.

This is deliberately a **selected-library** interface. It accepts only the exact
frozen Phase108 reverse fixture or Phase109 derived ownership fixture. The full
checked source then passes through the mature frontend and erasure again. This
restriction preserves the established fixed List<String>/String runtime entry
contract: an erased generic function alone does not prove arbitrary input data
layouts or foreign ABI compatibility. General source admission requires preserving
or checking those type/layout facts; a name whitelist alone would be insufficient.

The image is not a fully direct-IR self-hosted compiler. Its acquisition still
uses mature Bend C lowering followed by cproc/QBE. Its admitted ordinary requests
run parsing, checking, erasure, owned lowering and QBE emission in native Bend,
without a JS host or a scalar-only substitute frontend.

## Checks before another image acquisition

`prepare-check.py --out FRESH --bridge CHECKED_API_SOURCE_DIR --config SOURCE_DIR/config.bend`
builds a small entry typecheck fixture using exact interface types/signatures and
explicit semantic mocks. Under a short guard, run `stage0-library.mjs SOURCE
OUT_API nxo_lower`. The complete book is checked; export a non-IO helper, not
`main`. Never execute the mock main or count this as frontend correctness.
The corrected fixture check took 1.04 s; actual native semantics are independently
qualified using the complete mature frontend.

`qualify.py --source SOURCE_DIR --image IMAGE_DIR --suite HOSTED_SUITE --out FRESH`
checks all nine exact source/policy products, live Base, IR JSON, four refusals,
then builds native-produced QBE and checks thirteen runtime observations. Use a
120-second/2-GiB guard. Recorded qualification time is 9.73 s.
