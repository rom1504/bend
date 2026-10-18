# Native scalar frontend experiment

The compiler algorithms in this path are Bend: parsing, checking, ownership and
layout admission, checked-term lowering, optimization, and QBE text emission.
`prepare.py` assembles an authenticated source snapshot; `run.py` authenticates
files, launches the acquired image and records its output. Neither host script
implements compiler semantics.

This is an additive experiment. Its machine image is acquired once using the
existing native Bend compiler and Clang. Ordinary requests then use native Bend
and, for executable construction, QBE, GNU assembler/linker and the common runner.
They require neither Bun nor Clang. This is not QBE self-hosting, an installed
compiler replacement, a complete language backend, or a CPU/GPU runtime migration.

## Preparation and acquisition

Run source assembly into a fresh directory:

```sh
python3 selfhost/tools/performance/phase107/frontend/native/prepare.py \
  --out selfhost/build/phase107/native-source01
```

The script authenticates the selected Phase102 compiler source and its admitted
Base/cache assets. It retains that source, renames its old `main`, and clones the
exact 13-function `p86_plan*` chain. The clone returns annotated definitions after
`jl_checked_error` instead of calling `nr_prepare_annotated`. It then appends the
shared Nx modules and the new Bend entry. The generated manifest records every
input and the three deliberate source changes. Unreachable old backends are
retained in source but can be omitted by normal code generation.

Acquire the image using the campaign's serial guarded build queue. Reuse
`selfhost/tools/native/cli/start.c` with `BEND_NATIVE_HOST=1`, which places the
program-name slot expected by `IO.args`. Preserve exact source, generated-C,
startup, build-command, executable and resource receipts. A successful source
assembly alone establishes neither typechecking nor native execution.

## Request contract

The acquired binary takes five user arguments:

```text
ABS_INPUT ENTRY json|qbe|units raw|fast cache|live
```

Use the authenticated launcher for research requests:

```sh
python3 selfhost/tools/performance/phase107/frontend/native/run.py INPUT.bend \
  --manifest selfhost/build/phase107/native-source01/manifest.json \
  --binary ACQUIRED_IMAGE --binary-sha256 ACQUISITION_DIGEST \
  --entry bench --format units --policy fast --base cache \
  --out selfhost/build/phase107/native-request01
```

The digest must come from the separately retained image acquisition receipt.
The launcher checks identity; it does not prove that an arbitrary executable was
built from the declared source. Run it inside the existing phase86 memory/time
guard. `--verify-only` checks identities without executing the target.

`cache` verifies the exact admitted Base and carrier bytes before invocation;
the embedded cache stamp alone is not authentication. `live` prepares the pinned
Base from source and is a separate timing condition. Both modes perform request
checking. The source is limited to one file importing Base, at most16MiB; other
imports are explicitly refused by the selected frontend. Annotation starts from
`main`, so another requested entry must be reachable from `main`.

`raw` preserves lowered Nx IR. `fast` applies explicit self-tail conversion,
bounded deep inlining with4096 nodes, and folding. QBE entry fusion has its
independent512-node cap. `units` returns JSON containing the entire typed program
and named QBE units; `json` returns only the typed program, while `qbe` returns one
combined IL file. Unsupported language features are refused. All request output
goes to stdout; the launcher creates fresh artifact paths.

Reports separate authentication, native-process and complete-launcher clocks.
Backend assembly/link/runtime measurements belong to the consuming harness. Do
not compare these clocks to a JS-only inner call while omitting JS startup, or
include one-time Clang acquisition in only one side of an ordinary-request ratio.
