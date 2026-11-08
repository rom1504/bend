# Phase180 — canonical application representation: bounded experiment closed

**Decision: do not integrate or broaden this version.** The complete medium
frontend improves only0.76%, below the5% gate set before implementation. The
effect is smaller than the observed run variation. This is a useful rejection
of a partial representation migration, not a refutation of compact terms.

[Metrics](metrics.json) · [Replay](reproduce.md) ·
[Evidence](evidence-index.json) ·
[Project status](../../docs/self_hosted/projects/compact-frontend/STATUS.md) ·
[Original plan](../../docs/self_hosted/projects/compact-frontend/PLAN.md).

## What was implemented

The isolated Bend candidate adds `KApply{function,argument,originBegin,originEnd}`.
It represents exactly an App with empty name/removed fields, id0, quantity0 and
two children. Raw parser Apps have quantity1 and remain generic. Malformed
legacy values remain accepted where the previous APIs accepted them.

The experiment changes32 declarations and adds three helpers/two forward laws.
It includes construction, direct child access, span/rebuild observers, checker
pair results, environment substitution and fixed-arity substitution/beta frames.
All substitution remains inside the existing recursive owner. A direct-match
audit found27 KTerm consumers:25 changed and two ownership-metadata recognizers
already reject canonical generic and compact applications identically.

The candidate is an overlay under `selfhost/tests/phase180`, not another editable
production compiler. The source transport freezes exact baseline/candidate
snapshots. Declaration content grows by approximately122 lines/5.6KB; the
serialized snapshot additionally inserts blank separators between declarations.
Its physical line count must not be presented as production source growth.
The maintained source and installed/compiler reference images are unchanged.

## Measurement and decision

Both extracted native frontends use the same independently qualified Phase175 N2
producer, runtime object, QBE/assembler/linker, prepared Base, CPU3, one worker
and GPU off. They process the same real656,302-byte compiler source. Fresh
processes run baseline/candidate/candidate/baseline; filesystem caches are not
flushed. No target jobs run concurrently.

| Measured quantity | Baseline | Candidate | Observation |
| --- | ---: | ---: | --- |
| Complete frontend median | 12.2465s | 12.1540s | 0.76% lower; below5% gate |
| Whole process median | 14.8286s | 14.7093s | 0.80% lower |
| Frontend individual samples | 12.338,12.155s | 11.984,12.324s | Variation exceeds median difference |
| Extracted executable acquisition | 53.958s | 54.982s | One build each; not a throughput conclusion |
| Extracted QBE bytes | 37,260,458 | 37,301,083 | +0.11% |
| Extracted ELF bytes | 5,904,864 | 5,920,136 | +0.26% |

The frontend clock includes parsing/checking and subsequent request preparation;
it excludes the structural digest used to observe the complete output. Whole
process timing includes Base preparation, digest and teardown. Neither metric
is a full compiler source-to-executable build. No new175s/180s cold-build claim
is made. The failed first transfer gate means no second-input performance or
expensive full-image qualification campaign was justified.

## What the generated code shows

The intended local simplification survives native lowering. `app` previously
called two list constructors and the general term constructor helper; now it
directly constructs one four-field object. Its linked function body shrinks
from33 to13 instructions. Both versions retain private `app`, `kid`, `ks` and
`p177s_loop` workers; loss of direct-worker admission does not explain this result.

The larger computation remains mixed-representation:

- `ks(KApply)` recreates two list cells for compatibility consumers.
- The substitution worker keeps both generic traversal and compact traversal,
  including beta restoration and the affine stack contract. Its machine body
  grows from1,122 to1,300 instructions and its QBE blocks from60 to82.
- Static constructor sites inside that worker decrease31→23, but take sites
  rise9→16 and keep/dup sites24→30. These are static sites, not dynamic counts
  or an attributed runtime cost. Fewer constructor sites do not prove less time.
- `kid` gains direct compact access but still handles all old representations.
  Its own body grows16→101 instructions; baseline delegated more work to callees,
  so that comparison does not establish a slower child lookup.

The timings establish that this particular migration does not produce a useful
complete-request gain. The code identifies retained work and added complexity;
it does not measure how much time each compatibility path consumes. Exact
selected SSA, assembly and linked machine bodies are preserved in the archive.

## Correctness evidence and limits

Both hosted APIs and both native frontend sources pass the unchanged upstream
source acceptance gate.669 finite application observations pass, including
literal expectations, raw and compact inputs, all old substitution cases,
nested beta restoration, span/quantity metadata, malformed child counts,
retained aliases and depth128.70 complete frontend observations pass across14
inputs and five cumulative stages: parsing, checking, context, annotation and
request. They include ordinary programs and invalid input diagnostics.

The independent structural oracle expands only KApply into its exact legacy
record, compares every scalar/key and rejects deliberate mutations. Input
fingerprints check retained aliases and mutation; neither the oracle nor its
host code implements substitution/checking semantics. Native timed requests
have identical representation-neutral output digests; those digests supplement
the complete-value controls and are not independent equivalence proofs.

The new `law` declarations are forward function contracts, **not mathematical
theorems**. This phase does not claim BendTT proof, complete compiler correctness,
whole-backend conformance, generated-user-program performance or N1/N2
reproduction. There is no production change to qualify or install.

## Failed attempts and research cost

Five early acquisitions fail at source checking: a law-backed definition used a
typed signature; environment substitution matched an earlier binder too late;
a match scrutinized a computed Boolean; branching closures consumed an affine
tail twice; and the pending function field needed an explicit unrestricted
quantity. All failures and frozen snapshots are retained. The final form uses
scalar state selection and an explicitly shared function field while retaining
the affine stack. No source-check gate was weakened.

Fifteen guarded jobs cost299.223 target wall seconds, including both acquisitions,
all finite controls, machine inspection and the balanced native pair. The five
failed jobs cost8.105s. Peak aggregate RSS was1,033,224,192 bytes, below the2GiB
limit. Source analysis, agent effort and quota are not measured by this figure.
Two bounded agents helped with audits, controls and machine inspection; root
owned the single execution lane. Completed and failed jobs have retention
closures; exact evidence is archived and verified without deleting artifacts.

## Consequence for the architecture project

Stop this overlay here. Do not generalize the one-record constructor win into a
whole-compiler speed forecast, and do not migrate every variant to justify work
already spent. The project now has a durable status, an explicit closed decision
and cheap reusable semantic controls instead of an open-ended refactor.

A successor experiment must identify a complete hot producer/consumer path whose
generic child-list interface can actually be retired, and measure how much work
that removes before expanding the representation. The
[boundary audit](../../selfhost/tests/phase180/boundary-audit.md) names concrete
remaining walks. Merely adding another compact variant while keeping the same
observers is not a new hypothesis. Reusing checked facts to remove a whole later
walk remains a separate alternative; it should face the same complete-request
gate. The current qualified compiler remains the reference.
