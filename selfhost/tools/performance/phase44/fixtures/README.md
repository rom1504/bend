# Composable backend validation

These finite controls exercise combinations of language features rather than
recognizers for benchmark names or an application algorithm. They are correctness
witnesses, not a representative performance corpus or a soundness proof.

`composition-v1.bend` is one small independently authored source. The pinned
`../fixture-catalog-v1.json` contains 35 explicit value oracles shared by baseline,
candidate and pinned TypeScript. U32 answers use modular arithmetic; recursive
Cargo answers use the finite arithmetic sum, not the compiler's traversal.

| Semantic property | Witness |
| --- | --- |
| Direct calls across ordinary helpers | `arithmetic` / `arithmetic.forward` |
| Equivalent local binding form | `arithmetic.let`, `cargo.let` |
| Zero-argument entry and computed results | `cargo.empty`, `cargo.nullary` |
| Multiple ordinary arguments and wraparound | Arithmetic edge inputs |
| Unrelated nested user ADTs and matching | Cargo, Envelope, construction and fold |
| Recursion composed with construction and calls | `cargo.make`, `cargo.sum`, root wrappers |
| Known function argument | `known` through `invoke` |
| Captured function, partial application, escape | `captured`, `partial`, `retained` |
| Unknown function at public boundary | Host supplies the runtime `shift` value to `invoke` |
| Deferred body and repeat calls | `deferred` returns an observed function |
| Left-to-right evaluation, error identity | Instrumented public observer functions |
| Dynamic function and binding mutation | Observer `.code`, `.code` getter, `G` binding getter |
| Nested execution while an outer call is active | Reentrant observer calls `ordered` |
| Feature interaction after implementation freeze | `mixed`: recursion + ADT + helper + captured callback |

The controller compares all ordinary value oracles with all three compilers.
Runtime-boundary controls compare unchanged Bend-generated JavaScript with the
candidate: TypeScript does not expose the same mutable `G`/function-object ABI.
The candidate must preserve existing observer effects and error identity instead
of relying on equality of final numeric output. Host descriptors are restored
between controls. Returned functions are called repeatedly with changing values.
No diagnostic edits are made to generated modules.

Mixed-feature points are run with `--include-mixed` after the implementation is
frozen. The source is available during development, so these are delayed feature
interaction checks, **not** an untouched or blinded holdout. Similarly, renaming,
helper extraction and local-binding variants are metamorphic correctness probes;
we do not treat their equal answers as evidence of equal optimization coverage.

## Root-owned execution

Use the unchanged checked-module preparation workflow. Baseline is the frozen
Phase43 checked14; candidate is the verified Phase44 checked attempt. Preparation
is compilation, not timed user-program execution.

```sh
python3 selfhost/tools/performance/programs/prepare.py \
  --attempt "$ATTEMPT" --role baseline \
  --catalog selfhost/tools/performance/phase44/fixture-catalog-v1.json \
  --set full --out "$NEW_PREPARATION" --node "$NODE" --cpu 3
```

Candidate uses `--role candidate`; TypeScript uses `--role typescript --upstream`
with the unchanged pin checkout, in place of `--attempt`. Each preparation emits
`modules/composition-v1.mjs` and its `.mjs.json` checked receipt. Execute under the
existing resource supervisor with fresh output:

```sh
"$NODE" selfhost/tools/performance/phase44/validate-ir-v1.mjs \
  "$BASELINE_MODULE" "$CANDIDATE_MODULE" "$TYPESCRIPT_MODULE" "$NEW_REPORT"
```

The controller pins exact source, catalog, modules, emission receipts, compiler
API/runtime/Base and checked attempt identities; it rechecks inputs at completion.
A later freeze run adds `--include-mixed`. This controller contains no compiler,
process spawn, timing or profile work. Root retains all failed source/compile/run
attempts; after consumption fixes require fresh versioned files.

## Admission beyond these controls

1. Every IR constructor has one documented evaluation-order contract. Lowering
   must preserve binding scope, erased arguments, tail position and partial-call
   behavior. Passes should refuse unsupported terms explicitly.
2. Match activation/coverage observations to the candidate's actual IR and emitted
   call sites. Emitted but unreachable workers are not successful coverage.
3. Run semantic controls before timing, then the existing short diverse corpus.
   Compare compiler cost, output size and maintained source complexity as well as
   generated execution; avoid growing a second per-family mode registry.
4. After one frozen candidate has demonstrated broad benefit, run maintained
   frontend/backend qualification and the complete runtime corpus once.

Future passes that alter public data layout, native host primitives, non-tail
stack handling or effects need their existing owner controls as well. This small
suite does not replace deep-recursion, constructor alias, malformed host input,
prototype mutation or full backend qualification. It intentionally avoids a large
new framework and reuses the existing bounded checked-image workflow.
