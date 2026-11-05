# Phase167 — demand-driven executable representations

Start from `022a0f05`. This is a separate architectural experiment. The qualified
Phase152 compiler, maintained source, runtime and installed selection stay intact.
The objective is complete cold source-to-executable work, with generated execution
quality and independent correctness retained as separate gates.

## Cost model and competing architectures

The qualified full build is249.222s with emission and QBE overlapping for242.103s;
these are not additive compiler and machine durations. The Phase161 diagnostic
has83.223s before the QBE entry and156.571s after it. Those observed clocks are
not a clean decomposition of249.222s. They nevertheless falsify a backend-only
10× prediction with the frontend/executor unchanged: even a free backend leaves
far more than24.922s. Generic production alone is11.588s, about4.83% of diagnostic
CPU. Phase164 already removed some generic bodies without a meaningful full gain.

Compare two architectural solutions:

1. A canonical direct-function program with explicit demand for scheduler
   identities. Direct bodies exist once; only actual function-value/scheduled
   references cause factories, adapters or genuine generic families to be built.
   Verify the actual direct/generic program and emit it without re-deriving a
   generic region registry. This eliminates categories of representation and
   late analysis, rather than merely changing lowering order.
2. A new typed expression/CFG compiler with explicit resumable SCC frames, or
   phase-scoped semantic data with root-tied borrowing. These could also reduce
   ownership and frontend execution cost, but require larger new semantic and
   ABI surfaces. They are not justified as immediate rewrites by existing profiles.

The first is the smallest executable test with a meaningful whole-region ceiling.
It can potentially remove much of repeated backend production/optimization/
registry work, whose combined envelope is substantial. It cannot alone establish
10× on the full compiler. The initial milestone is2× on complete compilation of
a real verifier computation, with acceptable generated execution. Failure is
useful only if the retained cost is measured and the next alternative is specific.
[Independent model](../../experiments/phase167/cost-and-falsification.md) and
[contrasting source architectures](../../experiments/phase167/architecture-alternatives.md).

## Minimum viable alternative

Reuse checked/erased source and existing typed `P113DFunction` control-flow nodes
as the durable direct representation. Preserve source-bound function interfaces
before scheduler IDs. Build a catalogue from actual names, live arities, factory
names and worker names; never guess an owner by reversing mangled text.

Produce direct candidates once, retaining current dependency admission and
stack-safe tail loops. The prototype may keep all admitted direct functions as
a conservative overapproximation; demand-driven private-body discovery is a later
test. Mark functions private unless an actual scheduler interface requires them.

Start scheduler demand from real main and every `N111FuncId` operand in retained
direct bodies. Scan every value position and nested branch. For each demand:

- An admitted worker needs one actual, source-bound ordinary-call adapter.
- An admitted function value needs its actual closure factory, generated then.
- A nonadmitted owner keeps its existing genuine generic family, once. Its
  continuations can conservatively remain together, and their references extend
  demand. Unknown identities fail rather than receiving fabricated bodies.

Use one final actual segment list, IDs, constructor catalogue and static image.
No empty original is presented as a proof of a missing generic body. The existing
generic verifier checks genuine bodies. Independent exact adapter checks bind
source, arity, actual header, body and final direct signature. Existing direct
verification checks final bodies and ordered call dependencies against actual
IDs. Missing workers, unknown FIDs, cyclic ordinary calls and malformed adapters
must be rejected. Retain source checking and independent output gates: structural
IR validation is not a theorem of semantic equivalence.

Emit final direct workers, actual raw generic segments and ABI tables directly.
Do not run the old global region registry or late repeated candidate pipeline.
Mode0 keeps admitted direct bodies; mode1 applies the existing bounded inliner
and source-derived cold-constructor facts. This changes optimization policy as
well as representations. Raw fallback may run slower; that is an explicit gate,
not a hidden tradeoff. This is distinct from Phase164, which still built every
factory and retained most later optimization/registry work.

## Gates and resource/time discipline

1. Upstream-check the small added implementation through an extracted hosted API.
   Test malformed direct/adapter/identity cases before interpreting output.
2. Compile a real nonempty `p111_verify_program` workload. Supply valid and invalid
   IR cases with independent verdict/output requirements; the old empty-program
   verifier control is insufficient. Also use a small ordinary mixed IO source.
3. Compare fresh complete requests using identical source, Base preparation,
   executing API/engine, QBE/runtime/assembler/linker and output obligations.
   Baseline and candidate routes live in the same checked API. Record Base,
   frontend, backend/verification/render, machine, total elapsed and execution
   separately. Initially serialize emission/machine construction; do not compare
   that sum directly to historical pipelined acquisition.
4. Count actual constructed factories/families/adapters and emitted functions;
   never infer eliminated compiler work solely from fewer bytes. Keep full output
   identity for unchanged controls, independent semantics/structure for changed IR.
5. If quality or completeness fails, retain the failure and use it to choose the
   next bounded alternative: restore only the missing necessary optimization,
   or simplify primary candidate construction. Do not restart a helper campaign.
6. Transfer only a surviving substantial result to a larger compiler workload.
   Acquire another native compiler/full self-build only after the small end-to-end
   results justify its cost. Hosted results remain hosted results until then.

Root owns CPU3 and the single guarded execution lane; agents own disjoint source
implementation and independent criticism. Preserve5GiB reserve, bounded RSS and
fresh artifact roots. Reclaim only individually verified archived artifacts.
Record rejected attempts and all timing components; no full qualification merely
to test an initial idea. Finish with working experimental code, evidence, cost
model, exact limitations and the next highest-information architectural step.

## Outcome

See the [Phase167 report](../../implementation/phase167/README.md). The initial
renderer retained a hidden registry and is preserved as a separate treatment.
Explicit plain emission, a single-generic counterarchitecture and general early
observer synthesis were implemented and measured. Early observers recovered the
exact16 candidates predicted by the dependency graph, but the generated-runtime
gate still fails; no native image or production selection was changed.
