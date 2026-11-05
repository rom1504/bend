# Phase166 — complete backend work census

`selfhost/build/phase166/backend-census02/jobs.json` prepares two separate
root-owned guarded jobs: unchanged Phase165 Map and compiler-verifier inputs,
one actual checked `NR_Request` per case, complete mature-C then QBE emission,
and exact full C/QBE byte gates. Their already-completed finite machine gates
transfer only if both outputs remain identical. No API/image acquisition or
request-graph duplication is needed. Each job has 90s, 3 GiB RSS and 24 MiB disk;
an unexpected larger product can hit the whole-job cap before its individual
16 MiB limit. The instrumented API is 4,313,736 bytes outside each run root.

`prepare.py` authenticates the retained Phase152 checked API (`b5bda080…`), then
adds an observation-only generated-JS overlay. It records exact original
function spans, signatures/hashes and every injection for 49 named functions.
The authentic checked receipt remains unchanged; the runner separately imports
the instrumented copy and records that fact. This is generated-code observation,
not a new checked compiler or a compiler-source optimization.

**Stage boundaries.** First-entry snapshots reuse the Phase161 generic/private
lowering sequence: prepared static input → generic producer → generic finishing
→ signatures → private producer → SCC/dependency admission. Further snapshots
cover original verification, inlining, commit, retained final verification,
late composition, registry preparation and first cursor render. C snapshots
cover static preparation, worker planning, generic production, finishing and
final runtime/program assembly. C already builds text while lowering, so its
final assembly interval is not the same responsibility as all QBE rendering.

No timed wrapper forces a `$JMP` return: that would move deferred work or alter
stack behavior. Snapshots are at actual emitted-function entries. Adjacent
observed first-entry snapshots form disjoint chronological intervals, including
descendants, continuations, GC, IO and observer overhead. They are **not exclusive
function durations**. QBE's required ordered sequence has an explicit admission
result; if it fails, retain raw counts/events but do not label those intervals
as the proposed stage partition. Repeated marker entries are counted even though
only their first occurrence defines an interval. Later re-entry remains in the
then-active chronological interval. Never add these intervals to their enclosing
whole-backend clock or treat a call count as repeated full-program execution.

**Actual work.** Explicit nonempty-row hooks count generic owner visits, private
candidate rows, dependency-admission candidate visits, and registry candidate
rows. Named entry counters cover flat/boxed candidate construction, scalar fact
gets/puts and statement analysis, original/compact verifier statements,
rendered private/legacy/public units, usage/liveness requests and compaction
queries. `call:` means a generated JS function invocation, not every source
tail-recursive step; row hooks are separately checked against non-loop emission.

A lexical scan skips strings/comments and the retained runtime regexp. Only
literal object properties `$: "Tag"` become
`$: (__p166_object("Tag"), "Tag")`; evaluation value/order and trampolines stay
unchanged. There are **14,053 static instrumentation sites**. Their **dynamic**
counts, by tag and stage, distinguish generic records, lists, N111/P113 products
and `$JMP` scaffolding. They count JS tagged-object construction-site events,
not native allocator calls, physical JS allocations after optimization, bytes,
retained memory, or every untagged/dynamically-tagged object. They cannot directly
partition Phase162's 2.132B native-runtime residual allocations.

Counters use scalar increments without a per-event record; stage snapshots
copy the bounded count maps. Marker labels and object keys can still incur JS
bookkeeping. Hooks remain present but disabled during frontend
preparation. They still change generated code/JIT and impose counter overhead.
Diagnostic clocks must not replace Phase165 clean clocks. Large work disparities
can identify the next complete responsibility to test; a large count alone is
not proof that work is redundant or removable. No verifier or optimizer is
disabled. Host file writes, full output validation and finite machine evidence
remain visible.

Preparation01 stopped before any target because old request graphs had been
archived. Preparation02 excludes only those unread graph files, retaining their
descriptors through the pinned prior plans; all active source/API/providers,
product oracles and machine receipts remain authenticated. No target jobs were
executed by this source-preparation task.

## Independent overlay audit and source interpretation

Read-only inversion of the prepared overlay removes exactly 14,053 tag edits,
49 recorded function insertions and the observer prefix, recovering the exact
original API SHA256 `b5bda080852437823a6d7391c09bef8b467694f388daa5a18627ad480f9e50df`.
The separate producer-label v2 passes the same inversion. This establishes that
there are no additional text edits; complete output gates remain the semantic
test. Loop/first-entry and diagnostic-overhead qualifications above still apply.

The first Map census passes both complete output gates and ordered QBE stages.
It observes 37,558,377 QBE versus 29,832,738 C tagged construction-site events,
including 19,271,784 QBE `Tuple` events. These must not be called tuple-shaped
IR products: there are only 20 static Tuple sites in nine lexical producers.
Twelve belong to Base `String.cmp`, `.fin` and `.rec`, two to `Char.cmp`, two to
`nat_divmod`; the remainder are `array_rmw`, `Nat.show.put` and two cache-carrier
getters. `prepare-v2.py` / `observer-v2.mjs` and
`backend-census03/jobs.json` add dynamic Tuple/WCon counts by the containing
generated function (175 static sites), including nested closures. Those labels
are lexical production sites, not dynamic callers. Original methods stay frozen.

The executed Map producer census also passes both complete output gates. All
19,271,784 QBE Tuple events come from the comparison family: 9,090,734 from
`Char.cmp`, 1,090,316 from `String.cmp`, 7,504,256 from `.rec` and 1,586,478 from
`.fin`. C constructs 14,408,000 WCon objects at `u32_to_word` sites. These are
measured **hosted** construction events; neither lexical attribution nor their
size establishes equivalent native work or a native optimization ceiling.

Prepared body reuse is real: `native/book.bend:nc_compact_definition` directly
returns `NativeStaticBody.dv`; `qbe/static-data.bend:p112s_defs` already performs
the ordinary body compaction/static transformation. Generic and private owner
lookups do not establish duplicate compaction. The Map census confirms generic
production has 72 compact-definition queries but only 84 `nc_compact` entries,
while private production has 76 compact-definition queries and **zero** recorded
`nc_compact` entries. Native/foreign fallbacks and later prepared contexts remain
separate. Do not add another general prepared-body cache on this evidence.

Verifier lookups are not whole-environment linear scans: `p111v_get` hashes into
the KDef index; `p147v_get` hashes into its typed Patricia table, with linear
collision buckets only. Compact assigned flow uses numeric IDs. In contrast,
lowering `native/bridge.bend:nc_word` searches its `List<NC_Binding>` linearly.
Changing that private lowering environment would not directly remove verifier
lookup cost.

The hosted comparison census does **not** support making Tuple removal the
strongest native gain hypothesis. The independent
[native comparison audit](independent-hypotheses.md#hosted-stringcmp-tuples-do-not-transfer-directly-to-native-work)
checks the qualified Phase152 SSA: `$p118borrow.read.String.cmp` already uses
scalar character reads and a tail loop, without per-character Tuple or SCon
construction. Borrowed `String.eq` and `String.order`, and the composed
`p126sc_has`/`p126sc_call_has` consumers, call that reader directly. Ordinary
`$direct.String.cmp` builds exactly two return tuples per call; the owned
`String.order` fallback can reach that adapter. Retained generic/legacy entries
also exist, but their dynamic use has not been measured. Nullary comparison
constructors are immediate values, not heap allocations.

Routing remaining Base equality predicates to `p88_string_eq` could therefore
test a **hosted** reconstruction cost, with complete output and predicate gates.
It would not establish the same native benefit. A native Tuple-removal proposal
first needs actual ordinary-adapter/fallback counts on the complete workload;
the borrowed reader's remaining character/header work is a separate question.
Also, `p111v_get` itself uses `index_hash`/`index_find`, whose collision bucket
already uses `p88_string_eq`; it is not evidence for Base cmp reconstruction.
The native audit and the confirmed prepared-body reuse above are useful negative
results that prevent repeating optimizations already present in the compiler.

A smaller exact repeated-fact example is `scalar-facts.bend:p113k_join_record`:
it has already found the right record, then `p113k_get(right,name)` hashes and
looks it up again. `p113l_base_scalar` similarly queries a Set operand through
both `p113k_replace` and `p113k_value`. Reusing those exact immutable facts is a
small causal ablation with unchanged output/epoch rules, but Map's entire
inlining-to-commit interval is only about 280 diagnostic milliseconds. It cannot
explain the multi-second verifier/rendering gap. The earlier flat-binding use-set
sharing experiment was neutral and is not a new opportunity here.
