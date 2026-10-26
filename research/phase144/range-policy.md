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
unchanged-output flag is introduced, and no compiler-native benefit is yet
measured. Source order, helper eligibility and inlining tables are exactly the
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

The next decisive gate is native cold compilation of a fixed full compiler
source, using the newly qualified final03 compiler as the acquisition tool.
Measure compilation cost and emitted-program quality separately. Broader45-case
runtime evidence or an explicit fast-development policy is required before
changing the maximum-optimization default.

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
native request latency and produced-code identity. This plan has not been
executed by the investigating subagent and supplies no new speed result yet.

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
