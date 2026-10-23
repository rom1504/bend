# Phase131: a bounded private borrowed query capability

Investigation at `9f7ab43`, using qualified Phase130 source
`995d6b4bf14963debb9a810de2ed941c3cd30a71fc34a156d96b1adbd1b06bdd` and its retained
full QBE. No target executions or production edits by this investigation agent.
The coordinator owns checking, runtime experiments and any later qualification.

## Finding: layout closure blocks a complete query

The promising first experiment is **shallow borrowed queries over finite
record/sum roots with opaque unobserved fields**. It reuses the existing checked
query/traversal, adapter, borrowed helper summaries and final verifier. It does
not rewrite String.order, introduce another backend or recognize compiler
function names.

The compiler's actual `p98_tag_eq` already holds a KTerm and key until its
Boolean result is produced. `p98_tag_eq_read` selects the generic tag or literal
`"Lam"`/`"Lit"`, then uses the existing equality traversal. The source is a
natural borrowed scalar query, but the selected generic reader schema only
accepts a finite two-constructor spine. KTerm has three constructors of widths
8, 8 and 5. Moreover, its **unobserved** payloads include both `List<KTerm>` and
`List<String>`: eagerly closing all field layouts also conflicts with the
one-instantiation-per-nominal-type rule. Neither obstacle is a reason to take,
retain and release payloads that the query never observes.

[Actual source archive](../../implementation/phase130/compiler-source01.bend.gz),
[KTerm definition](../../selfhost/src/core/term.bend#L25),
[finite-spine restriction](../../selfhost/tools/performance/phase128/borrow/next/layouts.bend#L29),
[existing borrowed helper contracts](../../selfhost/tools/performance/phase128/borrow/next/read-calls.bend#L29).

Exact selected source spans are KTerm 41–44, equality 6–19 and tag query
38766–38779. Their byte hashes and ordinary expected outputs are frozen in the
[proxy oracle](../../selfhost/tools/performance/phase131/regions/oracle.json).

## Actual generated-code evidence

Static inventory of `selfhost/build/phase111/p130-full-emit01/program.ssa`:

| Complete generated private function | Start line | QBE lines | Important static call sites |
| --- | ---: | ---: | --- |
| `$direct.p98_tag_eq_read` |170582|159|3 generic takes, 12 sinks, 4 keeps, 3 owning equality-adapter calls |
| `$direct.p98_tag_eq` |170741|195|3 generic takes, 14 sinks, 6 keeps, 3 owning equality-adapter calls |
| `$p118borrow.read.p88_string_eq_go` |2527|251|Already a borrowed reader; field helpers/fallbacks remain |
| `$p118borrow.read.has_name` |147138|111|Already composes a borrowed list cursor with private equality |

These are static sites across mutually exclusive arms and fallbacks, **not
dynamic counts**. The relevant causal distinction is that the tag query still
opens an eight-field owner and releases unused fields before calling an owning
adapter, despite an already-qualified borrowed equality reader existing.

The main `nq_uses` entry at QBE line2090830 remains generic, with keep/ctor/sink
work and scheduler jumps. Its list helper is generic too. It is therefore a
separate, larger private-region opportunity. The proposed shallow capability
will not automatically turn mutually recursive KTerm/List traversal into a
stack-safe local region, nor remove all register copies.

The Phase129 9–13% physical register-copy exposure and 12–24% reclamation
exposure overlap owner/context categories. They are pre-Phase130 observations,
not additive current gain budgets. Fresh profiles and selected reader counts
must determine actual impact. This experiment should first target ownership
inside tag/record queries; claim transport removal only if measured transitions
also disappear.

## The smallest semantic extension

[Experimental code](../../selfhost/tools/performance/phase131/regions/shallow.bend)
changes only `p128bl_node`:

1. Try the exact existing complete layout discovery first.
2. On refusal, accept a known nonnative, nonparameterized ADT with one through
   eight constructors. Every constructor's specialized declared fields must
   pass `nol_ctor_fields`. Width zero or 2–8 is supported; packed singleton,
   wider, dependent and unknown representations decline.
3. Keep scalar and already-supported plain spine fields visible with their
   existing exact type and layout evidence.
4. Give every other field the reserved abstract type
   `$p131.borrowed.opaque`, which must be absent from the source book. Do not
   traverse such fields while building the layout graph.
5. Let the unchanged NO evaluator prove that the computation actually uses only
   the visible view and returns its verified nonowning scalar result.

An opaque field's physical word can be loaded from a held root, but it has no
matcher layout or scalar type. The existing evaluator rejects attempts to match
it, use it in scalar arithmetic, pass it to a typed borrowed helper, promote it
to a recursive root, or return it as the observation. An inlined helper may
ignore it, which does not violate the contract. No new permission to emit
arbitrary runtime calls or cast its word to a borrowed pointer is introduced.

[Matcher checks](../../selfhost/src/back/native/observer-analysis.bend#L332),
[scalar checks](../../selfhost/src/back/native/observer-analysis.bend#L228),
[result/origin checks](../../selfhost/src/back/native/observer-analysis.bend#L388).

This is deliberately less general than lazy typed IR expansion. It preserves
all old admitted schemas and refuses queries that actually inspect unsupported
children. For example, inspecting `KTerm.id` or its tag may become possible;
walking arbitrary `KTerm.kids`, indexed families or all nine fields of KDef does
not become possible merely because one enclosing shell is known.

## Ownership, stack and runtime obligations

- The original scalar adapter retains the actual owning roots until the reader
  completes, then drops them once. Shared/static root and alias guards remain.
  Unique or ambiguous inputs retain the original owning function.
- All observations are beneath held roots; opaque payload ownership never
  transfers to the reader. Reading all eight words into scratch does not create
  eight owners. The existing borrowed-field helper and selected field template
  are unchanged.
- The result has the existing `nol_scalar` proof. A U64 machine word alone would
  not prove nonownership.
- No new recursion grammar is introduced. Shallow root matching is finite;
  recognized spine workers retain existing loop/progress rules. Unknown helper
  cycles, non-tail borrowed recursion and effects remain refused.
- Constructor identity, instantiated telescope, width, dependency order and
  final direct-function verification remain independent gates. Source-name or
  scratch-name resemblance is not permission.
- Runtime remains sequential; this does not change Phase128's ordinary RFC-load
  synchronization premise or qualify multicore/GPU behavior.

## Concrete experiment and finite gates

The prepared producer source02 is
`selfhost/build/phase131/regions-source02/compiler.bend`, SHA256
`e5f32523997b25728585bca4d25cd3439de395a5ca1142c491e90c0305dfeb5c`.
It is an experiment until the coordinator's independent checks pass. Source01
failed a missing local KDef annotation in the control module, not an executed
semantic counterexample; its complete input remains retained.
The coordinator's source02 checked API acquisition succeeded in 15.13 seconds
with 2.18 GB peak process-tree RSS. Runtime selection and performance remain
unmeasured at this handoff.

[Thirteen finite controls](../../selfhost/tools/performance/phase131/regions/controls-v02.bend)
exercise supported/refused widths, opaque-symbol collision, scalar conversion,
matching, helper passing, result escape and recursive promotion. Reuse seven
existing layout controls and ten borrowed-call controls unchanged. Synthetic
abstract values are data for the verifier; never execute them as native pointers.

The [ordinary fixtures](../../selfhost/tools/performance/phase131/regions/cases.json)
contain the exact original KTerm and six tag/equality functions. They exercise
three KTerm constructors, nested retained payloads, aliases, Unicode, shared
and unique/fallback roots. An unrelated `P131Packet` has three constructors and
two incompatible opaque List instantiations. Its label query provides transfer;
payload-count and owned-payload-return functions must remain refused by the new
observer path while still executing correctly through the ordinary compiler.

Before timing, require positive actual reader selection for tag/record queries
and negative planner diagnostics for `p131_opaque_count` and
`p131_opaque_escape`. Complete ordinary outputs alone could all pass on fallback.
Then compare identical programs emitted by parent and candidate, generated code,
clean runtime and diagnostic take/keep/sink/dispatch/copy counts. The timed
wrapper has a frozen scalar sum and adjustable repetitions; units are
milliseconds, avoiding Phase130's initial clock-label mistake.

## Expected information, costs and limits

The capability is a fallback inside an existing pass, not another whole-program
scan. It still performs constructor/telescope analysis for new candidates, and
many previously refused functions may now consume more analysis budget. The
query proxy can win while compiler emission gets slower; measure both. The
candidate must retain its original bounded layout/evaluation fuel and refuse
quickly when no useful private reader is produced.

The first meaningful gate is a selected reader with no owning take/sink/keep
inside the observed query, plus correct fallbacks and improvement on **both**
compiler-tag and record-transfer. This is a high-information, small acquisition
experiment. No current whole-compiler gain estimate is defensible without
dynamic tag-query exposure. Even total elimination of that context would not
eliminate the independently dispatched caller or all destruction costs.

If useful, the abstraction worth preserving is a **held-root view with explicitly
opaque unobserved fields**. A later per-computation plan could carry more exact
visible fields across calls and local continuations. Do not broaden it to all
ADT traversals or mutate the production ABI just to claim a private-region
architecture. First show this finite view pays for its compiler cost.

## First experiment: legality alone was insufficient

The coordinator completed `regions-jobs02`. Thirty finite controls and both
independent ordinary output oracles passed. The packet reader/query were
eligible; the compiler tag reader/query were not. Opaque payload traversal and
escape were correctly refused. The retained diagnostics distinguish the reasons:

- The KTerm schema now succeeds, but its `"Lam"`/`"Lit"` branches call an existing
  verified equality helper with a **virtual constructor**, rather than an atom
  beneath a held root. The unchanged raw-pointer argument contract correctly
  rejects this. Claiming static storage or pretending the virtual value is a
  pointer would be invalid.
- The packet query receives a correct private reader, but earlier private
  inlining has already copied its old owning body into `p131_once` and
  `p131_repeat`. The corresponding function bodies are byte-identical between
  parent and shallow-only candidate in both fixtures. The record proxy's clean
  median CPU times, 34.924ms and 35.129ms at 100,000 repetitions, do not demonstrate
  a speedup. Increasing repetition count cannot remove this pass-order barrier.

[Frozen first-attempt evidence](../../selfhost/tools/performance/phase131/regions/attempt01-evidence.json)
records exact body hashes, receipts and static calls. These observations are
more useful than counting newly admitted readers: admission did not imply that
the hot caller used them.

## Bounded second iteration

`virtual-v01.bend` preserves the pointer-call gate. When an **already verified**
reader instead receives a finite typed virtual constructor root, it evaluates
the helper's unchanged source body through the existing NO evaluator. Constructor
identity, field types/arity and every atom's scalar or held-origin proof are
checked. Expansion is limited to 16 levels and the existing 4096-step evaluator
fuel. Unknown helpers, effects, malformed constructors and unheld atoms retain
their previous refusal. Virtual objects never become raw borrowed pointers.
This permits ordinary partial evaluation of a short literal comparison without
introducing another equality algorithm or a string-name recognizer. Nine finite
controls exercise the new boundary. Source03 is the isolated candidate.

`late-inline-v01.bend`, source04, separately tests installing checked borrowed
workers **before** the existing private-function inliner copies their bodies.
The initial request-bound original verifier remains; terminal emission runs the
unchanged `p114s_optimize`, independently verifies the resulting program and
falls back to the original verified program if that check fails. This deliberately
conservative prototype may add verification cost. It must earn its overhead
through actual caller code changes and measured runtime before promotion.

One important falsification condition is whether the old early inliner was also
needed to make owning fallbacks leaf-like for initial helper-summary admission.
If moving it removes necessary seeds, preserve the already computed optimized
proof snapshot for summary discovery while applying proven worker replacements
to uninlined caller IR. Do not weaken ready-prefix verification merely to make
the reordered pass produce output. No runtime or general IR rewrite is needed
to test these scheduling alternatives.

At this point in the experiment the candidates were preparation-only. The
subsequent results below retain those failures and keep the Phase130 production
compiler unchanged.

## Second iteration results and the corrected staging experiment

Source03 passed the coordinator's checked acquisition and all 39 finite controls.
Both compiler tag-query plans now report eligibility 1 with no diagnostic. The
virtual-constructor specialization solved the literal/held-origin barrier while
leaving raw borrowed-call rejection unchanged. A retained-root literal fixture
adds thirteen exact Lam/Lit comparisons, prefix/missing/Unicode cases and final
observations of the held keys. This fixture has an independent pre-execution
oracle; its actual runtime qualification is a separate gate.

Source04 emitted all three ordinary fixtures through independent original gates,
but static inspection rejected it as a performance candidate. New packet/tag
readers were absent. Its timed functions became shorter by moving calls back
out of line, rather than eliminating owning work. There were two staging issues:

1. Summary seeding originally inspected optimized owning fallbacks. Moving the
   inliner changes that admission context; source-level legality is insufficient
   if the summary's independently checked fallback bundle cannot be reused.
2. The ordinary `p114s_open`/`p113a_verify` route checks direct imports. Borrowed
   imports use the existing `p118b_project_functions` contract projection and
   `p118b_verify_functions` gate. Running the ordinary optimizer over the derived
   graph can conservatively reject it and retain the input unchanged.

The [second static receipt](../../selfhost/tools/performance/phase131/regions/attempt02-static.json)
separates shorter callers from eliminated work. No runtime speedup follows from
that instruction-count change alone.

Source06 corrects both issues without changing verifier declarations: retain
the old independently verified optimized snapshot for seed-summary discovery,
apply those facts to the uninlined caller graph, then run the existing inliner
and range propagation with the same projected-import, certificate and namespace
checks already used by `p126bp_complete`. Source07 adds seven finite boundary
controls: malformed imports, root counts, missing results and forward calls must
still refuse. All 91 protected declarations remain unchanged.

The provisional schedule deliberately repeats optimization/verification work.
It establishes whether correct fact reuse and pass placement expose a useful
capability; it does not establish a profitable compiler implementation. If it
works, remove duplicate preparation using a shared verified stage result before
considering production promotion. Do not confuse a faster query proxy with a
cheaper native compiler request.

The coordinator's `p131-regions-api07` checked source07; all 46 finite
controls pass, including the seven late-boundary negative/positive tests. The
three ordinary fixtures then passed independently checked emission, aligned
native builds, exact stdout and empty stderr. The table below reports the
separate root-owned clean runtime measurements.

The general architectural finding is that these stages accept **different
verified IR contracts**. Moving a function list across stages without its
borrowed-import and fallback-summary evidence can disable optimization even
when every function remains semantically valid. If the scheduling experiment
pays off, preserve a small shared verified-stage result carrying that evidence;
do not merely add more recognizers around lost information.

A separate source03 transfer experiment now uses the exact compiler
`nq_uses`/`nq_uses_list`/`nw_uses` computation. Its larger recursive caller retains
private tag-query calls in the actual native compiler. The
[frozen proxy](../../selfhost/tools/performance/phase131/regions/uses.oracle.json)
can test the new tag reader without late scheduling overhead, avoiding a false
conclusion based only on a tiny caller whose owning body had been inlined.
It retains synthetic input-tree roots and has ten independent ordinary outputs;
it is an extracted compiler workload, not a new frozen benchmark definition.

## Measured result: useful capability, expensive schedule

The corrected source07 schedule finally connects the selected hot callers to
borrowed readers. Three interleaved clean rounds on CPU3, with one million
repetitions per process, give:

| Frozen workload | Parent median | Source07 median | Runtime reduction | Whole QBE growth | Native binary growth |
| --- | ---: | ---: | ---: | ---: | ---: |
| Compiler KTerm tag query | 429.79 ms | 181.67 ms | 57.73% | 49.04% | 10.11% |
| Unrelated packet query | 380.89 ms | 179.91 ms | 52.76% | 51.99% | 8.54% |

These are whole-child times for small repeated queries, not compiler throughput
or broad benchmark results. Raw rounds remain in
`selfhost/build/phase131/regions-late02-run/timing/report.json`. The candidate
tag times range from 179.27 to 198.79 ms; the parent ranges from 427.98 to
430.12 ms. The gain is much larger than this observed variation, although three
rounds do not establish a precise confidence interval.

The installed readers contain no owning take/keep/sink calls. Borrowed field
loads and unchanged equality traversal replace the old take/reconstruct/release
path. The original held-root adapter and owning fallback remain. The adapter
can still sink its consumed input ownership after the scalar result; eliminating
internal ownership work does not mean eliminating every reference operation.

The machine code explains why instruction totals alone were misleading. The
compiler-tag outer loop shrinks from 556 to 81 instructions, while its once
worker grows from 419 to 1,657, including inlined guarded readers and alternative
fallback branches. Packet's equivalent loop shrinks from 395 to 81 and its
worker grows from 278 to 1,092. These are static counts across all branches, not
executed instruction counts. Successful runtime paths can improve while total
code increases. Exact QBE and disassembly are retained under
`selfhost/build/phase131/regions-inspection01/`, generated reproducibly by
`regions/inspect-results.py`.

The cost objection remains. Single observed hosted integrated-emission stages
increased from 7.32 to 10.61 seconds and from 5.87 to 7.98 seconds for these two
fixtures. They are diagnostic observations from separate acquisitions, not a
controlled compiler-throughput measurement, but agree with the known duplicated
preparation. **Do not integrate source07 as the default.** It is a useful
capability ceiling and evidence that pass placement matters.

## Cheaper transfer: exact compiler occurrence queries

The separately frozen `compiler-uses.bend` extracts the original `nq_uses`,
`nq_uses_list`, `nw_uses` and supporting tag-query functions without rewriting
their algorithms. Both the Phase130 parent and **source03** passed the ten-line
ordinary output oracle. Source03 has the shallow layout and virtual-constructor
helper capability, without source07's repeated preparation.

Here the larger recursive caller retains its tag-helper calls, so no pass
reordering is required. The 138-line QBE / 130-instruction `nq_uses` segment is
byte-identical and calls the tag-query adapter twice. The parent adapter has
194 QBE lines / 179 machine instructions, with three take, fourteen sink and
six keep sites across its branches. The candidate adapter has 17 QBE lines /
38 instructions and calls a verified borrowed reader after the existing root
guard; the owning fallback and two final root sinks remain. Its new 963-line /
745-instruction reader has no take/keep/sink sites. That larger total reflects
finite constructor/literal alternatives, not a claim that every query executes
745 instructions.

Whole QBE grows 774,384 to 867,524 bytes (12.03%), and the binary grows 271,904
to 281,192 bytes (3.42%). The single hosted integrated stage is 7.94 versus
8.51 seconds; a controlled compiler request comparison is still needed before
claiming a cost. The clean 1,024-repeat pilot selected 2,047 repetitions for three paired
CPU3 rounds. The unchanged computation retains shared 255-node trees and checks
exact present/absent results. Parent median whole-child wall time is **595.33 ms**,
candidate **479.70 ms**: **19.42% less runtime**, or **1.241× throughput**. Median
CPU time improves 19.44%. Candidate rounds range 479.63–490.32 ms; parent rounds
range 594.37–639.49 ms. All six timed outputs pass, and median peak RSS is nearly
unchanged (9,800 versus 9,796 KiB). The first parent round is slower, but the
median and the remaining paired measurements still show the benefit. These
three rounds do not provide a precise confidence interval.

[Frozen transfer evidence](../../selfhost/tools/performance/phase131/regions/attempt04-nq-uses.json)
retains exact source/binary/report identities and raw results. The underlying
receipt is `selfhost/build/phase131/regions-uses-timed01/report.json`. This is a
substantial improvement in one actual compiler computation, with no duplicated
preparation schedule. Its input tree remains synthetic; **it is not a 19.42%
compiler request speedup or a broad benchmark result**. A full native candidate
request is the next required measurement before estimating overall value.

The practical integration direction is source03 plus the independent product
projection capability, retaining actual helper summaries and verified fallback
closures. Projection's closure repair can recover absent workers, but cannot
undo arbitrary ownership code already copied into an existing caller by early
inlining. This distinction prevents calling all composition barriers solved.
The next shared interface should carry verified helpers, layouts and fallback
contracts through the existing pipeline; it should not copy the whole old
preparation merely to rediscover them.
