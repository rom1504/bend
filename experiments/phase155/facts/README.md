# Phase155 facts candidates 01–04

These four private Bend candidates target the owned fact-cell return and repeated
accesses left in Phase154. The original report found a 13.02% selected compiler
improvement but only 2.36% on Map; it did not qualify a backend migration. These
new sources make no numerical speed claim.

All eight entries take `+n: U32` and return a checksum `String`. Each constructs
32 real `P154Facts` entries, runs `n` changing transfers/updates, then consumes all
normal fields, versions, relation and predicate metadata in a final checksum.
Setup and final consumption are included. Four keys use the actual fixed local
spellings `value`, `p112_s_a`, `p112_s_b`, `p112_s_test`; the remaining keys are
numeric, including both U32 endpoints and a deliberate hash collision with
`value`. Boolean seed provenance uses valid self-root epochs. No arrays are used.

| ID | Candidate | Isolated change |
| --- | --- | --- |
| 01 | `p155f_01_new` | Descend to scalar width without returning an owned whole cell/fact. |
| 02 | `p155f_02_new` | Read one existing whole cell for width and version; retain that owned result interface. |
| 03 | `p155f_03_new` | Retain one hash across the same whole-cell reads and ordinary update. |
| 04 | `p155f_04_new` | Publish an actual comparison fact and its self-rooted predicate together, retaining old relation metadata. |

The matching `_old` entry uses unchanged Phase154 fact operations. Ideas02 and03
reuse capabilities already exposed by the low-level API; their hypotheses concern
unfused caller patterns, not missing runtime features. Production `p147n_has` and
`p147n_capacity_at` already demonstrate scalar-return tree queries for different
facts. Idea01 asks whether that pattern eliminates the remaining Phase154 owned
result path. Actual borrowed-worker admission and native transport remain root
checks, not source-level assumptions.

The complete small consumer loops are more informative than lookup-only timings,
but remain deterministic, bounded table traces. The combined width/version score
is a probe for paired access, not a proposed compiler semantic formula. Idea04
uses the current `p113k_bin_fact` comparison transfer and exactly the publication
shape used by `p154p_record`; it is not a general multi-key transaction. Checksum
agreement is weaker than whole-structure equality and no whole-compiler gain may
be inferred from this screen.

`spec.json` records the common harness contract and control sizes. The root owns
source checking, native measurement and machine inspection. No targets or builds
were run while preparing this family; no production source was edited.

A separate `p155f_controls(n) -> String` entry must return `"ok"`. It compares
query outputs to original operations and compares both update candidates to
original whole tables field by field, including trie structure, collision bucket
ordering, full normal facts, all epochs, relation subjects/truth and predicate
roots/inversion. It covers every seeded key plus absent keys; repeated updates
exercise retained and invalidated metadata. This exact finite control is listed
in `spec.json.extraChecks` and is separate from every timed kernel.
