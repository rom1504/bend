# Phase118 checkpoint: transport, rejected reuse, and scalar borrowing

The selected direction is still allocation-only destination passing, cold
constructor metadata, root-preserving borrowing, and sized constructor helpers.
The focused transport experiment adds another9–13% to map/lexer/tree, and direct
builtin bank use cuts the closure256 screen128→87ms. Read
[P118-002](../../experiments/phase118/P118-002-live-register-transport.md) for the
scope and provenance contract. The full45 result remains Phase117's4.240× until
the broader campaign runs.

Consumed-cell reuse is not selected. Its first list128 screen210ms loses to the
allocation-only197ms. Constant-count helper specialization recovers196ms, while
lexer249ms is effectively tied with250ms. Saving an allocation did not produce
a measured general advantage after credit transport, ownership branches and
call ABI costs. Both versions and all28 finite controls are retained.

A scalar-result borrowed observer prototype adds a shared-root guard and an
original owning fallback. It conservatively declines aliased nontrivial roots,
holds all original owners through the readonly computation, and drops them
afterward. Its ordinary alias/shared/unique/static/Unicode controls pass. The
first emission failed the independent worker verifier because the branch
condition was U64; v2 explicitly compares it with zero to produce U32.
Only one new observer appears in the focused benchmark set, and map128 remains
183ms. There is no runtime justification for selecting this extra machinery yet.
Correctness controls demonstrate its bounded behavior, not broad usefulness.

The request-bound Bend entry now owns original lowering/verification and derived
ownership analysis. Four emissions match the diagnostic route byte for byte.
This removes repeated analysis within a request; it is not a persistent cache.
A matched warm whole-entry cost harness is prepared to measure its actual cost
against the exact Phase117 source under the same Bun host.

Two compiler-source inspection attempts produced no compiler-workload result:
Node hit its JavaScript stack limit, and Bun reached a120s deadline. The prior
full-source frontend alone took222s, making that second cap too short. Neither
was an OOM. Subsequent full acquisition must use the established larger guard
and reuse that frontend work instead of repeating cheap-looking inspections.

Native source/runtime qualification is prepared with a new integrated-entry
contract, exact composition replay, independent ordinary suites and raw-QBE
reproduction. It does not claim that the old staged-renderer gate is unchanged.
Installed production selection remains untouched.
