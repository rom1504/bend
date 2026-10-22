# P126-003: preserve conditional preparation inside local recursion

Status: bounded implementation independently reviewed; checked acquisition pending.

The ordinary frozen ray workload visits 1,048,576 column leaves but only 5,120
pixel computations. Its column recursion still crosses the generic scheduler.
The actual continuation contains a guarded U32 shift between the authenticated
frame push and second self descent. Existing H-table admission rejects every
N111If at that position, even when both arms contain already permitted statements.

Test a single admission extension: recursively permit such conditional statements
in the H-table own-descent prefix, while retaining the exact final argument-store,
target and arity check. Preserve branch operations, frame order and all-argument
snapshots before parameter rebinding. Do not change legacy R/G plans, ready-helper
catalogues, parallel semantics, stack depth management or native recursion.

The inherited predicate admits more than arithmetic: some existing ownership
helpers are nontransitioning and permitted. They remain in place and in order;
this extension is not a proof that arbitrary ownership operations are pure.
Frame changes, register-bank observations, arbitrary calls, pointer replacement,
wrong target/arity and branch returns remain refused.

Implementation: `selfhost/tools/performance/phase126/scalar-resume/model.bend`.
Thirteen pure admission/refusal controls supplement an ordinary binary shift-tree
fixture and original benchmarks. No invented memory graph is executed. Selected
comparison source09 is based directly on qualified Phase125, isolating this rule
from the float/table experiments. Inspect actual worker admission before claiming
benefit; row recursion may remain unsupported because callable catalogues do not
automatically include newly derived H workers.

Success means whole-program speed and transfer, not merely more admitted sites.
If useful, combine with local float cleanup and tables; retain native qualification
as a later integrated gate. This is a small composition capability, not a new IR.
