# Phase166 — independent falsification notes

Source-only audit; no target runs. These are bounded hypotheses, not new speed
results. Qualified compiler remains Phase152.

## What the reciprocal equality experiment rules out

Phase165's full check-only request changed from 16.877521s to 17.137127s
(1.01538×); the 182KB checker changed 1.00548×. It replaces 41 checker
`String.eq` source references, with 36 static native call references disappearing
after compilation. This excludes a large *whole-request* penalty from this
transplant in that bendc configuration. It does **not** establish per-call parity,
frequency of the changed sites, or the cost of QBE's ownership/calling boundary.

Evidence: [Phase165 report](../../implementation/phase165/README.md),
[code-shape receipt](../phase165/ours-equality-code-shape.json),
[transfer boundary](../phase165/transfer-note.md).

“There were few string operations” is not supported. Existing Phase162 diagnostic
counts contain 98,864,430 shared native `str_cmp` loop visits: 14,902,235 during
parse, 32,779,605 during check, and 51,170,964 during report. But that counter
includes comparison called *inside native Map*. Map native helpers survive the
Phase165 equality transplant. Consequently these counts do not establish what
fraction of string work the 41 changed sites cover.

Exact sources: `selfhost/build/phase162/bendc-diag-full02/counts.json`;
[hook definition](../phase162/bendc-frontend-hooks.json), counter
`native_string_compare_steps` on the `str_cmp` loop; retained
`selfhost/build/phase158/current/rt/bendrt.h:3469` (`str_cmp`), `:3500`
(`map_leaf`), `:3509` (`F_Map_dget`), `:3521` (`F_Map_dhas`). These are C observer
counts, not events measured in our qualified QBE compiler.

## Actual ceilings and work elsewhere

Qualified Phase153 machine sampling has 7,406 physical leaf samples:

| Physical leaf category | Samples | Share |
|---|---:|---:|
| Borrowed `p88_string_eq_go` reader | 384 | 5.185% |
| Borrowed `index_hash` reader | 199 | 2.687% |
| Borrowed `String.cmp` reader | 152 | 2.052% |
| All `p118_rt_borrow_scalar_safe` guards, across functions | 94 | 1.269% |
| Reclamation, ownership/products, allocation, register copy combined | — | 42.71% |

Source: `selfhost/build/phase153/attribution01/report.json`, `matrix`;
[disjoint category accounting](../../implementation/phase153/metrics.json).
Thus equality-reader elimination alone has a roughly 5.2% directly observed
CPU envelope; deleting every scalar guard would have only a 1.27% direct envelope.
Neither is a guaranteed wall-time gain, and ownership costs are not automatically
attributable to equality. These figures favor complete lookup/consumer boundaries
over a guard-only optimization.

The QBE already contains a borrowed direct equality loop. At
`selfhost/build/phase152/native-n2/program.ssa:3136` it reads tags/RFC headers and
fields; the adapter at `:3387` checks borrowing safety, calls the reader and sinks
inputs, or uses the owned fallback. `alloc8 2048` here is stack scratch, not a
heap allocation. The guard in
[`runtime.c`](../../selfhost/src/runtime/qbe/runtime.c:4794) protects both unique
ownership and same-root alias cases. A removed check requires a proved lifetime
contract, not only correct comparison output on distinct strings. This audit
read the emitted QBE and existing machine-PC attribution; it did not disassemble
the ELF anew.

Small complete-request Phase153 event attribution offers a different opportunity:
`p111v_get` has 4,627,175 drop events; `lookup` has 1,200,449 drops against only
223 allocation events. `String.append` and `p144e_body_tail` together account for
40.99% of allocation events. Equality's active owner has 106,537 dispatches and
zero allocation events. Source:
`selfhost/build/phase153/events-attribution01/report.json`, `owners`.
This includes prepared-Base loading and all request stages on an 8,202-byte input;
active-owner attribution is not an exclusive callee cost, and these proportions
must not be extrapolated to full self-compilation.

Priority supported by current evidence:

1. Complete owned lookup → actual field/scalar consumer, preserving alias/root
   lifetime, to expose traversal plus avoidable reclamation at the boundary.
2. Backend text/body materialization allocation, measured separately on a real
   complete request; this is a different, potentially larger work category.
3. Equality reader/adapter specialization only after the first measurement
   demonstrates that it dominates the complete boundary.

## One decisive small experiment

Use the proposed identical-source complete lookup batch in
[P166-001](P166-001-complete-lookup.md). First compare **complete decoded result
values** with the independent literal `lookup-oracle.py --values` controls, then
time repeated, consumed results through QBE and bendc. Keep input construction
and full child timing visible; distinguish equal/early-miss/late-miss, collision,
Unicode, absent, shared-root and distinct-root cases. If a gap appears, observe
this one batch for QBE guard pass/fallback, equality-loop and drop counts, and
separate bendc explicit-equality from Map-internal comparison counts. This holds
the actual computation fixed and answers whether the gap is reader work or its
surrounding ownership/index boundary. Do not infer a full-build gain from it.

Bounded method review: P166-001 correctly rejects unequal work and missing output;
P166-002 correctly separates hosted events from native allocation. The literal
oracle is independent of lookup, but its timed dual digest is not injective.
Small controls therefore need the complete values gate; digest equality alone
does not certify all fields. Fixtures currently contain empty child/constructor
lists, so they do not independently qualify arbitrary deep record ownership.

## Hosted `String.cmp` tuples do not transfer directly to native work

Additional source-only check against qualified Phase152
`selfhost/build/phase152/native-n2/program.ssa`:

| Actual native function / location | Surviving materialization |
|---|---|
| `$p118borrow.read.String.cmp`, lines3563–3809 | No Tuple or SCon construction. Borrowed field loads, U32 comparison, tail loop; only nullary LT/EQ/GT constructors. |
| `$direct.String.cmp`, lines3811–3831 | Calls scalar reader, then constructs exactly two tuples once to return `((a,b),order)`. |
| `$p118borrow.read.String.order`, line363120 | Calls scalar reader directly; neither return tuple is built. |
| `$p118borrow.read.String.eq`, line363166 | Calls scalar reader directly and returns Bool; no tuple construction. |
| `$direct.String.order`, line363133 | Borrow-safe branch reads then sinks inputs; owned fallback at line363104 calls ordinary String.cmp and Pair.snd, so its two tuples survive. |

Nullary `p111_rt_ctor` returns an immediate before heap allocation
([runtime.c:3936](../../selfhost/src/runtime/qbe/runtime.c:3936)); the reader's
U32 comparison is opcode22. Its `alloc8` scratch is stack space. Therefore the
19.27M/34.7M hosted Tuple observations cannot be reported as native tuple
allocations. In particular the per-character reconstruction observed in hosted
Base code is already absent from the native borrowed reader. Retained generic
and legacy recursive entries still exist; this static audit does not count their
dynamic use or the scalar-adapter fallback rate.

Concrete repeated backend consumer: `p126sc_has` scans names using `String.eq`
([product-composition.bend:540](../../selfhost/src/back/qbe/product-composition.bend:540)).
Its composed borrowed worker calls the scalar cmp reader directly at SSA372352;
`p126sc_call_has` does likewise at SSA372634/372741/372830. Verification-context
header equality (`verification-context.bend:9`) reaches the same reader from
`$p118borrow.read.p140v_header` at SSA388477. These native paths do not materialize
the Base cmp tuples counted by an unoptimized hosted observer.

Conversely `p111v_get` is not an ordered String.cmp lookup: source
[`verify-segments.bend:3`](../../selfhost/src/back/qbe/verify-segments.bend:3)
calls `index_hash` and `index_find`, confirmed at SSA301095/301100. The trie bucket
uses `p88_string_eq` (`core/index.bend:182`). Treating its activity as evidence
for Base String.cmp tuple reconstruction would conflate two distinct paths.

A native tuple-removal hypothesis now requires measuring calls to the ordinary
two-tuple adapter or its owned fallback, rather than multiplying hosted Tuple
events by native allocation cost. Existing scalar-reader physical samples show
that its character/header/dispatch work remains real even though reconstruction
has disappeared.
