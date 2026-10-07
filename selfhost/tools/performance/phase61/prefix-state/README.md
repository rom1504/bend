# Request-context prefix checkpoint (unselected prototype)

`selfhost/src/check/prefix-state.bend` is a diagnostic-only Bend implementation.
It does not replace ABI2 or accept persistent/host-provided checked worlds.
Root must integrate and check it before any probe execution. No target has run.

Preparation receives the actual prefix and suffix, uses their exact whole-book
`norm_max_book`, performs unchanged `check_declarations`, and checks every prefix
event with the actual complete remaining event list. It retains the successful
`DChecking`, entire immutable `KWorld` (book, memo, fresh, checked), and `seen`.
The split worker duplicates only the chronological diagnostic worker's stop
condition; signatures, publication, failures and duplicate guards are unchanged.

Resume requires identical prefix values, constructor definitions, literals,
quantities and source intervals; identical ordered whole declaration headers;
identical whole-book fresh bound; no same-name prefix/suffix law fill; and a
successful preparation. Foreign values remain in the declaration key. Failure
of any predicate executes ordinary `dg_check_world` on the whole book. Source
origins are applied by the unchanged completion/diagnostic consumer.

This retains the whole request's predeclaration ordering and permits same-header
suffix body revisions/repeated requests. It **does not** prove Base-only state
can be extended to a different declaration context/fresh floor. Preparing a new
checkpoint costs the prefix checking work, so the first request has no claimed
saving. Prefix disjoint checks currently scan a cached suffix context; complete
key validation/transport/allocation must be included in later measurements.

Root-owned guarded probe (after checked integration):

```sh
NODE tools/performance/phase61/prefix-state/controls-v1.mjs ATTEMPT SOURCE NEW_OUT
```

Run from `selfhost/` under the existing single CPU3 process guard (1 GiB Node
heap, 2 GiB tree RSS, 4 GiB available-memory floor). Substitute the selected
frozen Node. The controller adds private lexical diagnostic exports, pins the
checked API/runtime/Base/driver/source and module hashes, reads actual source
through the unchanged loader, and compares whole checker outcomes with resume.
It never calls `prepareBase`/`inspect`, so historical driver cache paths are not
written. Its saved probe is a diagnostic derivative, never a checked image.

Initial falsifiers: successful repeated actual source; empty prefix; changed
prefix span; changed suffix header; changed fresh bound; cross-boundary fill;
failed prefix; same-signature body revision; warm checkpoint immutability.
Keep a failing source's world/diagnostic compared as well as acceptance. Retain
all failures. A broader Base-only certificate/rebase is a separate experiment;
never promote this checkpoint to the public raw API or serialize it as trusted.

## Immediate Base-only diagnostic (no new build)

```sh
/home/ai/.nvm/versions/node/v24.18.0/bin/node tools/performance/phase61/prefix-state/base-probe-v2.mjs build/phase58/checked-last01 build/phase61/prefix-base-probe01
```

Root supplies the existing external guard; run from `selfhost/`. This probes
only the already checked baseline using exact Base source intervals. It records
fresh state, generated names, live memo, completed-output maximum IDs and unresolved Ref
names. It reads loader inputs without invoking cache-writing APIs. A zero-mint,
empty-memo, closed-reference result would justify investigating a Base-only
rebase, not establish it: exact declaration/checked-output order and negative
lookup/constructor capture still need independent proof and full comparison.

## Cold-prefix candidate: not integrated or qualified

`base_prefix_prepare(prefix)` runs the actual checker and returns a compact
`KBasePrefixState{bound,delta,stamp,patches,ready}`. The publication order is
re-derived from the unchanged parsed Base book. Only checked definitions that
actually differ from that book are stored, not a second complete KWorld.
Preparation verifies the cached checked-publication order, exact world-book
replay, empty memo, closed Ref/ADT queries and absence of escaped fresh IDs.

`base_prefix_check(state,whole,prefix)` verifies exact prefix including spans and
Lambda quantity presence, then admits only disjoint declaration/constructor
names, no reserved synthetic `~`/kernel namespace, an actual bounded fresh floor
and a successful preparation. It rebuilds ordinary request declarations, replays
cached publications, restores seen/output order, translates fresh and cache stamp
by the whole-book bound offset, and invokes unchanged `dg_check_events` on the
suffix. Otherwise it calls unchanged `dg_check_world` on the original request.
The 1,048,576 admission bound is conservative refusal, not a broadened checker
resource budget. It does not by itself prove fresh-translation equivariance.

The measured baseline has source bound 3,412, next fresh 3,967, no memo/generated
names and checked/assembled maximum 3,412. These are necessary empirical facts,
not a proof that +555 or negative lookup behavior is invariant under extension.
The module remains unreferenced/unselected until moved-floor/context controls and
independent source audit establish that narrower contract. Required falsifiers:
several whole bounds, empty/novel ADT suffix, same-name/fill/constructor capture,
reserved names, changed Base/spans/quantity metadata, failed/rejected suffix,
live specialization/forward references and generated-name/memo/fresh exhaustion.
Compare **complete** world/memo/fresh/seen/checked output and first diagnostic,
not acceptance or assembled output alone.

Root alone owns driver/cache integration: exact API/Base/source-interval identity,
new prepared-payload schema and whole-payload integrity are mandatory. A source
cache marker, arbitrary host-created state, or unchecked disk sidecar cannot
create a trusted checkpoint. Old/missing/drifting state uses the complete path.
The raw checkpoint helper is private to the trusted inspector; it must never
turn public `check_program_diagnostic` into a caller-injected proof capability.

## Fast cold controls after checked integration

```sh
NODE tools/performance/phase61/prefix-state/cold-controls-v1.mjs ATTEMPT SOURCE [SOURCE...] build/phase61/prefix-cold-controls01
```

Root supplies the single guard. Use actual Numeric and MapSet sources first;
additional held-outs follow only after the focused contract survives. The tool
checks positive checker **and** complete-program outcomes, exact full versus
resumed world/index/memo/fresh/checked/first diagnostic, and actual check-call
counts. Per source: ordinary/repeated, three moved floors, five fallback cases;
plus an empty-suffix case. Wrong source validity or a refused preparation fails
rather than silently reducing the denominator. No clean latency is reported.
The older `controls-v1.mjs` applies only to the preserved request-context draft;
it is not the recommended cold-prefix command.

Integration signatures (root/driver owner only):

- `base_prefix_prepare(prefix) -> KBasePrefixState`.
- `check_program_diagnostic_seed(book, validated, origins, state) -> DResult`.
- State: `{$: 'KBasePrefixState', bound, delta, stamp, patches, ready}`;
  three U32 metadata fields, `patches: List<KDef>`, `ready: Bool`.
- Suggested private cache field `checkedPrefixState`, schema 1 and actual
  `base_prefix_prepare` producer; whole state/payload integrity plus exact
  API/Base/canonical path/source intervals. Freeze the nested state and book.
- Keep existing complete checker and cache validation independent. Never upgrade
  an old parsed cache into a checked state from its marker alone. A malformed,
  absent, false, stale or unauthenticated state uses the original full method.

Static review: source `94016ffec5955637a6f74e0cd2e7c89573e46d0da468dcd4179a0f3438c30ba5`
and cold controls `f8c153e4924f6645c015e6e95a3286354add284ffcb4ed80f20f0a2cc7b3cd63`
passed independent review for the private authenticated actual-Base scope.
This is not runtime qualification. The unchanged checker bridge remains live
until root freezes/builds the candidate and the complete differential passes.
