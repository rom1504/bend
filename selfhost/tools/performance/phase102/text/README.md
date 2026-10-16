# Iterative append on the original linked String ABI

This lane tests a general canonical String operation. It does not change String
storage, Char encoding, task ownership, application sources, or upstream code.
Root owns serial guarded compiler/build/program execution; preparation tools only
rewrite text or deserialize an already checked cache.

Current compiler integration uses the explicitly versioned `append-v2.bend`,
`integrate-v2.py`, `prepare-bend-v2.py`, `admission-fixtures-v2.mjs`, and
`check-admission-v2.mjs`. Unversioned files are frozen v1 evidence: its guard
missed checked App nodes whose non-owning metadata quantity is zero. V2 accepts
the parser's quantity one and the annotator's quantity zero while retaining all
ownership/signature/body checks. Consumed v1 bytes were restored against their
saved hashes and archived in `selfhost/build/phase102/text-method-archive01`.

## Saved-C mechanism experiment

`prepare.py` exposes `transform(source, reuse=True)` and a CLI. `--copy` disables
exclusive-cell reuse while retaining iterative control flow. `linked-append.c`
is its exact helper. `check.py` reuses authenticated Phase101 independent String
controls and baseline/upstream products; it builds only new candidates and checks
complete output at one, two and four workers. That check is a root-owned target.

```sh
python3 -B selfhost/tools/performance/phase102/text/prepare.py \
  --source SAVED_BASELINE.c --out selfhost/build/phase102/NEW
python3 -B selfhost/tools/performance/phase102/text/check.py \
  --out selfhost/build/phase102/NEW_CONTROLS
```

## Isolated Bend compiler candidate

`append-v2.bend` contains the bounded structural admission predicate, late native
segment rewrite, and exact C helper as a Bend String. `helper-provenance.json`
records the small mechanical conversion from the tested C helper. The selected
reuse branch and names differ; the lifetime operations do not.

Admission requires checked scoped permission, the canonical Base definition and
String/Char/U32 type owners, the exact owned signature, and this exact body up to
annotation erasure, binder renaming and source locations:

```text
match SNil:    lambda right: right
match SCon:   lambda head tail right:
                SCon(head, String.append(tail, right))
fallback:     impossible
```

The predicate checks quantities, child counts, empty removed-effect metadata,
binder names and IDs, distinct live binder IDs, constructor names and recursive
callee identity. A same-named user definition, unsafe definition, changed body,
noncanonical type owner or raw entry receives no permission.

The rewrite requires `$direct.String.append`, two `N_W64` parameters, one result,
and a direct frame. `nc_binding` produces `N_W64`; the initial `N_Box` draft would
have failed to activate and was corrected before target execution. The actual
parameter names are captured by `ne_take` before `WL_OPEN`, so the helper call
must use those names rather than reading the shadowed incoming registers.

Only host C selects the helper. Original segment metadata and device body remain.
The helper is emitted before worker declarations through the existing
`nc_with_show(..., workers, ...)` argument; `nc_helpers`, `runtime.c`, the runtime
template and its provenance are unchanged. No name-only `ni_template` intrinsic
is added, and existing partial-application adapters remain.

`integrate-v2.py` exposes both `transform_flat(source)` and
`patch(whole_source, equal='p88_string_eq') -> (source, reversible_edits)`.
`integration.patch` shows the canonical `nf_finish_ready` change. For a canonical
source tree add `append-v2.bend` to the candidate native module manifest. For the
installed Phase98 derivative use:

```sh
python3 -B selfhost/tools/performance/phase102/text/prepare-bend-v2.py \
  --out selfhost/build/phase102/NEW_APPEND_SOURCE
```

The prepared artifact `selfhost/build/phase102/append-bend-source03/changes.json`
is accepted by Phase102 `build-api.py`; the candidate adds 149 physical lines.
It is an experiment, not an installed native compiler or qualified B1/B2 chain.
The root can apply `integrate.patch` after the typed lane's source transformation
and concatenate their reversible edit records for a combined candidate.

## Guard fixtures and qualification

`admission-fixtures-v2.mjs` authenticates and decodes a saved checked Base cache
without importing a compiler. It saves the actual append KTerm and eighteen body
cases: three valid bodies, including the actual checked Base and alpha renaming, and fifteen independent
structural changes that must be refused. Generated artifacts belong under
`selfhost/build/phase102/`, not this method directory.

```sh
node selfhost/tools/performance/phase102/text/admission-fixtures-v2.mjs \
  selfhost/build/phase102/NEW_ADMISSION_FIXTURES
```

`check-admission-v2.mjs` is a **root-owned compiler API target**. It currently consumes
`selfhost/build/phase102/append-admission-fixtures03` and checks the body cases,
raw/unsafe/type/owner permission refusals, exact segment activation, unsupported
entry fallback, preserved metadata and device code, and the helper literal's
exact derived bytes. Export `nx_append_body`, `nx_append_allowed`,
`nx_append_segments` and `nx_append_helper` when acquiring the candidate API.

```sh
node selfhost/tools/performance/phase102/text/check-admission-v2.mjs \
  CANDIDATE_CHECKED_API.mjs selfhost/build/phase102/NEW_GUARD_RESULT
```

Finite controls are not a whole-compiler proof. General recursion modulo
constructor is a distinct follow-up: its admission must account for evaluation
order, prefix effects/ownership, partial-result cleanup, constructor layout and
unpublished result holes. The narrow append guard earns one implementation while
that more general pass is evaluated independently.
