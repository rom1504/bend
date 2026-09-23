# P5-020 — declaration freshness after successful graph elaboration

Preregistered during P5-015's timing hold. Owner: direct_calls. The original plan
below was recorded before implementation. Correctness: selected gates passed,
with explicit residual failures. Measurement: bounded accepted-path cost gate
found no material regression. Decision: scoped promotion at 23:54:26 UTC.

## Hypothesis and boundary

Some declarations shadow already defined imported/Base names but reach the
checker instead of failing in the frontend. Examples include
`import/duplicate_name`, `import/shadow_lib`, `import/shadow_tmpl_lib` and
`parse/reserved_def_name_000`. A frontend validation of the completed declaration
event stream can reject these successful parses without changing acceptance,
ordinary law filling or existing parser/elaborator errors.

Run the new validation **only after existing parsing and elaboration succeed**.
Preserve an existing error verbatim. Walk events chronologically, maintaining the
latest prior declaration for each fully qualified name; a first-match lookup in
the uncollapsed chronological list is insufficient. Keep constructor names and
top-level definition/family names in their existing separate namespaces. Do not
reinterpret import aliases as declaration namespace qualification.

Pinned TypeScript permits filling an ordinary, non-native, non-foreign unfilled
law. The merged representation also marks Base's own law and body events native
after parsing: a native-to-native Base law fill must remain valid, while a later
user declaration cannot fill that native declaration. Type/signature agreement
and all other checker rules remain in the checker. The candidate must not turn
checker equivalence tests into frontend work.

## Explicit limitations

The current host parses a module before discovering its dependencies. This
post-success repair cannot reproduce an imported duplicate that should precede
a later raw parser error, dependency-error versus main-parser-error ordering,
or imported law filling rejected by the existing standalone parser. It also
does not repair declaration source locations lost before this pass. Report phase,
reason and exact diagnostic agreement separately; matching rejection alone is
not exact conformance.

## Cheap gate and promotion

After the parent releases the timing hold, create an isolated source overlay
from the current integrated source and genuinely bootstrap it. Compare baseline,
candidate and pinned TypeScript on the four examples and neighbors:

- ordinary local law then body, repeated completed definition, and filled foreign
  definitions;
- Base/native collisions and Base's own ordinary law fills, with seeded and
  unseeded loading;
- namespace-local definitions, aliases versus canonical module names, and legal
  constructor/top-level spelling overlap;
- an earlier invalid pattern followed by a duplicate, an earlier checker error
  followed by a duplicate, and the explicitly deferred later-raw-parser-error
  case;
- imported failures, open ordinary laws, and local scope shadowing.

Retain exact raw observations and all failed attempts. Stop on any changed
acceptance, lost existing parser error, new positive failure, Base seed mismatch
or unbounded duplicate scanning. Request independent review before copying any
source into production. No broad sweep or timing claim without parent approval.

## Outcome

The first checked prototype retained a prefix book with `book_put`; static cost
review identified unnecessary filtering on law fills. Candidate02 uses the
existing `index_find`/`index_set` tree directly, hashing each event name once.
This is a separate retained prototype, not a silent edit to the first build.

Forty-five paired observations resolve 18 acceptance/phase differences with zero
new exact differences. Eight positive fixtures match exactly. One native-law
control repairs an actual checker false acceptance, so the final scope is broader
than rejection-phase repair alone. Four imported-law-fill semantic differences
and 28 exact differences remain. Compact_index gave scoped static approval.
Thirty accepted-path timed requests and ten seeded/unseeded equality checks pass;
no speedup is claimed from the lower candidate totals.

Only `src/load/graph.bend` was promoted after archive verification and an original
hash guard. See the [report and preserved attempts](../../implementation/phase5/imported-freshness.md).
