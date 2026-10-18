# Phase109 frozen semantic and ownership controls

`manifest.json` freezes 13 ownership cases at 18:15:07 UTC on 2026-10-18,
before any candidate execution. `cases.json` supplies runtime term construction
and alias descriptors. `expected.jsonl` is an independent sequence-reversal oracle,
not captured incumbent or candidate output. The unchanged compiler `nt_reverse`
and held-out Base `String.reverse.go` are the two source witnesses.

```sh
python3 -B selfhost/tools/performance/phase109/controls/check.py
python3 -B selfhost/tools/performance/phase109/controls/check.py --stdout CAPTURE.jsonl
```

Use repeated `--case NAME` when checking a selected subset; output order remains
manifest order. The checker never launches a target. Case hashes encode each
Unicode scalar as u32 little-endian; list hashes prefix each string with its
codepoint count. Counts, preserved aliases and exact allocator release are separate
observations. This is finite testing, not a memory-safety or compiler proof.

The cases cover empty/singleton/deep values, heap/static inputs, an independently
held root, a held tail plus held opaque string head, Unicode and combining
characters. The deep case has 65,536 list cells, with nonuniform opaque heads,
and an appended accumulator. The runtime harness must use production allocation,
keep/take/build/sink and check all owned roots are released. It must not implement
the tested reversal itself. Physical-path qualification is a separate obligation;
source features alone do not prove static/shared branches executed.

Phase108's original semantic fixtures/oracles are referenced without copies or
changes. `non-tail-list` supplies the continuation-heavy full-backend comparison;
it remains explicitly unsupported in the initial owned direct-IR slice.
Negative lowering and ABI entries in the manifest are **planned gates**, not
recorded passing tests. Implementation receipts must identify actual executed
controls separately.

`production-workers.c` contains two byte-exact production-generated function
bodies, with source and body hashes in `production-workers.json`. Both already
have direct self-tail loops: they do not enter the continuation trampoline for
every reversed node. Use them as a C reference against the new Nx worker in the
same runtime harness. Their original program constructor IDs differ from the
fixed adapter's IDs; explicit macro/table rebinding is required and must be
recorded. No text-to-IR translation is involved.

`baseline-plan.json` freezes four build profiles over the same three existing
complete generated C files: original Clang transport, portable Clang transport,
portable Clang with the cproc support ABI, and portable cproc/QBE. The extra Clang
profile separates external atomics/CLZ plus accessor changes from the machine
backend. It is a command plan, not execution evidence. Build and run under root's
serial CPU3 process-tree guard; these tiny programs measure semantic compatibility
and build latency, not representative execution speed.

`derived/` is a separately frozen extension for four generic source functions:
List/String discard and List/String duplicate. They use the same 13 ownership
inputs with separate expected results, exercising compiler-inserted Sink/Keep
and immediate Char ownership behavior. This is two new transformation shapes,
not 26 new language families. Use `check.py --variant discard` or
`--variant duplicate`. The original reverse manifest, inputs and oracle remain
unchanged. Sources are frozen before checking; retain failed source and correction
records if frontend admission requires a syntax repair.

The executable four-profile harness is `baseline.py`; root runs it under the
Phase86 process-tree guard on CPU3. `--rounds 3` alternates profile order each
round; `--only nt-reverse non-tail-list` selects cases. All objects/executables
are fresh per round, and input/source digests are checked around each command.
Build times, binary identity, `.text` size and exact outputs are retained.
