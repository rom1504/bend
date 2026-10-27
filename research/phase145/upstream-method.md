# Comparing actual upstream work without another compiler build

This investigation uses the immutable Phase66 implementation: `bend.ts`
`1d133151…fe49`, `comp.ts` `2b13224b…629c`, Base `99ac43f2…facf`, and Bun1.4.3.
The comparison subject is final04 Bend source `865cff6a…745c4ed`; this method
neither modifies that source nor acquires another compiler image.

The bounded inputs are the exact Phase88 Lexer, Closures256 and Map128 programs,
plus the independently checked21,869-byte actual compiler Patricia-index slice
from Phase144. The1024-declaration compiler prefix is included **only as a
parser workload**: its dependency closure and whole-program validity have not
been established. It is not used for a successful check/emission speed claim.

The root-only commands are in `selfhost/build/phase145/upstream03/jobs.json`.
Run generated-artifact preparation, then original/clean/counted Lexer before
continuing. Every job uses CPU3,3GiB process-tree RSS,16GiB available-memory
floor and a bounded deadline. No Clang, machine build, compiler self-build or
benchmark execution is included. Version01 metadata was prepared but not run;
version02 corrects preservation of named exports in transpiled wrappers. Its
preparation refused a whitespace-sensitive loop anchor after0.351s, before any
compiler workload ran. Version03 matches a unique generated label across
whitespace while retaining exact reversible edits; the failed receipt remains.

For each input, three fresh processes perform the same requested actions:

1. Import the pinned original TypeScript, load the real source, check it and
   emit complete C. This produces the independent output oracle.
2. Import its clean Bun-transpiled JavaScript, performing the same actions and
   requiring complete C byte identity against1.
3. Import an observational derivative of2, with the same output requirement.
   Removing its appended wrappers and reversing the recorded declaration/point
   edits must recover2 exactly. Pinned upstream files stay unchanged.

`base.bend` in each derivative directory is only a symlink to the pinned file;
`book_load` resolves its actual original path. Real foreign/effect sources are
pinned too. This keeps source qualification and embedded effect paths stable.
Hash verification brackets execution. Observers save failed reports and actual
outputs; no failed diagnostic is silently accepted as an optimization result.

## The architectural distinction worth measuring

Upstream `book_valid` checks a definition and assigns `tld.e = def_check(...)`
(`bend.ts:3875`). `def_check` returns `term_check(...).tm` (`bend.ts:3736`). The
checker builds the checked runtime term while checking, rather than scheduling
a separate whole-book erasure pass. For example, `term_check` constructs a
checked match from its already checked branch results (`bend.ts:3655–3658`).
The backend's `fun_of` raises `tld.e` back into its higher-order representation
and memoizes the result (`comp.ts:1169`). This is an existing reusable producer
product, with conversion cost and semantic obligations still present.

Our source has separate `annotate_selected`/checked-context construction and
reachability/layout/erasure steps before raw lowering. The earlier native profile
measured annotation6.42s and erasure6.11s, plus layout and context work, in
final03—not final04. Upstream's arrangement is evidence for investigating
producer-consumer reuse; it does not prove that our separate steps are redundant
or that its product satisfies our stronger native admission obligations.

Upstream is also **not a one-pass emitter**. `compile_book` resets emitted
segments and selected caches, then re-emits until ownership/hot/static fact
cardinalities stop changing (`comp.ts:2768–2810`). The diagnostic records every
round's three starting sizes and final sizes. `file_book` performs reachability,
type dependency discovery and scalar/flat facts before that loop. Comparing only
one named emitter call would hide its repeated work.

## Counts and clocks have separate meanings

Top-level clocks report import, load, check and complete C emission separately.
`parse_book` is nested in load; `def_check` is nested in checking. Internal stage
records include inclusive and exclusive-of-other-observed-stage clocks, not
exclusive CPU instruction costs. Erasure is fused with checking, so the report
explicitly has **no standalone upstream erasure time**.

The generated-copy counters measure:

- Actual entries into parser, checking/inference, conversion/normalization,
  persistent-map, backend analysis and emission functions, including recursive
  entries that the older Phase83 exported-wrapper method missed.
- The tag and distinct object identities presented to selected term functions.
  Identity revisits reveal repeated presentation of a shared node, not semantic
  equality, mutation independence or necessarily wasted work.
- Actual `term_wnf` focus-loop iterations, including internal loop progress that
  function-entry counters alone miss.
- Definition checking by name, `Check` result construction, backend memo
  hits/misses, emitted statement-text UTF-16 units and ownership fact rounds.

These are separate quantities; do not add them into a universal "operations"
number. One normalization entry can perform many focus iterations. One Map call
can inspect a variable-sized key or allocate a path. UTF-16 units passed to
`file_push` are neither heap allocation bytes nor final UTF-8 output size.
Repeated rounds may be required to discover facts. A missed memo lookup incurs
an extra diagnostic lookup; timing that observer is not a clean result.

The meaningful correspondence with our compiler is at semantic boundaries:
`term_check`/`term_infer` versus `check`/`infer`, declaration-body checking,
normalization, constructor/identifier lookup, runtime-term production, and
reachable-body analysis. Counts across different representations or helper
factoring are not automatically comparable. Match the actual input, source/Base
participation, checked definition set and semantic result before interpreting a
count ratio. C emission and direct QBE emission perform different backend work.

This upstream path loads and checks Base source in every process; our ordinary
native path decodes a prepared Base. Both costs remain visible. A ratio of their
complete totals is a comparison of those workflows, not an equal-work language
or execution-backend speed ratio. No new compiler parity claim follows.

## Cheap next discriminator

Join these observations to final04's existing/native and checked-API stage
observations on the same three source files and the real index slice. First ask
whether disproportionate work is in repeated normalization/conversion, wide
record reconstruction, verification passes or generated execution cost. Then
freeze one complete producer→verification→consumer computation, including
conversion, cleanup and unchanged final checking. Test reusable local IDs/facts
there before a new full compiler acquisition. The11.06% compact-verifier result
remains a slice result, not evidence of a whole-pipeline speedup.

Offline summarization uses:

```sh
python3 -B selfhost/tools/performance/phase145/upstream/summarize.py \
  --plan selfhost/build/phase145/upstream03/plan.json \
  --out selfhost/build/phase145/upstream03/summary01.json
```

The summary refuses an existing destination and preserves missing/failed cases.
Single fresh observations are an information screen, not confidence intervals.
No target was run by the preparing subagent; execution results must be appended
only after the root-owned jobs finish.

## Completed root execution

All16 upstream03 jobs subsequently passed in31.781 seconds of guarded wall.
See [actual findings and scope](upstream-findings.md) and the pinned
`selfhost/build/phase145/upstream03/summary01.json`. The original compiler source
remains unchanged. Preparation and offline analysis were performed by the
subagent; all compiler workload execution was performed by the root.

## Optional full-source parse discriminator

A separate prepared two-job plan at
`selfhost/build/phase145/upstream-full-parse01/jobs.json` uses the exact frozen
Phase142 input (`15f5cada…7dac1`,2,946,225 bytes), pristine upstream then the same
counted generated artifact. It is parse/load only, including Base, with a30-second
and3GiB bound per job. The initial191,922-byte prefix took0.308 seconds to load;
this justifies the bounded attempt, not a linear runtime or memory guarantee.
No checking, erasure, output generation or new instrumentation is authorized by
this extension. Loader summaries are checked, not complete structural AST equality.
Root execution and actual observations remain separate from this preparation.

The full-source extension has now executed successfully: original loader2.583s,
counted5.023s, with matching loaded summaries and no checking/emission. Results
and source-shape limits are in [upstream findings](upstream-findings.md) and
`selfhost/build/phase145/upstream-full-parse01/summary02.json`. The entire
extension cost9.334 guarded seconds. The loader includes resolution/conversion;
it is not a raw-syntax-only measurement.

The generic worker's historical scope boilerplate incorrectly says Base was
checked on every request. In the prefix/full parse-only variants, the actual
branch never invokes `book_valid`; Base is loaded and parsed only, and
`erasedBodies` remains0. Preserve those receipts and use this corrected scope.
