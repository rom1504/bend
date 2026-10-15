# Compiler list and environment algebra

Status: source checking, safe elaboration and independent BendTT acceptance
passed in root-run [algebra-all03](../../../build/phase96/algebra-all03/report.json).
The unchanged kernel also rejects the retained false-equality control. All
21 law bodies are inventoried as nonopaque. No target was run by this package's
author. `all.bend` imports fourteen public laws and seven supporting lemmas. Every law has a
body; there are no new axioms or `@unsafe` definitions. Finite controls and
mutation rejection are separate evidence, never substitutes for universal proofs.

| Module | Public laws | Compiler connection |
| --- | --- | --- |
| `list.bend` | `append_right_identity`, `append_associative`, `append_length` | Actual Base append and length. Native bridge/flat composers append environment and call lists; preserve order and duplicates. Length uses unbounded Nat, not compiler U32 counters. |
| `reverse.bend` | `reverse_accumulator`, `reverse_append`, `reverse_involution` | Actual Base accumulator reverse. `front/declarations.bend:f_result` and native argument reconstruction use this operation. These laws support ordered accumulator transformations without proving each unsafe caller. |
| `membership.bend` | `contains_singleton`, `contains_append`, `contains_duplicate` | Actual Base `List.contains`, for an arbitrary closed comparator. The native `nb_contains` and mutually recursive `has_name` adapters are not imported or proved equivalent here. Boolean membership does not justify deduplicating an ordered result or changing first-match lookup. |
| `filter.bend` | `filter_cons_decision`, `filter_append`, `filter_idempotent` | Actual Base `List.filter`, for any closed pure total predicate. Compiler-specific liveness filtering has a separate adapter obligation. Stable order and duplicates remain part of the result. |
| `environment.bend` | `prefix_chunking`, `prefix_order_and_drop` | Exact Phase94 safe helper from an unpromoted compiler candidate, plus its frozen reference filter. Complete ordered rows and arbitrary drop value are preserved. No proof of `nc_env_extend`, NU_Set analysis, emission or runtime is claimed. |

Supporting lemmas: `reverse_append_acc`, `or_associative`, `or_idempotent`,
`or_right_identity`, `filter_put_append`, `filter_recheck`, and `prefix_step_order`. The helper
operations imported from Base/Phase94 are not counted as new compiler laws.
`inventory.json` gives the machine-readable split.

The package directly imports Base rather than reimplementing append, reverse,
length, contains or filter. The current and pinned Base files are identical:
SHA256 `99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf`.
`phase94/helper.bend` and `phase94/reference.bend` are byte-for-byte copies with
source hashes in `phase94/provenance.json`; this keeps a package snapshot usable
without rewriting its imports. These copies retain their earlier proof boundary
and unpromoted status.

The pinned upstream `bendtt.lean` is SHA256
`83cdd36e66dcd2cabcc3d10556c9c874f8d823956feab88f8bb5a81473d51be3`.
Its separation of typing from live termination, earlier-definition ordering,
and structural descent guides this package's small lemma dependencies. The
proofs use explicit equality motives and structural induction. Closed template
callbacks represent arbitrary functions, not comparator/predicate axioms. No
Lean theorem is imported as an assumption into a Bend proof. The reverse lemma
structure follows `tests/proof/list_reverse_concat.bend`, but targets actual Base
operations instead of that test's separate `LL` implementation.

Root should snapshot this directory, check modules incrementally, then check
and elaborate `all.bend`. Independently check the complete safe dependency
closure with the unchanged BendTT kernel and retained false-equality control.
Do not report kernel acceptance from the Bend frontend's source verdict alone.

`mutations.json` specifies six semantic negatives. Four falsify public claims
while retaining their original proof bodies; two change the imported candidate
helper while keeping its laws/reference frozen. Apply each to its own snapshot,
require source/proof rejection, preserve the diagnostic, and distinguish a
typing/termination rejection from an independently checked kernel rejection.
The root-run [negative campaign](../../../build/phase96/algebra-negative-check01/report.json)
passes all eleven checks: eight intended proof rejections and three standalone
helper admissions. The four false-statement mutations are counted separately
from the two environment implementation mutations and two constant observers.

Semantic adequacy controls: append/duplicate algebra alone admits an always-False
observer, and append/idempotence alone admits an always-empty filter. The public
`contains_singleton` and `filter_cons_decision` anchors exclude those mutants.
The standalone `negative-controls/constant-helpers.bend` passes safe source
checking, and both `reject-constant-*.bend` entry files reject their altered
anchors. They are
excluded from `all.bend`; no failed claim is an assumed law. These controls are
also not a claim that the twelve other laws form a complete compiler specification.

The upstream model for a production-connected equality is `subk_sub` and the
`@[csimp] sub_subz` theorem at pinned `bendtt.lean:435–441`: an optimized helper
is equated to a simple reference for full arbitrary inputs. Root's elaboration
audit must find every used actual helper and theorem body safe and nonopaque,
with no omitted unsafe dependencies. Only arbitrary typed template parameters
may be opaque; they do not establish production callback safety.

Root-run mutation plan: `prepare-negatives.py --out FRESH_PHASE96_DIRECTORY`
authenticates the accepted proof closure, prepares isolated copies, and writes
`plan.json` with serial commands and prerequisites. It executes no target. The
first prepared plan is [algebra-negatives01](../../../build/phase96/algebra-negatives01/plan.json):
eleven source checks cover four false-claim mutations, two well-formed helper
mutations followed by their frozen laws, and two constant-observer anchor
negatives after a shared law-free helper check. All expected results pass in
[algebra-negative-check01](../../../build/phase96/algebra-negative-check01/report.json).
Both environment helpers and the constant-helper module are admitted before
the frozen laws reject them. These source rejections are separate from the
positive independent kernel proof verdict; none is advertised as a kernel
mutation rejection.
