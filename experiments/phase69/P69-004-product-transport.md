# P69-004: constructor-proven product transport through a tail loop

Status: prospective, registered before deriving or executing target code.

Compiler23's lexer allocates one two-field Tuple per character, immediately
consumes it on the next self-tail iteration, and already receives both fields
from a private product worker. The Mode field is already packed for valid
values; this experiment does not change its layout, scalar arithmetic, helpers,
scheduling metadata, or source program.

**Hypothesis:** a constructor-proven internal loop carrying those two evaluated
fields avoids the Tuple allocation/take/free protocol and materially reduces
lexer execution time after the independent scheduling/static-data improvements.
The initial generic entry and raw matcher order remain present. A cold invalid
String path reconstructs the Tuple before the original drop, rather than assuming
all raw inputs have valid tags or distributing a parent's drop through its fields.

The source-only producer recognizes the exact saved compiler23 worker, preserves
all ordinary entry tests and sequence/error checkpoints, creates one private
three-word loop, and redirects only a self-tail transition whose state is a
fresh constructor. Fields retain the original `rfc_seal` calls. The private loop
retains the two fields across its own tail transitions. It does not recurse on
the C stack. The generic entry calls it once at the proven transition.

Inputs: the checked compiler23 C source identified in the
[Phase68 parity survey](../../implementation/phase68/c23-parity-survey.md).
Derivatives may compose with the separately registered static-data and reachable
bang changes, but the input identity and every source replacement are recorded.
Producer and derivation receipts live under
`selfhost/tools/performance/phase69/product-transport/` and a fresh root-selected
raw directory. Only the root execution lane compiles or executes a target.

Selection gates: independent output oracles; unchanged initial generic/raw
entry behavior; at least one matching decrease in allocation/take/free counts;
balanced clean runtime comparison with the exact unchanged input; repeat on
another product-loop shape before production integration. Reject if the private
entry activates by annotation alone, changes first-error/demand order, permits
non-tail recursion, or merely moves boxes to an equally frequent boundary.

The intended general implementation is a private constructor-proven loop entry
fed by `NQBundle` values, with an ordinary boxed entry retained. This differs
from globally weakening `nq_entry_demand`, recursively flattening every type, or
changing the scheduler ABI. Map multiword returns remain a separate larger slice.

No gain or correctness claim is made until root-owned target results exist.
