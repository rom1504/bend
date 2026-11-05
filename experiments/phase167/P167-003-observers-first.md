# P167-003: source-derived observers before dependency admission

Status: bounded additive source prepared; root owns acquisition and measurement.
No production or previously frozen experiment module is changed.

The raw-candidate census finds cyclic ordinary-call dependencies, including
String.cmp/cmp.fin. The maintained compiler already supplies a source-derived
borrowed reader and owning boxed wrapper for String.cmp; the matched baseline
machine census includes `$p118borrow.read.String.cmp`. This motivates moving a
general existing capability earlier, not adding a name-specific intrinsic.

`selfhost/tests/phase167/demand-observers.bend` exposes:

- `p167ob_plan(0,plan)`: plain segment emission plus checked live capability.
  Other modes refuse; this is not a synonym for all existing optimizer modes.
- `p167ob_request(request)`: one semantic lowering and statistics.
- `p167ob_lowered(request,lowered)`: independently admit and emit that same
  privately prepared result, avoiding a second lowering for diagnostics.

The entry first establishes checked request/runtime admission and the maintained
permission disjunction: `ns_definitions(book,names)` or `p118i_permission(request)`.
It then uses actual constructor/static preparation and the general
`p118e_workers(book,no_candidate_names(...),[])`. This helper's internal
`no_observer_plan(...,True)` is justified by that prior source-bound permission;
it is not an unconditional permission grant. Existing root-use, wrapper-use,
layout, source analysis and private-name collision conditions remain unchanged.

The initial workers are checked as private ordinary-call functions using
`p118b_project_functions` and `p118b_verify_projected`, with an independently
checked actual constructor catalogue and an empty scheduled-identity map. This
conservatively refuses a seed needing a scheduled identity. It supplies no fake
public header or generic body. The source-generated owning wrappers' original
public flags remain available only while matching their exact owner/arity to
source declarations with `p164a_allowed`.

Only those exact source owners are removed from subsequent raw candidate
production. The complete checked worker list and its signatures seed the
existing `p113d_passes`, using the existing reversed accumulator convention.
Other source owners retain raw candidate production and the normal demanded
generic fallback. Existing `p167l_functions` makes every final worker private.
An optional raw product sibling not supplied by the source worker bundle can
remain unavailable: skipping its source candidate is a conservative coverage
and code-quality limitation, not evidence that all siblings were replaced.

Final admission retains `p167v_original`: actual headers/constructors, generic
bodies, static image, and exact source/header/final-worker adapter obligations.
The direct-body stage uses the unchanged `p118b_verify_functions` on the entire
actual final private function list and actual final IDs. It projects each
readonly runtime import with the existing constructor/count/type contracts,
then runs the ordered direct checker. Source permission and root lifetime are
established by the retained source producer analysis; the projection checker
does not itself prove those source properties. No existing verifier is edited.

Emission uses `p167plain_chunks(...,True)`: genuine per-segment emission, no
legacy registry, and live transport only when its existing predicate succeeds.
No inlining, late product/borrow retry, original full-program optimization
pipeline, or new cold-constructor policy is restored. The host only transports
requests and results.

Statistics append six values to the original seven demand counters:
`selectedObserverOwners, seedFunctions, remainingSourceNames, rawCandidates,
finalFunctions, nonseedAdmitted`. Nonseed admission includes flat/helper bodies;
it is not automatically a rescued-caller count. Compute actual rescued worker
identities by comparing the final list against the frozen raw diagnostic for the
same request. Do not rerun the baseline candidate pipeline inside clean timing.

Required gates are source permission refusal, malformed borrowed import
projection, missing/changed seeded worker, ordinary adapter controls, complete
request output and generated execution against the independent oracle. Charge
observer analysis, early projection, demand construction, full final checking,
emission and teardown. Early analysis could cost more than avoided candidate
work; additional admission need not improve runtime. This experiment establishes
neither a tenfold cold-build forecast nor general compiler qualification by
construction.
