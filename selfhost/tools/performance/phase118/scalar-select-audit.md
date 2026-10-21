# Scalar selection audit

Read-only source/assembly inspection; no compiler, program, benchmark, or new
control was executed. The existing `float-screen01` receipt records Mandelbrot
candidate 201/200/201 ms, Phase117 269/268/269 ms, and pinned upstream 49/50/50 ms.
Those whole-program measurements do not attribute the remaining gap to branches.

The useful opportunity is **two remaining data-selection branches plus redundant
Boolean normalization**, not wholesale replacement of branch lowering. The source
`mit` loop has seven scalar selections: three arithmetic-shift sign masks, two
Boolean-to-U32 conversions, and two choices between new and retained loop values.
All seven are generic scalar patterns; no workload-name recognition is needed.

| Observation | Candidate `$direct.mit` | Upstream inlined `spin_5` |
|---|---:|---:|
| Static instructions in loop region | 97 | 38 |
| Conditional jumps | 3: exit + two selections | 1: loop backedge |
| Conditional moves | 5 | 2 |
| `setcc` instructions | 7 | 2 |
| Calls / stack memory references inside region | 0 / 0 | 0 / 0 |

Candidate region is `.Lbb166` through the jump back to it in `program.s`; upstream
is `WL_FID_HFOLD` addresses `0x7820..0x78a9` inclusive. Counts include both sides of
branches and are static instruction counts, not executed-instruction or cycle
measurements. The candidate function has 618 emitted QBE lines and nine `jnz`:
seven selection diamonds and two Nat-case checks. QBE eliminates the impossible
Nat failure path and turns five selections into conditional moves. The standalone
`$direct.sel` also already becomes a conditional move.

The two remaining `jnz` test the same normalized `e2 == 0` predicate. QBE sinks
the new real/imaginary coordinate arithmetic into the selected paths; Clang keeps
that arithmetic before two `cmove` instructions. Clang also replaces each
sign-mask selection by `sar 31; and 0xff000000`, while QBE retains a sequence of
shift, comparison, `setz`, extension, another comparison and `cmov`. Candidate
Boolean-to-U32 conversions likewise retain comparison/inversion/select chains.
The escape predicate is monotone within an iteration sequence (false until escape,
then true), so these are not established to be unpredictable branches. Removing
them may trade branch cost for additional eager arithmetic.

An exact “both arms are one Set” hook is unlikely to reach these seven diamonds
as currently emitted. Every true arm has **two copies** before its jump; false
arms have ten or eleven operations before their jump, including unused remnants
of inlined Bool matching. None is literally a one-copy-per-arm emitted diamond.
This is emitted-QBE evidence, not a fresh export of the structured P113D graph.
Inspect that graph before choosing a recognizer: a small pure-copy/dead-definition
cleanup or select recognition before inlining may expose the intended rule.
Phase117 `scalar-identities-v2.bend` only recognizes adjacent comparison followed
by exact 0/1 diamonds; Phase113 `bool-width/model.bend` requires one U64 constant
Set per arm. Their near-neutral result does not establish the value of arbitrary
payload selection, but broadening the old pattern alone does not address its
failure to match these inlined bodies.

A safe bounded experiment would retain original verification and admit only
scalar U64 selections of already available locals/constants, with the same
destination in both arms, or two terminal single-result arms. Normalize the
condition exactly as the existing branch does, explicitly extend its 0/1 word,
then form full-width `m = 0 - predicate` and `b ^ ((a ^ b) & m)`. Snapshot operands
before assigning an overlapping destination. Preserve all 64 payload bits; an
`N_W32` kind is insufficient because packed Bool words also use it. No calls,
loads, ownership operations, allocation, division, FP work, branch-local operand,
or other side effect may be speculated by this rule. For terminal results,
preserve result count and terminal status. This semantic equation establishes no
backend performance benefit; QBE already selects `cmov` for simple cases.

Ordinary positive controls should cover arbitrary scalar condition values (0,
1, and other nonzero values), high U64 payload bits, equal operands, destination
overlap, nested selections, and a loop retaining either old or new values. Keep
effectful/owning branch controls as unchanged fallbacks. Before a broad change,
require actual structured-pattern hits, exact full outputs, and reduced hot
machine work on an ordinary select/loop fixture. A generic sign-mask/Boolean
cleanup is at least as plausible as forcing arithmetic bit-select for all arms.

Audited identities (SHA-256):

- `selfhost/build/phase118/float-emit01/mandelbrot.ssa`:
  `5611743852ca588fcdeaf09371f3e2e14f62b76ef3ee9f785685fbcdb7266401`.
- `selfhost/build/phase111/p118-float01-mandelbrot-build/program.s`:
  `74a2b98ed3e04ea23de14b21284fdc8b207ca6d8515da227c0e5f5a9a71d9c09`.
- Candidate ELF in that build directory:
  `5652a3e780f70614476fd0e010ab6e481a7d4b7cd33be579b3851baaddd9f6ad`.
- `selfhost/build/phase93/broad01/mandelbrot/upstream.1.c`:
  `3284630bdba8d4185bb4d280ac76b52aba0646000a826b1e368681f8bc6a55a4`.
- Upstream ELF `upstream.program` beside that C:
  `3ab38f8b020bc620d1fad0fa711204fbc4be4e0ac6d99c34df03aa989aa450a7`.

The upstream C is the pinned mature route: `spin_0/1` implement select, `spin_2`
the sign mask, `spin_3` Boolean conversion, and `spin_5` the recursive loop. The
machine comparison uses its existing Clang O3 binary, not a reconstructed build.
