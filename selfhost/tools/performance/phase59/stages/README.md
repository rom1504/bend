# Ordinary first-request stage clocks

These are diagnostic copies for the installed Phase58 last01 B2 versus pinned
TypeScript investigation. They change neither compiler source nor installed
files. Root owns all executions; preparation/measurement belongs to the separate
Phase59 latency method. No stage tool imports or executes a compiler.

## Preserve the measured window

Frozen Phase58 `latency-method04/worker.mjs` measures three adjacent intervals:

1. Host import: B2 imports the ordinary driver; TypeScript imports `bend.ts` and
   `comp.ts`.
2. API load: B2 calls ordinary `D.loadApi()`; TS records zero because its API is
   already imported. B2 includes actual module import and ABI checks here.
3. First request: the existing `compile(row)` call. This includes its ordinary
   status/ABI assertions, but ends before output byte validation, hashing or save.

The published combined measure adds those three intervals. It excludes process
startup, static worker-helper imports, identity preflight, Base-cache priming,
prepared-oracle execution and the post-return output checks. Do not import the
actual target API or issue a preliminary request in the measured fresh worker.
The existing profiled Phase58 loop ran *after* first/later requests and included
validation; it does not explain this first combined interval directly.

B2 uses its already primed private Base disk cache, with a fresh process and
ordinary request-local book. Its request still hashes the API and Base, reads
and parses cache JSON and validates cache/source spans. Keep all this work. Do
not introduce a persistent inspector or silently subtract cache validation.
Pinned TS uses `book_nil`, `book_load`, `book_valid`, then `js_lib(book,true)`;
this method does not inject a corresponding decoded Base cache into TS.

## Actual stage map

The exact driver is SHA256
`eb4bb871371fb2fb61fa1c077d093a817a1f6ae35205ebb2beecfb6e064fc417`.
The producer refuses another source version. The relevant ordinary source is
[`typed-driver.mjs`](../../../typed-driver.mjs), functions `loadApiForIdentity`,
`inspectWithMemo`, `discoverSources`, `readBaseCache` and `validateSpanCache`.

| Driver stage | Included work / interpretation |
| --- | --- |
| `driver.api-load` | Module lookup/import and ABI checks; repeats inside ordinary inspect with an already loaded URL. It is not always a new module evaluation. |
| `driver.base-identity` | API/Base byte hashing, path and source-text reads, cache path selection. |
| `driver.base-cache` | Cache read, JSON decode and validation; nested validation is reported separately by exclusive time. |
| `driver.cache-validation`, `driver.span-validation` | Source/cache identity checks, reserialization hash and graph span validation. These remain inside request cost. |
| `driver.source-graph` | Files/import traversal, namespace/source completion and host graph assembly; child source-header/completion/span stages identify their shares. |
| `driver.prepare-base` | The unchanged cache-miss preparation branch, if actually reached. No artificial call is added. |
| `compiler.check-and-complete` | `check_program_diagnostic` for current ABI2, including ordinary checking, specialization/completion and TODO result. It is not a pure type-check-only interval. |
| `compiler.owned-layout`, `compiler.context`, `compiler.roots-and-stops` | Existing ownership admission and private emission context/root/native-stop planning. |
| `compiler.source-reach`, `compiler.annotation` | Original source pruning and typed annotations. |
| `compiler.emitted-reach` | Actual emitted dependency analysis, including result/error extraction; not just a generic graph walk. |
| `compiler.foreign-check`, `compiler.layout-proof` | Existing foreign admission and runtime-layout verification. |
| `compiler.foreign-paths`, `compiler.foreign-modules` | Exact foreign-path collection and module production; source/resolver child stages keep host work visible. |
| `compiler.library` | Unsplit actual `jd_library_selected`; context/SCC facts, definitions and host exports remain bundled. No diagnostic decomposition replaces the call. |
| `driver.output-assembly` | Host prefix, runtime-file read and final code concatenation. |
| `driver.inspect` exclusive | Remaining dispatch/control, ABI selection, report/error handling and host bookkeeping not assigned to a narrower stage. |

At the TS worker's existing call sites, use `ts.book-load`, `ts.book-valid` and
`ts.js-lib`. `book_load` includes file/import traversal and parsing; `book_valid`
can create/check live instances. `js_lib` includes root selection, `file_book`
analysis, definition/effect emission, host export conversion and final text.
These are faithful executable boundaries, not a claim that each matches one B2
stage. `first-request` exclusive retains book creation and wrapper assertions.
No TS source or compiler function needs replacing for these first-level clocks.

## Source comparison and limits

The two request paths solve the same checked library task through different
host representations. Pinned TypeScript starts with `book_nil()` and a fresh
import `Map`, loads source files into its native book, validates that book in
place, then calls `js_lib`. The selected B2 enters the ordinary typed driver,
which carries named compiler terms and source-range metadata across its API.
Neither path is merely printing an already checked user program.

B2's prepared Base cache removes repeated Base parsing from the normal hit path,
but it does not make the cached book free. `baseCacheInfo` hashes API/Base bytes
and reads Base text. `readBaseCache` reads and JSON-decodes the saved graph;
`validateSpanCache` checks identities and reserializes the book for its recorded
hash, then `validateSpanBook` walks the object graph to check source ranges and
literal payloads. The loader also validates newly parsed source books. These
are actual request operations, separate from the harness's untimed provenance
checks. Their stage costs must remain in the combined numerator.

The ordinary call uses no persistent inspector memo. A fresh checked request
also establishes its own definition and live-instance world. A validated disk
cache is not permission to reuse arbitrary completed specializations or mutable
request state. The current ABI2 `check_program_diagnostic` bundles checking,
live-instance work, assembled specialization and TODO completion. It would be
incorrect to attribute its whole interval to type comparison, or to add a second
specialization interval that this driver branch never executes. TypeScript's
`book_valid` likewise performs live-instance checking within validation.

Emission also has different boundaries: B2 exposes source reach, annotation,
emitted reach and layout checks before an unsplit library call; TypeScript
performs its graph, definition and host-export work within `js_lib`. A larger
stage does not prove redundant work. Memoization, omitted validation or changed
stage boundaries would require separate semantic and identity evidence. This
information-only campaign measures the existing paths and preserves those costs.

## Integration interface

During preparation, first stage the ordinary driver with its exact image inputs.
Create a new adjacent derivative without importing either target:

```sh
python3 selfhost/tools/performance/phase59/stages/derive-driver.py \
  selfhost/build/phase59/PRIVATE/project/tools/typed-driver.mjs \
  selfhost/build/phase59/PRIVATE/project/tools/typed-driver-stages.mjs
```

The output has an adjacent `typed-driver-stages.derivation.json`. Keep the
original image-driver identity and this diagnostic derivation as separate
bindings. The same directory preserves the original project/runtime resolution.
All original bytes recover by reversing insertions. Original return expressions,
API arguments, statement order and Promise behavior remain unchanged; clocks add
function `try/finally` and concrete-call markers only.

Import `createStageClock` and `STAGE_SYMBOL` from `clock.mjs` in the stage worker.
Before the actual measured target import, install
`globalThis[STAGE_SYMBOL] = createStageClock()`.
Use synchronous `begin(name)` and `end(token)` around the original awaited calls:

```js
const token = clock.begin('host-import');
try { await load(image); } finally { clock.end(token); }
```

Repeat for `api-load` and `first-request`. Within the TS compile function, bracket
the existing `book_load`, `book_valid` and `js_lib` calls the same way, assigning
their original results directly. Do not turn synchronous calls into Promises.
The initial stage tool does not enable inspector recording or serialize per-call
logs. Obtain `clock.snapshot()` only after the roots close; perform original
output validation/hash/save afterward and retain every ordinary oracle.

Snapshots contain nested inclusive times, child totals and exclusive residuals.
**Sum exclusive times**, not nested inclusives. Their sum must match the sum of
the three nonoverlapping roots. The monotonic clock checks this identity. A
source exception/early return can skip a concrete-call end marker; the enclosing
finally closes and labels that child `incomplete`. Successful requests require
zero incomplete events; an errored request is not a completed-stage pass.

Hook overhead and instrumentation may change JIT/GC and timing. Stage observations
are diagnostic wall times, not clean latency or quantitative CPU attribution.
Use the planned three rotated rounds × two inputs × two roles, with unchanged
prepared output oracles. Code/body equivalence, clean timing and CPU/allocation
profiles are separate evidence, not inferred from stage sums.
