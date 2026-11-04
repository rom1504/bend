# Phase157 generated code shape: real compiler helpers

Read-only source/ELF inspection, 2026-11-04. No target, compiler or profiler was
executed for this audit. The three inspected builds report completion, but their
semantic/performance qualification belongs to the separate Phase157 run receipts.
RC is not included here. The bendc artifact includes the explicit effect adapter;
it must not be described as an unmodified out-of-box backend result.

## Exact artifacts and method

All paths below are relative to `selfhost/build/phase157/`:

| Role | Artifact | Bytes | SHA256 |
| --- | --- | ---: | --- |
| Upstream C | `upstream02/program.c` | 7,250,618 | `c94c12900e15fe34f5ff798da47478f232786176a3eb75c8d324fb56372412d8` |
| Our QBE | `qbe02/program.ssa` | 23,979,462 | `f889981d650d18120b2561fcad5cb3c26ea2cc533bf53bc7cd71ecbfbb181b1a` |
| bendc GC | `gc03/program-adapted.c` | 1,445,181 | `4dbb234a71c378c8250e70e783b912025660ca906eb5f92ca41d213ffa69a9a8` |
| Upstream executable | `upstream02/program` | 3,311,688 | `8699c527f157a36a4ee9039612c8aea64ecba6efa468212c47fd351d900433c0` |
| Our executable | `qbe02/program` | 4,017,712 | `2eb4dc254925ac36c652e4fe0d2af861433fa627c3a4d8bf645560ae0fafb743` |
| bendc GC executable | `gc03/program` | 1,954,840 | `ad6061004d5239184c93ab0ec4acf0c1e6e32990fb251cb09479e2aecfe997a2` |

`upstream02` reuses the original upstream machine product; its receipt binds that
reuse. Use the normalized common input and normalization receipt, not the earlier
unnormalized source hash, when joining these artifacts to the comparison.

The static method is `nm -S --defined-only`, `readelf -SW` and
`objdump -d --no-show-raw-insn --disassemble=SYMBOL`. Instruction counts below count
addressed disassembly rows, including alignment instructions, inside the selected
symbol. Calls count both `call` and `callq`; tail jumps are not calls. These are
**static sites, not executed instructions, allocations or elapsed cost**. Symbol
bodies have different inlining/outlining boundaries; caller/callee counts cannot
be compared as whole logical-operation costs.

QBE symbols encode the source name as underscore-separated decimal character
codes after `_FID_`. For example, `$direct.lookup` becomes
`p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_`.
The worker prefix matters: `p113d_` is a direct worker, `p112w_` is another direct
wrapper, and exported `p111_` entries use the shared runtime state/dispatcher.

## 1. Candidate construction has three different call boundaries

In bendc GC, `gc03/program-adapted.c:22275`,
`U_p113d__candidate(V a0, V a1, V *o)` makes ordinary calls to `F_nd__arity`,
`F_nf__worker__kinds`, `F_lookup`, `F_nc__compact__definition`, and
`F_p113d__lower`. Its three outputs are written directly into `o[0..2]`.
`F_p113d__candidate` wraps that output in a three-field constructor. The
`BEND_UINL` helper is eligible for forced inlining; this exact executable has no
separate `F_`/`U_` candidate symbol, so its body cannot be assigned an independent
machine size. Generated `W_` wrappers still support first-class calls.

Upstream `upstream02/program.c:193551` begins
`WL_CASE(FID_P113D_CANDIDATE)`, followed by nine `K6982..K6990` continuation
segments through line193913. Parameters/results move through the register bank
and explicit continuation stack; `seq` selects stack continuations, while the
other path constructs tasks. The final continuation returns seven flattened
words through `WL_RETN(7)`, whereas bendc's helper returns three pointer/immediate
values including a nested record. Thus a larger segment count does not mean
upstream is simply boxing every record.

Our QBE public entry, `qbe02/program.ssa:415474`, produces a closure. The actual
`$direct.p113d_candidate` entry at line415509 is still an exported `p111_`
state/continuation entry, **not** a `p113d_` direct machine worker. It and the
following ten `$p111.k.*` entries occupy1,830 machine bytes, excluding callees
and public/currying wrappers. The first entry explicitly retains two inputs,
stores captures and continuation5749 on the runtime stack, then calls
`p111_rt_jump`; its machine body is143bytes/35 static instructions/3 call sites.
The separate `$direct.p113d_candidate_code` is a real direct worker, but that
smaller helper must not stand in for the complete candidate construction.

**Opportunity to test:** preserve typed direct-call/result conventions across
this real owner boundary, reducing argument publication and continuation traffic.
This is a general calling-convention/admission question, not a proposal to bypass
the original verifier or hand-specialize these five benchmark owners.

## 2. Lookup is already direct in ours; ownership and field access remain

| Selected machine body | Bytes | Static instructions | Call sites |
| --- | ---: | ---: | ---: |
| bendc `F_lookup` | 734 | 163 | 5 |
| ours `p113d_` / `$direct.lookup` | 760 | 206 | 26 |
| upstream `WL_FID_LOOKUP` entry only | 2,777 | 668 | 26 |
| bendc `F_index__find` | 1,239 | 267 | 7 |
| ours `p113d_` / `$direct.index_find` | 1,628 | 409 | 47 |
| upstream `WL_FID_INDEX_FIND` entry only | 2,940 | 695 | 24 |

Upstream lookup also has four `C6950..C6953` closure segments; index-find has
fourteen `C6839..C6852` segments. The entry-only rows deliberately exclude these
and all callees. bendc's C lookup still constructs closures around `F_kc`
(`gc03/program-adapted.c:8856`); C compilation inlines substantial dispatch and
allocation fast paths. Its five retained calls are `str_cache`, string equality,
two `gc_refill` sites and a fail-stop. This is not zero-allocation code.

Our direct lookup (`program.ssa:75308`) contains four `p111_rt_keep`, eleven
`p111_rt_sink`, two `p125_rt_take2` and four fail call sites. These survive as
machine calls in this body; they are not merely verbose QBE spelling. Direct
index-find (`program.ssa:73711`) has29 sink sites,3 keeps, one generic take,
three take2, one take4, two ctor2 and four failure sites. Alternatives/failure
branches make these totals much larger than any particular executed path.

There is also concrete local scratch overhead: direct lookup's QBE declares
`alloc8 2048` plus16bytes, and its machine prologue subtracts`0x810` bytes before
saved-register pushes. bendc `F_lookup` subtracts`0x18`; upstream's lookup entry
subtracts`0x50` plus a saved register. These are per-selected-body reservations,
not maximum stack use or measured stack traffic. Trimming scratch may help code
generation, but the static frame size alone gives no speedup estimate.

**Opportunity to test:** keep read-only context traversal in a well-defined
borrowed region, with direct field reads and explicit lifetime exits. First
measure whether repeated retains/takes/destruction or continuation publication
is actually hot; GC-vs-RC timing alone will not distinguish them.

## 3. Equality exposes a compact, composable representation boundary

bendc's `F_p88__string__eq__go` at generated C line8654 loops over `FLD` fields,
compares raw character words and returns an immediate Boolean. Its machine body
is173bytes/53 static instructions, with just one call site on the fail-stop path.
It still traverses linked String nodes: this is not a byte-buffer/memcmp rewrite.
The runtime represents `V` as64bits, nullary constructors as tagged immediates,
and heap fields as `((V*)v)[i+1]` (`vendor/rt/bendrt.h:79–116`). The generated GC
C contains no explicit `rc_dup`, `rc_dupn` or `rc_drop` call sites; collection and
allocation work remain in its included runtime.

Our equality is split three ways:

| `p113d_` worker, decoded name | QBE line | Machine bytes | Static instructions | Call sites |
| --- | ---: | ---: | ---: | ---: |
| `$direct.p88_string_eq_go` | 761 | 120 | 41 | 5 |
| `$p118borrow.read.p88_string_eq_go` | 510 | 902 | 220 | 10 |
| `$p128borrow.owned.p88_string_eq_go` | 322 | 601 | 154 | 16 |

The wrapper calls `p118_rt_borrow_scalar_safe`, selects owned/borrowed workers,
and sinks its two inputs after the borrowed route. The borrowed worker performs
tag/location/forwarding checks and retains fallback `p118_rt_borrow_fields` and
`p111_rt_special_ctor` calls. The owned worker has take/sink/special-take paths.
Some calls are failure/fallback sites; the table does not assert all are taken.

Upstream supplies an important counterexample to “only GC can do this”: its
`spin_1` at C line6032 reads character/tail fields through `term_peek`, loops
without per-character ownership calls, and carries a raw `u32` Boolean. `spin_0`
at6095 wraps that scan; `spin_3` at6081 sinks the two inputs afterwards. This
source shape is structurally a borrowed scan with lifetime cleanup at the outer
boundary. These helpers are inlined into other symbols, so no isolated machine
count is assigned to them here.

**Opportunity to test:** a trusted typed borrowed-call convention that carries
raw scalar results across helpers, paying representation admission once per
region. Preserve fallback behavior and ownership joins; earlier mutable-array
failures show why deleting checks locally is not a proof that lifetimes agree.

## Size context and next interpretation

ELF `.text` sizes from `readelf` are1,677,620bytes for bendc GC,
2,282,996 for upstream and2,296,801 for ours. Our23.98MB QBE therefore does not
translate into23.98MB of executable instructions. The emitted sources have
36,520/202,818/582,527 lines for GC C/upstream C/QBE, but these are different
languages and packaging: bendc includes a separate runtime header, upstream C
contains runtime/device paths, and QBE links a separate runtime. They are not
source-maintenance complexity comparisons. Defined text-symbol counts are
1,704/4,702/13,951 respectively; inlining, wrapper generation and dispatcher
segments account for much of that difference.

The strongest follow-up is to combine the independent full-output timing ladder
with physical profiles, then select a real hot boundary among owner calling
conventions, borrowed traversals and scalar-result representation. Do not infer
whole-compiler gains from the above byte or call-site counts. A backend can have
larger static code but run a shorter fast path; a GC path can postpone work to a
collection. Complete process lifetimes and measured coverage remain essential.

At audit close, root reported that preliminary calibration changed the ordering
between one and sixteen repetitions, with GC growing much more expensive and
using substantially more RSS at sixteen. These are not balanced results and are
not reproduced as a score here. They specifically prevent interpreting compact
GC code as an automatic performance win. Separate GC-stat diagnostics can test
collection pressure; retained heap size alone cannot establish the cause. Root
also reported RC failing the complete-output control: there is no admissible RC
performance comparison.
