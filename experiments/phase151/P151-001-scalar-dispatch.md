# P151-001 — scalar U32 dispatch versus expanded literal patterns

Status: acquisition improvement demonstrated; source-only production promotion
rejected because execution regresses. [Plan](../../design/phase151/README.md).

Hypothesis: scalar comparisons reduce acquisition cost for existing fixed-result
U32 dispatch functions while preserving complete outputs and execution speed.
Primary witness `p88_roles`; unrelated transfer `p112fp_binary`.

Falsifiers: no meaningful fresh-process acquisition difference, execution
regression that offsets the gain, any table/fallback/consumer mismatch, or a
complete-consumer effect too small to justify integration. No production source
change or whole-build result is implied by the experiment.

Outcome: complete two-table acquisition1.4254→0.8201s; separate exact-QBE
emission1.1673→0.5702s. Execution instead costs1.91×/1.41× for roles/opcodes.
Balanced direct helpers remove that regression but expand to27 declarations and
3.8× reference QBE. P151-002 isolates the missing prepared Unit fact and restores
local runtime parity without that source expansion. No full compiler gate run.
