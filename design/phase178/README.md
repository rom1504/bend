# Phase178 — frontend refactor and cleanup

Parent: `296f288`, canonical source SHA256
`1a359a4c94c8293fec12b8722793a5beafae1896dc2a8307bf5359a7f367532f`.

The objective is a coherent frontend with fewer duplicated implementations and
fewer producer/consumer traversals, while preserving language behavior, native
stack safety and generated-code quality. This is not an installed-release change.

1. Consolidate the copied definition-parser continuations. Preserve actual public
   entry points, resolution timing and arbitrary book/scope behavior at those
   boundaries. Audit reachability before preserving internal compatibility: the
   old six-helper chain has no production caller or promised export. Delete it
   instead of adding wrappers and optional state solely to keep it callable.
   Require net source simplification and unchanged selected parser code.
2. Establish a small typed product between a producer and its consumers, with
   actual removal of an old traversal. Initial inspection of annotation/layout
   shows that complete fusion changes roughly twenty dependent helper contracts
   or duplicates most annotation. Prefer the smaller erased-body/ordered-reference
   boundary first if that gives a clean, fully testable implementation. Do not
   attach another cache to generic KTerm or keep both consumer paths active.
3. Clean obsolete comments and documentation directly affected by the changes.
   Preserve independent final verifiers, protected declarations, all existing
   entry profiles and the qualified reference images.

The parser and producer/consumer implementations are independent bounded tasks.
One coordinator owns integration, all compiler execution and the resource lane.
All compiler algorithms remain Bend. Reuse existing transport/measurement tools;
new host code may only assemble exact sources, compare outputs and record evidence.

## Gates and stopping rules

- Freeze the actual baseline before edits. Record declaration additions/removals
  and canonical source/line changes; do not claim a speedup from smaller input.
- Independently source-check small APIs and compare complete boundary values.
  Use the565 current parser/header controls and audit all five maintained entry
  closures. Superseded internal helpers need not remain arbitrary test exports;
  the initial compatibility prototype is preserved as rejected evidence.
  Reference collection must preserve duplicates/order and omit
  dead runtime branches exactly; test full products, not hashes alone.
- Compare complete real frontend requests on the existing small/medium compiler
  inputs. Retain failed alternatives. Reject structural changes that merely add
  allocation or lose direct-worker admission without an offsetting simplification.
- After integration, check the complete maintained source and appropriate native
  finite/unchanged-program gates. Use full cold/self-hosting runs only if needed
  for the final combined change, not after every helper edit.
- Report source complexity, compiler latency, output preservation and qualification
  separately. Finite laws/signatures are not proof of compiler equivalence.

Follow the existing disk/RSS/time guard and retention policy. Keep all qualified
images available; do not install a new compiler or post a PR comment in this phase.

## Measured decision

The erased-body/reference product passes1,474 complete-value observations but is
neutral on the complete medium frontend (12.234→12.2215s, two reversed pairs).
It adds result objects and helper contracts without demonstrated latency or
simplicity benefit. Preserve it as an experiment; do not integrate it or broaden
it to annotation/layout. The production change remains deletion of unreachable
parser code, inventory reconciliation and directly related workflow cleanup.
