# Phase154 — create compact identities before backend work

Starting point: `bde17c0`, qualified Phase152 N2, unchanged installed selection.
The user authorizes Phase153's first experiment, not an unconditional full IR
rewrite. Root owns one guarded CPU3 target lane; bounded agents can investigate
and prepare independent source/harness components.

## Hypothesis and decision

Backend lowering, initial optimization and output/cleanup consume 101.45 seconds
in Phase153's diagnostic capture. A complete region near twice as fast would
justify investigating a material whole-build saving. The percentage is conditional:
this small experiment cannot establish a new cold-build or upstream ratio.

Produce numeric local identities and compact semantic facts directly from real
pre-backend compiler inputs. Retain them through more than one consumer and
render names only at the independent verifier/output boundary. Start with a
small representation that avoids Phase148's costly array transport. No source
program names or benchmark identities may control legality or optimization.

Phase148's late pack→optimize→unpack result was neutral or slower. Do not repeat
that experiment with conversion cost hidden. Capture before the affected
producer, include producer work in both timings, and charge all conversions,
validation, rendering, writing and teardown. Retain complete outputs and actual
unsupported cases. Choose compiler work plus unrelated Map work before timing.

## Gates and time allocation

1. Identify the smallest genuine producer-to-consumer region and freeze its
   boundaries, inputs, old path and output oracle. Approximately 15–25 minutes
   for source investigation and harness reuse, not a new profiling campaign.
2. Implement a private checked Bend prototype. Compiler algorithms stay in Bend;
   host code only extracts declarations, transports fixtures and measures.
   Prefer a bounded 1–2 hour decision over production migration before evidence.
3. Check exact identities, control cases and complete old/new emitted output.
   Keep the independent final verifier unchanged. Ownership, scope, branch joins,
   epochs, calls and public names must retain their original meanings.
4. Build one small native executable with both paths. Time alternating pairs
   with common input lifetimes and repetitions. Start with the compiler family;
   transfer to Map. Inspect actual native operations if the result is surprising.
5. Proceed to a full compiler only with a substantial, representative complete-
   region win. Otherwise preserve the negative result and stop the migration.
   No full self-hosting or broad 45-program campaign to qualify a failed idea.

Every target uses the maintained disk/process guard, an explicit fresh root,
2GiB RSS, 16GiB available-memory floor and default 5GiB disk reserve. Close and
preserve all attempts. Existing unrelated workspace edits remain untouched.

## Report

Separate changed representation, removed dynamic work, semantic correctness,
measured regional time, compiler acquisition/validation cost, source complexity
and unmeasured whole-build/generalization claims. Record failed hypotheses and
whether the native backend actually implements the intended cheap accesses.
