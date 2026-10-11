# Compiler23 versus upstream C: the missing representation contract

Investigation only, 2026-10-11. No compiler, generated program or runtime was
changed. This lane read source and performed lexical analysis on CPU0; it ran
no Clang, compiler image or native benchmark. Timing claims below are from the
[qualified previous campaign](../../implementation/phase68/native-facts-and-calls.md),
not new measurements.

A newly discovered, cheaper discriminator comes first: **dead imported bang
references change the global scheduler mode** for tree and lexer. See the
reachability review below. The larger architectural opportunity is **a shared
typed value layout across ordinary
workers, scheduler calls and closures**. The existing private product pass only
flattens a single constructor shell whose fields remain generic Terms. Upstream
flattens nonrecursive sums and products recursively, carries those words through
scheduler returns, and knows which words can own heap allocations. A few direct
calls alone cannot recover that contract.

## Inputs and reproducibility

The [machine-readable analysis](../../implementation/phase68/evidence/c23-code-shapes.json)
hashes all twelve actual qualified C files, their emission receipts and the
analysis producer. Each C hash is checked against its original emission receipt.
Candidate B1 is `079c0be19a15d707147b4c3f3b381cb7387dd42fdfb6de87c9137b63dedb644b`,
source checkpoint `b2ec0a2`; pinned upstream is
`059266225b77c8ca256ac6b25ee5c21449bab151`. Compiler23 is a source candidate;
this does not promote the installed Phase67 release.

Run from the repository root:

```sh
taskset -c 0 python3 selfhost/tools/performance/phase68/parity-survey/code-shapes.py \
  --output /tmp/c23-code-shapes.json
```

Candidate C is under `selfhost/build/phase68/native-facts23-rest/<family>-selfhost/program.c`,
except lexer, under `native-facts23-lexer/lexer-selfhost/program.c`. Upstream
numeric/array/closures are under `selfhost/build/phase67/native-baseline02/`;
tree/Map/lexer are under `native-heldout-baseline02/`. The report's C line
anchors use these exact hashed inputs. Large C artifacts are preserved by the
[previous campaign capsule](../../selfhost/tools/performance/phase68/facts-calls/evidence/README.md).

The analyzer counts lexical occurrences in generated `Spins` and `Segments`
regions, excluding runtime support. It can remove literal `DEVICE`/`!DEVICE`
guards but retains other configuration alternatives. These are **static source
counts**, not execution frequencies, LLVM instructions or time attribution.
Unit detail keeps workers and named benchmark/Map segments; anonymous
continuations contribute to region totals but are omitted from detailed JSON.

| Family | Runtime / upstream | C lines candidate / upstream | Worker definitions | Scheduler segments |
|---|---:|---:|---:|---:|
| Numeric |0.992×|34,157 /4,548|16 /14|426 /51|
| Array |1.006×|34,892 /4,627|23 /17|438 /51|
| Closures |1.785×|33,472 /4,795|12 /10|416 /65|
| Tree |3.118×|38,486 /5,566|22 /18|554 /80|
| Map |1.786×|55,942 /11,178|36 /23|946 /169|
| Lexer |2.646×|43,471 /5,483|30 /25|599 /69|

Numeric and arrays show why C size cannot stand in for runtime: they are at
parity despite similarly large source expansion. In every candidate,
`Nat.read.trim` alone occupies **11,659 generated lines**, in argument parsing
outside the timed repeated kernel. This is a separate compiler/Clang-time and
simplicity lead, not evidence that deleting cold code will close runtime parity.

## Dead imported bang references change execution mode

Independent source review finds no bang references in either dynamic fixture's
reachable local `bench` graph. Tree reaches14 definitions; lexer reaches24.
The only fixture bang references are in their **original imported main**:
`bsort!`/`scan!` in tree, `batch!` in lexer. The phase46 wrappers call `W.bench`,
never `W.main`, and contain no bang references. The JSON records each fixture
hash, wrapper hash, reachable definition list and bang-reference owner. This
is a lexical local graph plus source review, not a claim to have constructed a
complete typed whole-program graph.

Despite that, compiler23 C defines **BANGS39 for tree and BANGS16 for lexer**;
both upstream C files define zero. `book.bend:240–243` scans bang references
from **all definitions**, and `nc_compile` at line252 passes that list into
otherwise main-reachable compilation. `nc_compile_def` at line131 marks live
definitions by membership in that all-book list. Thus a dead imported main
can mark a live, ordinarily called helper as a bang target. The emitted BANGS
number counts marked segments, not source bang occurrences.

Both native runtimes choose the serial scheduler path using
`!BANGS && pool_size == 1`. Consequently the stale positive global flag can
make an entirely ordinary one-thread benchmark use heap-backed tasks rather
than the stack continuation path. This is a much stronger explanation for
excess allocations and dispatch than helper call counts alone; root owns a
separate saved-C diagnostic to measure it. No runtime gain is claimed by this
read-only review.

There is a second compile-time consequence: `flat.bend:248–249` also feeds
all-book bangs into worker candidate selection. A saved-C global-flag-only
screen therefore isolates runtime mode and **cannot measure any recovered
worker opportunities** from correcting reachability during compilation.
Reachable bang calls, parallel binding syntax, escaping closures, imported
aliases and device behavior need explicit production controls. Do not change
all BANGS constants indiscriminately in real programs.

## Lexer: the loop is direct, but its state is still allocated

Candidate C `NF_…lexer:lex` at line17388 is already a self-tail loop. Its hot
iteration calls `$product.…lexer:step`, receiving two generic Terms, then at
lines17524–17537 performs:

```c
u64 state = heap_alloc(e, cls_fit(2));
e.mem[state + 0] = rfc_seal(e, mode);
e.mem[state + 1] = rfc_seal(e, accumulator);
next_state = term_ctr(CID_TUPLE, state);
/* next iteration takes this Tuple apart again */
goto nf_again;
```

Names above are shortened for explanation; exact code is in the pinned C.
The worker body contains one explicit allocation site, two seal sites, three
`ctr_take` sites and fifteen `err_seen` sites across its branches.

Upstream `spin_22` at C1817 carries **String plus three u32 words**: Mode tag,
Mode payload and accumulator. `spin_18` returns those three words; the loop
assigns them and repeats. It has no state allocation or seal site and one
String `ctr_take` site. Upstream `spin_13` at C1542 handles Mode dispatch with
scalar tags/payloads. Our ordinary and product `step.at` bodies still operate
on generic Mode Terms, but valid Mode constructors are already packed immediate
values in compiler23. **There is no additional Mode heap allocation per
character to eliminate.** The definite allocation opportunity is the outer
Tuple. Splitting one packed Mode register into two scalar tag/payload registers
is a separate experiment in representation and instruction simplification; it
must not be credited with the Tuple allocation savings.

This is not just missing tail recursion or a missing ordinary worker: both
already exist. The prior 2–3% result is consistent with removing a scheduling
boundary while retaining per-character state boxing. Code inspection proves
the extra work exists; fresh profiles/ablation must establish its time share.

## Map: scheduler returns also need layouts

Candidate `$direct.Map.bit.go` at C22712 handles its empty-string branch by
allocating a Tuple, sealing both fields and returning one Term through
`WL_RETN(1)`. Other branches and continuations likewise transport boxed
products. The character helper is invoked by a scheduler jump after installing
a continuation (C22761–22778).

Upstream `FID_MAP_BIT_GO` at C4506 returns String and Bool directly in **r0/r1**
with `WL_RETN(2)`. Its character branch directly calls `spin_2` and `spin_3`;
its recursive continuation at C4567 directly calls `spin_4` and also returns
two words. It retains scheduler recursion: the win is not replacing all
scheduler calls with ordinary C recursion.

The current limitation is explicit in
[`product.bend`](../../selfhost/src/back/native/product.bend):
`nq_transfer`/`nq_box_return` at lines33–43 rebox a product when the destination
is `NC_Scheduler`. Improving ordinary-worker admission cannot remove this
representation boundary. A result-layout-aware scheduler ABI is required to
match this upstream mechanism generally.

## Tree: a real direct-call gap plus ownership facts

Upstream `WARP` at C2129 keeps scheduler recursion and parallel fork/join
control. Its leaf branch calls `spin_9` directly; its join segment at C2252
calls `spin_10` (`warp_zip`) directly. Ours `$direct.…warp` at C20431 instead
jumps to separate `$direct.…warp_leaf` and `$direct.…warp_zip` entry segments,
which then invoke their admitted ordinary workers. These are real extra helper
boundaries, distinct from the recursion that both compilers retain.

Upstream knows unshared Tree nodes can be destructured with `term_loc`, field
loads and `heap_free`, and constructed without sealing each child. Ours uses
`ctr_take`/`spare_free` and generic child sealing. Upstream `spin_10` at C1449
has one allocation site, two frees and no `rfc_seal`/`ctr_take` sites; our
`warp_zip` worker at C14196 has six allocation sites, nine seals and six
`ctr_take` sites across all branches/fallbacks. Those lexical counts do not
mean every invocation executes all sites.

**Challenge to the direct-call hypothesis:** it is a useful experiment, but
upstream still schedules recursive Tree and Map operations. Removing helper
boundaries alone cannot eliminate excess constructor/refcount transport, and
must not be advertised as a demonstrated 3× tree win.

## Closures: known partial application is avoidable construction work

Candidate closure `chain` at C16213 calls the unsaturated `compose` reference,
constructs a captured addition closure and uses generic closure application to
supply arguments. `compose` at C16399 emits its own chain of curried closure
stages. Upstream `CHAIN` at C2115 first computes the recursive closure, then
its continuation at C2156 allocates **one closure capturing scalar k and h**.
This explains a concrete source of extra construction-time closure applications
in the previous dynamic-count difference; it is not evidence that all remaining
runtime closure application can disappear.

Upstream still dynamically applies the captured function at C2171–2229 and
allocates a small addition closure on that path. Thus upstream itself presents
an opportunity for an eventual below-parity experiment: specialize a proven
known local target/capture or eliminate a nonescaping closure. No speed gain is
measured here, and the general case must retain higher-order semantics.

## Source mechanisms and the missing shared abstraction

Pinned upstream source references below are to `selfhost/.bootstrap/upstream-phase66/bend2/comp.ts`:

- `lay_of`/`lay_pack`, lines923–964: recursively flatten nonrecursive ADTs,
  including sums with scalar tag words; recursive/open layouts stay boxed.
- `lay_c`, line981: represent word32 as C `u32`, other words as `Term`.
- `node_fields`, lines1584–1618: choose direct/borrowed/generic field access
  using sharing/static facts and owned/borrowed roots.
- `val_owned`/`val_sink`, lines1655–1665: only owned boxed words require dropping.
- `seg_open`, line1554: flatten the words **and kinds** of captured values and
  results into scheduler segment parameters.
- `call_eta`, lines707–715, used by `emit_expr` at line2417: handle known
  unsaturated applications through typed eta expansion rather than always
  evaluating a generic curried reference.
- `facts_hot`, line1420, and the fixed-point emission described at line1295:
  propagate sharing/ownership facts across definitions, including dependent
  families, rather than locally guessing that a constructor is unshared.

Current Bend source exposes corresponding seams:

- `product.bend` starts: “Private fixed-shell products. Fields keep the ordinary
  one-word Term ABI.” `NQShape` carries one constructor identity/width; it is
  not a recursive sum/product layout with kinds and ownership.
- `product.bend:372–417`: parameter-demand checks intentionally preserve raw
  malformed/error/drop behavior. The fix is not declaring String constructors
  exhaustive in the raw route or blindly unboxing inputs earlier.
- `direct.bend:134`: known direct-call lowering requires exact saturation;
  otherwise `nf_slow_app` leads into generic application. `nd_arity` at line69
  already considers leading lambdas, so merely increasing arity is not new.
- `book.bend:252` lowers scheduler definitions before final worker planning;
  `flat.bend:202–213` then wraps admitted entry segments. This explains why
  callers do not automatically become direct ordinary calls.
- `bridge.bend:289–300` creates scheduler frames around cut calls, explicitly
  lowering both value and continuation with `NC_Scheduler{}`.

## Recommended discriminating experiments

0. **Reachability and scheduler mode.** Screen the tree/lexer saved C with
   only global `BANGS` changed to zero, leaving per-FID flags and program bodies
   untouched. This is valid as a diagnostic only after the no-live-bang source
   review below. A production fix must derive facts from the live definition
   graph and retain bang behavior for truly reachable parallel calls.
1. **Typed multiword values and calls.** Prototype lexer carrying Mode tag,
   payload and accumulator as words; separately prototype Map returning its
   product through scheduler result registers. Measure each component before
   combining them. This tests a general layout contract in both ordinary and
   recursive control flow, rather than one benchmark-specific rewrite.
2. **Unique Tree path.** Prototype the ownership/sharing facts needed for direct
   Node loads/stores and unsealed owned children, plus a separate direct-helper
   call arm. Isolate the two mechanisms; do not assume their speedups multiply.
3. **Known partial applications.** Prototype typed capture/eta lowering that
   gives closures the same construction shape as upstream, while retaining
   unknown-call fallback. Add cases with effect/error-producing arguments so
   eta expansion does not silently change evaluation timing.
4. **Only then attempt to beat upstream.** Inspect whether known local closure
   targets, producer/consumer fusion or constructor reuse remove work upstream
   still performs. Matching upstream layouts is a credible parity direction;
   0.5× overall requires additional measured advantages across several families.

Each prototype should use saved C for a fast mechanism screen, independent
checksums, dynamic allocation/dispatch counts and native CPU profiles, followed
by a checked Bend implementation if the effect is substantial. Validate unknown
raw inputs, early errors, parent-versus-field ownership/drop ordering, shared
values, self-recursion/stack bounds and the device fallback before promotion.
The six benchmark families are finite coverage; add held-out ADT, sharing and
higher-order combinations before interpreting the gains as general.
