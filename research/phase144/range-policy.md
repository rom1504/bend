# One fewer range pass as an explicit compilation policy

This isolated experiment changes only `p114s_ranges` to return its boundary.
It leaves the existing inner range call, inlining, table publication, incoming
verification, inline commit and independent final verifier unchanged. It is a
program-quality/compilation-cost tradeoff, not an equivalence-cleanup claim or
an assertion that range analysis is idempotent.

The actual ordinary route is `p128raw_session_finish`; changing only the older
`p114s_lower_request` wrapper would miss it. All selected calls to
`p114s_ranges` or its lowered wrapper immediately follow `p114s_inline`, so the
one-declaration overlay covers the ordinary native route and older optimizer
wrappers coherently. It changes no transformation, runtime, ownership rule,
calling convention, descriptor, or independent verifier.

The input boundary has already been opened and checked. Successful inlining
has already passed `p134v_commit`; if that commit rejects a candidate, its
original checked boundary is retained. Omitting a later optional optimization
does not accept unverified IR. The final `p113a_verify`/observer/emission gates
are still reached unchanged. These are structural and admission arguments,
not a whole-compiler semantic theorem.

The three-family census shows the main quality risk concretely: the omitted
pass changed one SCC function in each request that had never run the inner
pass. Other, unmeasured inputs could also improve on a second analysis. No
unchanged-output flag is introduced. The later native measurement below tests
the compiler-native benefit. Source order, helper eligibility and inlining tables are exactly the
old policy until the omitted outer boundary.

An alternative was to move range analysis into both inliner fallback branches.
That has a larger policy effect: an original body over2,048 nodes can shrink
below the512-node publication limit, or an original helper whose expanded body
exceeds16KiB can simplify before publication. It can therefore alter later
inlining choices. The current falsifier deliberately avoids that extra change.

The first comparison uses the exact frozen benchmark wrappers for Lexer, Map
and closures, with their independent complete-output and repetition-count
oracles. Existing checked baseline API and a separately checked one-declaration
candidate emit QBE through the same sealed Bend cursor. Both variants use the
same runtime and QBE/assembler/linker policy. Three alternating runtime pairs
are a diagnostic screen, not the frozen44-case headline or a correctness proof.

If runtime is acceptable, the important next measurement is a same-input cold
native compiler request. The full compiler may have a different fraction of
functions gated out of inlining and a different range-analysis cost. A claim
of5–15% compiler improvement remains a hypothesis until that measurement.
Production integration and qualification are separate decisions.

## Executed three-family screen and machine result

The root checked the isolated source, emitted both variants, passed all six
independent output/count smokes, and ran three alternating pairs. Receipts are
`range-skip-builds01/report.json` and `range-skip-times01/report.json` under
`selfhost/build/phase144`.

| Frozen benchmark wrapper | Baseline median ms | Skip median ms | Runtime ratio | Generated object |
| --- | ---: | ---: | ---: | --- |
| Lexer |678|678|1.000|byte-identical|
| Map churn128 |1,062|1,065|1.0028|byte-identical|
| Closures256 |17|17|1.000|byte-identical|

The closures interval is too short for a useful small-regression bound. More
decisively, **all three complete generated assembly and object files are
byte-identical**. Their921/1,345/626 function bodies and all object sections
match. Linked executable `.text` is also exact; differing executable hashes
come only from build-ID and symbol/string-table sections. No timing difference
here can be attributed to different generated instructions.

The static, reproducible inspection is
`verifier/range-skip-machine-v01.py`, with exact inputs and diffs in
`selfhost/build/phase144/range-skip-machine01/report.json`. It executes no target.
Each skipped variant has1,086 additional QBE bytes. The four changed SCC bodies
serve `U32.read`, `Nat.read`, `Nat.show` and `U32.show`; the timing wrappers add
the first three beyond the ordinary-source census. The differences include
propagating10/48 through copies, removing redundant32-bit extensions, and using
immediate operands. QBE removes these differences before emitting assembly.
Map's key constructor also calls the `U32.show` worker, so this was not solely
dead output formatting.

This demonstrates redundant work across compiler stages for these inputs.
It does not prove every range transformation is redundant or that the same
result holds for the full compiler. Root-observed complete hosted emission
guard times31.26→28.98s are an exploratory~7% reduction, not a native request
benchmark; process/JIT/GC and guard overhead remain included.

## Final03 optional composition and remaining gate

The same one-declaration overlay is separately composed onto final03 source
`31e1b13a…e3ea2` at `range-skip-final03-source01/compiler.bend`, SHA-256
`4ff3c13b760b8aa78489b371389409c0498313b693b8ecbb777111d879f29da7`.
It removes177 source bytes; every other declaration, including proof bodies,
inlining, range semantics and independent verifiers, is unchanged.
The root executed `range-skip-final03-source01/jobs.json`: the source check and
all127 existing integrated controls plus26 verification-reuse controls and18
small optimizer equivalence fixtures passed. These171 finite controls are
separate from native qualification and arbitrary-input semantic equivalence.
No default or installed compiler has been changed by this work.

The decisive next gate was native cold compilation of a fixed full compiler
source, using the newly qualified final03 compiler as the acquisition tool.
Compilation cost and emitted-program quality are measured separately below.
Broader45-case runtime evidence or an explicit fast-development policy is
required before changing the maximum-optimization default.

The metadata-only acquisition/measurement plan is now
`selfhost/build/phase144/range-fast-native-plan01/jobs.json`. It reuses the root's
fresh final03N2 Phase142 baseline instead of launching another baseline request.
Its three guarded jobs acquire an experimental fast compiler using final03N2,
measure a fast request on the exact same frozen Phase142 input, and compile the
unchanged final03 source for comparison with the retained Q2 assembly/object.
All source, checked-API,171-control, producer-Q3, machine-tool and actual serial
runtime identities are pinned. The two pipe builds omit duplicate textual IR
but retain its digest and machine artifacts; they do not constitute a new
qualification campaign. The final static result separates acquisition cost,
native request latency and produced-code identity. The root executed this plan;
the investigating subagent performed only the static audit and job preparation.

## Executed native cost and full-compiler machine audit

`selfhost/build/phase144/range-fast-native-result01.json` records a fresh
same-input pair on the frozen Phase142 compiler source (`15f5cada…7dac1`):

| Compiler policy | Native request wall time | CPU time | Peak RSS KiB |
| --- | ---: | ---: | ---: |
| Final03 ordinary policy |251.861s|251.575s|1,046,956|
| Final03 skipping the outer range pass |239.924s|239.591s|1,023,524|

The experimental policy takes0.952605× the baseline time, a **4.74% reduction**.
This is one matched pair, not a repeated confidence interval. Both use the
same linked serial-RFC runtime (`2d078323…93a3`). This measures compiler request
cost, not the speed of the programs that request produces. Its QBE output is
allowed to differ because this is an explicit optimization-policy experiment.

The separate machine-quality experiment compiled the **same unchanged final03
compiler source** (`31e1b13a…e3ea2`) with the two policies. Both resulting
executables implement the ordinary full-range policy; only the policy used to
build them differs. The original is `phase134/p144-final03-n2/program`; the
comparison is `phase134/p144-range-fast-final03-product01/program`.

Unlike the three small benchmark wrappers, the complete compiler's assembly
and object files differ. A bounded static inspection in
`verifier/range-fast-workers-v01.py` compares all71,722 function symbols and
retains snippets only for changed functions. Its receipt is
`selfhost/build/phase144/range-fast-worker-audit01/report.json`:

- The function symbol sets are identical.
- 2,474 raw object function hashes differ.
- Only **three functions have different instruction sequences** after
  normalizing function-local `.Lbb` label numbers. Registers, immediates,
  external symbols, data references and instructions remain exact.
- The other2,471 raw changes have identical normalized assembly, so these
  are address/relocation/alignment effects rather than different operations.

| Changed worker | Source computation | Function bytes, ordinary→skip |
| --- | --- | ---: |
| `$p126scc.1634` |`sp_drop` / `sp_drop_next`: drop a prefix of specialization terms |265→356|
| `$p126scc.5186` |`p140r_drop` / `p140r_drop_next` / `p140r_skip`: skip data in an emission-reuse cursor |265→356|
| `$p126scc.2572` |`j_u32_node` / `j_word` / `j_word_bit`: compact or legacy word-literal readback |1,727→1,793|

The first two loops normally branch directly on `n == 0`. Without the outer
range information, their machine code materializes that Boolean, validates
its raw-or-packed Boolean representation, and retains an unreachable error
branch with sink/fail calls. The third retains a similar check for `at == 32`
and a different32-bit OR spelling. These are actual generated-code changes,
not merely layout. QBE does **not** remove all of this redundant work itself.
Static presence does not establish runtime importance: for example, the
emission-reuse skip worker need not execute during a cold compilation.

This narrows the quality question sharply. The whole compiler does not suffer
a broad instruction-quality change from this policy, but three affected
workers can still matter dynamically. No arbitrary-input equivalence or
performance bound follows from the static inspection.

## Executed exact-output test of the resulting compiler

`selfhost/build/phase144/range-produced-latency-plan01/jobs.json` contains one
guarded native request for the unchanged-source compiler built by the fast
policy. It compiles the same frozen Phase142 input and **requires exact QBE**
against the fresh ordinary-policy baseline, SHA-256
`ac29be094a56cb5e5125b7982a083a15b8e2d5f8c3505b7c1e484c65675abd36`.
The source, producer receipts, actual linked runtime, tool identities and
oracle are pinned. The request output is
`selfhost/build/phase130/p144-range-produced-final03-fixed142-01`.

The root executed this job successfully. The receipt
`selfhost/build/phase130/p144-range-produced-final03-fixed142-01/report.json`
records248.612644s native request time versus the baseline251.861219s: ratio
**0.987102**. Both produced the exact115,966,145-byte QBE oracle; stderr is empty
and exit status is zero. This is **no observed regression in one pair**, not a
statistically established1.29% speedup. The new outer guard time251.209s is not
the native child clock and must not be compared directly with251.861s.

This isolates the speed of the generated compiler: both images implement the
same full-range policy on the same input, unlike the preceding4.74% policy-cost
comparison. The preparer and investigator did not execute targets; the root
owns the measured run. These original fast-policy artifacts remain separate
from subsequent final04 composition and qualification. Neither artifact alone
establishes arbitrary-input semantic equivalence or broad45-program speed.

## Why not remove the inner range pass now?

Unlike the outer pass, the inner call is before `p113i_table_function`. Its
result determines helper eligibility (at most512nodes and8,192 stack bytes)
and is the exact body substituted into later callers. Constant folding and
branch pruning can therefore enable an inlining decision that QBE never sees
if the helper remains a separate call. The retained ordinary census observes
32 changed inner inputs out of69 executed calls, but does not retain enough
admission detail to say how many cross an eligibility threshold or are reused.
It is not evidence that the inner pass is either mostly useful or mostly wasted.

A later bounded measurement should record eligibility before/after the inner
pass and successful subsequent uses of those table entries. That would
distinguish code cleanup QBE can reproduce from a useful Bend-level admission
effect. Remove neither the inner pass nor its table effects blindly.
