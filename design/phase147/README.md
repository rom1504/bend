# Phase147: remove cold compiler representation work

Start from the consolidated compiler at `d419f53`. Target complete source-to-native
cold compilation toward 150 seconds, then 100 seconds. These are research targets,
not predicted results. Prior 237.49 s is compiler execution alone on source03;
the older 247 s full build is a different source. Use one frozen current source
and explicit assets for this campaign. Prepared Base is held constant; no
source-specific semantic or object reuse, and OS caches are not flushed.

## Hypothesis and ambition

The compiler repeatedly turns numeric identities into strings and compact facts
into generic records. Schema, flow, joins, transformations and rendering then
reconstruct those values. Optimizing a complete computation could remove more
work than another isolated lookup tweak. Previous compact-record work gained
only 11% on one slice; conversion and generated worker admission are key risks.

1. Minimum useful result: fresh trustworthy native profiles and one complete
   schema/flow verifier experiment, including negative controls and teardown.
2. Larger result: carry numeric identities and immutable schema across a real
   raw/direct boundary and an unrelated analysis consumer, materially reducing
   complete request time while preserving emitted QBE.
3. Stretch: if evidence supports it, extend the representation through lowering
   and emission or remove an entire text-materialization boundary. Do not build a
   universal IR or change backend just to satisfy an ambition label.

## Execution and gates

- Assemble canonical source and run one matched cold native construction baseline.
- Relink the selected compiler object with the maintained profiler. Authenticate
  source owners and stage IDs; check a small independent output before one full
  source capture. Preserve failed sampling and reject insufficient delivery.
- Build small checked Bend experiments first. Original public verifiers remain
  independent oracles. Test complete accepted and rejected results, schema-first
  errors, reserved names, widths, memory capacities, branch joins, terminal paths,
  runtime calls and function/constructor identity. Charge conversion and cleanup.
- Use alternating uninstrumented native timings and explicit final-product
  identities. Diagnostic samples/counters are explanatory, never speed results.
  Reject a candidate that only improves a synthetic lookup or loses worker admission.
- Broaden only after meaningful region gains and transfer. Integrate in the single
  module tree; no experiment copies of the full compiler at HEAD. Any changed
  protected verifier needs explicit semantic review and manifest maintenance;
  independent final verification and proof obligations are not waived.
- A promising integrated candidate gets current-source full timing, relevant
  frontend/native controls and exact positive QBE products. Actual native
  self-reproduction and broader gates precede any release replacement. Keep the
  selected qualified compiler usable throughout.

## Resource and cost discipline

One root-owned CPU3 target lane; bounded agents handle profiler preparation,
prototype implementation, semantic falsification and harness work. Each compiler
job uses the maintained disk/RSS/time guard and fresh roots. Baseline and profiling
reuse one source and native object. Avoid repeating full builds for early ideas.
Keep failed attempts, exact recipes and per-run costs; close all jobs with explicit
retention and verified archive recovery. Keep the 5 GiB reserve and protect
unrelated edits. Commit design, validated changes and an honest final report.

## Initial priorities

First: numeric/compact verifier region across schema, flow, joins and actual
consumers. Second: registry/rendering materialization if the profile or prototype
rejects the first route. Frontend cursor/token work remains a distinct later
experiment. Existing duplicate raw-check removal is already present and cannot
be counted again. No upstream parity or 100-second claim without matched evidence.
