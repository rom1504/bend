# Phase107 bounded inlining

The new implementation under
[`inline/`](../../selfhost/tools/performance/phase107/inline/) adds a shared,
Bend-written optimization over the existing native IR. It does not edit the
production compiler or claim complete Bend-to-native lowering. The parent phase's
real source bridge can compose this pass between lowering and either backend.

The selected first boundary is small terminating pure scalar helpers, including
the lexical classifier shape seen in Phase106. Calls in a caller loop can expand;
callee loops, recursion, pointers and effects cannot. Every argument is evaluated
once into a fresh parameter local. Every callee local is reset on every invocation,
which is necessary inside caller loops. Terminal conditional returns become fresh
result assignments before the original caller continuation. Callee definitions
remain available and unsupported calls remain intact.

Code growth has a global explicit budget, bounded call graph/expansion depth and
per-callee limits. The JSON oracle counts actual AST nodes independently. It checks
that output growth stays within the requested capped budget; this measures AST
growth rather than promising a bound on emitted machine-code bytes. Refusal is
conservative: for example, early-return control flow with later statements is not
restructured speculatively.

The optional `nx_inline_deep` adds original-call-graph summaries while preserving
the common expansion engine. Shallow function facts are checked once; a gray DFS
path detects recursion and a completed-result cache reuses both positive and
negative results. Analysis is bounded to256 functions/dependency depth, separate
from four-level expansion and4096-node growth. This admits deep acyclic helper
chains without expanding them without limit. The original `nx_inline` policy is
retained as the comparison. The accepted bridge05 source snapshot predates this
extension, so the extended implementation needs its own checked acquisition.

The next separately named policy, `nx_inline_entry`, spends the same global4096
growth budget on the entry function first and allows128 expansion levels under
the existing acyclic certificate. Original function order and all definitions
are retained. This isolates budget priority and expansion depth from dead-code
removal or backend changes; baseline/deep API behavior remains depth4. Its target
is general deep acyclic call graphs, not recognition of benchmark names.

The additional `nx_tail_optimize` pass targets actual lowered scalar recurrence. It folds
terminal assignment/return aliases and distributes a final return into return-free
conditional branches, exposing self-tail calls hidden behind merge locals. Every
tail call becomes argument snapshots, original-local resets and simultaneous
parameter updates inside an explicit loop. Other returns exit normally. An
unreachable typed-zero return accommodates the existing verifier's structural
termination rule. No generic `continue`, mutual-tail ABI, pointer frame reuse or
ownership transformation is introduced. Existing loops, non-tail result use and
mixed early-return/dead-continuation layouts refuse unchanged.

Separate controls exercise merge-local recurrence, simultaneous argument updates,
per-invocation zero locals, non-tail recursion, dead continuations, pre-existing
loops, pointer frames and mutual-only calls. Million-iteration triangular sums
have independent expected values and are labeled native-only, avoiding recursive
Python reference execution at that depth. This pass also requires separate
checked acquisition and actual constant-stack execution before any speed claim.
The first tail audit revealed that `tail_dead` is invalid under the existing IR
verifier. Its unchanged result is an invalid-input refusal control, not a passing
semantic/native case; its data rows are explicitly marked and excluded from
interpreter execution. The failed audit is retained rather than silently
relabeling that run as successful.

Six finite semantic fixtures target argument snapshots, caller-name collisions,
nested conditional returns, merge-local conditionals, per-iteration local
initialization and nested calls. A seventh recursive fixture is compared
structurally and never executed. Existing
pointer-sharing workloads provide a refusal control. Expected outputs are frozen
independently; the Phase106 interpreter supplies a second execution model. Three
well-typed emitted-IR mutants test whether the oracle notices dropped local reset,
swapped parameter snapshots and discarded results.

Two small exact-result laws constrain the real safe continuation helper. They are
not a proof of inlining; freshness, traversal, termination admission and semantic
preservation remain explicit unproved boundaries. This limited contract can catch
the helper being wired to the wrong destination/result while broader finite
controls exercise the transformation.

The first integrated checked API acquisition passed in
[`bridge-check05/process.json`](../../selfhost/build/phase107/bridge-check05/process.json):
11 checked exports including `nx_inline`, 1.392s guarded wall and approximately
151MB peak tree RSS. This is source/API admission, not a whole-pass proof or a
performance measurement of optimized output. Earlier inference failures are
retained; explicit types on constructor-valued local bindings fixed them.

The complete baseline/deep/tail API then passed
[`bridge-check08/process.json`](../../selfhost/build/phase107/bridge-check08/process.json):
16 checked exports,1.697s guarded wall, approximately167MB tree RSS. The preceding
bridge07 failure exposed a name collision with Phase106's `nx_tail()` workload;
the new pass is explicitly named `nx_tail_optimize`. A static scan now checks all
206 assembled Phase106/107 helper definitions for duplicates. No historical
workload implementation was changed to resolve the collision.

The root-run [`audit01`](../../selfhost/build/phase107/audit01/report.json) passes72
baseline/deep transformation pairs at budgets0,1,32,4096, including464 finite
before/after input pairs. Three admitted output mutations are detected: omitted
local reset changes14 to21, swapped argument snapshots change33 to42, and a
discarded result changes16 to0. These are emitted-IR semantic mutation controls,
not source mutants or a proof of the optimizer.

[`tail-audit02`](../../selfhost/build/phase107/tail-audit02/report.json) passes eight
structural comparisons and69 native outputs across GCC, Cranelift and QBE,
including six million-step observations. Seven structural pairs are valid IR;
the eighth is the deliberately invalid `tail_dead` input. Its historical report
contains49 valid finite input pairs and seven extra interpreter observations of
invalid IR. Those seven are not accepted compiler-semantic cases. Current controls
skip them; native observations only build the three positive fixtures and are
unaffected. The failed predecessor and original report remain intact.

The entry-first policy is prepared for separate checking/measurement. Continuation
laws remain separately scheduled. Root owns runtime/build measurements and the
phase report's final integration conclusion.

The external integer-runner ABI now explicitly refuses a selected entry with a
live Bool parameter. Internal Bool helpers and erased Bool arguments remain
eligible. This is a boundary contract: arbitrary integer CLI inputs do not denote
valid Bend Bool values, whose scalar representation must remain zero or one.
The `refuse_bool_entry.bend` source probe selects `bench`, while its ordinary Bend
`main` supplies a well-typed True value. This admission change needs the next
checked source acquisition; it is not a change to the production compiler.

`bootstrap-compare.mjs` prepares a serial differential comparison between two
compiled versions of the same frozen Bend bridge. It compares checked-source
acceptance/refusal and exact IR, fixture construction, bounded optimization,
verification, JSON/C/QBE and ordered per-function QBE units. Inputs and compiled
APIs are hashed, failed results are retained, and repeated identical verified IR
shares emission checks. It requires identical public JS Bool/string/U32 and tagged
record/list boundaries rather than normalizing mismatches away. This checks stage
equivalence of the experimental API; independent semantic/native oracles remain
necessary, and it does not demonstrate a native fixed point or recursive speedup.
Execution is scheduled by the root agent separately from preparation.

The separately composable `nx_reachable` pass is prepared to remove unused
functions after inlining. It operates on closed programs with one external entry,
traversing direct calls and all function-address expressions, including stored or
returned closures and both conditional arms. It preserves original function order
and the complete bodies of retained functions. Recursive call graphs terminate
through a visited set; invalid inputs and bounded-capacity failures refuse
unchanged. Limits are256 functions and65536 counted IR nodes, followed by a verifier
check on the candidate. This is deliberately independent of purity analysis and
does not change the meaning or budget of any inliner API.

Seven source-defined graph controls distinguish direct/transitive references,
stored and returned function pointers, dead versus reachable cycles, syntactically
dead branch references and the257-function capacity boundary. Frozen structural
expectations and wrapping-add results accompany them. The intended independent
audit checks retained bodies/order, complete reachability, idempotence, unchanged
refusal and detection of removed-address-target mutations. Acquisition and
measurements are pending separately; preparation itself supplies no speed claim.
