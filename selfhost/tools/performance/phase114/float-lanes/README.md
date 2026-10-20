Optional P114-011 local float-lane reuse, on the exact checked scalar-operands
source02. The experiment is recorded before targets in
`experiments/phase114/P114-011-local-float-lanes.md`. This is not selected/default.

`modules01.json` pins the parent source/admission/API, unchanged runtime and
three Bend modules. The only override is `p114so_stmts`. Produced float results
and exact unchanged U64 local copies carry at most sixteen local-to-lane facts.
Other statements clear them through the original walker. Arithmetic/conversion
order, every full-word result, private/public ABI and original verifier stay
unchanged. Unsupported buffers retain the exact parent's path. No type kind,
memory value or argument creates a fact.

Source-only preparation already wrote `selfhost/build/phase114/float-lanes-source01`.
Use a fresh output name for any retry; never overwrite the snapshot. Root alone
executes API/compiler/native jobs. After a checked API, these are root recipes:

```sh
python3 -B selfhost/tools/performance/phase114/float-lanes/admit.py \
  --source selfhost/build/phase114/float-lanes-source01 \
  --api-report selfhost/build/phase111/p114-float-lanes-api01/report.json \
  --out selfhost/build/phase114/float-lanes-admission01

node selfhost/tools/performance/phase114/float-lanes/controls.mjs \
  selfhost/build/phase111/p114-float-lanes-api01/api.mjs \
  selfhost/build/phase114/float-lanes-controls01
```

The checked API needs the parent transport exports plus the diagnostics in
`modules01.json`. The diagnostic lowers two actual ordinary sources through the
unchanged checked frontend and original runtime/IR gates, then compares the
parent API02 and candidate rendering of the identical function. It requires the
same ordered float operations and word-result assignments, fewer float casts on
the positive workers, and byte-identical sqrt fallback. It separately reports
surviving local copies and repeated operation destination names; lexical source
shadowing alone does not establish machine-name rebinding coverage. Eight small
fact-map assertions cover aliasing, self-copy, kill/rebind and the size cap. No
fabricated IR is executed as a native program.

The ordinary fixtures and literal complete outputs are pinned in
`controls/manifest01.json`; the new `copy-chain` source includes exact copies,
shadowing, unsigned conversion, both comparison branches and sqrt fallback.
The existing independent `ordinary-floats` fixture remains unchanged. Root may
emit/build/run each using the established staged array pipeline and expected
JSON. Only after positive actual reuse and complete outputs should the frozen
ray/local-pair screen run. No target result or speed gain is claimed here.
