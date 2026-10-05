# Phase52 independent direct-backend semantics

Frozen `semantic-catalog-v2.json` selects 16 source fixtures and 57 scenarios.
No execution results are claimed by this plan. The eleven copied compile fixtures
retain maintained `#|` oracles; four foreign fixtures retain their source/JavaScript
companions and exact expected output. The new direct-contract fixture tests the
public default-callable library independently of the legacy `G`/vector runtime.

The critical counterexamples are live-slot erasure at public JS calls, empty and
partial argument groups, excess host arguments, captured and matched-recursive
factories, named ADT fields/getter order, Char construction before an invalid
later argument, 50,000 tail turns, 48-bit Nat bounds, F32 rounding/NaN/infinity/
signed zero, Array dynamic closure transport and public function callbacks.
Selected Math/String hooks change actual used builtins; Array.isArray is a
nondependency witness. Plain input retention and errors/events are compared as
separate observable state. FFI witnesses cover shared module state, erased effect
binders/callback arity, ordinary effect arity and raw inbound Nat values.

The callable contract is the pinned upstream TypeScript module's `default` object.
JS inputs use only live parameters; native Nat results follow the upstream host
representation. Library observations call `default[exportName]` and subsequent
returned JS functions directly. There is no `G`, `call`, legacy closure vector or
manual generated-program normalization. Expected values and Nat/Char error
substrings were frozen from maintained goldens/runtime policy before execution;
remaining observable values/errors/events must match TypeScript exactly.

Acquisition uses the separately owned `emit-worker.mjs`. Library cases select
`library`; catalog `mode:"program"` cases select `compile` (`js_book` for pinned
TypeScript). Unsupported candidate program emission must fail explicitly. Ordinary
candidate emission must use the checked Bend compiler's direct backend, never
TypeScript delegation. This runtime controller validates receipt lineage; source
review and compiler qualification establish that implementation obligation.

Runner:

```sh
node semantic-runner-v2.mjs MANIFEST_JSON FRESH_OUTPUT_DIRECTORY
```

The manifest pins `catalog:{file,sha256}` and has exactly two roles:
`typescript:{modules:{CASE_ID:MODULE_PATH}}` and
`direct:{attempt:{file,sha256},modules:{CASE_ID:MODULE_PATH}}`.
Module paths are relative to the manifest or absolute. Every module needs its
adjacent `.json` checked-emission receipt. All direct modules must bind one checked
attempt/API/runtime/Base/driver, backend `direct`, and calling contract
`upstream-compatible-direct-v1`. TS sources, source/foreign files, emitted outputs
and declared direct support inputs retain exact hash checks. Earlier/manual JS
outputs cannot qualify through favorable results.

Each scenario runs in a fresh Node child with a 30-second deadline, 1GiB heap and
4MiB stack. Root must run the runner under the campaign's bounded tree RSS,
available-memory floor, CPU affinity and total deadline. The controller itself
is untimed; no results feed benchmark sample counts. All failed raw logs remain
in the fresh output directory; report failure stops promotion. These selected
scopes supplement, rather than replace, the broader frontend/backend/release gates.

Versions1 remain preserved as unexecuted initial plans/tools. Version2 explicitly
consumes both characters in the staged-order fixture, adds a public callable
callback and plain-input retention, freezes independent error oracles, and joins
all genuine candidate receipts to one selected compiler image.
