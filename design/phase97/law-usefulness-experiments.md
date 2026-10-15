# Phase97: test whether laws improve optimization work

Baseline: `1962bc7`, Phase96's frozen law suite, unchanged Phase90 installed
compiler and native07 qualification. The user asks for experiments that answer:
are the laws useful, which additional laws matter, how should usefulness be
validated, and what would broader compiler correctness cost?

## Questions and experiments

1. **Independent challenges.** An agent reads maintained production helpers but
   not Phase96 law bodies, mutations or finite-case oracle. Before execution,
   freeze up to eight plausible semantic faults and two legitimate equivalent
   changes. Run the existing suite unchanged and report semantic detections,
   escaped faults, rejected valid changes and irrelevant/ill-formed cases
   separately. This is independent selection, not a statistically representative
   mutation score or a fully blinded study. Search for relevant historical bugs
   and retain exact commit/old/new provenance; do not invent historical defects.
2. **Use on a real optimization.** Select a measured native projection caller,
   prepare one isolated source candidate and small native controls with live
   aliases. Inspect emitted code and measure before/after work in a fast loop.
   Run existing law contracts and an operation-specific bridge/control. Acquire
   at most one full candidate image initially, only if the micro evidence supports
   it; compare actual compiler requests before considering larger validation.
   A neutral or rejected candidate is a valid outcome, not a reason to broaden
   indefinitely or claim helper speed as end-to-end speed.
3. **Probe the missing ownership boundary.** Distinguish full-value equality from
   safe generated execution. Use native alias-survival cases and, where feasible,
   a controlled low-level lifetime defect or sanitizer run. A Bend theorem cannot
   certify an independently altered C runtime. Identify what a formal heap/root
   invariant and actual lowering bridge would need to establish.
4. **Build a small semantic-preservation pilot.** Define a minimal nontrivial
   transformation or ownership model, a precise evaluator/observation and an
   actual safe Bend proof with an independent kernel verdict. Include a semantic
   bad transformation and a compositional statement if feasible. Explicitly label
   a model as a model; it is not a proof of production code without a checked
   source/lowering connection. Preserve failed attempts and measure proof work.
5. **Assess return on effort and next scope.** Record target time, preparation and
   review effort boundaries, added code, actionable counterexamples, accepted
   legitimate changes, proof limitations and actual performance. Recommend a
   few specific next obligations and a scoped correctness roadmap based on the
   experiment, not the number of law declarations.

## Method

Freeze recipes and expectations before tests. Root runs targets serially through
existing resource guards; agents prepare sources and review offline. Reuse pinned
images, Bun, Lean and cached unchanged BendTT. Keep source-check failures, semantic
rejections, independent kernel checks, finite execution and benchmark results
separate. Use a few-second focused loop before full Phase96 audit or compiler
build; no repeated broad runtime/conformance campaigns for law-only changes.

The independent challenge tests initially use all unchanged finite cases, so
coverage gaps remain visible. Add a minimal case only after recording an escape,
and label that second result as a strengthened suite. For universal properties,
require complete actual helper/theorem bodies and explicit assumptions. Preserve
all failed/raw attempts. Do not reinterpret unsafe acceptance as a proof.

Current production, baseline images, human-written upstream sources and historical
evidence stay unchanged unless a separately qualified candidate justifies a
promotion. The existing five metric definitions remain in force; a correct model
or a detected mutant alone changes none of those metrics. No PR comments.

## Deliverables and stopping point

Commit the design, then runnable experiments, compact reproducible evidence,
documentation and an implementation report answering each question. Stop after
the bounded challenge campaign, one optimization decision, the ownership boundary
experiment and one semantic pilot. Whole-compiler verification is a scoped future
project, not an unbounded goal silently started by this experiment.
