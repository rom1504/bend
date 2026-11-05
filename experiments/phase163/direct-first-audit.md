# Phase163: a concrete direct-first QBE subset

Source-only audit at Phase163 start `a8b5989`. No compiler, build, benchmark,
or generated target was executed. Qualified generated code was inspected as
text; a streaming offline scan followed ordinary call symbols. This is an
implementation proposal, not a new correctness or performance result.

## Recommendation

Start the materialization change with the existing boxed `book_final_reverse`
worker, then the complete **definition lookup cluster**. Both are real compiler
code. The latter already has a closed set of **16 native direct workers** in the
qualified executable. It covers boxed records, list/tree traversal, strings,
reference management and borrowed observations. It is considerably more useful
than a scalar arithmetic demonstration, and needs no new recursion semantics.

The first benefit under test is avoiding construction and processing of scheduled
bodies which the final implementation does not execute. These workers are
**already direct at runtime**: promoting this subset cannot honestly be described
as converting its execution from a trampoline to native calls. A second, distinct
experiment must demonstrate new direct coverage for currently scheduled code.

Do not start by replacing `constructor_exists` with an early-exit loop. Its
current native code evaluates the recursive suffix before combining Boolean
results; this is a non-tail, eager fold, not a short-circuit search.

## Current implementation, not a proposed cache

The maintained entry is
`selfhost/src/back/common/constructor-facts.bend:193–222`:

1. `p144o_lower_request` obtains the checked native request and constructor facts.
2. `p144o_catalogued` calls `p112s_prepare`.
3. `p144o_lower_bangs` runs both `p111_compile_defs` and `p113pl_candidates`.
4. `p128raw_plan_finish` applies tail-pair SCC composition and dependency admission.

`p112s_defs` already creates a `NativeStaticBody` for every reachable ordinary
definition (`back/qbe/static-data.bend:162`). `nc_compact_definition`
(`back/native/book.bend:103`) returns its cached body. The opportunity is separate
downstream lowering, analysis, segment materialization and registry work, not
adding another common-body cache.

The existing direct IR is sufficient for ordinary **boxed** arguments/results:
`P113DStmt`, `P113DFunction` and `P113DCandidate` in
`back/qbe/model.bend:243–272`. It has ordinary calls, conditionals, scalar runtime
operations, results and `P113DAgain` loops. A candidate does not require a flat
product result. `p113d_candidate` builds a one-word boxed result from the prepared
body (`direct-lower.bend:213`); the selected product path's original candidate
also retains this boxed route (`typed-regions.bend`, `p126s_original_candidate`).

## Exact observed native cluster

Evidence is the qualified Phase152 N2 QBE file
`selfhost/build/phase152/native-n2/program.ssa`, SHA256
`1032c6a6495ca86bb26ad2bcd7ae639ed49dc987765dfe567dce7ac6224bf7bb`.
The hash is the existing qualified identity, not newly recomputed here.

Names below are decoded from decimal-byte symbol names. `p113d_` denotes the
ordinary native worker. `$direct.` **inside a name is insufficient evidence**:
a `p111_FID_...$direct...` symbol can still be a scheduled segment.

| Ordinary worker | QBE line | Direct callees, excluding runtime |
| --- | ---: | --- |
| `$direct.lookup` | 295477 | `dc`, `index_find`, `index_hash`, `p137q_is_cache`, `p137q_name_eq` |
| `$direct.dc` | 53095 | none |
| `$direct.dn` | 55919 | none |
| `$direct.index_find` | 208836 | `index_bucket`, `p88_string_eq_go` |
| `$direct.index_bucket` | 208718 | `dn`, `p88_string_eq_go` |
| `$direct.index_hash` | 2205 | borrowed-read and owned `index_hash` workers |
| `$direct.p137q_is_cache` | 198164 | `p88_string_eq_go` |
| `$direct.p137q_name_eq` | 198146 | borrowed-read and owned name-equality workers |
| `$direct.p88_string_eq_go` | 3387 | borrowed-read and owned string-equality workers |
| `$p118borrow.read.index_hash` | 2103 | none |
| `$p128borrow.owned.index_hash` | 2022 | none |
| `$p118borrow.read.p137q_name_eq` | 197856 | borrowed string equality and `p98_eq_finish` |
| `$p128borrow.owned.p137q_name_eq` | 197688 | `$direct.p88_string_eq_go` |
| `$p118borrow.read.p88_string_eq_go` | 3136 | none |
| `$p128borrow.owned.p88_string_eq_go` | 2948 | none |
| `$p118borrow.read.p98_eq_finish` | 3415 | none |

This is the transitive ordinary-call closure of `$direct.lookup` in this emitted
artifact, not the entire source dependency closure. Constructor/static tables,
runtime support, closure entry points and ownership plans remain required.

The remaining called runtime symbols in that closure are `p111_rt_fail`,
`p111_rt_keep`, `p111_rt_sink`, `p111_rt_take`, `p111_rt_special_ctor`,
`p111_rt_special_take`, `p125_rt_ctor2`, `p125_rt_take2`, `p125_rt_take4`,
`p118_rt_borrow_scalar_safe`, and `p118_rt_borrow_fields`. There are no calls to
`p111_rt_jump` or `p111_rt_return` inside these 16 workers. The inter-worker call
graph is acyclic; their input-dependent iteration stays inside workers.

Source owners include `core/term.bend:378` (`lookup`),
`core/index.bend:66,116,177` (`index_hash`, `index_find`, `index_bucket`), and
`back/common/query-boundaries.bend:139,155` (name/cache observations).

For an even smaller integration probe, `$direct.book_final_reverse` is already a
51-line native worker at QBE line17330. It depends only on `p125_rt_ctor2`,
`p125_rt_take2`, and `p111_rt_fail`. Its self-recursion is a native loop. This is
the lowest-cost place to prove the new generic-body omission interface before
including borrowed worker composition.

## Legality and ABI contract

Use a closed, positively admitted subset; retain the existing scheduled fallback
for every other owner. The initial admissible class is ordinary non-foreign,
non-native, non-bang definitions, with at most32 argument words, one boxed result,
supported prepared nodes, and all direct callees admitted. These match the
existing candidate boundaries (`direct-lower.bend:228`). Do not infer eligibility
from the source function's name or a successful type check alone.

1. **State and word representation.** The direct ABI is
   `(state, argument words...) -> word`; state is borrowed, boxed words keep the
   current runtime representation. `p113e_private` emits it
   (`verify-direct.bend:333`). Multi-result workers use a different out-buffer ABI
   and are unnecessary for the first subset.
2. **Ownership.** Preserve the candidate's generated `keep`, `sink`, `take` and
   constructor operations, liveness partition, argument order and failure paths.
   For borrowed variants, preserve the safety selector and the corresponding
   owned fallback; a raw borrowed descendant cannot outlive its owner. Removing
   the generic body must not silently remove ownership planning or its checks.
3. **Stack safety.** Self-tail edges become `P113DAgain`; arguments are snapshotted
   before parameter moves (`verify-direct.bend:237–252`). Ordinary calls in the
   selected closure form a DAG, hence native call depth is bounded independently
   of list/tree/string length. Existing tail-pair SCC conversion additionally
   requires a call immediately followed by its exact result and compatible
   arities (`product-composition.bend:550–669`). Do not admit a general recursive
   SCC merely by predeclaring its signatures.
4. **Scheduler and closure entry.** External scheduled callers still need the
   function's registered ID and wrapper. `p113e_public` loads scheduler argument
   registers, calls the native worker, and returns through `p111_rt_return`
   (`verify-direct.bend:363`). Unsaturated references also need the existing
   zero-argument closure factory/eta entry. Removing the ordinary function's
   generic worker is not permission to drop that factory.
5. **Static identity.** Preserve constructor schemas, static nodes, source-name
   resolution, function arities, incoming frame obligations and effect flags.
   `N111Ids` currently obtains function metadata from original segments, not just
   the direct candidate list. Deterministic remapping may be legitimate, but must
   update every use and is a separate output/qualification boundary.
6. **Independent verification.** Retain both the existing original/fallback
   verification and direct-program checks for the portions still represented.
   `p113e_verify_original` builds `P113Original` facts from original segment
   headers (`verify-direct.bend:20,197`), and `p113e_verify` first verifies the
   original static program (`:211`). Empty bodies or fake successful fallback
   verification are not a substitute for a verified direct-only entry.

## Smallest implementation change that actually removes work

Separate **entry metadata/factory production** from **scheduled body lowering**.
`p111_entry` currently builds the factory, then `p111_extend` lowers the prepared
body a second way to produce the scheduled `$direct.*` entry
(`back/qbe/lower.bend:613–649`). After positive direct admission, construct the
required factory and explicit direct-entry descriptor without that body and its
continuation segments. For the pilot, all other definitions take the unchanged
`p111_compile_defs` route.

The new descriptor must be validated against the direct function signature and
constructor/static catalog by the independent verifier, then rendered by the
existing scheduler wrapper. This needs a real representation/interface change:
the present `P113DProgram` contract says the original verified static program is
always retained. Merely filtering final QBE text, inserting empty segments, or
passing a forged original-verification certificate does not implement this plan.

Prefer first using `book_final_reverse`, which needs no borrowed helper
composition. Then admit the lookup closure while preserving the existing
borrowed/read/owned workers and their checks. The final 16-worker closure is an
observed target, not proof that all16 are available at the earliest candidate
stage: several are produced by later ownership composition. Either move the
required planning before generic-body selection or leave those owners on the
fallback route until their final direct replacement is known.

An intermediate diagnostic can retain original bodies for checking but remove
their downstream registry/render work. That isolates downstream savings, but
does **not** test savings from avoiding generic body construction. Name the
boundary accurately in its receipt.

## Currently scheduled code and the first expansion obstacle

In the same qualified output, `constructor_exists` (line1363203), `f_ctor_lookup`
(1024311), `book_final_scan` (1320838), and `p143cp_canon` (662138) have scheduled
`p111` entries, without corresponding ordinary `p113d` workers of those names.
Their presence in `$direct.*` source names must not be counted as native direct
execution.

`constructor_exists` is a particularly informative negative control. Source
`check/kernel.bend:1156` combines the current row's Boolean with recursive rest
using `||`. Generated QBE saves a Boolean continuation, recursively jumps to the
same scheduled owner, then calls `p111_rt_op` with operation68 to combine the
values. This confirms non-tail evaluation in the selected implementation. The
existing direct lowering explicitly rejects a non-tail self call
(`direct-lower.bend:91`).

A legal future transformation could recognize a total associative Boolean fold,
carry an accumulator, and **still evaluate every row in the same order**. It
would need to preserve evaluation of each row's lookup and the final result,
including error/invalid-shape behavior. Early exit when the accumulator becomes
true is a different transformation and is not justified by the present audit.

`f_ctor_lookup` has nested child traversal followed by resuming the rest; ordinary
unbounded native recursion would lose the existing stack-safety guarantee.
`book_final_scan`/`book_final_step` also depend on `index_set`/`p131i_insert`, which
are not ordinary native workers in this artifact. These require a larger closed
conversion or a direct-to-scheduled bridge; they are not the cheapest first
subset.

## What the first controls must establish

The root-owned experiment should retain the complete old/new verifier outcomes,
selected owner list, direct-call closure, number of omitted scheduled bodies and
continuations, and number of retained wrappers/static nodes. Compare complete
observable lookup results on hits/misses, collisions, caches, duplicate names,
deep indexes and shared owners; use a long reverse/list case for stack safety.
Then check an actual compiler request, including the final output and failure
behavior, before timing self-compilation.

No speed estimate follows from the16-worker count. Phase161 measured11.59s of
generic-body production,26.78s of private-candidate production, and substantial
later registry/render work on a full diagnostic request. Removing selected
generic bodies can remove only their contribution plus demonstrated downstream
work. General direct-first lowering could eventually change much more; this
small subset tests the required interface and correctness contract first.

## Additive workloads prepared for the root-owned screen

`selfhost/tests/phase163/direct-workloads.bend` supplies these two actual-helper
exports, with no maintained compiler edits:

- `p163w_reverse(n: U32) -> List<KDef>` repeatedly calls the real
  `book_final_reverse` on four records and consumes every returned record. The
  four input records include duplicate, Unicode and empty names; every field is
  retained in the output. At `n=1`, the arities must be `[4,3,2,1]`.
- `p163w_lookup(n: U32) -> List<KDef>` performs ten actual lookups per repetition.
  It covers plain first-match/duplicate semantics, Unicode and empty names,
  misses, current collision leaves and retained legacy index records. At `n=1`,
  outcomes are arities `[1,3,4,0,5,6,0,5,6,0]`; the three zero entries must be the
  complete `Absent` definition, not merely a scalar zero.

`p163w_reverse_expected` and `p163w_lookup_expected` construct the full expected
records/order independently of the reverse and lookup algorithms. Use these via
a separately compiled reference path; exclude their declaration closure from the
candidate/timed library. Fixture construction is shared intentionally, but the
expected result selection and order are literal and do not call either target.
No checksum replaces complete output equality. Repetitions increment payloads by
eight and retain each round's results, preventing ignored repeated calls from
being an acceptable implementation.

Begin with `n=0,1,2`; larger inputs are separate stack/ownership controls. This
initial fixture does not cover every index-node shape, malformed graph or error
case. The broader controls described above remain necessary before promotion.
The new source has not been executed or compiler-checked by this audit agent;
root owns those gates.

## Bounded review of the additive direct prototype

Source-only review of `direct-first.bend`, `direct-controls.bend`, and
`direct-executable.bend` found no concrete blocking defect in their restricted
admission contract. This review did not execute the structural controls or a
generated program.

- `public=False` removes the original scheduled-wrapper metadata obligation;
  unchanged `p113e_functions` still checks bodies, signatures and dependency
  order. Unknown calls and ordinary recursive cycles cannot obtain permission
  from a preseeded signature table. `P113DAgain` and the existing proven tail-pair
  transformation retain their existing treatment.
- The empty function-ID map is used both for direct verification and direct
  emission. Constructor schema checking and `p112s_nodes_error` are retained.
  Static words have the restricted existing `P112SRaw/Packed/Box` representation;
  raw values are U32, and boxed references must point into the prior immutable
  image. The prototype does not add a new function-pointer static form.
- The executable adapter is restricted to checked, pure, zero-argument `main`
  with one boxed result. Its sole scheduled wrapper uses the existing
  `p113e_public` implementation and a separately fixed text contract. The
  descriptor-only `main -> 0` alias is not exposed to direct bodies. This is a
  new narrow adapter contract, not a fabricated generic-program certificate.
- `NR_Request` must originate in the checked pipeline. The prototype's
  `nc_compile_error_known` call is not a substitute for dependent type checking.
  Reachable foreign/bang code refuses; error/unsupported candidate admission
  must be reported rather than counted as compiled coverage.

Two measurement limits matter: the executable route currently renders the
standalone library and then renders private workers again; it also omits some
later ownership/optimization composition. Charge duplicate rendering honestly,
and measure generated execution separately instead of assuming equality of
performance because the primitive direct ABI is reused.

**Source02 supersession:** the prototype agent subsequently split `p163d_plan`
from rendering. Executable emission now consumes that plan without rendering an
unused library first. The duplicate-rendering observation applies to Source01
only; the later-optimization/execution limitation still applies. See
`direct-library.md` for the versioned contract and `hybrid-direct-first.md` for
the proposed mixed route retaining the ordinary optimization pipeline.

For a larger construction-cost transfer set, the qualified artifact confirms
ordinary native workers for these actual compiler roots:

| Roots | Responsibilities | Example QBE line |
| --- | --- | ---: |
| `f_find` | frontend recursive lookup, existing tail SCC | 163096 |
| `p111v_value` | independent verifier value validation | 385663 |
| `p111q_value`, `p111q_args` | value/argument QBE rendering | 425315,430813 |
| `p111q_descriptor` | executable descriptor construction | 296312 |
| `p111q_ctor_table`, `p111q_words` | constructor/word tables | 138184,138171 |
| `p111q_string_defs` | string-data declarations | 137638 |
| `p113e_signature` | direct ABI metadata | 136226 |

A combined request over these roots and the lookup/reverse roots provides a
more useful admitted-size ceiling than timing the tiny reverse helper alone.
Compare the same selected closure, actual emitted workers/bytes and complete
outcomes, not a small candidate library against full-program baseline work.
Report raw-stage refusal where later pipeline transformations were required;
being direct in the final qualified artifact does not guarantee initial
candidate admission. Include currently scheduled `constructor_exists`,
`book_final_scan`, `p111q_tables`, and `subst` as coverage/refusal controls. This
audit proposes that bounded transfer set; it does not claim the set has passed.
