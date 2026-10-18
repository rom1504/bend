# Phase110 ownership IR and bounded research loop

[Design](../../../../design/phase110/ownership-laws-and-search.md) ·
[Experiment](../../../../experiments/phase110/P110-001-owned-interfaces.md) ·
[Report and figures](../../../../implementation/phase110/README.md).

This is an additive experimental compiler path written in Bend. It reuses checked
NativeErasedBody facts, explicit ownership operations and the shared native IR.
Python assembles exact source snapshots/supervises processes; JS transports facts
and calls the checked Bend API. Neither implements a source optimization.

The qualified experimental image is `native-source05`, using the simpler
`compact-general` runtime profile and explicit `runtime-ir-single` policy. This
is an admitted worker-library compiler, not the full-language installed compiler.
Reverse gains transfer to compiler append, but the final transfer screen finds
a regression on non-tail recursive Base String.append; see the report. A fixed
policy is not claimed to be universally optimal.

Root serializes compiler/target work on CPU3 under `../phase86/guard.py`. Do not
wrap the law checker in another guard: it owns that lock itself. Preserve fresh
output directories and immutable receipts. The tools below assume repository
root as the working directory. Native replay requires the pinned existing image,
runtime and tools, or restoration/acquisition from the evidence manifests.

## Use the native compiler directly

This command invokes native Bend and emits a QBE library for the actual Base
String.append. `general` obtains the checked entry and complete callee closure
internally. The root must be reachable from checked `main` in the input.

```sh
phase110_image=selfhost/build/phase108/p110-native-source05/image/program
phase110_input="$PWD/selfhost/tools/performance/phase110/controls/admission/string-append/source.bend"
"$phase110_image" --threads 1 --gpu off -- phase110 \
  "$phase110_input" general String.append qbe runtime-ir-single live
```

Use `ir` to inspect the generated machine IR or `c` for the same-graph C control.
The public worker symbol is `nx_entry`; it takes the runtime context and owning
Term arguments and returns one owning Term. QBE plus GNU assembler builds the
object, which links with the cached production runtime and a caller/harness.
The native entry guide documents canonical types, refusal boundaries, fixed
contracts, acquisition and explicit policies. No Bun, Clang, cproc or Python
executes in the command above. The image's one-time acquisition still uses
C/cproc/QBE; the runtime object is also an acquired dependency.

## Pick the smallest loop that answers the question

| Loop | Observed time in this campaign | What it establishes |
|---|---:|---|
| Checked development API build | Approximately 1.4–2.0 s | Bend source checks and exact development API |
| Native closed-call worker semantics | 13.7 s | Eight actual native products, 36 observations per backend |
| Actual Base String.append semantics | 14.6 s | Two products, 20 observations per backend |
| Fixed-policy append transfer | 55.8 s | Five paired rounds on five predeclared cases; no reselection |
| Final eleven-choice training screen | 56.9 s | Training policy costs; distinct frozen selection step required |
| Final fresh held-out evaluation | 15.0 s | Evaluation of already frozen winners; never train on its results |
| Native image emission plus construction | 236.6 s | Acquire a new frontend image after smaller gates justify it |

Times are observed walls, not timeout promises. Use a 1–2 GiB process-tree limit
for small work. Full acquisition requires 4 GiB and a 16 GiB available-memory
floor; its maximum measured tree was 3.086 GB. Subagents prepare/review source
offline while root owns the single target lane. Do not multiply target processes
to fill agent slots.

For example, replay the actual native-produced closed-call products with a fresh
destination (the Clang control needs the pinned Lean toolchain on PATH):

```sh
PATH="/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin:$PATH" \
python3 -B selfhost/tools/performance/phase86/guard.py \
  --out selfhost/build/phase110/my-semantics-guard --seconds 60 \
  --rss-mib 1024 --available-mib 4096 --cpu 3 -- \
  python3 -B selfhost/tools/performance/phase110/native/run-semantics.py \
  --qualification selfhost/build/phase110/native-general-qualify01/report.json \
  --prepared selfhost/build/phase110/closure-native-semantics01 \
  --runtime-object selfhost/build/phase110/general-build01/runtime.o \
  --out selfhost/build/phase110/my-semantics
```

This replays existing products, not the frontend itself. Add the native qualifier
only after changing frontend admission or emission. `--backends qbe` narrows the
worker gate when the C emitter is unchanged. A failed first replay due to missing
Clang PATH is retained in the evidence; expected semantic outputs never changed.

## Development and evidence tools

- `assemble.py --out DIR`: compose the checked API source and exact width profile.
- `calls/prepare.py --source SOURCE --out DIR`: add closed owning ordinary calls
  using authenticated declaration replacements; historical files stay unchanged.
- `build-api.py --source SOURCE --out DIR --calls --runtime-ir`: check/build the
  small development API, under the outer guard.
- `emit.mjs API CAPTURE OUT CONTRACT POLICY`: Bend lowering and QBE/C emission.
- `run.py`: compile multiple worker policies with one cached production runtime
  object, compare every result to the independent harness oracle.
- `search.py`: serial, alternating, immutable worker evaluation; optional frozen
  `--calibration` controls per-workload repetitions.
- `relink.py`: reuse qualified worker objects with an independent held-out harness.
- `contracts.py`, `probe.py`: actual ownership ABI and physical-graph obligations.
- `laws/README.md`: safe source-connected laws, independent kernel and mutants.
- `controls/README.md`: frozen training/held-out inputs and replay commands.
- `native/README.md`: authenticated native acquisition, fixed/general requests,
  product qualification and execution gates.
- `controls/audit/final-selection.py`: recompute the frozen magnitude/round rule
  from saved training observations; the raw search minimum alone is not selection.
- `figures.py`, `account.py`, `seal.py`: saved-data analysis, resource/source
  accounting and a hash-verified evidence capsule. They do not optimize programs.

Policies include the Phase109 incumbent, inline tags, constant specialization,
atomic pair reconstruction/take, and private structured runtime templates. The
private template verifier regenerates the graph from checked ownership operations;
it is a correspondence gate, not a mathematical proof of machine semantics.
Ordinary opaque libraries still refuse raw memory operations. Single-thread and
runtime layout premises must remain explicit.

Use the small API and kernels before native image acquisition. No broad45 or full
self-reproduction is needed for each local policy. The selected production compiler
and Phase108 full-language cproc/QBE bootstrap remain unchanged.

The compiler source, runtime ABI, controls, evaluator and policy are separately
pinned. A new evaluator version needs its own receipt. The final held-outs are
now regression inputs for future work, not perpetually fresh evidence. Source
model laws, physical execution and native bootstrap evidence answer different
questions; none should be described as whole-compiler proof.
